# AI Testing QA Lab

Status: `planned`  
Hardwarebedarf: `low` bis `medium`  
Installationsart: lokal, CI, WSL2, VPS

## Zweck

Automatisierte Tests fuer Agenten, Prompts, Modelle, Regressionen und Setup-Skripte.

## Kern-Tools

| Tool | Zweck | Status |
|---|---|---|
| pytest | Python-Tests | empfohlen |
| bats-core | Shell-Tests | geplant |
| shellcheck/shfmt | Shell-Qualitaet | empfohlen |
| Playwright | UI-/Browser-Tests | empfohlen |
| promptfoo | Prompt-Regressionen | empfohlen |
| deepeval | LLM-Evaluation | optional |

## Qualitaetsregeln

- Jeder neue Installer bekommt mindestens `bash -n` und einen Dry-Run-Check.
- Prompt-Tests duerfen keine echten API-Keys benoetigen.
- Kritische Profile bekommen Safety-Gate-Tests.
