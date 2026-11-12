"""Pure model planning fixtures; no conversion, model APIs or active config writes."""
from copy import deepcopy
import importlib.util
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('pipeline_fixture', ROOT / 'scripts/models/openclaw_pipeline.py')
pipeline = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(pipeline)


class PipelinePlan(unittest.TestCase):
    def setUp(self):
        self.config = {'version': 1, 'models': [
            {'model': 'qwq:32b', 'task': 'finance', 'quantization': 'Q4_K_M', 'max_context': 4096,
             'required_vram_mib': 24576, 'license_reviewed': True, 'runtime_reviewed': True},
            {'model': 'deepseek-r1:14b', 'task': 'finance', 'quantization': 'Q4_K_M', 'max_context': 4096,
             'required_vram_mib': 16384, 'license_reviewed': True, 'runtime_reviewed': True}]}

    def test_only_installed_reviewed_fitting_models_can_be_proposed(self):
        names = ['qwq:32b', 'deepseek-r1:14b']
        result = pipeline.route(self.config, names, 'finance', 18000, 4096)
        self.assertEqual(result['selected_model'], 'deepseek-r1:14b')
        self.assertFalse(result['executed'])
        self.assertIsNone(result['inference_time_seconds'])
        self.assertFalse(result['automatic_download'])
        for names, vram, context in [([], 50000, 4096), (names, 8000, 4096), (names, 50000, 8192)]:
            self.assertEqual(pipeline.route(self.config, names, 'finance', vram, context)['status'], 'blocked')

    def test_license_and_task_boundaries_never_silently_fallback(self):
        config = deepcopy(self.config)
        for row in config['models']:
            row['license_reviewed'] = False
        names = ['qwq:32b', 'deepseek-r1:14b']
        self.assertEqual(pipeline.route(config, names, 'finance', 50000, 4096)['status'], 'blocked')
        self.assertEqual(pipeline.route(self.config, names, 'code', 50000, 4096)['status'], 'blocked')
        self.assertEqual(pipeline.route(self.config, names, 'audio', 50000, 4096)['status'], 'transcription-required')

    def test_export_is_two_stage_and_never_registers_or_rewrites(self):
        result = pipeline.export_plan('custom-legal:review', './merged', './llama.cpp', './isolated', 'Q4_K_M')
        self.assertIn('f16', result['conversion_argv'])
        self.assertNotIn('Q4_K_M', result['conversion_argv'])
        self.assertEqual(result['quantization_argv'][-1], 'Q4_K_M')
        self.assertFalse(result['executed'])
        self.assertFalse(result['active_config_modified'])
        self.assertTrue(result['benchmark_requires_separate_approval'])
        self.assertIn('PARAMETER num_ctx 4096', result['modelfile_proposal'])

    def test_invalid_values_and_duplicate_models_are_rejected(self):
        for name in ('bad;id', 'a\nb', '../../outside'):
            with self.assertRaises(ValueError):
                pipeline.export_plan(name, './merged', './llama', './out', 'Q8_0')
        for vram in (-1, True, 1.5):
            with self.assertRaises(ValueError):
                pipeline.route(self.config, [], 'general', vram, 4096)
        config = deepcopy(self.config)
        config['models'].append(config['models'][0])
        with self.assertRaises(ValueError):
            pipeline.route(config, [], 'general', 50000, 4096)


if __name__ == '__main__':
    unittest.main()
