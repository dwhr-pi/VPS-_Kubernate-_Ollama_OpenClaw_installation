"use strict";

// Test the installed CLI and repository runner using local files only.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { spawnSync } = require("node:child_process");

function main(cli) {
  assert(cli && path.isAbsolute(cli), "Absolute installed markdown-link-check CLI required");
  const executable = fs.realpathSync(cli);
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "link-check-contract-"));
  try {
    const good = path.join(directory, "good.md");
    const bad = path.join(directory, "bad.md");
    const config = path.join(directory, "config.json");
    fs.writeFileSync(good, "# Fixture\n\n[Local](good.md)\n");
    fs.writeFileSync(bad, "# Fixture\n\n[Missing](missing-fixture.md)\n");
    fs.writeFileSync(config, JSON.stringify({ ignorePatterns: [], aliveStatusCodes: [200, 206] }));
    for (const target of [executable, path.join(__dirname, "check_markdown_links.cjs")]) {
      for (const [files, expected] of [
        [[good], 0],
        [[bad], 1],
        [[bad, good], 1],
      ]) {
        const result = spawnSync(process.execPath, [target, "-c", config, ...files], {
          encoding: "utf8",
          timeout: 20000,
          shell: false,
        });
        assert.ifError(result.error);
        assert.equal(result.signal, null, "CLI terminated before reporting a result");
        assert.equal(
          result.status,
          expected,
          `Incorrect link-check exit status: ${result.stdout}${result.stderr}`,
        );
      }
    }
    console.log(
      "Link checker contract: live local file=0, missing file=1, mixed inputs=1; no HTTP",
    );
  } finally {
    // This private temporary fixture is created and owned solely by this process.
    fs.rmSync(directory, { recursive: true, force: true });
  }
}

if (require.main === module) main(process.argv[2]);
module.exports = { main };
