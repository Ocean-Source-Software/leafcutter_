params.perind_file = 'gs://leafcutter-inputs/cached-intermediary-outputs/leafcutter_perind_numers.counts.gz'

process outlierAnalysis {

  publishDir 'test-outputs'
  cpus 1
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

process sortOutlierFiles {

    publishDir 'test-outputs'
    cpus 2
    container 'oceansource/leafcutter:workflows'
    containerOptions = '--user root'
    
    input:
        path outlier_file

    output:
        path '*.txt.sorted'
    
    """
    sort -k1,1 -k2,2n -k3,3n $outlier_file > ${outlier_file}.sorted
    """
     
}

workflow {
    perind_file = Channel.fromPath(params.perind_file)
    outlierAnalysis(perind_file) | concat |  sortOutlierFiles
}