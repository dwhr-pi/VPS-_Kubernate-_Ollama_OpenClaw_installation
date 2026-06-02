import fs from "node:fs";
import path from "node:path";
import { generateProject } from "./generate-site.mjs";
import { normalizeBrief } from "./lib/briefing.mjs";
import { addJob, loadQueue } from "./queue-store.mjs";

function parseArgs(argv) {
  const result = { _: [] };
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (token.startsWith("--")) {
      const key = token.slice(2);
      const next = argv[i + 1];
      if (!next || next.startsWith("--")) {
        result[key] = true;
      } else {
        result[key] = next;
        i += 1;
      }
    } else {
      result._.push(token);
    }
  }
  return result;
}

function readBrief(args) {
  if (args["brief-file"]) {
    return JSON.parse(fs.readFileSync(path.resolve(args["brief-file"]), "utf8"));
  }

  return {
    businessName: args["business-name"],
    industry: args.industry,
    audience: args.audience,
    style: args.style,
    pages: args.pages,
    cta: args.cta,
    colors: args.colors ? args.colors.split(",").map((entry) => entry.trim()).filter(Boolean) : undefined,
    language: args.language,
    offer: args.offer,
    prompt: args.prompt
  };
}

function printUsage() {
  console.log(`WebsiteFactory CLI

Commands:
  create
  queue-add
  queue-status
`);
}

async function main() {
  const [, , command, ...rest] = process.argv;
  const args = parseArgs(rest);

  switch (command) {
    case "create": {
      const brief = normalizeBrief(readBrief(args));
      const outputDir = args["output-dir"] ? path.resolve(args["output-dir"]) : undefined;
      const result = await generateProject({ brief, outputDir });
      console.log(`Projekt erzeugt: ${result.outputDir}`);
      break;
    }
    case "queue-add": {
      const brief = normalizeBrief(readBrief(args));
      const outputDir = args["output-dir"] ? path.resolve(args["output-dir"]) : path.resolve(process.cwd(), "generated-sites", brief.slug);
      const job = addJob({ brief, outputDir, type: "create-site" });
      console.log(`Queue-Job angelegt: ${job.id}`);
      break;
    }
    case "queue-status": {
      console.log(JSON.stringify(loadQueue(), null, 2));
      break;
    }
    default:
      printUsage();
      process.exit(command ? 2 : 0);
  }
}

main();
