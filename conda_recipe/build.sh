#!/bin/bash

set -e -x

pushd ./leafcutter
# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old >DESCRIPTION

mamba install r-base r-bh r-dt r-hmisc r-r.utils r-rcpp r-rcppeigen r-stanheaders r-domc r-dplyr r-foreach r-ggplot2 r-gridextra r-intervals r-optparse r-reshape2 r-rstan r-shiny r-shinycssloaders r-roxygen2 bioconductor-dirichletmultinomial

$R CMD INSTALL --preclean --build .
popd
