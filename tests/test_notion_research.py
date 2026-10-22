"""Offline checks for the bounded Notion review exporter; no credentials needed."""
import contextlib
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import Mock, patch
from urllib.error import HTTPError, URLError


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("notion_research", ROOT / "scripts/notion_research.py")
n = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(n)
PID = "11111111-1111-4111-8111-111111111111"
CID = "22222222-2222-4222-8222-222222222222"


def block(text="hello", kind="paragraph", **extra):
    return {"id": CID, "type": kind, kind: {"rich_text": [{"plain_text": text}]}, **extra}


def page(**extra):
    return {"id": PID, "title": "Example", "blocks": [block()], **extra}


def listing(results=(), more=False, cursor=None):
    return {"results": list(results), "has_more": more, "next_cursor": cursor}


class Opener:
    def __init__(self, *responses):
        self.responses = iter(responses)
        self.calls = []

    def open(self, req, timeout):
        self.calls.append((req, timeout))
        response = next(self.responses)
        if isinstance(response, Exception):
            raise response
        return io.BytesIO(response if isinstance(response, bytes) else json.dumps(response).encode())


class NotionResearchTests(unittest.TestCase):
    def test_ids_reject_urls_and_normalize(self):
        self.assertEqual(n.notion_id(PID.replace("-", "").upper()), PID)
        for value in ("https://notion.site/" + PID, "../../escape", "bad", "g" * 32):
            with self.subTest(value=value), self.assertRaises(n.ExportError):
                n.notion_id(value)

    def test_default_and_explicit_plan_do_not_fetch_or_write(self):
        with tempfile.TemporaryDirectory() as tmp, patch.object(n, "Client") as client:
            dest = Path(tmp) / "not-created"
            for args in (["--page", PID], ["--search-title", "Agent", "--dry-run"],
                         ["--snapshot-json", "absent.json", "--dry-run"]):
                with contextlib.redirect_stdout(io.StringIO()):
                    self.assertEqual(n.main([*args, "--output", str(dest)]), 0)
            client.assert_not_called()
            self.assertFalse(dest.exists())

    def test_cli_bounds_and_mutually_exclusive_actions(self):
        for args in (["--page", PID, "--max-pages", "51"],
                     ["--search-title", "x"],
                     ["--snapshot-json", "a.json", "--fetch"],
                     ["--page", PID, "--fetch", "--dry-run"]):
            with self.subTest(args=args), contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
                n.main(args)

    def test_token_validation(self):
        for token in ("", " ", "secret\ninjected", "secret\rheader"):
            with self.assertRaises(n.ExportError):
                n.Client(token)

    def test_request_fixed_host_version_timeout(self):
        opener = Opener({"object": "page"})
        client = n.Client("test-secret", opener=opener)
        client.request("GET", "/pages/" + PID)
        req, timeout = opener.calls[0]
        self.assertEqual(req.full_url, n.API + "/pages/" + PID)
        self.assertEqual(req.get_header("Authorization"), "Bearer test-secret")
        self.assertEqual(req.get_header("Notion-version"), n.VERSION)
        self.assertEqual(timeout, 15)

    def test_write_routes_and_foreign_hosts_blocked(self):
        opener = Opener()
        client = n.Client("test", opener=opener)
        for method, route in (("PATCH", "/pages/" + PID), ("POST", "/pages"),
                              ("GET", "https://evil.example/"), ("GET", "/users/me")):
            with self.assertRaises(n.ExportError):
                client.request(method, route)
        self.assertEqual(opener.calls, [])

    def test_redirect_rejected(self):
        with self.assertRaises(n.ExportError):
            n.NoRedirect().redirect_request(None, None, 302, "redirect", {}, "https://evil.example")

    def test_pagination_get_and_post(self):
        for method, path in (("GET", "/blocks/" + PID + "/children"), ("POST", "/search")):
            opener = Opener(listing([1], True, "cursor-one"), listing([2]))
            client = n.Client("test", opener=opener)
            self.assertEqual(list(client.paginated(method, path, {"query": "title"})), [1, 2])
            req = opener.calls[1][0]
            if method == "GET":
                self.assertIn("start_cursor=cursor-one", req.full_url)
            else:
                self.assertEqual(json.loads(req.data)["start_cursor"], "cursor-one")
                self.assertEqual(json.loads(req.data)["query"], "title")

    def test_bad_and_repeated_cursors_abort(self):
        for responses in ((listing([], True),),
                          (listing([], True, "same"), listing([], True, "same")),
                          ({"results": "invalid", "has_more": False},)):
            with self.assertRaises(n.ExportError):
                list(n.Client("test", opener=Opener(*responses)).paginated("POST", "/search"))

    def test_pagination_and_request_budgets(self):
        responses = [listing([], True, str(i)) for i in range(20)]
        with self.assertRaisesRegex(n.ExportError, "Pagination-Limit"):
            list(n.Client("test", opener=Opener(*responses)).paginated("POST", "/search"))
        client = n.Client("test", max_requests=1, opener=Opener({}, {}))
        client.request("POST", "/search")
        with self.assertRaisesRegex(n.ExportError, "Request-Limit"):
            client.request("POST", "/search")

    def test_429_bounded_retry(self):
        error = HTTPError(n.API, 429, "rate", {"Retry-After": "2"}, None)
        opener = Opener(error, {"ok": True})
        with patch.object(n.time, "sleep") as sleep:
            self.assertTrue(n.Client("test", opener=opener).request("POST", "/search")["ok"])
            sleep.assert_called_once_with(2)
        opener = Opener(error, error, error)
        with patch.object(n.time, "sleep") as sleep, self.assertRaisesRegex(n.ExportError, "429"):
            n.Client("test", opener=opener).request("POST", "/search")
        self.assertEqual(sleep.call_count, 2)

    def test_retry_after_and_errors_do_not_leak_secrets(self):
        for error in (HTTPError(n.API, 429, "test-secret", {"Retry-After": "61"}, None),
                      HTTPError(n.API, 403, "test-secret", {}, None),
                      URLError("test-secret"), TimeoutError("test-secret")):
            with self.subTest(error=error), self.assertRaises(n.ExportError) as caught:
                n.Client("test-secret", opener=Opener(error)).request("POST", "/search")
            self.assertNotIn("test-secret", str(caught.exception))

    def test_response_shape_json_and_size_limits(self):
        for response in ([], b"invalid-json", b"x" * (2 * 1024 * 1024 + 1)):
            with self.assertRaises(n.ExportError):
                n.Client("test", opener=Opener(response)).request("POST", "/search")
        client = n.Client("test", opener=Opener({}))
        client.bytes = 16 * 1024 * 1024
        with self.assertRaises(n.ExportError):
            client.request("POST", "/search")

    def test_rich_text_and_titles(self):
        self.assertEqual(n.rich_text([{"text": {"content": "one"}}, {"plain_text": "two", "text": None}]), "onetwo")
        self.assertEqual(n.page_title({"properties": {"Name": {"type": "title", "title": [{"plain_text": "Title"}]}}}), "Title")
        for data in (None, [None], [{"text": None}], [{"plain_text": 5}]):
            with self.assertRaises(n.ExportError):
                n.rich_text(data)

    def test_recursive_tree_and_cycle_budget(self):
        client = Mock()
        client.paginated.side_effect = [[block("parent", has_children=True)], [block("child")]]
        tree = n.read_tree(client, PID, [2])
        self.assertEqual(tree[0]["children"][0]["paragraph"]["rich_text"][0]["plain_text"], "child")
        for budget, depth, ancestors in (([0], 0, ()), ([10], 9, ()), ([10], 0, (PID,))):
            client.paginated.side_effect = None
            client.paginated.return_value = [block()]
            with self.assertRaises(n.ExportError):
                n.read_tree(client, PID, budget, depth, ancestors)

    def test_render_escape_code_and_unsupported_warning(self):
        warnings = set()
        blocks = [block('![remote](https://evil.example/x) <script>x</script>'),
                  block('```\nprint("kept")', "code"), {"type": "image", "image": {}}]
        rendered = n.render_blocks(blocks, warnings)
        self.assertIn(r"\!\[remote\]\(", rendered)
        self.assertIn("&lt;script&gt;", rendered)
        self.assertIn('````\n```\nprint("kept")\n````', rendered)
        self.assertTrue(any("image" in warning for warning in warnings))
        self.assertNotIn("<script>", rendered)

    def test_missing_children_depth_and_block_limits(self):
        for blocks, budget, depth in (([block(has_children=True)], [5], 0),
                                      ([block()], [0], 0), ([], [5], 9)):
            with self.assertRaises(n.ExportError):
                n.render_blocks(blocks, set(), budget, depth)

    def test_collect_search_filter_and_limits(self):
        client = Mock()
        client.paginated.side_effect = [iter([{"object": "page", "id": PID}]), iter([])]
        self.assertEqual(n.collect(client, "search", "Agent", 1)[0]["id"], PID)
        args = client.paginated.call_args_list[0].args
        self.assertEqual(args[2]["filter"], {"value": "page", "property": "object"})
        client.paginated.side_effect = None
        client.paginated.return_value = [{"object": "page", "id": PID}]
        with self.assertRaises(n.ExportError):
            n.collect(client, "search", "Agent", 0)

    def test_publish_manifest_safe_names_and_separate_runs(self):
        with tempfile.TemporaryDirectory() as tmp:
            first = n.publish([page(title="../../outside\n![x](https://evil.example)")], tmp)
            second = n.publish([page()], tmp)
            self.assertNotEqual(first, second)
            manifest = json.loads((first / "manifest.json").read_text())
            self.assertTrue(manifest["review_required"])
            self.assertFalse(manifest["auto_indexed"])
            self.assertEqual(manifest["source_mode"], "offline_snapshot")
            self.assertIsNone(manifest["fetched_at"])
            self.assertIn("exported_at", manifest)
            entry = manifest["pages"][0]
            self.assertEqual(entry["file"], PID.replace("-", "") + ".md")
            raw = (first / entry["file"]).read_bytes()
            self.assertEqual(entry["sha256"], hashlib.sha256(raw).hexdigest())
            self.assertTrue(entry["source_url"].startswith("https://www.notion.so/"))
            self.assertIn(b"Ungepruefte externe Quelle", raw)
            self.assertEqual(len(list(Path(tmp).iterdir())), 2)

    def test_duplicate_invalid_pages_leave_no_output(self):
        with tempfile.TemporaryDirectory() as tmp:
            output = Path(tmp) / "absent"
            for pages in ([page(), page()], [page(title=None)], [page(blocks=None)]):
                with self.assertRaises(n.ExportError):
                    n.publish(pages, output)
                self.assertFalse(output.exists())

    def test_api_provenance_records_fetch_completion(self):
        with tempfile.TemporaryDirectory() as tmp:
            output = n.publish([page()], tmp, source_mode="api")
            manifest = json.loads((output / "manifest.json").read_text())
            self.assertEqual(manifest["source_mode"], "api")
            self.assertEqual(manifest["fetched_at"], manifest["exported_at"])

    def test_repository_and_filesystem_root_rejected(self):
        for target in (ROOT, ROOT / "do-not-create", Path(ROOT.anchor)):
            with self.assertRaises(n.ExportError):
                n.publish([], target)

    def test_failed_write_cleans_only_own_stage(self):
        with tempfile.TemporaryDirectory() as tmp:
            keep = Path(tmp) / "keep.txt"
            keep.write_text("keep")
            with patch.object(n.Path, "write_bytes", side_effect=OSError("full")), self.assertRaises(OSError):
                n.publish([page()], tmp)
            self.assertEqual(list(Path(tmp).iterdir()), [keep])
            self.assertEqual(keep.read_text(), "keep")

    def test_snapshot_example_runs_without_client(self):
        with tempfile.TemporaryDirectory() as tmp, patch.object(n, "Client") as client:
            with contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(n.main(["--snapshot-json", str(ROOT / "examples/notion-research/sample.json"), "--output", tmp]), 0)
            client.assert_not_called()
            self.assertEqual(len(list(Path(tmp).glob("review-*/manifest.json"))), 1)

    def test_fetch_failure_never_publishes(self):
        with patch.object(n, "Client"), patch.object(n, "collect", side_effect=n.ExportError("failed")), patch.object(n, "publish") as publish:
            with self.assertRaises(n.ExportError):
                n.main(["--page", PID, "--fetch"])
            publish.assert_not_called()

    def test_documentation_links_and_boundaries(self):
        doc = (ROOT / "docs/tools/notion-research.md").read_text(encoding="utf-8")
        for text in ("2026-03-11", "--fetch", "--snapshot-json", "data_sources", "notion.com/templates/category/ai"):
            self.assertIn(text, doc)
        for path in ("docs/TOOLS_CATALOG.md", "docs/TOOL_INDEX.md", "docs/tools/ruflo.md"):
            self.assertIn("notion-research.md", (ROOT / path).read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
