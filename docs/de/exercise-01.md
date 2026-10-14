# Aufgabe 1 – Die Engine zum Laufen bringen

> **Voraussetzung:** Aufgabe 0 ist abgeschlossen (der Sollprozess liegt fachlich vor).
> **Arbeitsverzeichnis:** `services/process-application`
> **Neu in dieser Aufgabe:** Operaton-Starter, Engine-Konfiguration, Embedded-Datenbank (H2), Auto-Deployment, Cockpit, H2-Konsole, `act_*`-Tabellen, Start-Formular, Manual Task, EnterpriseGlue The Bridge (optionale zusätzliche UI).

## Darum geht es

In Aufgabe 0 hast du den **kompletten Sollprozess** des Inner Circle modelliert. Bevor jemand den
ganzen Ablauf automatisiert, hat ein externer Consultant einen **bewusst winzigen ersten Ausschnitt**
grob aufgesetzt: ein Start-Formular für die Anmeldedaten, danach zwei **Manual Tasks** –
„Confirm" und „Send welcome mail". Manual Tasks sind Platzhalter: Die Engine läuft einfach durch
sie hindurch. So bekommst du eine Prozessinstanz, die von vorne bis hinten durchläuft – ohne eine
Zeile Code.

Diese Mini-Fassung ist **nicht** der Sollprozess und **nicht** das Zielmodell. Sie existiert nur,
um die Engine überhaupt einmal zu starten und ein Gefühl für Deployment, Ausführung und den
Datenbestand zu bekommen. Ab Aufgabe 2 baust du die Platzhalter Stück für Stück zu echten
Schritten aus.

Was jetzt fehlt, ist die **Laufzeitumgebung**: ein Spring-Boot-Modul, in dem die Operaton-Engine
läuft. Genau das richtest du jetzt ein.

## Lernziele

Nach dieser Aufgabe kannst du

- ein Spring-Boot-Modul mit eingebetteter Operaton-Engine lauffähig machen,
- benennen, was die Engine zum Starten braucht (Datenbank, Auto-Configuration, Auto-Deployment),
- dich im Cockpit zwischen Processes, Tasklist und Admin bewegen,
- die `act_*`-Tabellen den Kategorien Repository, Runtime und History zuordnen,
- eine Instanz über ein **Start-Formular** in der Tasklist starten,
- erklären, warum eine Instanz mit lauter **Manual Tasks** ohne Anhalten durchläuft.

## Ziel-Modell

![BPMN-Modell der Aufgabe](../assets/exercise-01.svg)

Das ist der bewusst reduzierte Ausschnitt: Start-Formular → Manual Task „Confirm" → Manual Task
„Send welcome mail" → Ende. Er liegt fertig unter
`services/process-application/src/main/resources/bpmn/membership.bpmn`. Du modellierst in dieser
Aufgabe nichts – du bringst ihn zum Laufen.

## Aufgabe

> Es geht ums **Einrichten und Kennenlernen** – kein Business-Code.

### 1. Dependencies aktivieren

Öffne `services/process-application/pom.xml` und kommentiere den Block `TODO Exercise 1` ein: die
beiden Operaton-Starter (`webapp` und `rest`). Erst damit sind Engine, Cockpit-Webapp und
REST-API im Modul. Die Versionen kommen zentral aus der Root-`pom.xml` – trage sie **ohne**
`<version>` ein.

### 2. Konfiguration aktivieren

Die Engine speichert ihren gesamten Zustand in einer relationalen Datenbank. Im Training ist das
eine **H2-Datenbank**, die direkt in der Anwendung mitläuft und ihre Daten in einer Datei unter
`~/.operaton-training/` ablegt. Du musst nichts installieren und nichts separat starten: H2 legt
die Datei beim ersten Start an, die Engine erzeugt darin ihre `act_*`-Tabellen selbst.

Kommentiere in `services/process-application/src/main/resources/application.yaml` den Block
`TODO Exercise 1` ein. Er enthält:

- die Datenbank-Anbindung an die H2-Datei (`jdbc:h2:file:~/.operaton-training/exercise`, Benutzer
  `sa`, leeres Passwort),
- die **H2-Konsole** – eine SQL-Oberfläche im Browser, die Teil der Anwendung ist; du brauchst sie
  in Schritt 5,
- den Cockpit-Admin-User (`admin` / `admin`).

Fehlt der Block, startet die Anwendung trotzdem – nur nicht so, wie du sie brauchst: Spring Boot
weicht von sich aus auf eine flüchtige In-Memory-H2 aus. Die Engine legt dann keinen Admin-User an,
und statt der Anmeldung leitet das Cockpit auf die Seite **Operaton Setup** der Admin-App um, die
einen ersten User anlegen will. Die H2-Konsole ist beim Start per `mvnw` abgeschaltet
(`/h2-console` liefert 404), und nach einem Neustart sind alle Daten weg.

> **Begriff: Embedded-Datenbank** (eingebettete Datenbank). Eine Datenbank, die als Bibliothek
> **im selben Prozess** wie die Anwendung läuft statt als eigener Server. Sie startet und stoppt mit
> der Anwendung; weil H2 hier in eine Datei schreibt, übersteht der Datenbestand trotzdem einen
> Neustart. Embedded heißt nicht In-Memory: Eine In-Memory-Datenbank hält alles nur im
> Arbeitsspeicher – so wie die Ausweich-H2, wenn der Block fehlt, oder die Test-Datenbank ab
> Aufgabe 6.

### 3. Anwendung scharf schalten

Aktiviere in `TrainingApplication.java` die auskommentierten Annotationen
**`@SpringBootApplication`** und **`@EnableJpaRepositories`**. Erst dadurch greifen
Auto-Configuration und das automatische BPMN-Deployment: Alle `*.bpmn` unter `src/main/resources`
werden beim Start in die Engine deployt.

### 4. Anwendung starten

Jetzt kommt alles zusammen. Beobachte das Log – es zeigt, wie die Auto-Configuration die Engine
hochfährt und die BPMN-Datei deployt.

```bash
cd services/process-application && ../../mvnw spring-boot:run
```

Achte im Log auf diese Zeile – sie zeigt, dass die Konfiguration aus Schritt 2 greift und die
Engine auf der H2-Datei läuft:

```
H2 console available at '/h2-console'. Database available at 'jdbc:h2:file:~/.operaton-training/exercise'
```

Steht dort `jdbc:h2:mem:…` statt der Datei oder fehlt die Zeile ganz, ist der Block aus Schritt 2
nicht aktiv.

### 5. Die Tabellen der Engine ansehen

Beim ersten Start hat die Engine ihr Datenmodell selbst angelegt: mehrere Dutzend Tabellen mit dem
Präfix `act_`. Sieh sie dir in der H2-Konsole an, die in der laufenden Anwendung steckt:

1. Öffne [http://localhost:8080/h2-console](http://localhost:8080/h2-console). Die Einstellung
   **Generic H2 (Embedded)** bleibt unverändert.
2. Ersetze im Feld **JDBC URL** den vorbelegten Wert `jdbc:h2:~/test` durch
   `jdbc:h2:file:~/.operaton-training/exercise` – sonst sucht die Konsole eine Datenbank, die es
   nicht gibt. Nach dem ersten erfolgreichen Login merkt sich die Konsole die URL.
3. Lass den Benutzer auf `sa`, das Passwort leer und klicke **Connect**.

In der linken Spalte listet die Konsole jetzt die Tabellen auf (H2 schreibt ihre Namen groß, in SQL
ist die Schreibweise egal). Diese fünf Tabellen sind die wichtigsten:

| Tabelle | Präfix | Inhalt |
|---|---|---|
| `act_re_procdef` | `re` = Repository | deployte **Prozessdefinitionen** (`subscribeNewsletter`) |
| `act_ru_execution` | `ru` = Runtime | **laufende** Prozessinstanzen |
| `act_ru_task` | `ru` | offene **User Tasks** |
| `act_ru_variable` | `ru` | **Prozessvariablen** laufender Instanzen |
| `act_hi_procinst` | `hi` = History | **abgeschlossene** Prozessinstanzen |

Prüfe zum Einstieg, ob dein Modell deployt wurde. Tippe die Abfrage ins Eingabefeld der Konsole und
klicke **Run**:

```sql
SELECT key_, name_, version_ FROM act_re_procdef;
```

Bei einer frischen Datenbank ist das Ergebnis eine Zeile mit `subscribeNewsletter`,
`Join Inner Circle` und Version `1`. Stehen dort mehr Zeilen oder höhere Versionen, lief schon ein
anderes Modul auf derselben Datei – die Prozessdefinitionen aller Module sammeln sich darin (wie du
sie zurücksetzt, steht unter **Hinweise**).

### 6. Cockpit erkunden

Das Cockpit ist die Weboberfläche der Engine. Öffne
[http://localhost:8080/operaton/app/cockpit/](http://localhost:8080/operaton/app/cockpit/)
(admin / admin). Unter **Processes** erscheint `Join Inner Circle` – der Anzeigename des Modells;
der technische Prozess-Key dahinter ist `subscribeNewsletter`. Klick dich durch **Cockpit**,
**Tasklist** und **Admin**.

### 7. Prozess durchspielen

Der Prozess ist deployt, aber noch nie gelaufen. Starte ihn über das Start-Formular:

1. **Tasklist** → **Start process** → `Join Inner Circle`
2. Es erscheint ein **Start-Formular** mit den Feldern `email`, `name`, `age`. Fülle es aus und
   starte.
3. Die Instanz läuft **ohne anzuhalten** bis zum Ende durch – beide Manual Tasks werden von der
   Engine einfach durchlaufen.
4. Prüfe das Ergebnis in der H2-Konsole mit diesen drei Abfragen:

   ```sql
   SELECT proc_def_key_, state_ FROM act_hi_procinst;
   SELECT COUNT(*) FROM act_ru_execution;
   SELECT COUNT(*) FROM act_ru_task;
   ```

   Die erste zeigt deine Instanz mit `COMPLETED`, die beiden anderen liefern `0`: Laufende
   Prozessinstanzen und offene Tasks gibt es keine mehr.

> **Begriff: Start-Formular (Generated Form).** Die Felder `email`/`name`/`age` stehen als
> `camunda:formData` direkt am Start Event. Die Tasklist rendert daraus beim Starten automatisch
> ein Formular – keine zusätzliche Datei, kein HTML. Die eingegebenen Werte werden zu
> Prozessvariablen der Instanz.

> **Begriff: Manual Task.** Ein Task, den die Engine **nicht** ausführt und an dem sie **nicht**
> wartet – sie läuft einfach hindurch. Ein Platzhalter für „hier passiert später etwas". Deshalb
> durchläuft die Instanz das Modell auf einen Schlag. Ab Aufgabe 2 wird der erste Platzhalter zu
> einem echten User Task.

### 8. Optional: EnterpriseGlue The Bridge verbinden

Die Bridge ist eine zusätzliche Weboberfläche für die Engine: Hier lassen sich Prozesse
modellieren, deployen und verwalten – ergänzend zum Cockpit. Keine Aufgabe setzt sie voraus –
alles Nötige erledigst du im Cockpit. Dieser Schritt ist der einzige im Training, für den du Docker
brauchst: Die Bridge läuft in Docker-Containern, die `stack/docker-compose.yml` beschreibt. Fahre
sie in einem zweiten Terminal aus dem Wurzelverzeichnis des Repositories hoch – die Anwendung läuft
im ersten weiter:

```bash
cd stack && docker-compose up -d
```

Öffne die Bridge danach, melde dich an und verbinde sie mit deiner Engine.

1. Öffne [http://localhost:8081](http://localhost:8081) und melde dich mit dem Dev-Admin an
   (`admin@enterpriseglue.com` / `adminadmin`).
2. Registriere die Engine unter **Platform settings → Engines → Add engine**:

   | Feld | Wert |
   |---|---|
   | Engine name | `Training` (frei wählbar) |
   | Engine product | `Operaton` |
   | How EnterpriseGlue connects | `Connect directly to the engine` |
   | Endpoint URL | `http://host.docker.internal:8080/engine-rest` |
   | Endpoint authentication | `Username and password` → Username `admin`, Password `admin` |
   | Environment label | `Dev` (vorausgewählt) |

   Alles andere bleibt auf den Vorgaben. Die Endpoint-URL ist dieselbe REST-Schnittstelle, die auch
   das Cockpit nutzt. Aus dem Container heraus ist der Host über `host.docker.internal` erreichbar –
   nicht über `localhost`.
3. Nach **Create** steht die Engine auf **Connected**, und dieselbe Prozessdefinition
   (`Join Inner Circle` / `subscribeNewsletter`) erscheint in der Bridge unter **Mission Control**.

> **Begriff: EnterpriseGlue The Bridge.** Eine zusätzliche UI für die Engine (BPMN/DMN
> modellieren, deployen und verwalten). Sie spricht dieselbe `engine-rest`-API wie das Cockpit und
> ist damit eine Alternative zu den klassischen Operaton-Weboberflächen. Die genaue Bezeichnung der
> Felder kann je nach Bridge-Version abweichen; entscheidend sind die Endpoint-URL der Engine, eine
> *direkte* Verbindung und Benutzername/Passwort.

> **Hinweis: Warum Benutzername/Passwort?** Die Trainings-Engine läuft ohne Authentifizierung und
> ignoriert die Zugangsdaten. Die Bridge speichert eine Engine *ohne* Zugangsdaten aber nur, wenn sie
> hinter einem kundenseitig betriebenen Gateway oder Sidecar liegt (die andere Option unter *How
> EnterpriseGlue connects*) und ein Platform-Admin das ausdrücklich freigeschaltet hat. `admin`/`admin`
> sind die Cockpit-Admin-Zugangsdaten aus der `application.yaml` – sie wären also auch dann richtig,
> wenn du die REST-Authentifizierung später einschaltest.

## Randbedingungen

- Du arbeitest ausschließlich im Modul `services/process-application`.
- Das Modul enthält bereits das vollständige Skelett der hexagonalen Architektur. Die
  Business-Schicht ist auskommentiert und wird hier noch nicht gebraucht.
- Alle Module laufen auf Port `8080` und nutzen dieselbe H2-Datei unter `~/.operaton-training/`.
  Starte immer nur eines – die laufende Anwendung sperrt die Datei.
- Docker brauchst du nur für den optionalen Schritt 8 (Bridge); alle anderen Schritte laufen ohne.

## Erwartetes Ergebnis

Im Log erscheinen die H2-Zeile aus Schritt 4 mit
`Database available at 'jdbc:h2:file:~/.operaton-training/exercise'`,
`Auto-Deploying resources: [... membership.bpmn]` und `Started TrainingApplication`. Unter
`~/.operaton-training/` liegt die Datei `exercise.mv.db`. Die H2-Konsole zeigt die `act_*`-Tabellen,
das Cockpit ist erreichbar, `Join Inner Circle` steht unter **Processes**, und eine über das
Start-Formular gestartete Instanz läuft ohne anzuhalten bis zum End Event durch.

## Selbstcheck

- [ ] Dependencies, Konfiguration und `@SpringBootApplication` sind aktiviert
- [ ] Die Anwendung startet und deployt `membership.bpmn`
- [ ] Die H2-Konsole zeigt die `act_*`-Tabellen, und `act_re_procdef` enthält `subscribeNewsletter`
- [ ] `Join Inner Circle` erscheint im Cockpit unter **Processes**
- [ ] Eine über das Start-Formular gestartete Instanz läuft vollständig durch (History `COMPLETED`)
- [ ] Du kannst erklären, warum die Instanz mit lauter Manual Tasks nirgends wartet
- [ ] Optional: Die Bridge ist unter `http://localhost:8081` erreichbar und zeigt nach dem Verbinden dieselbe Prozessdefinition

## Hinweise

- Zeigt das Cockpit statt der Anmeldung die Seite **Operaton Setup** zum Anlegen eines ersten
  Users, ist der Block aus Schritt 2 nicht einkommentiert. Die Anwendung läuft dann auf einer
  flüchtigen In-Memory-H2 ohne Admin-User; im Log steht `jdbc:h2:mem:…` statt der H2-Datei. Leg
  dort keinen User an – er wäre nach dem nächsten Neustart weg –, sondern kommentiere den Block ein
  und starte neu. Startest du die Anwendung aus der IDE, ist `/h2-console` auch ohne den Block
  erreichbar (die Spring Boot DevTools schalten die Konsole dort ein); verlass dich auf die URL im
  Log.
- Bricht der Start mit
  `Database may be already in use: "…/.operaton-training/exercise.mv.db"` ab, hält bereits jemand
  anderes die Datei offen – ein anderes Modul, dasselbe Modul in einem zweiten Terminal oder ein
  Datenbank-Werkzeug wie *Database* in IntelliJ oder *SQLTools* in VS Code. Beende die Anwendung
  bzw. trenne die Verbindung und starte neu. Umgekehrt öffnen diese Werkzeuge die Datei nicht,
  solange die Anwendung läuft – nimm dafür die H2-Konsole.
- Meldet die H2-Konsole
  `Database "…" not found, either pre-create it or allow remote database creation …`, stimmt die
  URL im Feld **JDBC URL** nicht – meist steht dort noch der vorbelegte Wert `jdbc:h2:~/test`,
  manchmal ist es ein Tippfehler. Trage wie in Schritt 5 genau
  `jdbc:h2:file:~/.operaton-training/exercise` ein. Bleibt die Meldung bei richtiger URL, gibt es
  die Datei noch nicht: Die Anwendung läuft ohne den Block aus Schritt 2.
- Der Datenbestand der Engine übersteht einen Neustart der Anwendung. Für einen sauberen Neuanfang
  beende die Anwendung und lösche den Ordner `~/.operaton-training` (unter Windows
  `%USERPROFILE%\.operaton-training`); beim nächsten Start legen H2 und die Engine alles neu an.
- Die Präfixe sind ein Merkanker: `re` liegt fest, `ru` bewegt sich, `hi` ist Vergangenheit.
- **Bridge (Schritt 8):** Schlägt das Anlegen der Engine in der Bridge mit einem generischen Fehler
  fehl und zeigt `docker logs enterpriseglue-backend` die Meldung
  `Engine base URL must use HTTPS when endpoint policy is enforced`, läuft das Bridge-Backend ohne
  die `EG_ENGINE_*`-Variablen aus `stack/docker-compose.yml` (z. B. ein Container aus einer älteren
  Compose-Datei). Führe `cd stack && docker-compose up -d` erneut aus, damit das Backend neu erzeugt
  wird. Die verwandte Meldung
  `Engine base URL private host must have an exact endpoint-policy allowlist entry` bedeutet, dass
  `localhost`/`127.0.0.1` statt `host.docker.internal` eingetragen wurde.
- **Bridge (Schritt 8):** Bricht `docker-compose up -d` mit
  `container enterpriseglue-backend is unhealthy` ab und zeigt `docker logs enterpriseglue-backend`
  eine fehlgeschlagene Migration (z. B. `column "user_id" does not exist`), stammen die
  Bridge-Volumes von einem älteren Bridge-Image. Entweder setzt du die Bridge-Volumes zurück
  (frischer Stand) oder spielst einmalig `stack/enterpriseglue-ledger-baseline-v0.19.2.sql` ein –
  beide Rezepte stehen im Kopf dieser Datei.

## Referenzlösung

- Fertiges Modul: `../../solutions/exercise-01/`
- Modell: `../../models/exercise-01/membership.bpmn`
- Direkt ins Arbeitsmodul laden:

  ```bash
  ./mvnw -pl services/process-application antrun:run@load-solution -Dsolution=01
  ```

## Nächster Schritt

In Aufgabe 2 wird aus dem Platzhalter „Confirm" ein echter **User Task**, den du selbst mit
einem Formular modellierst.

➡️ [Weiter zu Aufgabe 2](exercise-02.md)
