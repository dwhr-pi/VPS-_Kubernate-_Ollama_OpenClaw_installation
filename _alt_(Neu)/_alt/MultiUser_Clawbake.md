## OpenClaw Multi-User-Erweiterungen: **Clawbake**

### **Die wichtigste Lösung: Clawbake**
Das Projekt **Clawbake** (von *NeurometricAI*) ist eine Open-Source-Erweiterung für das Instanz-Management von OpenClaw, die speziell für Teams und Multi-User-Szenarien entwickelt wurde.

*   **Individuelle Accounts:** Benutzer können sich über ein Web-Dashboard (z. B. via Google OIDC) einloggen.
*   **Eigene API-Daten:** Jeder Benutzer erhält eine eigene, isolierte OpenClaw-Instanz. Dort können sie ihre eigenen API-Keys (z. B. für Gemini, ChatGPT/OpenAI, Anthropic) hinterlegen, genau wie man es von den offiziellen Interfaces gewohnt ist.
*   **Unabhängige Gateway-Token:** Clawbake verwaltet für jede Instanz automatisch einen eigenen Gateway-Token. Die Instanzen sind durch Kubernetes-Namespaces und NetworkPolicies voneinander isoliert, sodass kein Benutzer Zugriff auf die Daten eines anderen hat.
*   **GitHub-Link:** [NeurometricAI/clawbake](https://github.com/NeurometricAI/clawbake)

### **Vergleich der Multi-User-Optionen**

| Feature | **Clawbake** (Empfohlen) | **users-for-openclaw** | **Standard OpenClaw** |
| :--- | :--- | :--- | :--- |
| **Konzept** | Multi-Instanz (K8s) | Skript-basierte Erweiterung | Einzelbenutzer-System |
| **API-Keys** | **Pro Benutzer (individuell)** | Meist geteilt (Shared) | Systemweit |
| **Gateway-Token** | **Pro Benutzer / Instanz** | Per-User Token möglich | Ein globaler Token |
| **Isolation** | Hoch (Namespace-Ebene) | Mittel (Session-Ebene) | Keine (Single User) |
| **Setup** | Komplex (Kubernetes) | Einfach (Shell-Skripte) | Einfach |

### **Weitere Alternativen**
1.  **rylena/users-for-openclaw:** Eine leichtere Lösung auf GitHub ([Link](https://github.com/rylena/users-for-openclaw)), die eine Multi-User-Logik in eine bestehende OpenClaw-Installation bringt. Sie bietet zwar separate Token pro Nutzer, ist aber primär darauf ausgelegt, dass die API-Credentials im Hintergrund geteilt werden.
2.  **JoySafeter:** Ein weiteres Projekt auf GitHub ([Link](https://github.com/jd-opensource/JoySafeter)), das einen Multi-Tenant-Proxy für OpenClaw bietet und ebenfalls auf Container-Isolation setzt.

**Fazit:** Wenn Sie eine Erfahrung wie bei ChatGPT oder Gemini suchen, bei der jeder Nutzer seine eigenen Keys verwaltet und einen eigenen Zugangstoken hat, ist **Clawbake** die derzeit ausgereifteste Open-Source-Lösung auf GitHub.
