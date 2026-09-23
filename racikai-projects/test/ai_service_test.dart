import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_racikai_application/services/ai_service.dart';

void main() {
  test(
    'posts question and preserves AI dataset recipe instead of dummy IDs',
    () async {
      final service = AiService(
        baseUrl: 'http://localhost:8000/',
        client: MockClient((request) async {
          expect(request.url.path, '/chat');
          expect(jsonDecode(request.body)['message'], 'ayam');
          return http.Response(
            jsonEncode({
              'text': 'Resep ditemukan',
              'recipes': [
                {
                  'id': '0',
                  'title': 'Ayam',
                  'ingredients': 'ayam, garam',
                  'instructions': 'Masak sampai matang.',
                },
              ],
            }),
            200,
          );
        }),
      );
      addTearDown(service.dispose);
      final message = await service.ask('ayam');
      expect(message.recipes.single.id, '0');
      expect(message.recipes.single.instructions, 'Masak sampai matang.');
      expect(message.sourceRecipeIds, isEmpty);
    },
  );

  test('unavailable model produces actionable error', () async {
    final service = AiService(
      client: MockClient((_) async => http.Response('{}', 503)),
    );
    addTearDown(service.dispose);
    await expectLater(service.ask('ayam'), throwsA(isA<AiServiceException>()));
  });

  test('invalid payload produces service error', () async {
    final service = AiService(
      client: MockClient((_) async => http.Response('{}', 200)),
    );
    addTearDown(service.dispose);
    await expectLater(service.ask('ayam'), throwsA(isA<AiServiceException>()));
  });

  test('connection failure produces service error', () async {
    final service = AiService(
      client: MockClient((_) async => throw http.ClientException('offline')),
    );
    addTearDown(service.dispose);
    await expectLater(service.ask('ayam'), throwsA(isA<AiServiceException>()));
  });
}
