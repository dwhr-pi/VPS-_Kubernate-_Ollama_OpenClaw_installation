"use strict";

const assert = require("node:assert/strict");
const { test } = require("node:test");
const { checkDocument, RETRY_DELAY_MS } = require("../scripts/quality/check_markdown_links.cjs");
const options = { aliveStatusCodes: [200, 206], ignorePatterns: [{ pattern: "^account$" }] };
const result = (link, statusCode, status = statusCode === 200 ? "alive" : "dead") => ({
  link,
  statusCode,
  status,
});

function fixture(responses) {
  const calls = [],
    delays = [],
    messages = [];
  return {
    calls,
    delays,
    messages,
    check: async (...args) => {
      calls.push(args);
      const response = responses[calls.length - 1];
      if (response instanceof Error) throw response;
      return response;
    },
    runtime: { wait: async (ms) => delays.push(ms), report: (message) => messages.push(message) },
  };
}

test("transport recovery reuses full document and exact options, bounded to two attempts", async () => {
  const f = fixture([
    [result("https://example.invalid/a", 0)],
    [result("https://example.invalid/a", 200)],
  ]);
  const markdown = "# Full document\n[Ref](https://example.invalid/a)\n";
  const actual = await checkDocument(markdown, options, f.check, f.runtime);
  assert.equal(actual[0].status, "alive");
  assert.equal(f.calls.length, 2);
  for (const args of f.calls) assert.deepEqual(args, [markdown, options]);
  assert.deepEqual(f.delays, [RETRY_DELAY_MS]);
});

test("a repeated transport failure remains failed after exactly one retry", async () => {
  const dead = result("https://example.invalid/a", 0);
  const f = fixture([[dead], [dead]]);
  assert.deepEqual(await checkDocument("text", options, f.check, f.runtime), [dead]);
  assert.equal(f.calls.length, 2);
});

test("HTTP errors, local files and ignored targets never trigger transport retry", async () => {
  for (const entry of [0, 202, 401, 403, 404, 429, 500, 503]
    .map((code) => result(code === 0 ? "missing.md" : "https://example.invalid/a", code))
    .concat([result("account", 0, "ignored")])) {
    const f = fixture([[entry]]);
    assert.deepEqual(await checkDocument("text", options, f.check, f.runtime), [entry]);
    assert.equal(f.calls.length, 1);
    assert.deepEqual(f.delays, []);
  }
});

test("retry of a mixed document cannot erase original 202, 403 or 404 failures", async () => {
  for (const code of [202, 403, 404]) {
    const fixed = result("https://example.invalid/retry", 0);
    const permanent = result("https://example.invalid/permanent", code);
    const f = fixture([
      [fixed, permanent],
      [result(fixed.link, 200), result(permanent.link, 200)],
    ]);
    const actual = await checkDocument("text", options, f.check, f.runtime);
    assert.equal(actual[0].status, "alive");
    assert.deepEqual(actual[1], permanent);
  }
});

test("missing or newly ignored retry results never clear a failure", async () => {
  const original = result("https://example.invalid/a", 0);
  for (const repeated of [[], [result(original.link, 0, "ignored")]]) {
    const f = fixture([[original], repeated]);
    assert.deepEqual(await checkDocument("text", options, f.check, f.runtime), [original]);
  }
});

test("a real HTTP error on the retry remains failed", async () => {
  const f = fixture([
    [result("https://example.invalid/a", 0)],
    [result("https://example.invalid/a", 403)],
  ]);
  const actual = await checkDocument("text", options, f.check, f.runtime);
  assert.equal(actual[0].status, "dead");
  assert.equal(actual[0].statusCode, 403);
});

test("errors and malformed successful statuses fail closed", async () => {
  for (const responses of [
    [new Error("parser failed")],
    [null],
    [[result("a", 202, "alive")]],
    [[result("a", 200), result("a", 200)]],
    [[{ link: "a", status: "unknown" }]],
  ]) {
    const f = fixture(responses);
    await assert.rejects(checkDocument("text", options, f.check, f.runtime));
  }
  const f = fixture([[result("https://example.invalid/a", 0)], new Error("retry parser failed")]);
  await assert.rejects(checkDocument("text", options, f.check, f.runtime));
  assert.equal(f.calls.length, 2);
});
