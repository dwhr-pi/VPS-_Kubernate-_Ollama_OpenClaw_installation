"""Offline archive contract; never contact a cluster or apply a manifest."""
import hashlib
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
ARCHIVE = 'docs/legacy/K8S_DEPLOYMENTS_LEGACY.md'
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')


class LegacyArchive(unittest.TestCase):
    def test_original_source_preserved_exactly_but_not_as_manifest(self):
        text = (ROOT / ARCHIVE).read_text(encoding='utf-8')
        blocks = re.findall(r'^```yaml\n(.*?)^```', text, re.M | re.S)
        self.assertEqual(len(blocks), 1)
        self.assertEqual(hashlib.sha256(blocks[0].encode()).hexdigest(),
                         '5c6b694dbfbab8e43b26364054777d9d2e930eb64e3acf5dc39da19c5d4354f2')
        self.assertFalse((ROOT / 'scripts/k8s_deployments.yaml').exists())
        self.assertIn('kein ausfuehrbarer Deployment-Pfad', text)
        self.assertIn('keine bereits laufenden Pods', text)
        self.assertTrue((ROOT / 'k8s/base/kustomization.yml').is_file())
        self.assertTrue((ROOT / 'k8s/overlays/vps-cpu/kustomization.yml').is_file())

    def test_no_dangling_local_markdown_links_to_removed_manifest(self):
        for path in [ROOT / 'readme.md', *sorted((ROOT / 'docs').rglob('*.md'))]:
            text = path.read_text(encoding='utf-8')
            self.assertNotRegex(text, r'\]\([^)]*scripts/k8s_deployments\.yaml')

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash unavailable')
    def test_display_only_and_missing_archive_fails(self):
        with tempfile.TemporaryDirectory(prefix='legacy archive ') as directory:
            root = Path(directory).resolve()
            script = root / 'scripts/operations/show_k8s_deployments.sh'
            script.parent.mkdir(parents=True)
            shutil.copyfile(ROOT / 'scripts/operations/show_k8s_deployments.sh', script)
            archive = root / ARCHIVE
            archive.parent.mkdir(parents=True)
            archive.write_text('fixture archive only\n', encoding='utf-8')
            result = subprocess.run([BASH, '--noprofile', '--norc', str(script)],
                                    cwd=root, capture_output=True, text=True, timeout=20)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('HISTORISCHE REFERENZ', result.stdout)
            self.assertIn('fixture archive only', result.stdout)
            self.assertIn('k8s/base', result.stdout)
            archive.unlink()
            result = subprocess.run([BASH, '--noprofile', '--norc', str(script)],
                                    cwd=root, capture_output=True, text=True, timeout=20)
            self.assertEqual(result.returncode, 1)
            self.assertIn('Referenz fehlt', result.stderr)


if __name__ == '__main__':
    unittest.main()
