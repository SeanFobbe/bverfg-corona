#!/bin/Rscript

#'# Vorbereitung


datestamp <- Sys.Date()

library(rmarkdown)
library(RcppTOML)




#'# Aufräumen

source("delete_all_data.R")




#+
#'# Datensatz erstellen
 


config <- parseTOML("config.toml")


begin.compreport <- Sys.time()

rmarkdown::render(input = "BVerfG-Corona_CorpusCreation.R",
                  envir = new.env(),
                  output_file = paste0("BVerfG-Corona_",
                                       config$cebverfg$date,
                                       "_CompilationReport.pdf"),
                  output_dir = "output")


end.compreport <- Sys.time()

print(end.compreport-begin.compreport)

