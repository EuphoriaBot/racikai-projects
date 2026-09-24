import json
import unittest

import httpx
from generation import GeminiGenerator


class GenerationTests(unittest.TestCase):
    def test_request_and_response(self):
        def handle(request):
            self.assertEqual(request.headers['x-goog-api-key'], 'test-key')
            self.assertNotIn('test-key', str(request.url))
            payload = json.loads(request.content)
            data = json.loads(payload['contents'][0]['parts'][0]['text'])
            self.assertEqual(data['DATA_RESEP'][0]['title'], 'Ayam')
            return httpx.Response(200, json={'candidates': [{'content': {'parts': [
                {'text': 'internal', 'thought': True}, {'text': 'Jawaban resep'}]}}]})
        generator = GeminiGenerator('test-key', 'test-model', httpx.MockTransport(handle))
        self.assertEqual(generator.generate('ayam', [{'title': 'Ayam'}]), 'Jawaban resep')

    def test_blocked_response_is_not_success(self):
        transport = httpx.MockTransport(lambda _: httpx.Response(200, json={'candidates': []}))
        with self.assertRaises(ValueError):
            GeminiGenerator('test-key', 'test-model', transport).generate('ayam', [])

    def test_invalid_model_rejected(self):
        with self.assertRaises(ValueError):
            GeminiGenerator('test-key', 'https://example.com')
