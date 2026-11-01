"""Offline policy checks with SDK substitutes; no inference or provider calls."""
import asyncio
import importlib.util
import io
import os
from pathlib import Path
import sys
import types
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]


class Rejected(Exception):
    def __init__(self, status_code, detail):
        self.status_code = status_code
        super().__init__(detail)


def load_policy():
    logger = types.ModuleType('litellm.integrations.custom_logger')
    logger.CustomLogger = type('CustomLogger', (), {})
    fastapi = types.ModuleType('fastapi')
    fastapi.HTTPException = Rejected
    spec = importlib.util.spec_from_file_location('local_policy_fixture', ROOT / 'services/inference-gateway/local_policy.py')
    module = importlib.util.module_from_spec(spec)
    with patch.dict(sys.modules, {'litellm.integrations.custom_logger': logger, 'fastapi': fastapi}):
        spec.loader.exec_module(module)
    return module


class LocalGatewayPolicy(unittest.TestCase):
    def setUp(self):
        self.module = load_policy()
        self.policy = self.module.LocalPolicy()
        self.env = patch.dict(os.environ, {'LITELLM_OLLAMA_MODEL': 'ollama/fixture', 'OLLAMA_API_BASE': 'http://127.0.0.1:11434'}, clear=True)
        self.env.start()
        self.addCleanup(self.env.stop)

    def call(self, data=None, identity='synthetic-key'):
        return asyncio.run(self.policy.async_pre_call_hook({'api_key': identity}, None,
            data if data is not None else {'model': 'local-default', 'messages': [{'role': 'user', 'content': 'fixture'}]}, 'completion'))

    def test_default_output_bound_and_key_not_retained(self):
        self.assertEqual(self.call()['max_tokens'], 256)
        self.assertNotIn('synthetic-key', self.policy.counts)

    def test_routes_and_overrides_fail_closed(self):
        for url in ('https://example.com:11434', 'http://127.0.0.1:11434/evil', 'http://user:pass@127.0.0.1:11434'):
            with self.subTest(url=url), patch.dict(os.environ, {'OLLAMA_API_BASE': url}), self.assertRaises(Rejected):
                self.call()
        for model in ('gpt-cloud', 'unknown'):
            with self.assertRaises(Rejected):
                self.call({'model': model, 'messages': []})
        with self.assertRaises(Rejected):
            self.call({'model': 'local-default', 'api_base': 'http://elsewhere', 'messages': []})

    def test_token_and_message_limits(self):
        for value in (False, 0, 1025, '100'):
            with self.subTest(value=value), self.assertRaises(Rejected):
                self.call({'model': 'local-default', 'messages': [{'role': 'user', 'content': 'fixture'}], 'max_tokens': value})
        for content in ('a' * 65537, '-----BEGIN PRIVATE KEY-----', [{'type': 'image_url'}]):
            with self.assertRaises(Rejected):
                self.call({'model': 'local-default', 'messages': [{'role': 'user', 'content': content}]})

    def test_per_key_global_and_window_limits(self):
        with patch.object(self.module.time, 'monotonic', return_value=120):
            for index in range(32):
                self.call(identity='key-' + str(index // 8))
            with self.assertRaises(Rejected) as failure:
                self.call(identity='another')
            self.assertEqual(failure.exception.status_code, 429)
        with patch.object(self.module.time, 'monotonic', return_value=180):
            self.call()
            self.assertEqual(self.policy.total, 1)

    def test_per_key_limit_and_missing_identity(self):
        for _ in range(8):
            self.call()
        with self.assertRaises(Rejected) as failure:
            self.call()
        self.assertEqual(failure.exception.status_code, 429)
        with self.assertRaises(Rejected):
            self.call(identity='')


class RiskConsent(unittest.TestCase):
    def test_one_action_only_and_finance_blocked(self):
        spec = importlib.util.spec_from_file_location('risk_fixture', ROOT / 'scripts/security/risk_consent.py')
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        tags = module.risks('OpenVoice')
        self.assertFalse(module.approve(tags, io.StringIO('\n'), True))
        self.assertFalse(module.approve(tags, io.StringIO('ACK:' + ','.join(tags)), False))
        self.assertTrue(module.approve(tags, io.StringIO('ACK:' + ','.join(tags)), True))
        self.assertFalse(module.approve(module.risks('Trading'), io.StringIO('ACK:finance-paper-only'), True))


if __name__ == '__main__':
    unittest.main()
