params.bamsIdentifierGroupA = "CEU"
params.bamsIdentifierGroupB = "YRI"
params.bamsDir = "gs://leafcutter-inputs/bams"

process makeJuncFiles {
  
  input:
    path bamFile

  output:
    path "${bamFile}.junc"

  """
  touch ${bamFile}.bed
  touch ${bamFile}.junc
  samtools view $bamFile | filter_cs.py | sam2bed.pl --use-RNA-strand - ${bamFile}.bed
  bed2junc.pl ${bamFile}.bed ${bamFile}.junc  
  """
}

process sortJuncFiles {
  
  input:
    path juncFile

  output:
    path "${juncFile}.sorted"

  """
  sort -n -k2,2 -k3,3 -k5,5 ${juncFile} > ${juncFile}.sorted
  """
}


workflow {
  groupA = Channel.fromPath("${params.bamsDir}/*${params.bamsIdentifierGroupA}*.bam")
  groupB = Channel.fromPath("${params.bamsDir}/*${params.bamsIdentifierGroupB}*.bam")
  allBams = groupA.concat(groupB)
  juncs = makeJuncFiles(allBams)
  sortJuncFiles(juncs)
}
