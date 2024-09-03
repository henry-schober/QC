process OUTPUT_COMBINE {
    label 'process_low'

    input:
    path(files)

    output:
    path("all_assemblyStats.txt")       , emit: assemblyStats
   
    script: 
    def prefix
    """
    join -1 1 -2 2 $files -t $'\\t'> all_assemblyStats.txt
    """
}
