process OUTPUT_COMBINE {
    label 'process_low'

    input:
    path(input_files)

    output:
    path("all_assemblyStats.tsv")       , emit: assemblyStats
   
    script: 
    def prefix
    """
    output_file="\${input_files[0]}"

    # Loop through the rest of the files and join them one by one
    for file in "\${input_files[@]:1}"; do
        output_file=\$(join  -t \$'\\t' "\$output_file" "\$file")
    done

    # Optionally save the final output to a file
    echo "\$output_file" >> all_assemblyStats.tsv
    """
}
