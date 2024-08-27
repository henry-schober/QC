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

    # Check if assemblyStats.txt exists
    if [[ -f assemblyStats.txt ]]; then
        paste assemblyStats.txt \$content >> temp.txt
    else
        paste \$content > temp.txt
    fi
    
    mv temp.txt assemblyStats.txt
    """
}
