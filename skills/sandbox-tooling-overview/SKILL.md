---
name: sandbox-tooling-overview
description: Build an evidence-based inventory of development tools and runtime capabilities, distinguishing discovered files, observed versions, functional tests and untested interview claims.
---

# Sandbox Tooling Overview

Use when comparing claimed sandbox capabilities with an actual development
environment or preparing a tooling readiness report. This repository copy
does not install or activate a global Grok skill.

## Workflow

1. Identify the target environment and task scope. Treat interview versions,
   foreign paths and claimed validation results as unverified evidence.
2. Inspect project manifests, lockfiles and permitted executable discovery.
   Do not start WSL or a container merely to discover tools in this setup.
3. Select only relevant probes within the authorized task. Discovery can use
   native PATH lookup; it does not execute a candidate. Inspect provenance
   before running version commands, imports, plugins or build scripts.
4. Record the exact probe, timestamp, scope, exit code and redacted evidence
   using the [report template](assets/capability-report.md). Do not expose
   tokens, full environment dumps or sensitive command output.
5. Separate found, observed, passed, failed, not-found and not-run.
   A PATH miss is not proof of absence outside the searched scope. A version
   response is not a successful build, browser test or deployment.
6. Report missing prerequisites without installing them implicitly. A failed
   probe is not permission to repair the host or contact external providers.

For existing installer paths consult the
[development toolchain guide](../../docs/tools/development-toolchain-check.md).
For interview corrections and source selection use the
[Grok guide](../../docs/tutorials/grok-development-tooling.md).

Return a compact inventory, evidence gaps and next checks. Prompt instructions
are not an OS sandbox; do not claim they enforce isolation or permissions.
