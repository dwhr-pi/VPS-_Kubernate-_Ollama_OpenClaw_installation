"""Offline handbook and dataset contracts; no weights, tokenizers, models or training."""
import ast
import json
from pathlib import Path
import re
import unittest
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / 'docs/models'


class CodingModelHandbook(unittest.TestCase):
    def test_qwen_model_is_distinct_from_client_and_pinned(self):
        rows = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        model, = [row for row in rows if row['id'] == 'qwen_coder']
        client, = [row for row in rows if row['id'] == 'qwen_code']
        self.assertNotEqual(model['source'], client['source'])
        specs = json.loads((ROOT / 'scripts/tools/helpers/gap_tools.json').read_text())
        spec = specs['qwen_coder']
        self.assertEqual(model['source_commit'], spec['pin'])
        self.assertEqual(spec['pin'], '33bc6aabd7791ad7b32f7e92104f11f2359ba890')
        self.assertEqual(spec['contracts']['README.md'],
                         '7553f06c6f17a7ce22a76995a210b07fb6724d32a0cdc7bd4961ed2866d80fd4')
        self.assertFalse(model['auto_install'])
        self.assertTrue(spec['source_status_only'])
        self.assertEqual(model['readiness'], 'planned')

    def test_each_model_guide_links_languages_and_weight_setup(self):
        for name in ('qwen-coder', 'deepseek-r1', 'minimax-m3'):
            text = (ROOT / 'docs/tools' / (name + '.md')).read_text(encoding='utf-8')
            for term in ('../models/README.md', 'Assembler', 'runtime_tested: false'):
                self.assertIn(term, text)
        text = (FOLDER / 'README.md').read_text(encoding='utf-8')
        for term in ('358', 'Next-Abschnitt', 'keine behauptete Supportliste',
                     'x86-64', 'AArch64', 'RISC-V', 'Intel-/AT&T', 'ABI', 'NASM/GAS',
                     'Gewichts-Pin', 'gesonderte Freigabe', 'Kein automatisches',
                     'Qwen Code', 'Aider', 'OpenCode', 'OpenHands', 'OpenClaw', 'LiteLLM'):
            self.assertIn(term, text)

    def test_weights_are_not_plaintext_and_identity_is_not_self_report(self):
        text = (FOLDER / 'WEIGHTS_RAG_AND_PROVENANCE.md').read_text(encoding='utf-8')
        for term in ('gar nicht verschluesselt', 'kein verschluesseltes Buch',
                     'nicht eindeutig umkehrbar', 'synthetischen Datensatz',
                     'SHA256', 'Tensor-Namen', 'Tokenizer', 'kein Herkunftstest',
                     'keinen universellen', 'Copyright-/NOTICE', 'read-only'):
            self.assertIn(term, text)

    def test_training_is_measurement_driven_and_successor_data_is_retokenized(self):
        text = (FOLDER / 'TRAINING_AND_EVALUATION.md').read_text(encoding='utf-8')
        for term in ('Retrievalproblem', 'Holdout', 'LoRA', 'QLoRA', 'continued pretraining',
                     'keine Tokenisierung', 'Alte Token-IDs', 'Loss-Masking',
                     'kein doppeltes Templating', 'kein Evaluationsrunner',
                     'Qwen-Adapter funktioniert nicht pauschal mit DeepSeek',
                     'catastrophic forgetting', 'synthetische Herkunft'):
            self.assertIn(term.casefold(), text.casefold())
        for code in re.findall(r'```python\n(.*?)\n```', text, re.S):
            ast.parse(code)

    def test_example_corpus_is_canonical_and_not_training_approved(self):
        path = ROOT / 'examples/models/coding-training.records.jsonl'
        rows = [json.loads(line) for line in path.read_text(encoding='utf-8').splitlines()]
        self.assertGreaterEqual(len(rows), 2)
        self.assertEqual(len({row['id'] for row in rows}), len(rows))
        for row in rows:
            self.assertEqual(row['schema_version'], 1)
            self.assertEqual(row['source'], 'self-authored-synthetic')
            self.assertEqual(row['review_status'], 'template-not-training-approved')
            self.assertEqual(row['license'], 'Apache-2.0')
            self.assertEqual([m['role'] for m in row['messages']], ['user', 'assistant'])
            self.assertTrue(all(isinstance(m['content'], str) and m['content'] for m in row['messages']))
            self.assertNotIn('input_ids', row)
        evaluation = json.loads((ROOT / 'examples/models/coding-eval-cases.json').read_text())
        self.assertFalse(evaluation['auto_execute'])
        self.assertEqual(evaluation['status'], 'template-not-executed')
        train_groups = {row['group_id'] for row in rows}
        test_groups = {row['group_id'] for row in evaluation['cases']}
        self.assertFalse(train_groups & test_groups)
        for row in evaluation['cases']:
            self.assertIsNone(row['result'])
        asm = [row for row in evaluation['cases'] if row['language'] == 'assembly']
        self.assertEqual({row['isa'] for row in asm}, {'x86-64', 'AArch64'})
        self.assertTrue(all(row.get('abi') and row.get('syntax') for row in asm))

    def test_local_navigation_and_fenced_blocks_are_valid(self):
        for doc in FOLDER.glob('*.md'):
            text = doc.read_text(encoding='utf-8')
            self.assertEqual(sum(line.startswith('```') for line in text.splitlines()) % 2, 0, doc.name)
            for target in re.findall(r'\]\(([^\s)]+)\)', text):
                parsed = urlsplit(target)
                if parsed.scheme:
                    self.assertEqual(parsed.scheme, 'https')
                    self.assertIsNone(parsed.username)
                    self.assertIsNone(parsed.password)
                elif not target.startswith('#'):
                    self.assertTrue((doc.parent / target.split('#')[0]).is_file(), (doc.name, target))
            self.assertNotRegex(text, r'(?im)^\s*(?:docker\s+(?:run|compose)|curl\b[^\n]*\|\s*(?:ba)?sh)')


if __name__ == '__main__':
    unittest.main()
