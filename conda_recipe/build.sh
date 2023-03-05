#!/bin/bash

set -e -x

mkdir -p $PREFIX/bin
cp clustering/* $PREFIX/bin
cp scripts/* $PREFIX/bin
cp leafviz/prepare_results.R $PREFIX/bin
chmod +x $PREFIX/bin/*

pushd ./leafcutter
# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old >DESCRIPTION

$R -e "install.packages('TailRank', repos='http://R-Forge.R-project.org')
"
$R CMD INSTALL --build .
popd
