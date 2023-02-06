#!/bin/bash

set -e -x

pushd ./leafcutter
# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old >DESCRIPTION

yes | mamba install r-base r-bh r-dt r-hmisc r-r.utils r-rcpp r-rcppeigen r-stanheaders r-domc r-dplyr r-foreach r-ggplot2 r-gridextra r-intervals r-optparse r-reshape2 r-rstan r-shiny r-shinyjs r-shinycssloaders r-roxygen2 bioconductor-dirichletmultinomial r-rstantools r-essentials samtools
Rscript -e 'if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager", repos="http://cran.us.r-project.org")

BiocManager::install("Biobase")
install.packages("TailRank", repos="http://R-Forge.R-project.org")
'

R CMD INSTALL --build .
popd
