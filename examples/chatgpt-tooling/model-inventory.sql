-- Interview example: configuration records, not a live model status check.
CREATE TABLE ai_models (
    id INTEGER PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    backend VARCHAR(80) NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT FALSE
);

INSERT INTO ai_models (id, name, backend, enabled)
VALUES (1, 'Qwen', 'llama.cpp', TRUE);

SELECT name, backend
FROM ai_models
WHERE enabled = TRUE;
