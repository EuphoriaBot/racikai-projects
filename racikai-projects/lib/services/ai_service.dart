import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/chat_message.dart';

class AiServiceException implements Exception {
  final String message;
  const AiServiceException(this.message);
}

class AiService {
  AiService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? defaultBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  static String get defaultBaseUrl {
    const configured = String.fromEnvironment('AI_BASE_URL');
    if (configured.isNotEmpty) return configured;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  Future<ChatMessage> ask(String question) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${_baseUrl.replaceAll(RegExp(r'/+$'), '')}/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'message': question, 'top_k': 3}),
          )
          .timeout(const Duration(seconds: 60));
      if (response.statusCode != 200) {
        throw AiServiceException(
          response.statusCode == 503
              ? 'Model AI belum siap. Periksa kelengkapan model di server.'
              : 'Server AI gagal memproses pertanyaan. Silakan coba lagi.',
        );
      }
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ChatMessage(
        role: ChatRole.assistant,
        text: data['text'] as String,
        recipes: (data['recipes'] as List<dynamic>)
            .map((item) => AiRecipe.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } on AiServiceException {
      rethrow;
    } on TimeoutException {
      throw const AiServiceException(
        'AI terlalu lama merespons. Silakan coba lagi.',
      );
    } on http.ClientException {
      throw const AiServiceException(
        'Tidak dapat terhubung ke AI. Pastikan backend aktif dan alamat server benar.',
      );
    } on FormatException {
      throw const AiServiceException('Format respons server AI tidak valid.');
    } on TypeError {
      throw const AiServiceException(
        'Data resep dari server AI tidak lengkap.',
      );
    }
  }

  void dispose() => _client.close();
}
