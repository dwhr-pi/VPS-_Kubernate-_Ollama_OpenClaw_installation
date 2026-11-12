"""Offline documentation and metrics contracts; no deployment or notifications."""
import json
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


class OrchestrationDocs(unittest.TestCase):
    def test_local_navigation_resolves(self):
        for name in ('docs/MODEL_ROUTING_EXPORT_AND_MONITORING.md', 'docs/OLLAMA_LOG_MONITOR.md',
                     'docs/models/MODEL_PAGE_TEMPLATE.md', 'examples/models/ROUTER_PROMPT.md'):
            doc = ROOT / name
            for target in re.findall(r'\]\(([^\s)]+)\)', doc.read_text()):
                if '://' not in target and not target.startswith('#'):
                    self.assertTrue((doc.parent / target.split('#')[0]).is_file(), target)

    def test_dashboard_does_not_confuse_inventory_ram_and_inference(self):
        dashboard = json.loads((ROOT / 'monitoring/grafana/dashboards/ollama-inventory.json').read_text())
        expressions = [target['expr'] for panel in dashboard['panels'] for target in panel['targets']]
        self.assertIn('ollama_monitor_up', expressions)
        self.assertIn('ollama_monitor_loaded_vram_bytes', expressions)
        for expr in expressions:
            self.assertNotIn('container_memory', expr)
            self.assertNotIn('ollama_request_duration', expr)
            self.assertNotIn('FB_TOTAL', expr)
        self.assertEqual(len({p['id'] for p in dashboard['panels']}), len(dashboard['panels']))

    def test_discord_uses_secret_reference_and_no_raw_logs(self):
        config = (ROOT / 'examples/monitoring/discord-alertmanager-config.yaml').read_text()
        self.assertIn('discordConfigs:', config)
        self.assertIn('name: llmops-discord-webhook', config)
        self.assertNotIn('/api/webhooks/', config)
        self.assertNotIn('webhookConfigs:', config)
        self.assertIn('followRedirects: false', config)
        self.assertNotIn('{{', config)

    def test_service_is_non_root_opt_in_and_bounded(self):
        unit = (ROOT / 'examples/systemd/ollama-log-monitor.service').read_text()
        self.assertIn('User=ollama-monitor', unit)
        self.assertIn('NoNewPrivileges=true', unit)
        self.assertIn('LoadCredential=kubeconfig:', unit)
        self.assertIn('MemoryMax=128M', unit)
        self.assertNotIn('--send-discord', unit)
        self.assertIn('--duration 86400', unit)

    def test_performance_alerts_separate_ram_gpu_and_gateway(self):
        rules = (ROOT / 'examples/monitoring/ollama-performance-rules.yaml').read_text()
        self.assertIn('litellm_request_total_latency_metric_bucket', rules)
        self.assertIn('kube_pod_container_resource_limits', rules)
        self.assertIn('resource="memory",unit="byte"} > 0', rules)
        self.assertIn('DCGM_FI_DEV_FB_FREE', rules)
        self.assertNotIn('ollama_request_duration_seconds', rules)
        self.assertNotIn('DCGM_FI_DEV_FB_TOTAL', rules)


if __name__ == '__main__':
    unittest.main()
