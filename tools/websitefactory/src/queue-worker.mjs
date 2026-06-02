import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { generateProject } from "./generate-site.mjs";
import { ensureDir, writeText } from "./lib/utils.mjs";
import { nextPendingJob, queueLockFile, queueLogDir, updateJob } from "./queue-store.mjs";

const minFreeRamMb = Number(process.env.WEBSITEFACTORY_MIN_FREE_RAM_MB || 1024);
const maxLoadFactor = Number(process.env.WEBSITEFACTORY_MAX_LOAD_FACTOR || 0.85);
const maxFixRounds = Number(process.env.WEBSITEFACTORY_MAX_FIX_ROUNDS || 3);

function canStartJob() {
  const freeRamMb = Math.round(os.freemem() / 1024 / 1024);
  const cpuCount = Math.max(os.cpus().length, 1);
  const load = os.loadavg()[0] || 0;
  const loadLimit = cpuCount * maxLoadFactor;
  return { ok: freeRamMb >= minFreeRamMb && load <= loadLimit, freeRamMb, load, loadLimit };
}

async function run() {
  if (fs.existsSync(queueLockFile)) {
    console.log("Queue-Lock vorhanden. Ein anderer WebsiteFactory-Worker laeuft bereits.");
    process.exit(0);
  }

  const guard = canStartJob();
  if (!guard.ok) {
    console.log(`Queue-Wache aktiv. Freier RAM: ${guard.freeRamMb} MB, Load: ${guard.load.toFixed(2)} von ${guard.loadLimit.toFixed(2)} erlaubt.`);
    process.exit(1);
  }

  const job = nextPendingJob();
  if (!job) {
    console.log("Keine pending Jobs in jobs/queue.json.");
    process.exit(0);
  }

  ensureDir(queueLogDir);
  fs.writeFileSync(queueLockFile, String(process.pid), "utf8");
  const logPath = path.join(queueLogDir, `${job.id}.log`);

  try {
    updateJob(job.id, { status: "running", startedAt: new Date().toISOString() });
    writeText(logPath, `WebsiteFactory Job ${job.id}\nStatus: running\n`);

    const result = await generateProject({ brief: job.brief, outputDir: job.outputDir });

    updateJob(job.id, {
      status: "done",
      resultDir: result.outputDir,
      fixRoundsUsed: Math.min(maxFixRounds, 1),
      finishedAt: new Date().toISOString()
    });

    writeText(logPath, `WebsiteFactory Job ${job.id}\nStatus: done\nOutput: ${result.outputDir}\nFix-Rounds-Plan: max ${maxFixRounds}\n`);
  } catch (error) {
    updateJob(job.id, {
      status: "failed",
      retries: Number(job.retries || 0) + 1,
      error: error instanceof Error ? error.message : String(error),
      finishedAt: new Date().toISOString()
    });
    writeText(logPath, `WebsiteFactory Job ${job.id}\nStatus: failed\nError: ${error instanceof Error ? error.stack || error.message : String(error)}\n`);
    process.exitCode = 1;
  } finally {
    try {
      fs.unlinkSync(queueLockFile);
    } catch {
      // no-op
    }
  }
}

run();
