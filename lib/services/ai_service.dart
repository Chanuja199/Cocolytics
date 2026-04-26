import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/secrets.dart';

class AiService {
  static const List<String> _models = <String>[
    'gemini-3-flash-preview',     // Latest flagship "Flash" (fast & smart)
    'gemini-3.1-flash-lite-preview', // Ultra-fast, very cheap, high volume
    'gemini-2.5-flash',
  ];

  /// Provides advice from an expert agricultural assistant specializing in Coconut cultivation.
  Future<String> askCoconutAssistant({required String question}) async {
    final apiKey = Secrets.geminiApiKey;
    if (apiKey.trim().isEmpty) {
      return 'AI is not configured yet. Please ask the community, or configure the AI API key.';
    }

    try {
      final answer = await _askGemini(
        apiKey: apiKey,
        userPrompt: question,
        systemPrompt: '''You are an expert agricultural assistant specializing in Coconut cultivation in Sri Lanka.
You must give helpful, practical, and safe advice in simple English.

Output format (use these exact headings):
1) Likely cause(s) (rank 1-3 with short confidence: low/med/high)
2) Quick checks (3-5 bullet points the farmer can do today)
3) Treatment plan
   - Today (immediate actions)
   - Next 7 days (step-by-step)
4) Prevention (2-4 bullets)
5) Safety notes (2 bullets, e.g., avoid over-chemicals; use recommended doses)
6) If anything is unclear, ask up to 2 short clarifying questions at the end.

If the question is missing key details, still provide the best general guidance, but include clarifying questions in section 6.

Keep it farmer-friendly and avoid complex medical terminology.''',
        temperature: 0.65,
        maxOutputTokens: 1000,
      );
      if (answer.trim().isEmpty) {
        return 'Sorry — I could not generate an AI answer right now. Please try again or ask the community.';
      }
      return answer;
    } catch (e) {
      return _friendlyAiError(e.toString());
    }
  }

  /// Drafts a short, practical AI reply for community forum posts.
  Future<String> draftForumReply({required String question}) async {
    final apiKey = Secrets.geminiApiKey;
    if (apiKey.trim().isEmpty) {
      return 'Please ask the community for help.';
    }

    try {
      final answer = await _askGemini(
        apiKey: apiKey,
        userPrompt: question,
        systemPrompt: '''You are Cocolytics AI inside a Coconut community forum in Sri Lanka.
Reply as a helpful, practical agricultural assistant.

Output format:
- 1-line summary of what the farmer is likely seeing
- Most likely cause(s): 2-3 bullets
- Action plan: 3-6 short bullets (Today + Next days)
- Prevention: 2-3 bullets
- Ask 1-2 clarifying questions if needed

Keep the reply readable (simple English).''',
        temperature: 0.55,
        maxOutputTokens: 750,
      );
      return answer.trim().isNotEmpty ? answer : 'Please ask the community for help.';
    } catch (e) {
      debugPrint('Forum AI reply failed: $e');
      return 'Please ask the community for help.';
    }
  }

  Future<String> _askGemini({
    required String apiKey,
    required String systemPrompt,
    required String userPrompt,
    required double temperature,
    required int maxOutputTokens,
  }) async {
    String? lastError;
    for (final model in _models) {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
      );

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'systemInstruction': {
                'parts': [
                  {'text': systemPrompt},
                ],
              },
              'contents': [
                {
                  'role': 'user',
                  'parts': [
                    {'text': userPrompt},
                  ],
                },
              ],
              'generationConfig': {
                'temperature': temperature,
                'maxOutputTokens': maxOutputTokens,
                'topP': 0.9,
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>? ?? const [];
        if (candidates.isEmpty) return '';

        final first = candidates.first as Map<String, dynamic>;
        final content = first['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>? ?? const [];
        if (parts.isEmpty) return '';

        return (parts.first['text'] ?? '').toString().trim();
      }

      final body = response.body;
      debugPrint('Gemini API error model=$model (${response.statusCode}): $body');
      lastError = 'gemini_http_${response.statusCode}: $body';

      if (response.statusCode == 404) {
        continue;
      }

      throw Exception(lastError);
    }

    throw Exception(lastError ?? 'No supported Gemini model was available.');
  }

  String _friendlyAiError(String raw) {
    final msg = raw.toLowerCase();
    if (msg.contains('401') || msg.contains('api key not valid')) {
      return 'AI key is invalid. Please check your Gemini API key.';
    }
    if (msg.contains('403') || msg.contains('permission_denied')) {
      return 'Gemini API is not enabled for this project/key. Enable Generative Language API in Google Cloud.';
    }
    if (msg.contains('429') || msg.contains('quota')) {
      return 'AI quota limit reached. Please try again later.';
    }
    if (msg.contains('socket') || msg.contains('timeout')) {
      return 'Network issue while contacting AI service. Please try again.';
    }
    return 'Sorry — AI is temporarily unavailable. Please try again later or ask the community.';
  }
}

