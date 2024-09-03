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
    BEGIN { FS="\t"; OFS="\t" }

    {
        # Determine the number of fields (columns) in the current row
        num_fields = NF

        # Calculate the maximum width needed for each field
        for (i = 1; i <= num_fields; i++) {
            field_length = length($i)
            if (field_length > max_lengths[i]) {
                max_lengths[i] = field_length
            }
        }

        # Store each line's fields for later printing
        for (i = 1; i <= num_fields; i++) {
            lines[NR, i] = $i
        }
    }

    END {
        # Print the lines with properly aligned columns
        for (j = 1; j <= NR; j++) {
            for (i = 1; i <= num_fields; i++) {
                # Calculate padding needed for each column
                printf "%-*s", max_lengths[i] + 2, lines[j, i]
            }
            print ""
        }
    }' > all_assemblyStats.txt
    """
}
