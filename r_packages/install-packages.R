cran_mirror <- "http://cran.ma.imperial.ac.uk/"
cran_packages <- c("devtools",
                   "plotly",
                   "d3heatmap",
                   "VennDiagram",
                   "kohonen",
                   "pROC",
                   "tidyr",
                   "networkD3",
                   "nloptr",
                   "stats",
                   "pairsD3",
                   "genefilter",
                   "base64enc",
                   "colorspace",
                   "htmlwidgets",
                   "png",
                   "randomForest",
                   "RPostgreSQL",
                   "pls",
                   "caret",
                   "e1071",
                   "gplots",
                   "ellipse",
                   "jsonlint",
                   "plyr")

for (pkg in cran_packages)
  if(!do.call(require, list(pkg)))
    install.packages(pkg, repo=cran_mirror)

install.packages("XML", repos = "http://www.omegahat.net/R")

bioc_packages <- c("Biobase",
                   "annotate",
                   "limma",
                   "genefilter",
                   "ropls",
                   "SSPA",
                   "timecourse",
                   "pcaMethods",
                   "impute"
                   )

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install(bioc_packages)

if (!require("devtools")) install.packages("devtools")
devtools::install_github("rstudio/d3heatmap")