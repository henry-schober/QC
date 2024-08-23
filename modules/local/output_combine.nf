process OUTPUT_COMBINE {
    label 'process_low'

    input:
    tuple val(meta), path(stat_files)

    output:
    tuple val(meta), path("*.assemblyStats.txt")       , emit: assemblyStats
   
    script: 
    def prefix
    """

    """
}
