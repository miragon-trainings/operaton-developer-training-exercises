# Aufgabe 0 – Den Sollprozess fachlich modellieren

> **Voraussetzung:** Kapitel 1 – du kennst BPMN als Notation: Events, Tasks, Sequenzfluss, Gateways. Subprozess, Boundary Events und Kompensation wendest du hier zum ersten Mal fachlich an (technisch vertieft in späteren Aufgaben).
> **Arbeitsverzeichnis:** ein beliebiger Ordner deiner Wahl (noch kein Code, noch kein Modul).
> **Neu in dieser Aufgabe:** BPMN-Modeler, der vollständige Sollprozess als gemeinsame Landkarte.

## Darum geht es

**Miravelo** ist ein Online-Shop für hochwertige Fahrräder – Gravel Bikes für lange
Wochenendtouren, Rennräder für alle, die es auf dem Asphalt schnell mögen. Die Kundschaft
ist jung, markenbewusst und ziemlich leidenschaftlich.

Miravelo baut daraus mehr als einen Verteiler: den **Inner Circle**, eine exklusive
Mitgliedschaft mit begrenzter Platzzahl. Wer beitreten will, registriert sich, bestätigt per
Double-Opt-In, bekommt einen Platz reserviert – und wird am Ende willkommen geheißen. Klingt
nach vier Kästchen, hat aber Bestätigungsfristen, eine Kapazitätsgrenze und einen Rückzieher,
wenn am Ende doch kein Platz frei ist.

> *„Zeichnen wir das doch erst mal auf, bevor jemand anfängt zu programmieren."*
> — der eine vernünftige Satz im ganzen Kickoff.

Bevor irgendetwas automatisiert wird, hältst du den **kompletten Sollprozess fachlich** fest:
Was passiert, in welcher Reihenfolge, wo wartet der Prozess, wo verzweigt er? Das ist die
Sprache, in der Fachbereich und Entwicklung sich einig werden – ohne eine Zeile Technik. Dieses
Modell ist die **Landkarte für das ganze Training**: Ab Aufgabe 1 automatisierst du es Stück für
Stück.

## Lernziele

Nach dieser Aufgabe kannst du

- einen BPMN-Modeler installieren und darin ein durchgängiges Modell anlegen,
- die Notation aus Kapitel 1 auf einen realen Geschäftsprozess anwenden – Start- und End Events,
  User Task und Service Task, Exclusive und Parallel Gateway – und die fortgeschrittenen Formen
  eingebetteter Subprozess, Boundary Events und Kompensation hier zum ersten Mal fachlich einsetzen,
- Warte- und Verzweigungspunkte im Ablauf begründen (wo wartet der Prozess auf einen Menschen,
  wo auf eine Frist, wo entscheidet eine Bedingung),
- Elemente so benennen, dass ein Fachbereich den Ablauf ohne Rückfragen vorlesen kann.

## Ziel-Modell

Das ist der vollständige Sollprozess des Inner Circle. Er sieht groß aus – ist aber nur die
Summe vieler kleiner, dir bekannter Bausteine. Genau diesen Ablauf baust du im Lauf des
Trainings Schritt für Schritt technisch nach.

![BPMN-Modell der Aufgabe](../assets/exercise-00.svg)

## Aufgabe

### 1. Modeler in der IDE installieren

Wir modellieren direkt in der IDE – keine separate Anwendung nötig. Installiere den **Miragon BPMN
Modeler** als [VS-Code-Extension](https://marketplace.visualstudio.com/items?itemName=miragon-gmbh.vs-code-bpmn-modeler)
oder als [IntelliJ-Plugin](https://plugins.jetbrains.com/plugin/32634-miragon-bpmn-modeler). Egal
welche IDE, es ist derselbe Modeler – so öffnet jede folgende Aufgabe das Modell in einem echten
Modeler. Ohne VS Code oder IntelliJ nutzt du die
[eigenständige Desktop-App](https://miragon.github.io/bpmn-modeler/) als Rückfalloption. Lege
danach ein neues BPMN-Diagramm an.

### 2. Registrierung und Kapazitätsprüfung modellieren

Beginne mit dem Rückgrat des Prozesses: Ein Interessent registriert sich, der Prozess reserviert
einen Platz und prüft dann, ob überhaupt noch einer frei ist. Ist keiner frei, endet die
Bewerbung mit einer Absage.

| Typ | Name |
|---|---|
| Start Event | Submit registration form |
| Service Task | Claim membership |
| Exclusive Gateway | Free seat available? |
| Service Task | Send rejection mail |
| End Event | Membership rejected |

Verbinde Start → *Claim membership* → *Free seat available?*. Vom Gateway führt ein Pfad **No** zu
*Send rejection mail* → *Membership rejected*. Der Pfad **Yes** bleibt zunächst offen – ihn füllst
du im nächsten Schritt. Der Platz wird also **vor** der Prüfung reserviert; darum kümmert sich
Schritt 6.

### 3. Die Bestätigung als Subprozess modellieren

Wer einen Platz bekommt, muss die Mitgliedschaft aktiv bestätigen (Double-Opt-In). Fasse diesen
Bestätigungsablauf in einem **eingebetteten Subprozess** zusammen – er bekommt gleich seine eigenen
Fristen und Ausnahmen, und ein Subprozess hält das übersichtlich.

Modelliere den Subprozess **Confirm membership** und darin:

| Typ | Name |
|---|---|
| Start Event (im Subprozess) | Confirmation required |
| Service Task | Send confirmation mail |
| User Task | Confirm membership |
| End Event (im Subprozess) | Membership confirmed |

Führe den **Yes**-Pfad des Gateways aus Schritt 2 in diesen Subprozess. An diesem *User Task*
hält der Prozess an: Hier wartet er, bis ein Mensch bestätigt.

### 4. Erinnerung, Frist und Ablehnung ergänzen

Menschen bestätigen nicht immer sofort – manche gar nicht. Häng deshalb **Boundary Events** an
den Subprozess *Confirm membership*, die drei Ausnahmen abbilden:

| Boundary Event | Typ | Name | Führt zu |
|---|---|---|---|
| Erinnerung | Timer, nicht unterbrechend, täglich | Every day | Service Task *Re-Send confirmation mail* → End Event *Mail sent again* |
| Abbruch nach Frist | Timer, unterbrechend, 3½ Tage | After 3 1/2 days | End Event *Membership declined* |
| Aktive Ablehnung | Message, unterbrechend | Confirmation rejected | End Event *Membership declined* |

Das **nicht unterbrechende** Timer-Event lässt den Subprozess weiterlaufen und schickt nebenbei
täglich eine Erinnerung. Die beiden **unterbrechenden** Events brechen die Bestätigung ab und
führen zu *Membership declined*.

### 5. Die Aktivierung parallel modellieren

Ist die Mitgliedschaft bestätigt, wird das Mitglied aktiviert – und zwei Dinge passieren
gleichzeitig: die Willkommens-Mail geht raus, und die Community wird informiert. Modelliere das
mit einem **Parallel Gateway** (Fork und Join). Schließe den Fork mit einem Parallel-Join
desselben Typs (AND mit AND), damit beide Zweige wieder synchronisiert werden, bevor es zu
*Membership activated* geht.

| Typ | Name |
|---|---|
| Parallel Gateway (Fork) | – |
| Service Task | Send Welcome Mail |
| Service Task | Notify community |
| Parallel Gateway (Join) | – |
| End Event | Membership activated |

Führe den Ausgang des Subprozesses in den Fork, beide Service Tasks parallel, dann in den Join
und zu *Membership activated*.

### 6. Kompensation ergänzen

Ein reservierter Platz darf nicht verfallen, wenn die Bewerbung am Ende doch scheitert. Wird die
Mitgliedschaft abgelehnt (*Membership declined*), muss die Reservierung aus Schritt 2 **rückgängig**
gemacht werden. Genau dafür gibt es Kompensation.

- Häng an *Claim membership* ein **Compensation Boundary Event** mit dem Namen *Membership declined*.
- Lege einen Kompensations-Handler *Revoke claim* (Service Task) an und verbinde ihn per
  **Association** mit dem Boundary Event. Er steht **außerhalb** des normalen Sequenzflusses.
- Mach das End Event *Membership declined* zu einem **Compensating End Event** – es stößt die
  Kompensation an.

### 7. Modell sichern

Speichere die Datei als `membership.bpmn` in einem Ordner deiner Wahl. Sie ist dein Referenzbild
für alle Folgeaufgaben.

## Randbedingungen

- **Nur fachlich.** Es geht um Ablauf und Benennung. Element-IDs nach Konvention, Formularfelder,
  die Anbindung von Service Tasks an Java-Code sowie `isExecutable` und `historyTimeToLive` lässt
  du hier bewusst weg – das kommt ab Aufgabe 2.
- **Sauber modellieren, nicht nur vollständig.** Wende die Modellierungsregeln aus Kapitel 1 an:
  Benenne jede Aktivität als Verb plus Objekt (*Claim membership*), jedes Gateway als Frage und
  jeden ausgehenden Sequenzfluss als Antwort (*Yes* / *No*). Rahme den Ablauf mit Start- und End
  Events und gib jedem End Event einen eigenen Namen. Halte den Happy Path – Registrierung,
  Bestätigung, Aktivierung – auf einer geraden Linie von links nach rechts und führe die Ausnahmen
  (Absage, Frist, Ablehnung, Erinnerung) kreuzungsfrei nach oben oder unten weg. Verzweige nur an
  Gateways: Fork und Join sind getrennte Rauten.
- **Das ist der Zielzustand, nicht der erste Schritt.** Niemand automatisiert diesen Prozess auf
  einmal. Ab Aufgabe 1 nimmst du dir kleine Ausschnitte vor.
- **Noch nicht ins Modul kopieren.** Unter `services/process-application/src/main/resources/bpmn/`
  liegt bereits ein bewusst rudimentäres `membership.bpmn`, das du in Aufgabe 1 brauchst.
  Überschreibe es jetzt nicht.
- Namen in den Modellen sind durchgehend englisch; die Aufgabenbeschreibungen gibt es auf
  Deutsch und Englisch.

## Erwartetes Ergebnis

Dein Modell bildet den vollständigen Ablauf ab: Registrierung, Platzreservierung, Kapazitäts-
Gateway, Bestätigungs-Subprozess mit Erinnerung, Frist und Ablehnung, parallele Aktivierung und
die Kompensation der Reservierung. Der Modeler meldet keine Fehler, und jemand aus dem Fachbereich
könnte den Ablauf vorlesen, ohne nachzufragen, was ein einzelnes Element bedeutet.

## Selbstcheck

- [ ] Der Prozess ist mit Start- und End Events gerahmt: der Hauptablauf startet mit *Submit
      registration form*, der Bestätigungs-Subprozess hat seinen eigenen Start, und jedes End Event
      trägt einen eigenen Namen (*Membership activated*, *Membership rejected*, *Membership
      declined*, *Mail sent again* sowie im Subprozess *Membership confirmed*)
- [ ] Jede Aktivität ist als Verb plus Objekt benannt, das Exclusive Gateway als Frage
      (*Free seat available?*) und seine ausgehenden Sequenzflüsse als Antwort (*Yes* / *No*)
- [ ] Die Kapazität wird über ein Exclusive Gateway mit einem **No**-Pfad zur Absage geprüft
- [ ] Die Bestätigung liegt in einem eingebetteten Subprozess mit einem User Task
- [ ] Am Subprozess hängen drei Boundary Events: täglicher (nicht unterbrechender) Timer,
      3½-Tage-Timer (unterbrechend) und ein Message Event (unterbrechend)
- [ ] Die Aktivierung läuft über ein Parallel Gateway; der Fork wird mit einem Parallel-Join
      desselben Typs geschlossen, der auf beide Zweige wartet (Willkommens-Mail und Community-Info
      laufen gleichzeitig)
- [ ] *Revoke claim* ist ein Kompensations-Handler, per Association an das Boundary Event von
      *Claim membership* gehängt, und *Membership declined* ist ein Compensating End Event
- [ ] Der Happy Path verläuft gerade von links nach rechts; die Ausnahmepfade zweigen kreuzungsfrei
      ab, und kein Gateway mergt und splittet zugleich (Fork und Join sind getrennte Rauten)
- [ ] Du bist jeden Pfad einmal von Hand durchgegangen: Happy Path, Absage, Frist-Abbruch, aktive
      Ablehnung und tägliche Erinnerung enden jeweils in genau einem benannten End Event; kein Zweig
      läuft ins Leere
- [ ] Du kannst in je einem Satz sagen, wo der Ablauf auf einen Menschen wartet (am User Task) und
      warum das Exclusive Gateway verzweigt
- [ ] Alle Elemente sind über Sequenzflüsse verbunden – kein loses Element
- [ ] Die Datei liegt als `membership.bpmn` gespeichert vor

## Hinweise

Lass dich von der Größe nicht abschrecken: Jeder fortgeschrittene Baustein bekommt später seine
**eigene Aufgabe**, in der du ihn technisch umsetzt – der Bestätigungsschritt in Aufgabe 4, das
Kapazitäts-Gateway in Aufgabe 5, Subprozess und Boundary Events in Aufgabe 7, die Kompensation in
Aufgabe 8. Hier zeichnest du zuerst die ganze Landkarte, damit du bei jedem Teilschritt weißt,
wohin er gehört.

Warum ein User Task und ein Service Task? Der **User Task** wartet auf einen Menschen – jemand
bestätigt die Mitgliedschaft. Der **Service Task** wird von einem System erledigt – der
Mailversand, die Platzreservierung. Diese Unterscheidung legt fest, wo der Prozess wartet und wo
er von allein weiterläuft. Die drei Mails sind übrigens **Service Tasks**, keine Send Tasks – ein
System erledigt sie (ab Aufgabe 3 setzt du sie als JavaDelegate um). Manual Task, Business Rule
Task, Script Task und die übrigen Task-Typen aus Kapitel 1 tauchen erst später auf oder bleiben
ganz außen vor.

**Warum keine Pools, Lanes oder Datenobjekte?** Der ganze Ablauf spielt bei Miravelo intern, mit
einem einzigen menschlichen Berührungspunkt – dem User Task *Confirm membership*; alle übrigen
Schritte sind Service Tasks. Nach der Regel „Lanes mit Disziplin" bekommt ein System keine eigene
Lane, und ein einzelner Beteiligter braucht weder Pool noch Lane – beides würde diese Landkarte
nur mit Rauschen füllen. Datenobjekte sind rein beschreibend, die Engine wertet sie nicht aus;
deshalb lassen wir sie hier bewusst weg und konzentrieren uns auf Ablauf und Benennung.

## Referenzlösung

`../../models/exercise-00/membership.bpmn` – öffne das Modell im Modeler und vergleiche es mit
deinem.

## Nächster Schritt

In Aufgabe 1 bringst du die Engine zum Laufen, die genau solche Modelle ausführt – zunächst mit
einem bewusst winzigen Ausschnitt.

➡️ [Weiter zu Aufgabe 1](exercise-01.md)
