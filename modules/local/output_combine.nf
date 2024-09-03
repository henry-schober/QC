process OUTPUT_COMBINE {
    label 'process_low'

    input:
    path(files)

    output:
    path("all_assemblyStats.txt")       , emit: assemblyStats
   
    script: 
    def prefix
    """
     paste $files | awk '
    {
        # Find the maximum length of each column
        for (i = 1; i <= NF; i++) {
            len = length(\$i)
            if (len > max_lengths[i]) {
                max_lengths[i] = len
            }
        }

        # Store the line fields for printing
        for (i = 1; i <= NF; i++) {
            lines[NR, i] = \$i
        }
    }

    END {
        # Print each line with padded columns
        for (j = 1; j <= NR; j++) {
            for (i = 1; i <= NF; i++) {
                # Print the column with padding and additional space
                printf "%-*s ", max_lengths[i] + 2, lines[j, i]
            }
            print ""
        }
    }' > all_assemblyStats.txt
    """
}
