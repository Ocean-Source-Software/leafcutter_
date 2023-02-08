#!/bin/bash

set -e -x

pushd ./leafcutter
# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old >DESCRIPTION

$R -e "install.packages('TailRank', repos='http://R-Forge.R-project.org')
"
$R CMD INSTALL --build .
popd
