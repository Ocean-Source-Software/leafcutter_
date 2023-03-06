params.bamsIdentifierGroupA = "CEU"
params.bamsIdentifierGroupB = "YRI"
params.bamsDir = "gs://leafcutter-inputs/bams"
params.annotation = "gs://leafcutter-inputs/annotations/gencode.v19.annotation.gtf.gz"
params.exons = "gs://leafcutter-inputs/annotations/gencode19_exons.txt.gz"
params.annotationDir = "gs://leafcutter-inputs/annotations"
params.annotationCode = "gencode_hg19"

process makeJuncFiles {
  
  publishDir 'test-outputs'
  cpus 2
  container 'oceansource/leafcutter:workflows'
  containerOptions = "--user root"
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

process plot {
  
  publishDir 'test-outputs'
  cpus 2
  container 'oceansource/leafcutter:workflows'
  containerOptions = "--user root"

  input:
    path exons
    path perind_file
    path groups_file
    path cluster_significance

  output:
    path '*.pdf'
    
  """
  ds_plots.R -e $exons $perind_file $groups_file $cluster_significance -f 0.05
  """

}

process outlierAnalysis {

  publishDir 'test-outputs'
  cpus 2
  container 'oceansource/leafcutter:workflows'
  containerOptions = '--user root'

  input:
    path numers_counts

  output:
    path '*outlier_clusterPvals.txt'
    path '*outlier_effSize.txt'
    path '*outlier_pVals.txt'
  
  """
  leafcutterMD.R --num_threads 8 $numers_counts
  """
   
}

process vis_prepare {

  publishDir 'test-outputs'
  cpus 2
  container 'oceansource/leafcutter:workflows'
  containerOptions = '--user root'
  

  input:
    path groups_file
    path perind_file
    path cluster_significance
    path effect_size
    val annotationCode
    path annotations

  output:
    path '*'

  """
  prepare_results.R -m $groups_file -f 0.5 $perind_file $cluster_significance $effect_size $annotationCode
  """

}

workflow {
  groupA = Channel.fromPath("${params.bamsDir}/*${params.bamsIdentifierGroupA}*.bam")
  groupB = Channel.fromPath("${params.bamsDir}/*${params.bamsIdentifierGroupB}*.bam")
  allBams = groupA.concat(groupB)
  annotation = Channel.fromPath(params.annotation)
  annotations = Channel.fromPath("${params.annotationDir}/**${params.annotationCode}_*")
  result = makeJuncFiles(allBams).collect()
  perind_file = cluster(result)
  (effect_size, cluster_significance, groups_file) = differential_splicing(groupA.collect(), groupB.collect(), perind_file, params.bamsIdentifierGroupA, params.bamsIdentifierGroupB)
  (plot_pdf, sout) = plot(params.exons, perind_file, groups_file, cluster_significance)
  (cluster_pvals, eff_size, pvals) = outlierAnalysis(perind_file)
  pvals.view()
  // vis_prepare(groups_file, perind_file, cluster_significance, effect_size, params.annotationCode, annotations.collect())
}