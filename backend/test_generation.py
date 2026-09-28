import json
import unittest

import httpx

from generation import GeminiGenerator


class GenerationTests(unittest.TestCase):
    def test_generate_request_and_response(self):
        def handle(request):
            self.assertEqual(
                request.headers["x-goog-api-key"],
                "test-key",
            )

            self.assertNotIn(
                "test-key",
                str(request.url),
            )

            self.assertTrue(
                str(request.url).endswith(
                    "/v1beta/interactions"
                )
            )

            payload = json.loads(request.content)

            self.assertEqual(
                payload["model"],
                "test-model",
            )

            self.assertEqual(
                payload["generation_config"]["thinking_level"],
                "minimal",
            )

            self.assertIn(
                "RacikAI",
                payload["system_instruction"],
            )

            data = json.loads(
                payload["input"]
            )

            self.assertEqual(
                data["DATA_RESEP"][0]["title"],
                "Ayam",
            )

            return httpx.Response(
                200,
                json={
                    "status": "completed",
                    "steps": [
                        {
                            "type": "model_output",
                            "content": [
                                {
                                    "type": "text",
                                    "text": "Jawaban resep",
                                }
                            ],
                        }
                    ],
                },
            )

        generator = GeminiGenerator(
            "test-key",
            "test-model",
            httpx.MockTransport(handle),
        )

        result = generator.generate(
            "ayam",
            [
                {
                    "title": "Ayam",
                }
            ],
        )

        self.assertEqual(
            result,
            "Jawaban resep",
        )

    def test_rewrite_query(self):
        def handle(request):
            payload = json.loads(
                request.content
            )

            self.assertEqual(
                payload["model"],
                "test-model",
            )

            self.assertEqual(
                payload["generation_config"]["thinking_level"],
                "minimal",
            )

            self.assertIn(
                "query pencarian",
                payload["system_instruction"].lower(),
            )

            data = json.loads(
                payload["input"]
            )

            self.assertEqual(
                data["PERTANYAAN_PENGGUNA"],
                "Saya punya ayam dan kecap",
            )

            return httpx.Response(
                200,
                json={
                    "status": "completed",
                    "steps": [
                        {
                            "type": "model_output",
                            "content": [
                                {
                                    "type": "text",
                                    "text": "`chicken soy sauce recipe`",
                                }
                            ],
                        }
                    ],
                },
            )

        generator = GeminiGenerator(
            "test-key",
            "test-model",
            httpx.MockTransport(handle),
        )

        result = generator.rewrite_query(
            "Saya punya ayam dan kecap"
        )

        self.assertEqual(
            result,
            "chicken soy sauce recipe",
        )

    def test_empty_response_is_not_success(self):
        transport = httpx.MockTransport(
            lambda _: httpx.Response(
                200,
                json={
                    "status": "completed",
                    "steps": [],
                },
            )
        )

        generator = GeminiGenerator(
            "test-key",
            "test-model",
            transport,
        )

        with self.assertRaises(
            ValueError
        ):
            generator.generate(
                "ayam",
                [],
            )

    def test_invalid_model_rejected(self):
        with self.assertRaises(
            ValueError
        ):
            GeminiGenerator(
                "test-key",
                "https://example.com",
            )


if __name__ == "__main__":
    unittest.main()