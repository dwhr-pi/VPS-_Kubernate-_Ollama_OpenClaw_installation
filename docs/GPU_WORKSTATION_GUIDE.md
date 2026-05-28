# GPU Workstation Guide

## Ziel

GPU-Workstations sind fuer ComfyUI, Video-KI, lokale groessere Modelle, Blender und Benchmarks geeignet. Diese Pfade bleiben opt-in.

## Vor Installation pruefen

- GPU erkannt
- Treiber/CUDA/ROCm passend
- freier Speicher mindestens 50 GB
- RAM mindestens 16 GB, besser 32 GB
- Windows-C:-Speicher bei WSL2 ausreichend

## Nicht automatisch installieren

- grosse Modelle
- CUDA-Toolchains
- Blender Source Build
- Video-/Wan-/AnimateDiff-Pipelines

## Empfohlene Reihenfolge

1. Doctor und Preflight
2. Treiber pruefen
3. kleines Testmodell
4. ComfyUI ohne Zusatzmodelle
5. Modellordner und Cleanup-Konzept
