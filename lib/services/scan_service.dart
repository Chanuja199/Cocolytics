import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/scan_model.dart';
import '../utils/app_constants.dart';
import 'cloudinary_service.dart';

class ScanService {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final _uuid = const Uuid();

  Future<ScanModel> scanLeaf({
    required String imagePath,
    required String userId,
    required String district,
    double? latitude,
    double? longitude,
  }) async {
    // Step 1 — upload image to Cloudinary
    final imageUrl = await _cloudinaryService.uploadLeafImage(imagePath);

    // Step 2 — send image URL to FastAPI for AI prediction
    final prediction = await _callAiModel(imageUrl);

    // Step 3 — build and return ScanModel
    return ScanModel(
      id: _uuid.v4(),
      userId: userId,
      imageUrl: imageUrl,
      diseaseName: prediction['disease_name'] ?? 'Unknown',
      botanicalName: prediction['botanical_name'] ?? '',
      scientificName: prediction['scientific_name'] ?? '',
      confidence: (prediction['confidence'] ?? 0.0).toDouble(),
      severity: prediction['severity'] ?? 'low',
      description: prediction['description'] ?? '',
      symptoms: List<String>.from(prediction['symptoms'] ?? []),
      district: district,
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      isSynced: false,
    );
  }

  Future<Map<String, dynamic>> _callAiModel(String imageUrl) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '${AppConstants.aiBaseUrl}${AppConstants.predictEndpoint}',
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'image_url': imageUrl}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('AI model error: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Cannot reach AI server. Check your connection.');
    } on http.ClientException {
      throw Exception('Cannot reach AI server. Is it running?');
    } catch (e) {
      throw Exception('Prediction failed: $e');
    }
  }
}
