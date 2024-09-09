process OUTPUT_COMBINE {
    label 'process_low'

    input:
    path(files)

    output:
    path("all_assemblyStats.tsv")       , emit: assemblyStats
   
    script: 
    def prefix
    """
    file=\$files
    join -t \$'\\t' <(join -t \$'\\t' "${file[0]}" "${file[1]}") "${file[2]}" >> all_assemblyStats.tsv

    """
}
