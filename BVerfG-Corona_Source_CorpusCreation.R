#'---
#'title: "Compilation Report | Corona-Rechtsprechung des Bundesverfassungsgerichts"
#'author: Seán Fobbe
#'papersize: a4
#'geometry: margin=3cm
#'fontsize: 11pt
#'output:
#'  pdf_document:
#'    toc: true
#'    toc_depth: 3
#'    number_sections: true
#'    pandoc_args: --listings
#'    includes:
#'      in_header: General_Source_TEX_Preamble_DE.tex
#'      before_body: [BVerfG-Corona_Source_TEX_CompilationTitle.tex]
#'bibliography: packages.bib
#'nocite: '@*'
#' ---




#'\newpage
#+
#'# Einleitung
#'
#+
#'## Überblick
#' Dieses R-Skript lädt den Corpus der Entscheidungen des Bundesverfassungsgerichts (CE-BVerfG) herunter, untersucht ihn auf mit SARS-CoV-2 assoziiertem Vokabular und speichert relevante Entscheidungen.  Es ist die Grundlage für den Datensatz \textbf{\datatitle\ (\datashort )}.
#'
#' Alle mit diesem Skript erstellten Datensätze werden dauerhaft kostenlos und urheberrechtsfrei auf Zenodo, dem wissenschaftlichen Archiv des CERN, veröffentlicht. Alle Versionen sind mit einem persistenten Digital Object Identifier (DOI) versehen. Die neueste Version des Datensatzes ist immer über den Link der Concept DOI erreichbar: \dataconcepturldoi



#+
#'## Funktionsweise

#' Primäre Endprodukte des Skripts sind folgende ZIP-Archive:
#' \begin{enumerate}
#' \item Alle Corona-relevanten Entscheidungen im PDF-Format
#' \item Alle Corona-relevanten Entscheidungen im TXT-Format
#' \item Alle Analyse-Ergebnisse (Tabellen als CSV, Grafiken als PDF und PNG)
#' \item Der Source Code und alle weiteren Quelldaten
#' \end{enumerate}
#'
#' Zusätzlich werden für alle ZIP-Archive kryptographische Signaturen (SHA2-256 und SHA3-512) berechnet und in einer CSV-Datei hinterlegt. Es kann optional ein PDF-Bericht erstellt werden (siehe unter "Kompilierung").


#+
#'## Systemanforderungen
#' Das Skript in seiner veröffentlichten Form kann nur unter Linux ausgeführt werden, da es Linux-spezifische Optimierungen (z.B. Fork Cluster) und Shell-Kommandos (z.B. OpenSSL) nutzt. Das Skript wurde unter Fedora Linux entwickelt und getestet. Die zur Kompilierung benutzte Version entnehmen Sie bitte dem **sessionInfo()**-Ausdruck am Ende dieses Berichts.
#'
#' In der Standard-Einstellung wird das Skript vollautomatisch die maximale Anzahl an Rechenkernen/Threads auf dem System zu nutzen. Wenn die Anzahl Threads (Variable "fullCores") auf 1 gesetzt wird, ist die Parallelisierung deaktiviert.
#'
#' Auf der Festplatte sollten 4 GB Speicherplatz vorhanden sein.
#' 
#' Um die PDF-Berichte kompilieren zu können benötigen Sie das R package **rmarkdown**, eine vollständige Installation von \LaTeX\ und alle in der Präambel-TEX-Datei angegebenen \LaTeX\ Packages.



#'\newpage
#+
#'## Kompilierung

#' Mit der Funktion **render()** von **rmarkdown** kann der **vollständige Datensatz**  kompiliert und das Skript mitsamt seinen Rechenergebnisse in ein gut lesbares PDF-Format überführt werden.
#'
#' Alle Kommentare sind im roxygen2-Stil gehalten. Das Skript kann daher auch **ohne render()** regulär als R-Skript ausgeführt werden. Es wird in diesem Fall kein PDF-Bericht erstellt und Diagramme werden nicht abgespeichert.

#' 
#' Um den vollständigen Datensatz zu kompilieren und einen PDF-Bericht zu erstellen, kopieren Sie bitte alle im Source-Archiv bereitgestellten Dateien in einen leeren Ordner und führen mit R diesen Befehl aus:

#+ eval = FALSE

rmarkdown::render(input = "BVerfG-Corona_Source_CorpusCreation.R",
                  output_file = paste0("BVerfG-Corona_2021-09-19_CompilationReport.pdf"),
                  envir = new.env())





#'# Parameter

#+
#'## Name des Datensatzes
datasetname <- "BVerfG-Corona"


#'## Datumsstempel
#' Dieser Datumsstempel wird in alle Dateinamen eingefügt. Er richtet sich nach der Version des Stamm-Datensatzes.

datestamp <- "2021-09-19"


#'## DOI der konkreten Datensatz-Version (CE-BVerfG)
#' Aus diesem Datensatz werden die Entscheidungen bezogen.

doi.version.cebverfg <- "10.5281/zenodo.5514083" # checked


#'## DOI der konkreten Datensatz-Version (BVerfG-Corona)
#' In diesen Datensatz werden die Corona-relevanten Entscheidungen überführt.

doi.version <- "10.5281/zenodo.5532937" # checked





#'## Verzeichnis für Analyse-Ergebnisse
#' Hinweis: Muss mit einem Schrägstrich enden!
outputdir <- paste0(getwd(),
                    "/ANALYSE/") 



#'## Optionen: Quanteda
tokens_locale <- "de_DE"


#'## Optionen: Knitr

#+
#'### Ausgabe-Format
dev <- c("pdf",
         "png")

#'### DPI für Raster-Grafiken
dpi <- 300

#'### Ausrichtung von Grafiken im Compilation Report
fig.align <- "center"



#'## Frequenztabellen: Ignorierte Variablen

#' Diese Variablen werden bei der Erstellung der Frequenztabellen nicht berücksichtigt.

varremove <- c("text",
               "eingangsnummer",
               "datum",
               "doc_id",
               "seite",
               "name",
               "ecli",
               "aktenzeichen",
               "zeichen",
               "tokens",
               "typen",
               "saetze",
               "version",
               "pressemitteilung",
               "zitiervorschlag",
               "kurzbeschreibung")



#'# Vorbereitung



#'## Datum und Uhrzeit (Beginn)

begin.script <- Sys.time()
print(begin.script)


#'## Ordner für Analyse-Ergebnisse erstellen
dir.create(outputdir)


#'## Packages

library(doParallel)   # Parallelisierung
library(ggplot2)      # Fortgeschrittene Datenvisualisierung
library(rmarkdown)    # Wissenschaftliches Reporting
library(knitr)        # Wissenschaftliches Reporting
library(kableExtra)   # Verbesserte Kable Tabellen
library(data.table)   # Fortgeschrittene Datenverarbeitung
library(quanteda)     # Fortgeschrittenes Natural Language Processing
library(quanteda.textplots) # Quanteda: Diagramme


#'## Zusätzliche Funktionen einlesen
#' **Hinweis:** Die hieraus verwendeten Funktionen werden jeweils vor der ersten Benutzung in vollem Umfang angezeigt um den Lesefluss zu verbessern.

source("General_Source_Functions.R")


#'## Quanteda-Optionen setzen
quanteda_options(tokens_locale = tokens_locale)


#'## Knitr Optionen setzen
knitr::opts_chunk$set(fig.path = outputdir,
                      dev = dev,
                      dpi = dpi,
                      fig.align = fig.align)



#'## Vollzitate statistischer Software
knitr::write_bib(c(.packages()),
                 "packages.bib")



#'## Parallelisierung aktivieren
#' Parallelisierung wird zur Datenanalyse mittels **quanteda** und **data.table** verwendet. Die Anzahl Threads wird automatisch auf das verfügbare Maximum des Systems gesetzt, kann aber auch nach Belieben auf das eigene System angepasst werden. Die Parallelisierung kann deaktiviert werden, indem die Variable **fullCores** auf 1 gesetzt wird.
#'
#' Die hier verwendete Funktion **makeForkCluster()** ist viel schneller als die Alternativen, funktioniert aber nur auf Unix-basierten Systemen (Linux, MacOS).

#+
#'### Anzahl logischer Kerne bestimmen

fullCores <- detectCores()
print(fullCores)

#'### Quanteda
quanteda_options(threads = fullCores) 

#+
#'### Data.table
setDTthreads(threads = fullCores)  





#'# Stamm-Datensatz einlesen (CE-BVerfG)
#' Der Stamm-Datensatz ist der \enquote{Corpus der Entscheidungen des Bundesverfassungsgerichts} (CE-BVerfG). Dieser enthält alle vom Bundesverfassungsgericht seit 1998 veröffentlichten Entscheidungen. Dessen **aktuellste** Version ist immer über diesen Digital Object Identifier (DOI) abrufbar: \url{https://doi.org/10.5281/zenodo.3902658}

#+
#'## Download der CSV-Datei
#' Der Datensatz im CSV-Format wird automatisch über einen verschlüsselten und langzeit-stabilen Link aus dem wissenschaftlichen Archiv des CERN heruntergeladen. Dieses Vorgehen garantiert die Verwendung einer authentischen Version des Datensatzes.


zip.csv <- paste0("CE-BVerfG_",
                   datestamp,
                   "_DE_CSV_Datensatz.zip")

print(zip.csv)


link.csv <- paste0("https://zenodo.org/record/",
                   gsub("10\\.5281/zenodo\\.([0-9]+)",
                        "\\1",
                        doi.version.cebverfg),
                   "/files/",
                   zip.csv,
                   "?download=1")

print(link.csv)


if(file.exists(zip.csv) == FALSE){

    download.file(link.csv,
                  zip.csv)

}


#'## CSV-Datei einlesen
dt.bverfg <- fread(cmd = paste("unzip -cq",
                               zip.csv))


#'## ZIP-Archiv löschen
unlink(zip.csv)


#'## Korpus-Objekt erstellen
corpus.bverfg <- corpus(dt.bverfg)





#'# Keywords in Context (KWIC)
#' Bei einer KWIC-Analyse (keywords in context) wird nach einer bestimmten Zeichengefolge gesucht und sowohl diese, als auch die angrenzenden Wörter werden angezeigt. Konkret wird an dieser Stelle eine alternative Suche nach den Mustern "Corona", "COVID" oder "SARS-CoV" durchgeführt. Groß- und Kleinschreibung wird ignoriert um eventuelle Tippfehler zu vernachlässigen. Das Sichtfenster wird auf 15 Tokens vor und nach dem Treffer gesetzt.


#+
#'## Tokenisierung

tokens <- tokens(corpus.bverfg,
                 what = "word",
                 remove_punct = FALSE,
                 remove_symbols = FALSE,
                 remove_numbers = FALSE,
                 remove_url = FALSE,
                 remove_separators = TRUE,
                 split_hyphens = FALSE,
                 include_docvars = TRUE,
                 padding = FALSE)
                 


#+
#'## KWIC-Analyse durchführen

kwic <- kwic(tokens,
             pattern = "(Corona)|(COVID)|(SARS-CoV)",
             window = 15,
             valuetype = "regex",
             case_insensitive = TRUE)




#'## KWIC-Tabelle speichern

file.kwic.sansdate <- paste(datasetname,
                            "02_KeywordsInContext.csv",
                            sep = "_")

file.kwic.date <- paste(datasetname,
                        datestamp,
                        "ANALYSE_02_KeywordsInContext.csv",
                        sep = "_")


fwrite(data.frame(kwic),
       paste0(outputdir,
              file.kwic.sansdate))


fwrite(data.frame(kwic),
       file.kwic.date)






#'# Lexical Dispersion Plot
#'Lexical Dispersion Plots zeigen mit einem vertikalen Strich an, an welcher Stelle in einem Dokument sich ein Token befindet. Alle Dokumente sind auf eine Länge von 1.0 normalisiert, d.h. ein Wert von 0.5 heißt immer, dass sich das Token in der Mitte des jeweiligen Dokumentes befindet. Viele und/oder dicke Striche deuten auf eine große Häufigkeit des Tokens hin.


#+
#'## Rechteckiges Format

#+ BVerfG-Corona_01_LexicalDispersion_Rechteckig, fig.height = 16, fig.width = 12

textplot_xray(kwic,
              scale = "relative")+
    labs(
        title = paste(datasetname,
                      "| Version",
                      datestamp,
                      "| Lexical Dispersion Plot"),
        caption = paste("DOI:",
                        doi.version,
                        "| Fobbe"))+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )




#'## A4-Format

#+ BVerfG-Corona_01_LexicalDispersion_A4, fig.height = 11.7, fig.width = 8.3

textplot_xray(kwic,
              scale = "relative")+
    labs(
        title = paste(datasetname,
                      "| Version",
                      datestamp,
                      "| Lexical Dispersion Plot"),
        caption = paste("DOI:",
                        doi.version,
                        "| Fobbe"))+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )







#'# TXT-Datensatz erstellen

#+
#'## Namen der Corona-Entscheidungen definieren
keep.txt <- unique(kwic$docname)

#'## Anzahl der TXT-Dateien
length(keep.txt)

#'## TXT-Datensatz herunterladen

zip.txt <- paste0("CE-BVerfG_",
                  datestamp,
                  "_DE_TXT_Datensatz.zip")


link.txt <- paste0("https://zenodo.org/record/",
                   gsub("10\\.5281/zenodo\\.([0-9]+)",
                        "\\1",
                        doi.version.cebverfg),
                   "/files/",
                   zip.txt,
                   "?download=1")


if(file.exists(zip.txt) == FALSE){

    download.file(link.txt,
                  zip.txt)

}


#'## ZIP-Archiv entpacken
unzip(zip.txt)


#'## Corona-Entscheidungen verpacken

zip(paste(datasetname,
          datestamp,
          "DE_TXT_Datensatz.zip",
          sep = "_"),
    keep.txt)


#'## TXT-Dateien löschen

files.txt <- list.files(pattern = ".txt")

unlink(files.txt)


#'## ZIP-Archiv löschen
unlink(zip.txt)




#'# PDF-Datensatz erstellen

#+
#'## Namen der Corona-Entscheidungen definieren
keep.pdf <- gsub(".txt",
                 ".pdf",
                 keep.txt)


#'## Anzahl der PDF-Dateien
length(keep.pdf)


#'## PDF-Datensatz herunterladen

zip.pdf <- paste0("CE-BVerfG_",
                   datestamp,
                   "_DE_PDF_Datensatz.zip")


link.pdf <- paste0("https://zenodo.org/record/",
                   gsub("10\\.5281/zenodo\\.([0-9]+)",
                        "\\1",
                        doi.version.cebverfg),
                   "/files/",
                   zip.pdf,
                   "?download=1")


if(file.exists(zip.pdf) == FALSE){

    download.file(link.pdf,
                  zip.pdf)

}



#'## ZIP-Archiv entpacken
unzip(zip.pdf)


#'## Corona-Entscheidungen verpacken

zip(paste(datasetname,
          datestamp,
          "DE_PDF_Datensatz.zip",
          sep = "_"),
    keep.pdf)


#'## PDF-Dateien löschen

files.pdf <- list.files(pattern = ".pdf")

unlink(files.pdf)


#'## ZIP-Archiv löschen
unlink(zip.pdf)







#'# Frequenztabellen erstellen



#+
#'## CE-BVerfG auf Corona-Entscheidungen reduzieren

dt.corona <- dt.bverfg[doc_id %in% keep.txt]


#'## Funktion anzeigen

#+ results = "asis"
print(f.fast.freqtable)


#'## Ignorierte Variablen
print(varremove)



#'## Liste zu prüfender Variablen

varlist <- names(dt.corona)

varlist <- setdiff(varlist,
                   varremove)

print(varlist)



#'## Frequenztabellen erstellen

prefix <- paste0(datasetname,
                 "_00_Frequenztabelle_var-")


#+ results = "asis"
f.fast.freqtable(dt.corona,
                 varlist = varlist,
                 sumrow = TRUE,
                 output.list = FALSE,
                 output.kable = TRUE,
                 output.csv = TRUE,
                 outputdir = outputdir,
                 prefix = prefix,
                 align = c("p{5cm}",
                           rep("r", 4)))





#'# Diagramm Kopieren

rechteckig <- list.files(outputdir, pattern = "Rechteckig.*\\.pdf",
                         full.names = TRUE)

rechteckig.path <- gsub("//",
                        "/",
                        rechteckig)

rechteckig.file <- gsub(".+//(.+)",
                        "\\1",
                        rechteckig)

rechteckig.file <- gsub("01",
                        paste0(datestamp,
                               "_ANALYSE_01"),
                        rechteckig.file)

rechteckig.file <- gsub("-1\\.pdf",
                        "\\.pdf",
                        rechteckig.file)


file.copy(rechteckig.path,
          rechteckig.file)








#'# Erstellen der ZIP-Archive

#+
#'## Verpacken der Analyse-Dateien

zip(paste0(datasetname,
           "_",
           datestamp,
           "_DE_",
           basename(outputdir),
           ".zip"),
    basename(outputdir))





#'## Verpacken der Source-Dateien

files.source <- c(list.files(pattern = "Source"),
                  "buttons")


files.source <- grep("spin",
                     files.source,
                     value = TRUE,
                     ignore.case = TRUE,
                     invert = TRUE)

zip(paste(datasetname,
           datestamp,
           "Source_Files.zip",
           sep = "_"),
    files.source)





#'# Kryptographische Hashes
#' Dieses Modul berechnet für jedes ZIP-Archiv zwei Arten von Hashes: SHA2-256 und SHA3-512. Mit diesen kann die Authentizität der Dateien geprüft werden und es wird dokumentiert, dass sie aus diesem Source Code hervorgegangen sind. Die SHA-2 und SHA-3 Algorithmen sind äußerst resistent gegenüber *collision* und *pre-imaging* Angriffen, sie gelten derzeit als kryptographisch sicher. Ein SHA3-Hash mit 512 bit Länge ist nach Stand von Wissenschaft und Technik auch gegenüber quantenkryptoanalytischen Verfahren unter Einsatz des *Grover-Algorithmus* hinreichend resistent.

#+
#'## Liste der ZIP-Archive erstellen
files.zip <- list.files(pattern = "\\.zip$",
                        ignore.case = TRUE)


#'## Funktion anzeigen
#+ results = "asis"
print(f.dopar.multihashes)

#'## Hashes berechnen
multihashes <- f.dopar.multihashes(files.zip)


#'## In Data Table umwandeln
setDT(multihashes)



#'## Index hinzufügen
multihashes$index <- seq_len(multihashes[,.N])


#'\newpage
#'## In Datei schreiben
fwrite(multihashes,
       paste(datasetname,
             datestamp,
             "KryptographischeHashes.csv",
             sep = "_"),
       na = "NA")


#'## Leerzeichen hinzufügen um Zeilenumbruch zu ermöglichen
multihashes$sha3.512 <- paste(substr(multihashes$sha3.512, 1, 64),
                              substr(multihashes$sha3.512, 65, 128))



#'## In Bericht anzeigen

kable(multihashes[,.(index,filename)],
      format = "latex",
      align = c("p{1cm}",
                "p{13cm}"),
      booktabs = TRUE,
      longtable = TRUE)


#'\newpage
kable(multihashes[,.(index,sha2.256)],
      format = "latex",
      align = c("c",
                "p{13cm}"),
      booktabs = TRUE,
      longtable = TRUE)



kable(multihashes[,.(index,sha3.512)],
      format = "latex",
      align = c("c",
                "p{13cm}"),
      booktabs = TRUE,
      longtable = TRUE)







#'# Abschluss


#+
#'## Datumsstempel
#' Hinweis: der Datumsstempel weicht vom Zeitpunkt der tatsächlichen Erstellung des Datensatzes ab, weil sich der Datumsstempel nach dem Tag des Abrufs des CE-BVerfG richtet.

print(datestamp)

#'## Datum und Uhrzeit (Anfang)
print(begin.script)

#'## Datum und Uhrzeit (Ende)
end.script <- Sys.time()
print(end.script)

#'## Laufzeit des gesamten Skriptes
print(end.script - begin.script)


#'## Warnungen
warnings()



#'# Parameter für strenge Replikationen

system2("openssl", "version", stdout = TRUE)

sessionInfo()


#'# Literaturverzeichnis

