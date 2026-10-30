"""Offline recipe planning checks; no media engines or assets needed."""
import contextlib
import copy
import importlib.util
import io
import json
from pathlib import Path
import re
import tempfile
from doc_assertions import assert_prose_in, assert_prose_not_in
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("media_workflow_plan", ROOT / "tools/media_workflow/plan.py")
p = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(p)


def example(name="photo-trend"):
    return json.loads((ROOT / ("examples/media-workflow/" + name + ".json")).read_text(encoding="utf-8"))


class MediaWorkflowTests(unittest.TestCase):
    def test_both_examples_are_review_plans_not_render_jobs(self):
        for name in ("photo-trend", "ugc-ad"):
            result = p.build_plan(example(name))
            self.assertEqual(result["status"], "review_required")
            self.assertFalse(result["render_ready"])
            self.assertTrue(result["blockers"])
            self.assertEqual(result["execution_policy"]["max_parallel_gpu_jobs"], 1)
            self.assertFalse(result["execution_policy"]["cloud_fallback"])
            self.assertTrue(all(not scene["adapter_implemented"] for scene in result["scenes"]))

    def test_hash_stable_across_key_order_and_sensitive_to_edits(self):
        recipe = example()
        original = p.build_plan(recipe)["recipe_sha256"]
        self.assertEqual(original, p.build_plan(dict(reversed(list(recipe.items()))))["recipe_sha256"])
        for key, value in (("seed", 9), ("script", "New script")):
            changed = copy.deepcopy(recipe)
            changed[key] = value
            self.assertNotEqual(original, p.build_plan(changed)["recipe_sha256"])
        recipe["scenes"][0]["prompt"] = "different motion"
        self.assertNotEqual(original, p.build_plan(recipe)["recipe_sha256"])

    def test_confirmation_never_enables_rendering(self):
        recipe = example("ugc-ad")
        recipe["rights"] = {key: True for key in recipe["rights"]}
        result = p.build_plan(recipe)
        self.assertFalse(result["render_ready"])
        self.assertTrue(any("Kommerzielle" in message for message in result["blockers"]))

    def test_budget_bounds_and_booleans_not_integers(self):
        for key, value in (("seed", True), ("seed", -1), ("seed", 4294967296),
                           ("version", 2), ("version", False), ("script", ""),
                           ("workflow", "arbitrary"), ("project", "../../escape")):
            recipe = example()
            recipe[key] = value
            with self.subTest(key=key, value=value), self.assertRaises(p.RecipeError):
                p.build_plan(recipe)
        for key, value in (("width", 481), ("height", 2000), ("fps", 60), ("fps", True)):
            recipe = example()
            recipe["canvas"][key] = value
            with self.assertRaises(p.RecipeError):
                p.build_plan(recipe)

    def test_strict_fields_prevent_command_or_endpoint_configuration(self):
        for target in ("top", "scene", "audio", "canvas", "rights"):
            recipe = example()
            obj = recipe if target == "top" else recipe["scenes"][0] if target == "scene" else recipe[target]
            obj["command"] = "do-not-execute"
            with self.subTest(target=target), self.assertRaises(p.RecipeError):
                p.build_plan(recipe)

    def test_assets_are_relative_references_not_urls_or_traversal(self):
        for value in ("https://example.com/x.png", "/etc/passwd", "C:/file.png", "assets/../file",
                      "assets/../../file", "assets\\file", "assets/", "assets/file?x", "assets/file#x"):
            with self.subTest(value=value), self.assertRaises(p.RecipeError):
                p.asset(value)
        self.assertEqual(p.asset("assets/own-image.png"), "assets/own-image.png")

    def test_scenes_unique_and_bounded(self):
        for scenes in ([], [example()["scenes"][0]] * 2, [example()["scenes"][0]] * 7):
            recipe = example()
            recipe["scenes"] = scenes
            with self.assertRaises(p.RecipeError):
                p.build_plan(recipe)
        recipe = example()
        recipe["scenes"] = [dict(recipe["scenes"][0], id="scene-" + str(i), seconds=8) for i in range(4)]
        with self.assertRaisesRegex(p.RecipeError, "30 Sekunden"):
            p.build_plan(recipe)

    def test_talking_head_requires_audio(self):
        recipe = example()
        recipe["scenes"][0]["kind"] = "talking_head"
        with self.assertRaises(p.RecipeError):
            p.build_plan(recipe)

    def test_audio_modes_and_rights_types(self):
        for audio in ({"mode": "cloud"}, {"mode": "none", "source": "assets/x.wav"},
                      {"mode": "tts"}, {"mode": "existing"}):
            recipe = example()
            recipe["audio"] = audio
            with self.assertRaises(p.RecipeError):
                p.build_plan(recipe)
        recipe["audio"] = {"mode": "existing", "source": "assets/x.wav"}
        self.assertFalse(p.build_plan(recipe)["render_ready"])
        recipe["rights"]["assets_confirmed"] = "yes"
        with self.assertRaises(p.RecipeError):
            p.build_plan(recipe)

    def test_input_recipe_not_mutated(self):
        recipe = example()
        original = copy.deepcopy(recipe)
        p.build_plan(recipe)
        self.assertEqual(recipe, original)

    def test_cli_only_reads_recipe_and_emits_json(self):
        source = ROOT / "examples/media-workflow/photo-trend.json"
        with patch("subprocess.run", side_effect=AssertionError("no subprocess")), \
                patch("socket.socket", side_effect=AssertionError("no network")), \
                patch.object(p.Path, "write_text", side_effect=AssertionError("no writes")), \
                contextlib.redirect_stdout(io.StringIO()) as output:
            self.assertEqual(p.main([str(source)]), 0)
            self.assertFalse(json.loads(output.getvalue())["render_ready"])

    def test_cli_rejects_invalid_json_duplicate_fields_size_and_nonfinite(self):
        for raw in (b"not-json", b'{"version":1,"version":1}', b'{"value":NaN}',
                    b'{"value":Infinity}', b"[]", b"x" * (128 * 1024 + 1), b"\xff"):
            with tempfile.TemporaryDirectory() as tmp:
                source = Path(tmp) / "recipe.json"
                source.write_bytes(raw)
                with contextlib.redirect_stdout(io.StringIO()) as out, contextlib.redirect_stderr(io.StringIO()):
                    self.assertEqual(p.main([str(source)]), 2)
                    self.assertEqual(out.getvalue(), "")

    def test_nominal_frames_are_not_model_parameters(self):
        result = p.build_plan(example())
        self.assertEqual(result["scenes"][0]["nominal_output_frames"], 48)
        self.assertEqual(result["seconds"], 3)

    def test_documentation_local_links_and_sources(self):
        docpath = ROOT / "docs/media_studio/EDITABLE_VIDEO_WORKFLOWS.md"
        doc = docpath.read_text(encoding="utf-8")
        for target in re.findall(r"\]\(([^)]+)\)", doc):
            if not target.startswith(("https://", "http://", "#")):
                self.assertTrue((docpath.parent / target.split("#")[0]).resolve().exists(), target)
        for text in ("render_ready=false", "kein implementierter Worker", "XTTS", "InsightFace",
                     "Sustainable Use License", "nicht auslesbar", "https://umnik.ai/",
                     "https://github.com/Wan-Video/Wan2.1", "POST /prompt"):
            assert_prose_in(self, text, doc)

    def test_guide_discoverable(self):
        for path in ("docs/TOOLS_CATALOG.md", "docs/TOOL_INDEX.md", "docs/media_studio/README.md",
                     "docs/media_studio/SOCIAL_AVATAR_AUTOMATION.md"):
            self.assertIn("EDITABLE_VIDEO_WORKFLOWS.md", (ROOT / path).read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
