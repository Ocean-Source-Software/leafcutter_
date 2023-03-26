params.bamsIdentifierGroupA = "CEU"
params.bamsIdentifierGroupB = "YRI"
params.bamsDir = "gs://leafcutter-inputs/bams"
params.perindFile = "gs://leafcutter-inputs/cached-intermediary-outputs/leafcutter_perind_numers.counts.gz"

process differential_splicing {
  
  publishDir 'test-outputs'
  cpus 2
  container 'oceansource/leafcutter:workflows'
  containerOptions = "--user root"
  
  input:
    path groupABams
    path groupBBams
    path perindCounts
    val groupAIdentifier
    val groupBIdentifier

  output:
    path '*effect_sizes.txt'
    path '*cluster_significance.txt'
    path 'groups_file.txt'
  """
  for file in $groupABams; do
    printf "%s\t%s\n" \$file $groupAIdentifier >> groups_file.txt
  done
  for file in $groupABams; do
    printf "%s\t%s\n" \$file $groupBIdentifier >> groups_file.txt
  done
  leafcutter_ds.R --num_threads 4 -i 3 $perindCounts groups_file.txt  
  """
}

workflow {
    groupA = Channel.fromPath("${params.bamsDir}/*${params.bamsIdentifierGroupA}*.bam")
    groupB = Channel.fromPath("${params.bamsDir}/*${params.bamsIdentifierGroupB}*.bam")
    perind_file = Channel.fromPath("${params.perindFile}")
    differential_splicing(groupA.collect(), groupB.collect(), perind_file, params.bamsIdentifierGroupA, params.bamsIdentifierGroupB) 
}