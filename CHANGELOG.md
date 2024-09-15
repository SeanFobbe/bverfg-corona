# Changelog

## Version \version

- Vollständige Aktualisierung der Daten
- Verschiebung der Konfigurations-Dateien in etc/
- Anpassung der Docker Compose-Konfiguration an Debian 11


## Version 2023-02-06

- Vollständige Aktualisierung der Daten
- Gesamte Laufzeitumgebung nun mit Docker versionskontrolliert
- Funktionen werden nun nicht mehr aus einem Submodule bezogen, sondern sind direkt im Projekt verankert
- Vereinfachung der Konfigurations-Datei
- ZIP-Archiv mit Source Code wird nun aus dem Git-Manifest generiert
- README im Hinblick auf Docker überarbeitet
- Speichern von temporären Dateien nun in speziellen Ordnern in files/, pdf/ und txt/
- Option für automatische Löschung der Dateien aus vorherigen Runs zu Konfiguration hinzugefügt
- Delete-Skript hinzugefügt



## Version 2022-08-24

- Vollständige Aktualisierung der Daten
- Diagramme sind deutlich überarbeitet und die Labels verschönert worden
- Umbenennung des run scripts und der Konfigurations-Datei

## Version 2022-02-01

- Vollständige Aktualisierung der Daten
- Strenge Versionskontrolle von R packages mit **renv**
- Kompilierung jetzt detailliert konfigurierbar, insbesondere die Parallelisierung
- Parallelisierung nun vollständig mit *future* statt mit *foreach* und *doParallel*
- Fehlerhafte Kompilierungen werden vor der nächsten Kompilierung vollautomatisch aufgeräumt
- Alle Ergebnisse werden automatisch fertig verpackt in den Ordner 'output' sortiert
- README und CHANGELOG sind jetzt externe Markdown-Dateien, die bei der Kompilierung automatisiert eingebunden werden

## Version 2021-09-19

- Vollständige Aktualisierung der Daten

## Version 2021-05-20

- Vollständige Aktualisierung der Daten

## Version 2021-01-08

- Erstveröffentlichung
