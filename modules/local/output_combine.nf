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
        # First pass: Calculate the maximum length for each column
        for (i = 1; i <= NF; i++) {
            len = length($i)
            if (len > max_lengths[i]) {
                max_lengths[i] = len
            }
        }

        # Store the line fields for printing in the END block
        for (i = 1; i <= NF; i++) {
            lines[NR, i] = $i
        }
    }

    END {
        # Second pass: Print each line with padded columns
        for (j = 1; j <= NR; j++) {
            for (i = 1; i <= NF; i++) {
                # Print the column with padding for alignment
                printf "%-*s", max_lengths[i] + 2, lines[j, i]
            }
            print ""
        }
    }' > all_assemblyStats.txt
    """
}
