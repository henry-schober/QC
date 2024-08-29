process OUTPUT_COMBINE {
    label 'process_low'

    input:
    path(files)

    output:
    path("assemblyStats.txt")       , emit: assemblyStats
   
    script: 
    def prefix
    """
    paste *.txt > all_assemblyStats.txt
    """
}
