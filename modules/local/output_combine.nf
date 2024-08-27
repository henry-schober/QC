wprocess OUTPUT_COMBINE {
    label 'process_low'

    input:
    path(files)

    output:
    tuple val(meta), path("assemblyStats.txt")       , emit: assemblyStats
   
    script: 
    def prefix
    """
    content=\$(echo '${files[]}')

    for f in *.txt
        do
        paste $content >> assemblyStats.txt
        done

    """
}
