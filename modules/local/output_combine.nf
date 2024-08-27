process OUTPUT_COMBINE {
    label 'process_low'

    input:
    path(stat_file1), path(stat_file2)

    output:
    tuple val(meta), path("assemblyStats.txt")       , emit: assemblyStats
   
    script: 
    def prefix
    """
    content=\$(echo '${stat_files}')

    for f in *.txt
        do
        paste $content >> assemblyStats.txt
        done

    """
}
