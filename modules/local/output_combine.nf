process OUTPUT_COMBINE {
    label 'process_low'

    input:
    tuple val(num), path(input_files)

    output:
    path("all_assemblyStats.tsv")       , emit: assemblyStats
   
    script: 
    def prefix
    """
    file_array_1=(\$(ls ${input_files}))

    echo \${file_array_1} > file_names.txt

    file_array_2=(\$(sort -n -k1,1 <(wc -L < file_names.txt)))

    output_file="\${file_array[0]}"

    # Loop through the rest of the files and join them one by one
    for file in "\${file_array[@]:1}"; do
        tmp_file=\$(mktemp)
        join -t \$'\\t' "\$output_file" "\$file" > "\$tmp_file"
        mv "\$tmp_file" "\$output_file"
    done

    # Optionally save the final output to a file
    mv "\$output_file" all_assemblyStats.tsv
    """
}
