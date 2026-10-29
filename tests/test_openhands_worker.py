"""Completion semantics at the pinned SDK boundary; no SDK or model is started."""
import importlib.util
from pathlib import Path
from types import SimpleNamespace
import unittest
from unittest.mock import Mock

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('openhands_task', ROOT / 'scripts/agents/openhands_task.py')
worker = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(worker)


class CompletionTests(unittest.TestCase):
    def test_only_finished_is_success(self):
        for status in ('finished', 'error', 'stuck', 'running', 'paused', None):
            conversation = SimpleNamespace(run=Mock(), state=SimpleNamespace(execution_status=status))
            if status == 'finished':
                worker.run_to_completion(conversation, 'finished')
            else:
                with self.assertRaises(RuntimeError):
                    worker.run_to_completion(conversation, 'finished')
            conversation.run.assert_called_once_with()

    def test_sdk_exception_is_not_swallowed(self):
        conversation = SimpleNamespace(run=Mock(side_effect=RuntimeError('fixture failure')))
        with self.assertRaisesRegex(RuntimeError, 'fixture failure'):
            worker.run_to_completion(conversation, 'finished')


if __name__ == '__main__':
    unittest.main()
