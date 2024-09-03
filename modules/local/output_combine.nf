process OUTPUT_COMBINE {
    label 'process_low'

    input:
    path(files)

    output:
    path("all_assemblyStats.txt")       , emit: assemblyStats
   
    script: 
    def prefix
    """
    paste -d '\\t\\t' $files > all_assemblyStats.txt
    """
}
