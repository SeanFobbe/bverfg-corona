# README


## Überblick

Dieser R Code lädt den [Corpus der Entscheidungen des Bundesverfassungsgerichts (CE-BVerfG)](https://doi.org/10.5281/zenodo.3902658) herunter, untersucht ihn auf mit SARS-CoV-2 assoziiertem Vokabular und speichert relevante Entscheidungen.  Es ist die Grundlage für den Datensatz **Corona-Rechtsprechung des Bundesverfassungsgerichts (BVerfG-Corona)**.

Alle mit diesem Skript erstellten Datensätze werden dauerhaft kostenlos und urheberrechtsfrei auf Zenodo, dem wissenschaftlichen Archiv des CERN, veröffentlicht. Alle Versionen sind mit einem persistenten Digital Object Identifier (DOI) versehen. Die neueste Version des Datensatzes ist immer über den Link der Concept DOI erreichbar: <https://doi.org/10.5281/zenodo.4459405>




## Funktionsweise

 Primäre Endprodukte des Skripts (im Ordner 'output') sind folgende ZIP-Archive:
 
- Alle Corona-relevanten Entscheidungen im PDF-Format
- Alle Corona-relevanten Entscheidungen im TXT-Format
- Alle Analyse-Ergebnisse (Tabellen als CSV, Grafiken als PDF und PNG)
- Der Source Code und alle weiteren Quelldaten


Zusätzlich werden für alle ZIP-Archive kryptographische Signaturen (SHA2-256 und SHA3-512) berechnet und in einer CSV-Datei hinterlegt. Es kann optional ein PDF-Bericht erstellt werden (siehe unter "Kompilierung").



## Systemanforderungen

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- 1 GB Speicherplatz auf Festplatte
- Multi-core CPU empfohlen (8 cores/16 threads für die Referenzdatensätze). 


In der Standard-Einstellung wird das Skript vollautomatisch die maximale Anzahl an Rechenkernen/Threads auf dem System zu nutzen. Die Anzahl der verwendeten Kerne kann in der Konfigurationsatei angepasst werden. Wenn die Anzahl Threads auf 1 gesetzt wird, ist die Parallelisierung deaktiviert.




## Anleitung


### Schritt 1: Ordner vorbereiten

Kopieren Sie bitte den gesamten Source Code in einen leeren Ordner (!), beispielsweise mit:

```
$ git clone https://github.com/seanfobbe/bverfg-corona.git
```

Verwenden Sie immer einen separaten und *leeren* Ordner für die Kompilierung. Die Skripte löschen innerhalb von bestimmten Unterordnern (`files/`, `temp/`, `analysis` und `output/`) alle Dateien die den Datensatz verunreinigen könnten --- aber auch nur dort.



### Schritt 2: Docker Image erstellen

Ein Docker Image stellt ein komplettes Betriebssystem mit der gesamten verwendeten Software automatisch zusammen. Nutzen Sie zur Erstellung des Images einfach:

```
$ bash docker-build-image.sh
```




### Schritt 3: Datensatz kompilieren

Falls Sie zuvor den Datensatz schon einmal kompiliert haben (ob erfolgreich oder erfolglos), können Sie mit folgendem Befehl alle Arbeitsdaten im Ordner löschen:

```
$ Rscript delete_all_data.R
```

Den vollständigen Datensatz kompilieren Sie mit folgendem Skript:

```
$ bash docker-run-project.sh
```





### Ergebnis

Der Datensatz und alle weiteren Ergebnisse sind nun im Ordner `output/` abgelegt.






## Pipeline visualisieren

Sie können die Pipeline visualisieren, aber nur nachdem sie die zentrale .Rmd-Datei mindestens einmal gerendert haben:

```
> targets::tar_glimpse()     # Nur Datenobjekte
> targets::tar_visnetwork()  # Alle Objekte
```





## Troubleshooting

Hilfreiche Befehle um Fehler zu lokalisieren und zu beheben.

```
> tar_progress()  # Zeigt Fortschritt und Fehler an
> tar_meta()      # Alle Metadaten
> tar_meta(fields = "warnings", complete_only = TRUE)  # Warnungen
> tar_meta(fields = "error", complete_only = TRUE)  # Fehlermeldungen
> tar_meta(fields = "seconds")  # Laufzeit der Targets
```





## Projektstruktur

Die folgende Struktur erläutert die wichtigsten Bestandteile des Projekts. Während der Kompilierung werden weitere Ordner erstellt (`files/`, `temp/` `analysis` und `output/`). Die Endergebnisse werden alle in `output/` abgelegt.

 
``` 
.
├── buttons                    # Buttons (nur optische Bedeutung)
├── BVerfG-Corona_CorpusCreation.R # Zentrale Definition der Pipeline
├── CHANGELOG.md               # Alle Änderungen
├── config.toml                # Zentrale Konfigurations-Datei
├── delete_all_data.R          # Löscht den Datensatz und Zwischenschritte
├── docker-build-image.sh      # Docker Image erstellen
├── docker.compose.yaml        # Konfiguration für Docker
├── Dockerfile                 # Definition des Docker Images
├── docker-run-project.sh      # Docker Image und Datensatz kompilieren
├── etc                        # Weitere Konfigurationsdateien
├── functions                  # Wichtige Schritte der Pipeline
├── gpg                        # Persönlicher Public GPG-Key für Seán Fobbe
├── LICENSE                    # Die Lizenz für den Source Code
├── README.md                  # Bedienungsanleitung
├── run_project.R              # Kompiliert den gesamten Datensatz
└── tex                        # LaTeX-Templates



``` 

 
## Weitere Open Access Veröffentlichungen (Fobbe)

Website — https://www.seanfobbe.de

Open Data  —  https://zenodo.org/communities/sean-fobbe-data/

Source Code  —  https://zenodo.org/communities/sean-fobbe-code/

Volltexte regulärer Publikationen  —  https://zenodo.org/communities/sean-fobbe-publications/




## Kontakt

Fehler gefunden? Anregungen? Kommentieren Sie gerne im Issue Tracker auf GitHub oder kontaktieren Sie mich via https://www.seanfobbe.de

