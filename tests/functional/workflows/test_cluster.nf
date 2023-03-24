params.juncsDir = "gs://leafcutter-inputs/cached-intermediary-outputs"

process cluster {

  publishDir 'test-outputs'
  cpus 2
  container 'oceansource/leafcutter:workflows'
  containerOptions = "--user root"
  input:
    path juncFiles

  output:
    path '*perind_numers.counts.gz'

  """
  printf "%s\n" $juncFiles > junction_files.txt
  leafcutter_cluster.py -j junction_files.txt -m 30 -o leafcutter -l '100000' -r . -p '0.001'
  """
}

// Run the workflow

workflow {
  juncs = Channel.fromPath("${params.juncsDir}/*.junc")
  cluster(juncs.collect())
}