import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../features/recipe/data/models/catalog_recipe.dart';

class RecipeCatalogException implements Exception {
  final String message;

  const RecipeCatalogException(this.message);
}

class RecipeCatalogService {
  RecipeCatalogService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? defaultBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  static String get defaultBaseUrl {
    const configured = String.fromEnvironment('AI_BASE_URL');

    if (configured.isNotEmpty) {
      return configured;
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://localhost:8000';
  }

  Future<CatalogPage> getRecipes({
    String query = '',
    String category = 'Semua',
    int page = 1,
    int limit = 24,
  }) async {
    try {
      final base = _baseUrl.replaceAll(RegExp(r'/+$'), '');

      final uri = Uri.parse('$base/recipes').replace(
        queryParameters: {
          if (query.trim().isNotEmpty) 'q': query.trim(),
          'category': category,
          'page': '$page',
          'limit': '$limit',
        },
      );

      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw const RecipeCatalogException(
          'Resep gagal dimuat. '
          'Silakan coba lagi.',
        );
      }

      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      return CatalogPage.fromJson(data);
    } on RecipeCatalogException {
      rethrow;
    } on TimeoutException {
      throw const RecipeCatalogException('Server terlalu lama merespons.');
    } on http.ClientException {
      throw const RecipeCatalogException(
        'Tidak dapat terhubung ke server resep. '
        'Pastikan backend aktif.',
      );
    } on FormatException {
      throw const RecipeCatalogException('Respons katalog resep tidak valid.');
    } on TypeError {
      throw const RecipeCatalogException('Data katalog resep tidak lengkap.');
    }
  }

  void dispose() {
    _client.close();
  }
}
