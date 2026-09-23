import json
import struct
import tempfile
import unittest
import os
from unittest.mock import patch
from pathlib import Path

from fastapi.testclient import TestClient
from app import create_app, validate_assets


class FakeEngine:
    def search(self, question, top_k):
        assert question == "ayam"
        return [{"id": "0", "title": "Ayam", "ingredients": "ayam, garam",
                 "instructions": "Masak ayam sampai matang."}][:top_k]


@patch.dict(os.environ, {"GEMINI_API_KEY": "", "GEMINI_MODEL": ""})
class ApiTests(unittest.TestCase):
    def test_chat_and_validation(self):
        with TestClient(create_app(FakeEngine)) as client:
            self.assertEqual(client.get('/health').json()['status'], 'ready')
            response = client.post('/chat', json={'message': ' ayam ', 'top_k': 1})
            self.assertEqual(response.status_code, 200)
            self.assertEqual(response.json()['recipes'][0]['id'], '0')
            for body in [{'message': ' '}, {'message': 'a' * 2001},
                         {'message': 'ayam', 'top_k': 0}, {'message': 'ayam', 'top_k': 6}]:
                self.assertEqual(client.post('/chat', json=body).status_code, 422)

    def test_unavailable_model(self):
        def fail():
            raise ValueError('model incomplete')
        with TestClient(create_app(fail)) as client:
            self.assertEqual(client.get('/health').json()['status'], 'not_ready')
            self.assertEqual(client.post('/chat', json={'message': 'ayam'}).status_code, 503)

    def test_truncated_weights(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            for name in ['config.json', 'tokenizer.json', 'modules.json',
                         'recipe_faiss.index', 'recipe_metadata.csv']:
                (root / name).touch()
            header = json.dumps({'weight': {'data_offsets': [0, 100]}}).encode()
            (root / 'model.safetensors').write_bytes(struct.pack('<Q', len(header)) + header)
            with self.assertRaisesRegex(ValueError, 'tidak lengkap'):
                validate_assets(root)

    def test_generation_uses_retrieved_sources(self):
        class Generator:
            def generate(self, question, recipes):
                assert question == 'ayam'
                assert recipes[0]['id'] == '0'
                return 'Masak ayam. Sumber resep: Ayam'
        with TestClient(create_app(FakeEngine, Generator)) as client:
            response = client.post('/chat', json={'message': 'ayam'}).json()
            self.assertEqual(response['generation'], 'gemini')
            self.assertIn('Sumber resep: Ayam', response['text'])

    def test_generation_failure_keeps_sources(self):
        class Generator:
            def generate(self, question, recipes):
                raise RuntimeError('private provider detail')
        with TestClient(create_app(FakeEngine, Generator)) as client:
            response = client.post('/chat', json={'message': 'ayam'}).json()
            self.assertEqual(response['generation'], 'unavailable')
            self.assertEqual(len(response['recipes']), 1)
            self.assertNotIn('private', response['text'])


if __name__ == '__main__':
    unittest.main()
