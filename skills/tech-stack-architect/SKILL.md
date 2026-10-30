---
name: tech-stack-architect
description: Prepare architecture decisions and project-specific Go or Rust CI and deployment proposals from an existing repository, with explicit validation gaps and release boundaries.
---

# Tech Stack Architect

Adapted from the user-supplied Gemini interview. This is a repository skill, not a globally
installed Gemini extension or a registered slash command.

## Architecture and delivery preparation

1. Inspect the target repository, manifests, existing CI and deployment model. Establish language,
   architecture, runtime dependencies and acceptance criteria.
2. Record the decision, alternatives, data flow, resource assumptions and evidence needed. Avoid
   selecting several equivalent frameworks by default.
3. For Go or Rust CI, adapt the appropriate
   [inactive examples](../../examples/manus-ci-cd/README.md), not the interview's old version pins.
   Keep tests and artifact generation separate from publishing.
4. For container proposals, check static/dynamic linking, libc, architecture, certificates, non-root
   operation and writable paths. Non-root application execution alone does not establish a rootless
   daemon.
5. For Kubernetes proposals, specify measured requests/limits, suitable probes, shutdown behavior,
   secret handling and exposure. Limits do not prevent OOM.
6. Leave unavailable image digests, domains and credentials explicitly unresolved. Do not invent
   production values to satisfy a request for complete examples.
7. Validate what the task permits and record commands, exit codes and gaps. Syntax/schema checks are
   not successful builds or production deployment.

The interview labels /ci-cd, /dockerize and /k8s-manifest describe task types, not automatically
available client commands. Activating workflows, publishing images, changing clusters or installing
tools requires task-specific scope. Do not access WSL for this documentation workflow.

Use the [Gemini guide](../../docs/tutorials/gemini-development-tooling.md) for source attribution
and corrections. Deliver a proposal or reviewed patch, validation results and outstanding
prerequisites, not an unsupported claim of production readiness.
