.DEFAULT_GOAL := help
PYTHON ?= python3

.PHONY: help plan check maintenance test-alert up down restart build clean update backup restore

help:
	@echo "OpenClaw: native Quellen, kein automatischer Start"
	@echo "make plan        - Offline-MCP-Plan"
	@echo "make check       - Begrenzte Offline-Regression"
	@echo "make maintenance - Beispiel einer begrenzten Silence, nur Plan"
	@echo "make test-alert  - Beispiel-Testalarm, nur Plan"
	@echo "Betrieb: docs/NATIVE_OPERATIONS_HANDBOOK.md"

plan:
	$(PYTHON) -B scripts/audio/openclaw_dejavu_mcp_server.py

check:
	$(PYTHON) -B -m unittest discover -s tests -p test_native_operations_bundle.py

maintenance:
	$(PYTHON) -B scripts/ops/alertmanager_maintenance.py silence --cluster example-cluster --namespace llmops --job dejavu

test-alert:
	$(PYTHON) -B scripts/ops/alertmanager_maintenance.py test-alert --cluster example-cluster --namespace llmops --job manual-test

# Never turn legacy start/delete names into silent no-op successes.
up down restart build clean update backup restore:
	@echo "Nicht implementiert/freigegeben. Kein Start, Cleanup oder Restore ausgefuehrt. Siehe docs/NATIVE_OPERATIONS_HANDBOOK.md"
	@exit 3
