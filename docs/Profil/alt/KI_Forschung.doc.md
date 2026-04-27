# Chatverlauf – KI Forschung / OpenClaw / Ollama Setup

---

## 👤 User

Promt Liste für KI Forschung erstellen, welche Tools wären außerdem für mein Ollama OpenClaw Projekt für das Profil KI_Forschung sinnvoll:
https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation

---

## 🤖 Assistant

Sehr gutes Setup, das du da baust – **Ollama + OpenClaw + Kubernetes** ist im Prinzip schon eine halbe Research-Plattform 😄  
Ich geb dir jetzt **3 Dinge in einem Paket**:

---

# 🧠 1. Prompt-Liste für dein Profil **KI_Forschung**

Diese Prompts sind so gebaut, dass sie mit Agenten wie OpenClaw + Ollama gut funktionieren (inkl. Tool-Use / RAG / Automation).

---

## 🔍 A. Deep Research Prompts
```txt
SYSTEM:
Du bist ein KI-Forschungsassistent mit Zugriff auf lokale Modelle, Dokumente und Webdaten.

USER:
Analysiere das Thema: {THEMA}

Aufgaben:
1. Aktueller Stand der Forschung (2024–2026)
2. Key Papers & Durchbrüche
3. Offene Probleme
4. Zukunftstrends (3–5 Jahre)
5. Eigene Hypothesen / Ideen
```

📚 B. Paper-Analyse
```Plain text
Analysiere dieses Paper:

- Kurz-Zusammenfassung
- Methodik
- Stärken / Schwächen
- Reproduzierbarkeit
- Neuheit
```
⚡ C. Hypothesen Generator

```Plain text
Generiere 10 Forschungs-Hypothesen zu: {THEMA}
```

🔁 D. Self Improving Agent

```Plain text
Analysiere → löse → kritisiere → verbessere (3 Iterationen)
🧩 E. Multi Agent Debate
Plain text
Simuliere:
- Researcher
- Engineer
- Reviewer

Diskutiere: {THEMA}
```

📊 F. Vergleich Prompt

```Plain text
Vergleiche Modelle nach:
- Reasoning
- Speed
- Memory
- Kosten
```
🧠 G. RAG Knowledge Extraction
```Plain text
Extrahiere Key Insights + Knowledge Graph Struktur
```

## ⚙️ 2. Tools für dein OpenClaw / Ollama Setup

### 🧱 Core Stack
* LangChain → Agenten & Tool Use
* LlamaIndex → Dokumente / RAG
* Chroma / Weaviate → Vector DB

### 🧠 Agent Frameworks
* CrewAI
* AutoGPT

### 🧪 Research Tools
* MLflow
* Weights & Biases

### ⚡ Serving / Performance
* vLLM
* llama.cpp

### 🎨 Multimodal
* Whisper (Speech)
* Stable Diffusion (Image)

### 🧬 Advanced
* Ray (Scaling)
* EnviroLLM (Efficiency Tracking)

## 🧩 3. Architektur Upgrade
```Plain text
User → OpenClaw → LangChain/CrewAI → Ollama + RAG + Tools
```

### 🔥 Erweiterungen

RAG Layer
* PDFs
* GitHub
* Papers
Multi-Agent System
* Planner
* Researcher
* Critic
Auto Pipelines
* Topic → Research → Summary → Storage
