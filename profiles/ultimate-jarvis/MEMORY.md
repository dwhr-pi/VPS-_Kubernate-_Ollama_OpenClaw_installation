# Memory Strategy

## Short Term

- OpenClaw session state
- current task context
- temporary scratch notes

## Medium Term

- PostgreSQL tables for tasks, preferences and audit notes

## Long Term

- Qdrant collections for embeddings and RAG

## Document Memory

Sources:

- Git repositories
- Markdown
- PDFs
- Office documents
- websites

## Retention

Default retention is conservative:

- test data can be deleted anytime
- private data needs explicit category
- sensitive data requires encryption and a deletion path

## Forbidden Defaults

- no unlimited retention for secrets
- no private mail ingestion without explicit consent
- no automatic memory of passwords, tokens or private keys
