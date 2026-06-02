import path from "node:path";
import { fileURLToPath } from "node:url";
import { ensureDir, nowIso, readJson, writeJson } from "./lib/utils.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const rootDir = path.resolve(__dirname, "..");

export const queueFile = path.join(rootDir, "jobs", "queue.json");
export const queueLockFile = path.join(rootDir, "jobs", "queue.lock");
export const queueLogDir = path.join(rootDir, "jobs", "logs");

export function loadQueue() {
  return readJson(queueFile, { jobs: [] }) || { jobs: [] };
}

export function saveQueue(queue) {
  ensureDir(path.dirname(queueFile));
  writeJson(queueFile, queue);
}

export function addJob(payload) {
  const queue = loadQueue();
  const job = {
    id: `${Date.now()}`,
    status: "pending",
    retries: 0,
    createdAt: nowIso(),
    updatedAt: nowIso(),
    ...payload
  };
  queue.jobs.push(job);
  saveQueue(queue);
  return job;
}

export function updateJob(jobId, updates) {
  const queue = loadQueue();
  const job = queue.jobs.find((entry) => entry.id === jobId);
  if (!job) return null;
  Object.assign(job, updates, { updatedAt: nowIso() });
  saveQueue(queue);
  return job;
}

export function nextPendingJob() {
  const queue = loadQueue();
  return queue.jobs.find((entry) => entry.status === "pending") || null;
}
