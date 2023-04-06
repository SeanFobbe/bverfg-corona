#!/bin/Rscript

#'# Vorbereitung


datestamp <- Sys.Date()

library(rmarkdown)
library(RcppTOML)




#'# Aufräumen


files.delete <- list.files(pattern = "\\.zip|\\.jpe?g|\\.png|\\.gif|\\.pdf|\\.txt|\\.bib|\\.csv|\\.spin\\.|\\.log|\\.html?",
                           ignore.case = TRUE)

unlink(files.delete)

unlink("output", recursive = TRUE)
unlink("analyse", recursive = TRUE)
unlink("ANALYSE", recursive = TRUE)
unlink("temp", recursive = TRUE)
unlink("data", recursive = TRUE)






#+
#'# Datensatz 
#' 


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

