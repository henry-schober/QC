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
        # Calculate the maximum length of the first column
        max_length = 0
        for (i = 1; i <= NF; i+=2) {
            if (length($i) > max_length) max_length = length($i)
        }

        # Print the first column with the necessary padding, followed by the second column
        for (i = 1; i <= NF; i+=2) {
            printf "%-*s\t", max_length + 1, $i
            if (i+1 <= NF) print $(i+1)
            else print ""
        }
    }' > all_assemblyStats.txt
    """
}
