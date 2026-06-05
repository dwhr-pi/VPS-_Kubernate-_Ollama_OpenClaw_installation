# Agent Registry

## JARVIS Core

Responsibilities:

- planning
- delegation
- coordination
- safety checks
- memory routing

## Research Agent

Tasks:

- documentation lookup
- source comparison
- web research
- evidence summaries

Recommended local models:

- `qwen2.5`
- `deepseek-r1`

## Coding Agent

Tasks:

- code generation
- debugging
- refactoring
- tests and documentation

Recommended local models:

- `qwen2.5-coder`
- `deepseek-coder`

## DevOps Agent

Tasks:

- Docker diagnostics
- Kubernetes read-only inspection
- monitoring and logs
- VPS and homelab runbooks

Safety:

- no destructive cluster or host changes without approval

## Vision Agent

Tasks:

- OCR
- screenshots
- image analysis
- video frame notes

Recommended models:

- Qwen-VL class models where available

## Marketing Agent

Tasks:

- landing pages
- social posts
- SEO drafts
- newsletters

Safety:

- no automatic publishing

## Memory Agent

Tasks:

- PostgreSQL notes
- Qdrant vectors
- RAG ingestion
- retention policy checks

Safety:

- no sensitive memory without explicit category and retention rule
