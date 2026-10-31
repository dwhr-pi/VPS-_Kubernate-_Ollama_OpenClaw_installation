"use strict";

const fs = require("node:fs/promises");
const path = require("node:path");
const { pathToFileURL } = require("node:url");
const { promisify } = require("node:util");
const RETRY_DELAY_MS = 5000;

function validateResults(results, options) {
  if (!Array.isArray(results)) throw new Error("Missing link-check results");
  const links = new Set();
  for (const result of results) {
    if (
      !result ||
      typeof result.link !== "string" ||
      links.has(result.link) ||
      !["alive", "dead", "ignored"].includes(result.status)
    ) {
      throw new Error("Malformed or duplicate link-check result");
    }
    links.add(result.link);
    if (
      result.status === "alive" &&
      !(options.aliveStatusCodes || [200, 206]).includes(result.statusCode)
    ) {
      throw new Error("Unexpected successful HTTP status");
    }
  }
  return results;
}

async function checkDocument(
  markdown,
  options,
  check,
  { wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms)), report = console.log } = {},
) {
  const initial = validateResults(await check(markdown, options), options);
  const retry = new Set(
    initial
      .filter(
        (result) =>
          result.status === "dead" && result.statusCode === 0 && /^https?:\/\//.test(result.link),
      )
      .map((result) => result.link),
  );
  if (!retry.size) return initial;

  report(`Retrying ${retry.size} HTTP(S) transport failure(s) once after ${RETRY_DELAY_MS}ms`);
  await wait(RETRY_DELAY_MS);
  // Reuse the complete upstream parser and identical options, not a reduced URL parser.
  const repeated = new Map(
    validateResults(await check(markdown, options), options).map((result) => [result.link, result]),
  );
  return initial.map((result) => {
    if (!retry.has(result.link)) return result;
    const next = repeated.get(result.link);
    // A missing result or newly ignored target never clears the original failure.
    return next && next.status !== "ignored" ? next : result;
  });
}

async function main(args) {
  const [flag, configFile, ...files] = args;
  if (flag !== "-c" || !configFile || !files.length) {
    throw new Error("Usage: check_markdown_links.cjs -c CONFIG FILE [FILE ...]");
  }
  if (require("markdown-link-check/package.json").version !== "3.15.0") {
    throw new Error("Pinned markdown-link-check 3.15.0 is required");
  }
  const check = promisify(require("markdown-link-check"));
  const config = JSON.parse(await fs.readFile(configFile, "utf8"));
  let failed = false;
  for (const file of files) {
    const absolute = path.resolve(file);
    const options = {
      ...config,
      baseUrl: pathToFileURL(path.dirname(absolute)).href,
      projectBaseUrl: pathToFileURL(process.cwd()).href,
    };
    const results = await checkDocument(await fs.readFile(absolute, "utf8"), options, check);
    const dead = results.filter((result) => result.status === "dead");
    console.log(`FILE: ${file}: ${results.length} checked, ${dead.length} failed`);
    for (const result of dead) {
      console.error(`[FAIL] ${result.link} -> Status: ${result.statusCode}`);
    }
    if (dead.length) failed = true;
  }
  return failed ? 1 : 0;
}

if (require.main === module) {
  main(process.argv.slice(2))
    .then((code) => {
      process.exitCode = code;
    })
    .catch((error) => {
      console.error(`Link check failed: ${error.message}`);
      process.exitCode = 2;
    });
}
module.exports = { checkDocument, validateResults, RETRY_DELAY_MS, main };
