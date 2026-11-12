"""Offline monitoring contracts; no live scraper, GPU, model or Grafana required."""
from contextlib import redirect_stdout, redirect_stderr
import importlib.util
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('tool_observability', ROOT / 'scripts/monitoring/tool_observability.py')
obs = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(obs)


class ToolObservability(unittest.TestCase):
    def test_all_registry_ids_are_covered_once(self):
        rows = obs.catalog()
        self.assertGreater(len(rows), 400)
        metrics = obs.textfile(rows)
        coverage = obs.render()[obs.OUTPUTS[3]]
        for row in rows:
            self.assertEqual(metrics.count('tool="' + row['id'] + '"'), 1)
            self.assertEqual(coverage.count('| `' + row['id'] + '` |'), 1)
        self.assertNotIn('openclaw_tool_monitoring_expected{', metrics)
        self.assertNotIn('installed', metrics.splitlines()[-1])

    def test_expectations_are_explicit_bounded_and_deduplicated(self):
        rows = obs.catalog()
        metrics = obs.textfile(rows, 'home-gpu', ['ollama', 'ollama'])
        self.assertEqual(metrics.count('openclaw_tool_monitoring_expected{'), 1)
        self.assertIn('monitoring_scope="home-gpu",tool="ollama"} 1', metrics)
        for scope in ('bad"label', 'bad\nlabel', '', 'a' * 129):
            with self.assertRaises(ValueError):
                obs.textfile(rows, scope)
        with self.assertRaises(ValueError):
            obs.textfile(rows, expected=['not-in-registry'])

    def test_default_plan_never_reads_registry_or_writes(self):
        with patch.object(obs, 'catalog') as catalog, patch.object(obs, 'render') as render:
            with redirect_stdout(io.StringIO()):
                self.assertEqual(obs.main([]), 0)
            catalog.assert_not_called()
            render.assert_not_called()

    def test_cli_cannot_silently_ignore_scope_or_unknown_tool(self):
        with redirect_stderr(io.StringIO()), redirect_stdout(io.StringIO()):
            self.assertEqual(obs.main(['--expect', 'ollama']), 1)
            self.assertEqual(obs.main(['--textfile', '--expect', 'not-in-registry']), 1)

    def test_generated_files_have_no_drift(self):
        for name, content in obs.render().items():
            self.assertEqual((ROOT / name).read_text(encoding='utf-8'), content, name)

    def test_native_rules_and_operator_resource_share_exact_groups(self):
        outputs = obs.render()
        native = json.loads(outputs[obs.OUTPUTS[0]])
        operator = json.loads(outputs[obs.OUTPUTS[1]])
        self.assertEqual(native, operator['spec'])
        self.assertEqual(operator['metadata']['labels']['release'], 'llmops-monitoring')
        rules = [rule for group in native['groups'] for rule in group['rules']]
        names = [rule['alert'] for rule in rules if 'alert' in rule]
        self.assertEqual(len(names), len(set(names)))
        self.assertTrue(all(rule.get('for') for rule in rules if 'alert' in rule))
        missing = next(rule for rule in rules if rule.get('alert') == 'OpenClawToolExpectedTargetMissing')
        self.assertIn('unless on (monitoring_scope, tool)', missing['expr'])
        self.assertIn('openclaw_tool_monitoring_expected', missing['expr'])
        self.assertFalse(any('absent(up)' in rule['expr'] for rule in rules))

    def test_private_config_includes_rules_only_when_requested(self):
        spec = importlib.util.spec_from_file_location('native_monitoring_fixture',
                                                      ROOT / 'scripts/security/native_monitoring_config.py')
        native = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(native)
        args = ('127.0.0.1:4000', '127.0.0.1:9100', '127.0.0.1:9404',
                '/fixture/token', '/fixture/receiver', '/fixture/alerts.yml')
        default, _ = native.configurations(*args)
        enabled, _ = native.configurations(*args, include_tool_rules=True)
        self.assertEqual(default['rule_files'], ['/fixture/alerts.yml'])
        self.assertEqual([Path(path).name for path in enabled['rule_files']], ['alerts.yml', 'tool-rules.yml'])

    def test_dashboard_has_variable_datasource_unique_ids_and_no_fake_health(self):
        board = obs.dashboard()
        panels = board['panels']
        self.assertEqual(len({panel['id'] for panel in panels}), len(panels))
        self.assertEqual({var['name'] for var in board['templating']['list']}, {'DS_PROMETHEUS', 'scope', 'tool'})
        for panel in panels[1:]:
            self.assertEqual(panel['datasource']['uid'], '${DS_PROMETHEUS}')
            self.assertEqual(panel['fieldConfig']['defaults']['noValue'], 'Keine Daten')
        expressions = '\n'.join(target['expr'] for panel in panels for target in panel.get('targets', []))
        self.assertNotIn('or vector(0)', expressions)
        self.assertNotIn('ollama_request_duration', expressions)
        self.assertIn('keine Daten', panels[0]['options']['content'])

    def test_duplicate_registry_ids_are_refused(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / 'config').mkdir()
            for rows in ([{'id': 'x'}, {'id': 'x'}], [{'id': 'bad"label'}]):
                (root / 'config/tools.yml').write_text(json.dumps({'tools': rows}), encoding='utf-8')
                with self.assertRaises(ValueError):
                    obs.catalog(root)

    def test_promtool_fixtures_cover_missing_down_healthy_and_unmonitored(self):
        tests = json.loads((ROOT / 'tests/fixtures/tool-observability.rules.test.yml').read_text(encoding='utf-8'))
        self.assertEqual(tests['rule_files'], ['../../monitoring/tool-rules.yml'])
        self.assertGreaterEqual(len(tests['tests']), 8)
        covered = {case['alertname'] for group in tests['tests'] for case in group['alert_rule_test']}
        alerts = {rule['alert'] for group in obs.groups() for rule in group['rules'] if 'alert' in rule}
        self.assertEqual(covered, alerts)


if __name__ == '__main__':
    unittest.main()
