# Prompt_Testing_Benchmark_Lab

## Zweck
Prompts, Agenten und Modellantworten reproduzierbar testen.

## Typische Aufgaben
- Promptfoo-Tests erstellen.
- Regressionsfaelle fuer Setup-Assistenten pflegen.
- Antwortqualitaet, Kosten und Latenz vergleichen.

## Empfohlene Tools
promptfoo, deepeval, pytest, LiteLLM, Langfuse, OpenLIT.

## Hardwarebedarf und Status
Hardware: leicht bis mittel. Status: planned. Installationsart: local, WSL2, VPS.

## Datenschutz und Sicherheit
Eval-Datensaetze duerfen keine echten Secrets enthalten. Externe Provider nur mit anonymisierten Testdaten.

## Beispiel-Prompt
`Baue einen Promptfoo-Test fuer unseren Installationsassistenten mit drei Fehlerfaellen und Erwartungskriterien.`

## Modelle
Ollama: `llama3.1:8b`, `qwen2.5:7b`. Cloud optional fuer Vergleichsmessungen.

## Grenzen
Tests ersetzen keine menschliche Freigabe fuer riskante Aktionen.
