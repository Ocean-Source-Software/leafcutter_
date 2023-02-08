#!/bin/bash

set -e -x

Rscript -e 'if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager", repos="http://cran.us.r-project.org")

BiocManager::install("Biobase")
BiocManager::install("DirichletMultinomial")
devtools::install_github("davidaknowles/leafcutter/leafcutter")
'
