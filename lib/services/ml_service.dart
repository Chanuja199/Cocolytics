import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/scan_model.dart';
import '../utils/secrets.dart';

class MLService {
  Interpreter? _interpreter;
  final _uuid = const Uuid();

  static const String _modelAsset = 'assets/coconut_disease_model.tflite';

  static const List<String> _labels = [
    'Bud Rot',
    'Healthy',
    'Leaf Spot',
    'Lethal Yellowing',
    'Root Wilt',
  ];

  static const Map<String, String> _diseaseIdMap = {
    'Bud Rot': 'bud_rot',
    'Healthy': 'healthy',
    'Leaf Spot': 'leaf_spot',
    'Lethal Yellowing': 'lethal_yellowing',
    'Root Wilt': 'root_wilt',
  };

  static const int _inputSize = 224;
  static const double _minGreenRatio = 0.15;

  static const List<String> _geminiModels = [
    'gemini-2.5-flash',
    'gemini-2.0-flash',
  ];

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(_modelAsset);
    } catch (e) {
      debugPrint('Failed to load model: $e');
    }
  }

  Future<ScanModel> classifyOffline({
    required String imagePath,
    required String userId,
    required String district,
    double? latitude,
    double? longitude,
    bool isOnline = false,
  }) async {
    if (_interpreter == null) await loadModel();
    if (_interpreter == null) {
      throw Exception('Model not loaded — please restart the app and try again.');
    }

    final file = File(imagePath);
    final imageBytes = file.readAsBytesSync();
    final rawImage = img.decodeImage(imageBytes);
    if (rawImage == null) {
      throw Exception('Could not decode image. Please pick a valid photo.');
    }

    final resized = img.copyResize(rawImage, width: _inputSize, height: _inputSize);

    if (!_passesColorFilter(resized)) {
      throw Exception(
        'This does not appear to be a plant leaf. '
        'Please take a clear photo of a coconut leaf and try again.',
      );
    }

    if (isOnline) {
      final isCoconutLeaf = await _verifyWithGemini(imageBytes);
      if (!isCoconutLeaf) {
        throw Exception(
          'AI verification: This image does not contain a coconut leaf. '
          'Please capture a clear photo of a coconut leaf to get an accurate diagnosis.',
        );
      }
    }

    final inputBuffer = Float32List(1 * _inputSize * _inputSize * 3);
    int idx = 0;
    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        inputBuffer[idx++] = pixel.r / 255.0;
        inputBuffer[idx++] = pixel.g / 255.0;
        inputBuffer[idx++] = pixel.b / 255.0;
      }
    }

    final input = inputBuffer.reshape([1, _inputSize, _inputSize, 3]);
    final output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

    try {
      _interpreter!.run(input, output);
    } catch (e) {
      throw Exception('Inference failed: $e');
    }

    final predictions = List<double>.from(output[0]);

    int maxIndex = 0;
    double maxConfidence = predictions[0];
    for (int i = 1; i < predictions.length; i++) {
      if (predictions[i] > maxConfidence) {
        maxConfidence = predictions[i];
        maxIndex = i;
      }
    }

    final diseaseName = maxIndex < _labels.length
        ? _labels[maxIndex]
        : 'Unknown';

    final guidance = _getGuidance(diseaseName);

    return ScanModel(
      id: _uuid.v4(),
      userId: userId,
      imageUrl: imagePath,
      diseaseName: diseaseName,
      botanicalName: 'Cocos nucifera',
      scientificName: 'Cocos nucifera L.',
      confidence: maxConfidence,
      severity: _getSeverity(maxConfidence, diseaseName),
      description: guidance['description'] as String? ?? '',
      symptoms: guidance['symptoms'] as List<String>? ?? [],
      district: district,
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      isSynced: false,
    );
  }

  static String getDiseaseId(String diseaseName) {
    return _diseaseIdMap[diseaseName] ??
        diseaseName.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
  }

  bool _passesColorFilter(img.Image image) {
    int plantPixels = 0;
    int totalPixels = 0;

    for (int y = 0; y < image.height; y += 2) {
      for (int x = 0; x < image.width; x += 2) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toDouble();
        final g = pixel.g.toDouble();
        final b = pixel.b.toDouble();

        final rN = r / 255.0;
        final gN = g / 255.0;
        final bN = b / 255.0;

        final cMax = max(rN, max(gN, bN));
        final cMin = min(rN, min(gN, bN));
        final delta = cMax - cMin;

        final v = cMax;
        final s = cMax == 0 ? 0.0 : delta / cMax;

        double h = 0;
        if (delta != 0) {
          if (cMax == rN) {
            h = 60 * (((gN - bN) / delta) % 6);
          } else if (cMax == gN) {
            h = 60 * (((bN - rN) / delta) + 2);
          } else {
            h = 60 * (((rN - gN) / delta) + 4);
          }
        }
        if (h < 0) h += 360;

        totalPixels++;

        if (h >= 15 && h <= 165 && s >= 0.10 && v >= 0.08) {
          plantPixels++;
        }
      }
    }

    if (totalPixels == 0) return false;

    final ratio = plantPixels / totalPixels;
    return ratio >= _minGreenRatio;
  }

  Future<bool> _verifyWithGemini(Uint8List imageBytes) async {
    final apiKey = Secrets.geminiApiKey;
    if (apiKey.trim().isEmpty) return true;

    final base64Image = base64Encode(imageBytes);

    for (final model in _geminiModels) {
      try {
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );

        final response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {
                        'inlineData': {
                          'mimeType': 'image/jpeg',
                          'data': base64Image,
                        },
                      },
                      {
                        'text':
                            'Does this image contain a coconut palm leaf or frond? '
                            'Reply with ONLY "YES" or "NO". Nothing else.',
                      },
                    ],
                  },
                ],
                'generationConfig': {
                  'temperature': 0.1,
                  'maxOutputTokens': 5,
                },
              }),
            )
            .timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = data['candidates'] as List<dynamic>? ?? [];
          if (candidates.isEmpty) return true;

          final parts = (candidates.first as Map<String, dynamic>)['content']
                  ?['parts'] as List<dynamic>? ??
              [];
          if (parts.isEmpty) return true;

          final answer = (parts.first['text'] ?? '').toString().trim().toUpperCase();
          
          if (answer.contains('NO')) return false;
          if (answer.contains('YES')) return true;

          return true;
        }

        if (response.statusCode == 404) continue;
        return true;
      } catch (e) {
        return true;
      }
    }
    return true;
  }

  Map<String, dynamic> _getGuidance(String diseaseName) {
    switch (diseaseName) {
      case 'Bud Rot':
        return {
          'severity': 'high',
          'description':
              'A severe and potentially fatal fungal disease affecting the '
              'heart of the palm. Consult your local agricultural officer immediately.',
          'symptoms': [
            'Yellowing of young leaves',
            'Foul smell from the bud',
            'Collapse of the spear leaf',
          ],
        };
      case 'Leaf Spot':
        return {
          'severity': 'medium',
          'description':
              'Caused by fungi, leading to necrosis on leaf surfaces. '
              'Improve drainage and avoid overhead watering.',
          'symptoms': [
            'Yellow or brown spots on leaves',
            'Necrotic spots expanding over time',
            'Leaf withering in severe cases',
          ],
        };
      case 'Lethal Yellowing':
        return {
          'severity': 'high',
          'description':
              'A devastating phytoplasma disease spread by planthoppers. '
              'There is no cure; infected trees must be removed to prevent spread.',
          'symptoms': [
            'Premature nut fall',
            'Blackened inflorescences',
            'Yellowing of leaves starting from the oldest',
          ],
        };
      case 'Root Wilt':
        return {
          'severity': 'high',
          'description':
              'A debilitating disease prevalent in South Asia. '
              'Focus on balanced fertilization and remove severely affected trees.',
          'symptoms': [
            'Flaccidity of leaves',
            'Leaf curling and ribbing',
            'Yellowing of older leaves',
          ],
        };
      case 'Healthy':
      default:
        return {
          'severity': 'low',
          'description':
              'The coconut leaf appears healthy. Continue regular care and field monitoring.',
          'symptoms': [
            'No visible signs of disease',
          ],
        };
    }
  }

  String _getSeverity(double confidence, String diseaseName) {
    if (diseaseName == 'Healthy') return 'low';
    if (confidence < 0.6) return 'low';
    switch (diseaseName) {
      case 'Bud Rot':
      case 'Lethal Yellowing':
      case 'Root Wilt':
        return 'high';
      case 'Leaf Spot':
        return 'medium';
      default:
        return 'medium';
    }
  }
}
