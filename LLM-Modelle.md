### 🧠 Allgemeine Modelle (Chat / Allzweck)
|Modell 			|Beschreibung 											|Pull-Befehl						|Funktion|GB  -  RAM|
|:-----------------:|-------------------------------------------------------|-----------------------------------|--------|----------|
|Llama 3.2 – 1B 	|Leicht, gut für einfache Chat-Aufgaben 				|```ollama pull llama3.2:1b```		|Funktion|1,3   	|
|Llama 3.2 – 3B 	|Besser bei komplexeren Aufgaben, noch CPU-freundlich 	|```ollama pull llama3.2:3b```		|        |      	|
|Llama 3   – 8B 	|Starkes Allzweck-LLM, braucht etwas RAM 				|```ollama pull llama3:8b```		|Funktion|		 4,6|
|Llama 3.1 – 8B 	|Starkes Allzweck-LLM, braucht etwas RAM 				|```ollama pull llama3.1:8b```		|        |      	|
|Llama 3.1 – 70B 	|Sehr leistungsfähig, aber groß 						|```ollama pull llama3.1:70b```		|        |      	|
|Llama 3.3:latest 	|Neues Llama-3-Update (größere Kapazität) 				|```ollama pull llama3.3:latest```	|        |      	|

Meta-Modelle aus der Llama-Familie für verschieden große Parametergrößen		

### 💡 Effiziente Modelle für CPU-Only

Diese Modelle sind gut geeignet, wenn du nur auf CPU laufen willst und nicht riesige Mengen RAM hast:

|Modell 			|Beschreibung 								|Pull-Befehl					|Funktion|GB  -  RAM|
|:-----------------:|-------------------------------------------|-------------------------------|--------|----------|
|Phi 3 Mini (3.8B) 	|Leicht, gute Qualität für kleineren RAM 	|```ollama pull phi3```			|Funktion| 2,2 	 3,5|
|Gemma 2 – 2B 		|Sehr klein & flott 						|```ollama pull gemma2:2b```	|        |  	    |
|Gemma 2 – 9B 		|Starker Allzweck-CPU-freundlicher 			|```ollama pull gemma2:9b```	|        |    	  |
|Moondream 2 (1.4B)	|Superleicht & schnell 						|```ollama pull moondream```	|        |    	  |
|Starling (7B) 		|Solider Allzweck-Chatter 					|```ollama pull starling-lm```	|        |   	   |

Kleinere Modelle sind stark quantisiert und daher auf CPU deutlich performanter als riesige Gewichte.

### 👨‍💻 Spezielle Kategorien
|Modell 					|Zweck 											|Pull-Befehl					|Funktion|GB  -  RAM|
|:-------------------------:|-----------------------------------------------|-------------------------------|--------|----------|
|Code Llama (7B) 			|Für Code-Generierung 							|```ollama pull codellama```	|        |   		|
|Neural Chat (7B) 			|Chat-optimiert 								|```ollama pull neural-chat```	|        |      	|
|Mistral (7B) 				|Gute Allzweck-Leistung 						|```ollama pull mistral```		|        |      	|
|LLaVA / Vision-Varianten 	|Text + Bild-Verarbeitung (falls unterstützt) 	|```ollama pull llava```		|        |			|

Diese Kategorien dienen z. B. für Coding, multimodale Aufgaben oder spezialisierte Chat-Erlebnisse.

#### 💾 Installieren & Nutzen

Herunterladen/installieren (pull) des betreffenden Modells:
```bash
ollama pull <modellname>
```

Starten/ausprobieren des betreffenden Modells:
```bash
ollama run <modellname>
```

Alle installierten Modelle anzeigen:
```bash
ollama list
```

Entfernen des Modells, wenn es nicht mehr gebraucht wird:
```bash
ollama rm <modellname>
```
#### 🧠 Hardware-Hinweise (CPU-Only)

+👉 Kleinere Modelle (1–9B Parameter) sind auf CPU mit 8–16 GB RAM oft nutzbar.
+👉 Größere Modelle (70B+) benötigen deutlich mehr Speicher und laufen auf CPU-Only meist sehr langsam oder gar nicht praktikabel ohne große RAM-Reserve.





#### Speicherplatz?
##### 🧠 Schritt 1: Wie viel RAM hat WSL wirklich?

In deiner Ubuntu-WSL:
```
free -h
```
Oder:
```
cat /proc/meminfo
```
Wenn da z.B. nur 2 GB oder 3 GB stehen → Problem gefunden.

##### ⚙️ Schritt 2: Mehr RAM für WSL freigeben

Du kannst WSL manuell konfigurieren.

+ 1️⃣ Windows-Datei öffnen:
```
C:\Users\DEIN_NAME\.wslconfig
```

Falls sie nicht existiert → neu erstellen.

+ 2️⃣ Inhalt einfügen:
```
[wsl2]
memory=8GB
processors=4
swap=4GB
```
Halte Dich bei diesen Angaben an die des verwendeten PCs.  
Wie viel RAM Dein PC insgesamt hat.  
Wie viel Kerne (Prozessor) die CPU Deines PCs insgesamt hat. 

+ 👉 8GB ist ein guter Startwert für LLM
+ 👉 processors optional
+ 👉 swap hilft, falls RAM knapp wird

+ 3️⃣ WSL komplett neu starten

In PowerShell:
```
wsl --shutdown
```
Dann Ubuntu neu starten.
```
wsl
```


🔥 Danach nochmal testen
```
ollama run <modellname>
```


#### Quantenmodelle

Wenn du auf deinem MiniPC lokal (CPU-only) mit Ollama arbeiten willst, ist Quantisierung der Schlüssel, um Modelle überhaupt vernünftig laufen zu lassen – je niedriger die Bit-Tiefe, desto weniger RAM braucht das Modell. Hier sind praktische Varianten, wie du verschiedene Modelle gezielt mit Q4 / Q8 & Co. ausprobieren kannst 👇

#### 🧠 Was bedeutet Quantisierung?

Quantisierung reduziert die Präzision der Gewichte eines Modells, damit es weniger Speicher braucht:

+ Q4 (4-bit): sehr sparsam, meist default & flott ➝ gut für CPU-Only.
+ Q8 (8-bit): bessere Qualität, braucht mehr RAM als Q4.

Andere (Q5, Q6 etc.): mittlere Kompromisse zwischen RAM & Qualität (manchmal nur extern verfügbar).

### 📦 Modelle mit verschiedenen Quantisierungen
✅ Leicht & CPU-freundlich – Perfekt für MiniPC

Diese Modelle laufen auf CPUs am flüssigsten:

|Modell				| Quant-Variante	| Beschreibung					| Beispiel Pull							|
|:-----------------:|-------------------|-------------------------------|---------------------------------------|
| tinyllama (1.1B)	| q4_k_m oder q8_0	| Winziger LLM zum Testen	 	| ```ollama pull tinyllama:latest``` 	|
| gemma2:2b			| q4_k_m, q8_0		| Sehr kleine & schnelle 2 B	| ```ollama pull gemma2:2b```			|
| gemma2:9b			| q4_k_m, q8_0		| Besser als 2B, CPU-freundlich	| ```ollama pull gemma2:9b```			|
| mistral:7b		| q4_k_m, q8_0		| Starker Allzweck-LLM			| ```ollama pull mistral:7b```			|

👉 Diese Größen sind typischerweise gut geeignet, wenn du ~8–16 GB RAM hast.

### 🔎 mittlere Modelle (gut balanciert)

Mit etwas mehr RAM kannst du diese ausprobieren:

|Modell			| Quant-Variante	| Zweck					| Pull-Befehl 							|
|:-------------:|-------------------|-----------------------|---------------------------------------|
| llama3.3:8b	| q4_k_m oder q8_0	| Starker Allzweck-Chat	| ```ollama pull llama3.3:8b-q4_k_m```	|
| codellama:7b	| q4_k_m, q8_0		| Programmgenerierung	| ```ollama pull codellama:7b-q4_k_m```	|
| magicoder:7b	| q4_k_m, q8_0		| Code-LLM				| ```ollama pull magicoder:7b-q4_k_m```	|

👉 Diese Modelle bringen deutlich bessere Antworten, benötigen aber auch mehr RAM.


### 🧠 Größere Modelle (nur mit viel RAM)

Wenn du wirklich viel RAM hast (>24 GB), kannst du diese probieren – aber sie sind für CPU-Only meist langsam:

| Modell	        | Quant-Variante	| Nutzen          		|
|:-----------------:|-------------------|-----------------------|
| llama3.3:70b		| q4_k_m, q8_0		| Sehr mächtiges Modell	|
| starcoder2:15b	| q4_k_m, q8_0		| Großer Code-LLM		|

👉 Ohne GPU & viel RAM laufen diese eher träge oder schlagen bei großen Kontexten auf.




#### 🏁 Beispiel-Pull-Befehle

```
# kleines 1.1B Modell, Q4
ollama pull tinyllama:latest

# Gemma2 9B, Q4
ollama pull gemma2:9b-q4_k_m

# Mistral 7B, Q8 (etwas bessere Qualität)
ollama pull mistral:7b-q8_0

# Llama3.3 8B, Q4
ollama pull llama3.3:8b-q4_k_m
```

#### 🧠 Empfehlungen nach RAM-Budget

+ **💾 ~8 GB RAM**:
➡ tinyllama / gemma2:2b / gemma2:9b (Q4)

+ **🧠 ~12–16 GB RAM**:
➡ mistral:7b (Q4), llama3.3:8b-q4_k_m

+ **💡 >20 GB RAM**:
➡ größere Modelle wie llama3.3:70b (Q4) oder größere Code-LLMs 👀

#### 📌 Tipp für Ollama-Quant-Varianten

Auf der Ollama Modellseite kannst du bei jedem Modell auf „Tags“ klicken, um alle verfügbaren Quantisierungen zu sehen – z. B. q4, q5, q6, q8 etc. Dort stehen auch die jeweiligen Pull-Befehle.
[Quelle Reddit](https://www.reddit.com/r/LocalLLaMA/comments/1e9hju5/ollama_site_pro_tips_i_wish_my_idiot_self_had/?utm_source=chatgpt.com)

#### Weitere Varianten
Wenn du mir deine RAM-Angabe und CPU-Nummer automatisch ermitteln lässt, kann ich dir eine maßgeschneiderte Empfehlung geben, welche quantisierten Modelle bei dir am besten laufen sollten 💪!

Dazu befindet sich eine Hardware Autodetect-Funktion auf der nachfolgenden Homepage, die eine Auflistung sonstiger in Frage kommender LLM-Modelle für Ollama auflistet:  
[Ollama Modellseite](https://www.ollamamodels.com/?utm_source=chatgpt.com)





