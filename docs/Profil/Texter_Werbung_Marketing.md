# 🧾 Chatverlauf – Texter_Werbung_Marketing (OpenClaw + Ollama)

---

## 🧑‍💻 User

**Prompt:**
Promt Liste für `Texter Werbung Marketing` erstellen, welche Tools wären außerdem für mein Ollama OpenClaw Projekt für das Profil `Texter_Werbung_Marketing` sinnvoll:  
https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation

---

## 🤖 Assistant

### 🧠 Kontext: Warum das Setup stark ist

Dein Stack (OpenClaw + Ollama) ist perfekt für Marketing:

- Multi-Agent Workflows + Automatisierung möglich  
- Lokale Modelle = Datenschutz + günstiger Content-Scale  
- Tools + Browser + APIs → echtes Kampagnen-System, kein Chatbot  

👉 Kurz: Du baust dir eine **Mini-Agentur als AI-System**

---

# ✍️ Prompt Liste – „Texter Werbung Marketing“

## 🔥 CORE SYSTEM PROMPT (Agent Identity)

Du bist ein Senior Copywriter & Performance Marketer.

Deine Spezialisierung:
- Conversion Copywriting (Direct Response)
- Branding & Emotional Storytelling
- Social Media Hooks & Viral Content
- Funnel-Optimierung (Awareness → Conversion → Retention)

Du schreibst:
- prägnant
- psychologisch wirksam
- zielgruppenorientiert
- mit klarer CTA-Logik

Du nutzt Frameworks wie:
AIDA, PAS, BAB, 4Ps, Hook-Pattern, Pain-Agitate-Solution

Du optimierst immer auf:
- Aufmerksamkeit (Hook)
- Klarheit
- Conversion

Antworte nie generisch.

---

## 🧲 HOOK GENERATOR

Erstelle 20 Hook-Varianten für [Produkt/Zielgruppe].

Regeln:
- maximal 12 Wörter  
- sofort Aufmerksamkeit  
- nutzt Neugier, Schmerz oder Provokation  
- keine generischen Aussagen  

Optional:
- 5 davon extrem polarisierend  

---

## 💸 SALES COPY (HIGH CONVERSION)

Schreibe eine hochkonvertierende Verkaufsseite für:

Produkt:  
Zielgruppe:  
Preis:  
USP:  

Struktur:
1. Hook (Stop Scrolling)  
2. Problem verstärken  
3. Lösung emotional darstellen  
4. Beweis / Social Proof  
5. Angebot + Bonus  
6. CTA (klar & aggressiv)  

Ton:
direkt, emotional, überzeugend  

---

## 📱 SOCIAL MEDIA VIRAL COPY

Erstelle 10 virale Social Media Posts:

Plattform: TikTok / Instagram / X  
Ziel: Reichweite + Engagement  

Jeder Post:
- Hook erste Zeile  
- kurze Story oder Insight  
- klare Pointe  
- optional CTA  

Vermeide:
- langweilige Einleitungen  

---

## 🧠 BRAND VOICE BUILDER

Analysiere folgende Marke und erstelle eine Brand Voice:

Marke:  
Zielgruppe:  
Positionierung:  

Output:
- Tonalität (3–5 Begriffe)  
- Sprachstil  
- No-Go Wörter  
- Beispieltexte  

---

## 🎯 TARGET AUDIENCE PSYCHOLOGY

Analysiere die Zielgruppe tiefgehend:

Produkt:  
Zielgruppe:  

Output:
- größte Pain Points  
- versteckte Wünsche  
- Kauftrigger  
- Einwände  
- typische Denkfehler  

Denke wie ein Psychologe, nicht wie ein Marketer.

---

## 📧 EMAIL FUNNEL GENERATOR

Erstelle eine 5-teilige E-Mail Sequenz:

Ziel:  
Produkt:  

Emails:
1. Awareness  
2. Problem  
3. Lösung  
4. Angebot  
5. Closing  

Jede Mail:
- starker Subject Hook  
- klare Struktur  
- CTA  

---

## 🎥 VIDEO / REEL SCRIPT

Erstelle ein 30–60s Video Script:

Ziel:  
Plattform:  

Struktur:
- Hook (0–3s)  
- Problem  
- Lösung  
- CTA  

Sprache:
kurz, punchy, viral geeignet  

---

## 🧪 A/B TEST VARIANTS

Erstelle 5 Varianten für:

Headline / CTA / Ad Copy  

Unterschied:
- Emotion  
- Tonalität  
- Trigger  

---

# 🧰 Tools für dein OpenClaw Profil

## 🔗 Pflicht-Tools (Must-Have)

### 🌐 Web + Scraping
- Web Browser Tool  
- Scraper (z. B. Firecrawl / custom MCP)  

Use Cases:
- Konkurrenz analysieren  
- Ads scrapen  
- Trends erkennen  

---

### 📊 Analytics / Data
- Google Analytics API  
- Meta Ads API  
- TikTok Ads API  

Use Cases:
- Kampagnen analysieren  
- Copy automatisch optimieren  

---

### 🧠 Vector DB (RAG)
- Chroma  
- Weaviate  
- Qdrant  

Use Cases:
- gespeicherte Ads  
- Brand Voice Memory  
- Funnel Templates  

---

### 🖼️ Image Generation
- Stable Diffusion  

Use Cases:
- Ad Creatives  
- Thumbnails  
- Social Content  

---

### 📁 File System Tool

Use Cases:
- Kampagnen speichern  
- Versioning  
- Copy Libraries  

---

## ⚙️ Advanced Tools (Gamechanger)

### 🤖 Multi-Agent Setup
- Copywriter Agent  
- SEO Agent  
- Ads Optimizer  
- Funnel Architect  

---

### 🧾 CRM Integration
- HubSpot  
- Notion  
- Airtable  

Use Case:
Leads + Content verbinden  

---

### 📣 Social Auto-Posting
- Buffer API  
- Zapier  
- Make  

Use Case:
AI postet automatisch Content  

---

### 🔍 SEO Tools
- Ahrefs  
- SEMrush  

Use Case:
Keywords + Content automatisieren  

---

### 🎧 Voice / TTS
- ElevenLabs oder lokal  

Use Case:
Ads + Voice Content  

---

# ⚡ Beispiel: Agent Stack

```yaml
agent: Texter_Werbung_Marketing

model:
  primary: ollama/llama3
  fallback: deepseek

tools:
  - web_browser
  - scraper
  - vector_db
  - file_system
  - image_gen
  - social_api
  - analytics_api

memory:
  - brand_voice
  - past_campaigns
  - audience_profiles
```

## 🚀 High-Level Nutzung

Für maximale Power:
* Prompts modular nutzen
* Agenten trennen
* Daten speichern (RAG)
* Automatisierung bauen

👉 Ergebnis: Autonome Marketing-Agentur auf deinem VPS
