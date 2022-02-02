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
#'      in_header: tex/Preamble_DE.tex
#'      before_body: [temp/BVerfG-Corona_Definitions.tex, tex/BVerfG-Corona_CompilationTitle.tex]
#'bibliography: temp/packages.bib
#'nocite: '@*'
#' ---


#+ echo = FALSE 
knitr::opts_chunk$set(echo = TRUE,
                      warning = TRUE,
                      message = TRUE)


#'\newpage


#+ results = "asis", echo = FALSE
cat(readLines("README.md"),
    sep = "\n")





#'# Vorbereitung

#'## Datumsstempel
#' Dieser Datumsstempel wird in alle Dateinamen eingefügt. Er wird am Anfang des Skripts gesetzt, für den den Fall, dass die Laufzeit die Datumsbarriere durchbricht.




#'## Datum und Uhrzeit (Beginn)
begin.script <- Sys.time()
print(begin.script)





#+
#'## Packages Laden

library(RcppTOML)     # Verarbeitung von TOML-Format
library(ggplot2)      # Fortgeschrittene Datenvisualisierung
library(rmarkdown)    # Wissenschaftliches Reporting
library(knitr)        # Wissenschaftliches Reporting
library(kableExtra)   # Verbesserte Kable Tabellen
library(data.table)   # Fortgeschrittene Datenverarbeitung
library(quanteda)     # Fortgeschrittenes Natural Language Processing
library(quanteda.textplots) # Quanteda: Diagramme
library(future)       # Parallelisierung mit Futures
library(future.apply) # Apply-Funtionen für Futures





#'## Zusätzliche Funktionen einlesen
#' **Hinweis:** Die hieraus verwendeten Funktionen werden jeweils vor der ersten Benutzung in vollem Umfang angezeigt um den Lesefluss zu verbessern.

source("R-fobbe-proto-package/f.fast.freqtable.R")
source("R-fobbe-proto-package/f.future_multihashes.R")



#'## Verzeichnis für Analyse-Ergebnisse und Diagramme definieren

dir.analysis <- paste0(getwd(),
                    "/analyse") 


#'## Weitere Verzeichnisse definieren

dirs <- c("output",
          "temp",
          "data")



#'## Dateien aus vorherigen Runs bereinigen

unlink(dir.analysis,
       recursive = TRUE)

unlink(dirs,
       recursive = TRUE)

files.delete <- list.files(pattern = "\\.zip|\\.jpe?g|\\.png|\\.gif|\\.pdf|\\.txt|\\.bib|\\.csv|\\.spin\\.|\\.log|\\.html?",
                           ignore.case = TRUE)


unlink(files.delete)




#'## Verzeichnisse anlegen

dir.create(dir.analysis)

lapply(dirs, dir.create)




#'## Vollzitate statistischer Software schreiben
knitr::write_bib(c(.packages()),
                 "temp/packages.bib")





#'## Allgemeine Konfiguration

#+
#'### Konfiguration einlesen
config <- parseTOML("BVerfG-Corona_Config.toml")

#'### Konfiguration anzeigen
print(config)



#+
#'### Knitr Optionen setzen
knitr::opts_chunk$set(fig.path = paste0(dir.analysis, "/"),
                      dev = config$fig$format,
                      dpi = config$fig$dpi,
                      fig.align = config$fig$align)


#'### Download Timeout setzen
options(timeout = config$download$timeout)



#'### Quellenangabe für Diagramme definieren

caption <- paste("Fobbe | DOI:",
                 config$doi$data$version)
print(caption)


#'### Präfix für Dateien definieren

prefix.files <- paste0(config$project$shortname,
                 "_",
                 config$cebverfg$date)
print(prefix.files)


#'### Präfix für Diagramme definieren

prefix.figuretitle <- paste(config$project$shortname,
                            "| Version",
                            config$cebverfg$date)


#'### Quanteda-Optionen setzen
quanteda_options(tokens_locale = config$quanteda$tokens_locale)




#'## LaTeX Konfiguration

#+
#'### LaTeX Parameter definieren

latexdefs <- c("%===========================\n% Definitionen\n%===========================",
               "\n% NOTE: Diese Datei wurde während des Kompilierungs-Prozesses automatisch erstellt.\n",
               "\n%-----Autor-----",
               paste0("\\newcommand{\\projectauthor}{",
                      config$project$author,
                      "}"),
               "\n%-----Version-----",
               paste0("\\newcommand{\\version}{",
                      config$cebverfg$date,
                      "}"),
               "\n%-----Titles-----",
               paste0("\\newcommand{\\datatitle}{",
                      config$project$fullname,
                      "}"),
               paste0("\\newcommand{\\datashort}{",
                      config$project$shortname,
                      "}"),
               paste0("\\newcommand{\\softwaretitle}{Source Code des \\enquote{",
                      config$project$fullname,
                      "}}"),
               paste0("\\newcommand{\\softwareshort}{",
                      config$project$shortname,
                      "-Source}"),
               "\n%-----Data DOIs-----",
               paste0("\\newcommand{\\dataconceptdoi}{",
                      config$doi$data$concept,
                      "}"),
               paste0("\\newcommand{\\dataversiondoi}{",
                      config$doi$data$version,
                      "}"),
               paste0("\\newcommand{\\dataconcepturldoi}{https://doi.org/",
                      config$doi$data$concept,
                      "}"),
               paste0("\\newcommand{\\dataversionurldoi}{https://doi.org/",
                      config$doi$data$version,
                      "}"),
               "\n%-----Software DOIs-----",
               paste0("\\newcommand{\\softwareconceptdoi}{",
                      config$doi$software$concept,
                      "}"),
               paste0("\\newcommand{\\softwareversiondoi}{",
                      config$doi$software$version,
                      "}"),
               paste0("\\newcommand{\\softwareconcepturldoi}{https://doi.org/",
                      config$doi$software$concept,
                      "}"),
               paste0("\\newcommand{\\softwareversionurldoi}{https://doi.org/",
                      config$doi$software$version,
                      "}"))




#'### LaTeX Parameter schreiben

writeLines(latexdefs,
           paste0("temp/",
                  config$project$shortname,
                  "_Definitions.tex"))






#'## Parallelisierung aktivieren
#' Parallelisierung wird zur Beschleunigung der Konvertierung von PDF zu TXT und der Datenanalyse mittels **quanteda** und **data.table** verwendet. Die Anzahl threads wird automatisch auf das verfügbare Maximum des Systems gesetzt, kann aber auch nach Belieben auf das eigene System angepasst werden. Die Parallelisierung kann deaktiviert werden, indem die Variable **fullCores** auf 1 gesetzt wird.



#+
#'### Anzahl logischer Kerne festlegen

if (config$cores$max == TRUE){
    fullCores <- availableCores()
}


if (config$cores$max == FALSE){
    fullCores <- as.integer(config$cores$number)
}



print(fullCores)

#'### Quanteda
quanteda_options(threads = fullCores) 

#'### Data.table
setDTthreads(threads = fullCores)  







#'# Stamm-Datensatz einlesen (CE-BVerfG)
#' Der Stamm-Datensatz ist der \enquote{Corpus der Entscheidungen des Bundesverfassungsgerichts} (CE-BVerfG). Dieser enthält alle vom Bundesverfassungsgericht seit 1998 veröffentlichten Entscheidungen. Dessen **aktuellste** Version ist immer über diesen Digital Object Identifier (DOI) abrufbar: \url{https://doi.org/10.5281/zenodo.3902658}

#+
#'## Download der CSV-Datei
#' Der Datensatz im CSV-Format wird automatisch über einen verschlüsselten und langzeit-stabilen Link aus dem wissenschaftlichen Archiv des CERN heruntergeladen. Dieses Vorgehen garantiert die Verwendung einer authentischen Version des Datensatzes.


zip.csv <- paste0("CE-BVerfG_",
                  config$cebverfg$date,
                  "_DE_CSV_Datensatz.zip")

print(zip.csv)


link.csv <- paste0("https://zenodo.org/record/",
                   gsub("10\\.5281/zenodo\\.([0-9]+)",
                        "\\1",
                        config$cebverfg$doi$data$version),
                   "/files/",
                   zip.csv,
                   "?download=1")

print(link.csv)


if (file.exists(file.path("data", zip.csv)) == FALSE){

    download.file(link.csv,
                  file.path("data", zip.csv))

}


#'## CSV-Datei einlesen
dt.bverfg <- fread(cmd = paste("unzip -cq",
                               file.path("data", zip.csv)))




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

file.kwic.sansdate <- paste(config$project$shortname,
                            "02_KeywordsInContext.csv",
                            sep = "_")

file.kwic.date <- paste(prefix.files,
                        "ANALYSE_02_KeywordsInContext.csv",
                        sep = "_")


fwrite(data.frame(kwic),
       file.path(dir.analysis,
              file.kwic.sansdate))


fwrite(data.frame(kwic),
       file.path("output",
                 file.kwic.date))






#'# Lexical Dispersion Plot
#'Lexical Dispersion Plots zeigen mit einem vertikalen Strich an, an welcher Stelle in einem Dokument sich ein Token befindet. Alle Dokumente sind auf eine Länge von 1.0 normalisiert, d.h. ein Wert von 0.5 heißt immer, dass sich das Token in der Mitte des jeweiligen Dokumentes befindet. Viele und/oder dicke Striche deuten auf eine große Häufigkeit des Tokens hin.


#+
#'## Rechteckiges Format

#+ BVerfG-Corona_01_LexicalDispersion_Rechteckig, fig.height = 16, fig.width = 12

textplot_xray(kwic,
              scale = "relative")+
    labs(
        title = paste(prefix.figuretitle,
                      "| Lexical Dispersion Plot"),
        caption = caption)+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )



#'\newpage
#'## A4-Format

#+ BVerfG-Corona_01_LexicalDispersion_A4, fig.height = 11.7, fig.width = 8.3

textplot_xray(kwic,
              scale = "relative")+
    labs(
        title = paste(prefix.figuretitle,
                      "| Lexical Dispersion Plot"),
        caption = caption)+
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
                  config$cebverfg$date,
                  "_DE_TXT_Datensatz.zip")


link.txt <- paste0("https://zenodo.org/record/",
                   gsub("10\\.5281/zenodo\\.([0-9]+)",
                        "\\1",
                        config$cebverfg$doi$data$version),
                   "/files/",
                   zip.txt,
                   "?download=1")

zip.txt.rel <- file.path("data", zip.txt)



if(file.exists(zip.txt.rel) == FALSE){

    download.file(link.txt,
                  zip.txt.rel)

}


#'## ZIP-Archiv entpacken
unzip(zip.txt.rel,
      exdir = ".")


#'## Corona-Entscheidungen verpacken

zip(file.path("output",
              paste(prefix.files,
                    "DE_TXT_Datensatz.zip",
                    sep = "_")),
    keep.txt)


#'## TXT-Dateien löschen

files.txt <- list.files(pattern = ".txt")

unlink(files.txt)




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
                   config$cebverfg$date,
                   "_DE_PDF_Datensatz.zip")


link.pdf <- paste0("https://zenodo.org/record/",
                   gsub("10\\.5281/zenodo\\.([0-9]+)",
                        "\\1",
                        config$cebverfg$doi$data$version),
                   "/files/",
                   zip.pdf,
                   "?download=1")

zip.pdf.rel <- file.path("data", zip.pdf)


if(file.exists(zip.pdf.rel) == FALSE){

    download.file(link.pdf,
                  zip.pdf.rel)

}



#'## ZIP-Archiv entpacken
unzip(zip.pdf.rel,
      exdir = ".")


#'## Corona-Entscheidungen verpacken

zip(file.path("output",
              paste(prefix.files,
                    "DE_PDF_Datensatz.zip",
                    sep = "_")),
    keep.pdf)


#'## PDF-Dateien löschen

files.pdf <- list.files(pattern = ".pdf")

unlink(files.pdf)








#'# Frequenztabellen erstellen



#+
#'## CE-BVerfG auf Corona-Entscheidungen reduzieren

dt.corona <- dt.bverfg[doc_id %in% keep.txt]


#'## Funktion anzeigen: f.fast.freqtable

#+ results = "asis"
print(f.fast.freqtable)


#'## Ignorierte Variablen
print(config$freqtable$ignore)



#'## Liste zu prüfender Variablen

varlist <- names(dt.corona)

varlist <- setdiff(varlist,
                   config$freqtable$ignore)

print(varlist)



#'## Frequenztabellen erstellen

prefix <- paste0(config$project$shortname,
                 "_00_Frequenztabelle_var-")


#+ results = "asis"
f.fast.freqtable(dt.corona,
                 varlist = varlist,
                 sumrow = TRUE,
                 output.list = FALSE,
                 output.kable = TRUE,
                 output.csv = TRUE,
                 outputdir = dir.analysis,
                 prefix = prefix,
                 align = c("p{5cm}",
                           rep("r", 4)))





#'# Diagramm Kopieren

rechteckig <- list.files(dir.analysis,
                         pattern = "Rechteckig.*\\.pdf",
                         full.names = TRUE)

rechteckig.path <- gsub("//",
                        "/",
                        rechteckig)

rechteckig.file <- gsub(".+//(.+)",
                        "\\1",
                        rechteckig)

rechteckig.file <- gsub("01",
                        paste0(config$cebverfg$date,
                               "_ANALYSE_01"),
                        rechteckig.file)

rechteckig.file <- gsub("-1\\.pdf",
                        "\\.pdf",
                        rechteckig.file)


file.copy(rechteckig.path,
          file.path("output",
                    rechteckig.file))








#'# Erstellen der ZIP-Archive

#+
#'## Verpacken der Analyse-Dateien

zip(paste0(prefix.files,
           "_DE_ANALYSE.zip"),
    basename(dir.analysis))





#'## Verpacken der Source-Dateien

files.source <- c(list.files(pattern = "\\.R$|\\.toml$"),
                  "CHANGELOG.md",
                  "README.md",
                  "R-fobbe-proto-package",
                  "buttons",
                  "tex",
                  "gpg",
                  list.files(pattern = "renv\\.lock|\\.Rprofile",
                             all.files = TRUE),
                  list.files("renv",
                             pattern = "activate\\.R",
                             full.names = TRUE))


files.source <- grep("spin",
                     files.source,
                     value = TRUE,
                     ignore.case = TRUE,
                     invert = TRUE)

zip(paste(prefix.files,
          "Source_Files.zip",
          sep = "_"),
    files.source)





#'# Kryptographische Hashes
#' Dieses Modul berechnet für jedes ZIP-Archiv zwei Arten von Hashes: SHA2-256 und SHA3-512. Mit diesen kann die Authentizität der Dateien geprüft werden und es wird dokumentiert, dass sie aus diesem Source Code hervorgegangen sind. Die SHA-2 und SHA-3 Algorithmen sind äußerst resistent gegenüber *collision* und *pre-imaging* Angriffen, sie gelten derzeit als kryptographisch sicher. Ein SHA3-Hash mit 512 bit Länge ist nach Stand von Wissenschaft und Technik auch gegenüber quantenkryptoanalytischen Verfahren unter Einsatz des *Grover-Algorithmus* hinreichend resistent.

#+
#'## Liste der ZIP-Archive erstellen
files.zip <- list.files(pattern = "\\.zip$",
                        ignore.case = TRUE)


#'## Funktion anzeigen: future_multihashes

print(f.future_multihashes)


#'## Hashes berechnen


if(config$parallel$multihashes == TRUE){

    plan("multicore",
         workers = fullCores)
    
}else{

    plan("sequential")

     }


multihashes <- f.future_multihashes(files.zip)




#'## In Data Table umwandeln
setDT(multihashes)

setnames(multihashes,
         old = "x",
         new = "filename")


#'## Index hinzufügen
multihashes$index <- seq_len(multihashes[,.N])

#'\newpage
#'## In Datei schreiben
fwrite(multihashes,
       file.path("output",
                 paste(prefix.files,
                       "KryptographischeHashes.csv",
                       sep = "_")),
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




#'# Aufräumen

files.output <- list.files(pattern = "\\.zip")

output.destination <- file.path("output",
                                 files.output)

print(files.output)

file.rename(files.output,
            output.destination)







#'# Abschluss


#+
#'## Datumsstempel
#' Hinweis: der Datumsstempel weicht vom Zeitpunkt der tatsächlichen Erstellung des Datensatzes ab, weil sich der Datumsstempel nach dem Tag des Abrufs des CE-BVerfG richtet.

print(config$cebverfg$date)

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



#+ results = "asis", echo = FALSE
cat(readLines("CHANGELOG.md"),
    sep = "\n")


#'# Literaturverzeichnis

