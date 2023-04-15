params.juncsDir = "test-outputs"

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
  juncs = Channel.fromPath("${params.juncsDir}/*.junc")
  result = sortJuncFiles(juncs)
}
