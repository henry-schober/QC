process OUTPUT_COMBINE {
    label 'process_low'

    input:
    path(input_files)

    output:
    path("all_assemblyStats.tsv")       , emit: assemblyStats
   
    script: 
    def prefix
    """
    file_array=(\$(ls ${input_files}))

    output_file="\${file_array[0]}"

    # Loop through the rest of the files and join them one by one
    for file in "\${file_array[@]:1}"; do
        tmp_file=\$(mktemp)
        join "\$output_file" "\$file" > "\$tmp_file"
        mv "\$tmp_file" "\$output_file"
    done

    # Optionally save the final output to a file
    mv "\$output_file" all_assemblyStats.tsv
    """
}
