params.juncsDir = "gs://leafcutter-inputs/cached-intermediary-outputs"

process cluster {

  input:
    path juncFiles

  output:
    path '*perind_numers.counts.gz'

  """
  printf "%s\n" $juncFiles > junction_files.txt
  leafcutter_cluster.py -j junction_files.txt -m 30 -o leafcutter -l '100000' -r . -p '0.001'
  """
}

process sortPerindFile {
  
  input:
    path perind_file

  output:
    path "${perind_file}.sorted"

  """
  zcat ${perind_file} | sort -n -t ':' -k2,2 -k3,3 > ${perind_file}.sorted
  """
}

workflow {
  juncs = Channel.fromPath("${params.juncsDir}/*.junc")
  perind_file = cluster(juncs.collect())
  sortPerindFile(perind_file)
}