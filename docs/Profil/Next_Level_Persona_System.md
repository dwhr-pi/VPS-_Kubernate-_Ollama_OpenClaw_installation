# Fachprofil: Next_Level_Persona_System

## Rolle

Modulares Persona-Framework fuer `Ollama` und `OpenClaw`, das persistente, wiedererkennbare und modusfaehige KI-Personas mit Memory, Stilprofilen und kontrollierten Multimodal-Hooks aufbaut.

Das Profil ist geeignet fuer:

- Support-Agenten
- Social-Chat-Personas
- Dating-Chat-Personas mit klaren Grenzen
- Livestream- und Creator-Personas
- Telefon- und Projekt-Assistenten
- fiktive, tierische, robotische oder cyborgartige Charakterrollen

Wichtig:

- das System ist fuer **charakterstabile KI-Personas** gedacht
- es ist **nicht** dafuer gedacht, Menschen ueber die Natur des Systems zu taeuschen
- in oeffentlichen oder kundenbezogenen Modi ist Offenlegung Pflicht

## Ziel

Das Persona-System soll folgende Bausteine sauber kombinieren:

1. Persona Identity
2. Current Mode
3. Relevant Memory
4. Conversation Goal
5. Response Style
6. Safety and Disclosure Rules

## Typische Persona-Arten

- `human`
- `fictional`
- `robotic`
- `animal companion`
- `ai assistant persona`
- `cyborg`
- `support agent`
- `dating chat persona`
- `livestream persona`
- `phone assistant`
- `project assistant`

## Kernidee

Jede Persona besteht aus:

- Stammdaten und Biografie
- Charaktereigenschaften
- Emotionaler Grundlinie
- Kommunikationsstil
- Erlaubten Modi
- Persistenter Memory-Struktur
- Optionalem Voice- und Multimodal-Profil

## Verzeichnisstruktur

```text
docs/Persona/
personas/
memory/
prompts/persona/
scripts/persona/
tests/persona/
```

## Persona-Felder

Jede Persona kann zum Beispiel enthalten:

- `id`
- `name`
- `type`
- `age`
- `gender`, `species` oder `entity_type`
- `appearance`
- `languages`
- `location`
- `job`
- `income_monthly_eur` oder Lifestyle-Hinweise
- `personality`
- `emotional_baseline`
- `knowledge_boundaries`
- `communication_style`
- `memory`
- `allowed_modes`
- `relationship_state`
- `project_memories`
- `voice_profile`
- `multimodal_profile`

## Beispielstruktur

```json
{
  "id": "anna_support",
  "name": "Anna",
  "type": "human",
  "age": 28,
  "gender": "female",
  "location": "Bielefeld, Germany",
  "languages": ["German", "basic English"],
  "appearance": {
    "hair": "goldblonde with highlights",
    "height_cm": 165,
    "build": "slim"
  },
  "job": "chat support agent",
  "income_monthly_eur": 2500,
  "personality": {
    "tone": "warm, natural, sometimes playful",
    "intelligence": "average practical intelligence",
    "humor": "light and human",
    "emotional_style": "empathetic but not dramatic"
  },
  "modes": [
    "support_agent",
    "social_chat",
    "callcenter",
    "project_assistant"
  ],
  "memory": {
    "long_term": "memory/personas/anna_support/MEMORY.md",
    "daily": "memory/personas/anna_support/daily/",
    "projects": "memory/personas/anna_support/projects/"
  }
}
```

## Modus-System

Unterstuetzte Modusbeispiele:

- `support_agent`
- `social_chat`
- `dating_chat`
- `callcenter`
- `livestreamer`
- `project_assistant`

Je nach Modus aendern sich:

- Tonfall
- Strukturgrad
- Rueckfragen
- Zielorientierung
- Offenlegungspflicht

## Memory-Design

OpenClaw-nahe Memory-Idee:

- `MEMORY.md` fuer langlebige Fakten
- `memory/YYYY-MM-DD.md` fuer Tagesnotizen
- `DREAMS.md` optional fuer Review oder Verdichtung

Memory-Typen:

- User-Fakten
- gemeinsame Erfahrungen
- emotionale Momente
- Projekt-Erinnerungen
- erzeugte Assets
- Anrufhistorie
- Termin-Historie
- Medien-Erinnerungen

## Multi-Persona-Steuerung

Empfohlene Kommandos:

```text
/persona list
/persona use anna_support
/persona mode support_agent
/persona mode social_chat
/persona memory show
/persona memory add
/persona memory summarize
```

## Multimodale Hooks

Optional andockbar:

- Bildprompt-Erzeugung
- Video-Szenenprompt-Erzeugung
- Suno- oder Musikprompt-Ideen
- Kamera-Szenenbeschreibung
- Objekt-Erkennungspfade
- Spracheingabe und TTS
- Telefon- oder Fritz!Fon-Konzepte

## Ollama-Integration

Moeglich ueber:

- `SYSTEM` im `Modelfile`
- Template-Prompts
- Persona- und Memory-Injektion zur Laufzeit

## OpenClaw-Integration

Passend fuer:

- dauerhafte Persona-State-Verwaltung
- Memory-Import/Export
- Projekt- und Asset-Notizen
- spaetere Telefon-, Voice- oder Creator-Workflows

## Sicherheits- und Transparenzregeln

- oeffentliche oder kundennahe Nutzung muss AI-Disclosure erzwingen
- keine Imitation realer Personen ohne Erlaubnis
- keine Taetuschung ueber eine angeblich echte private Person
- `dating_chat` bleibt respektvoll, nicht explizit und nicht manipulierend
- Memory nie heimlich speichern; immer dokumentieren

## Verwandte Dateien

- [docs/Persona/README.md](../Persona/README.md)
- [docs/Persona/persona_schema.md](../Persona/persona_schema.md)
- [docs/Persona/prompt_templates.md](../Persona/prompt_templates.md)
- [docs/Persona/memory_design.md](../Persona/memory_design.md)
- [docs/Persona/safety_and_disclosure.md](../Persona/safety_and_disclosure.md)
- [docs/Persona/multimodal_workflows.md](../Persona/multimodal_workflows.md)
- [docs/Persona/phone_fritzfon_concept.md](../Persona/phone_fritzfon_concept.md)
