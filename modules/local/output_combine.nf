process OUTPUT_COMBINE {
    label 'process_low'

    input:
    path(files)

    output:
    path("all_assemblyStats.txt")       , emit: assemblyStats
   
    script: 
    def prefix
    """
    paste $files | awk -v OFS="\\t\\t" '
    {
        # Loop through each field (each file content line)
        for (i = 1; i <= NF; i++) {
            # Find the maximum length of the fields across all lines
            if (length(\$i) > max_lengths[i]) {
                max_lengths[i] = length(\$i)
            }
            # Store the field in the lines array
            lines[NR, i] = \$i
        }
    }

    END {
        # Print each line with adjusted padding
        for (j = 1; j <= NR; j++) {
            for (i = 1; i <= NF; i++) {
                # Print each field (column) with proper padding
                printf "%-*s", max_lengths[i] + 2, lines[j, i]
            }
            print ""
        }
    }' > all_assemblyStats.txt
    """
}
