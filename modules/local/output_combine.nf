process OUTPUT_COMBINE {
    label 'process_low'

    input:
    path(files)

    output:
    path("all_assemblyStats.tsv")       , emit: assemblyStats
   
    script: 
    def prefix
    """
    file_array=(\$files)

    # Start with the first file
    output_file="${file_array[0]}"

    # Loop through the rest of the files and join them one by one
    for file in "${file_array[@]:1}"; do
        output_file=\$(join -t \$'\\t' "$output_file" "$file")
    done

    # Optionally save the final output to a file
    echo "$output_file" > all_assemblyStats.tsv
    """
}
