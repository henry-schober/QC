process OUTPUT {
    label 'process_low'

    input:
    tuple val(meta), path(ch_quast_tsv), path(ch_busco), path(ch_merqury)

    output:
    path("*.assemblyStats.txt")       , emit: assemblyStats
   
    script: 
    def prefix 
    def completeness = "${ch_busco}"
    def auto_busco = completeness.contains('summary.txt') ? 'cat ${ch_busco} >> \$prefix.assemblyStats.txt' : 'grep -A 17 "Results:" $ch_busco >> \$prefix.assemblyStats.txt'
    """
    prefix=\$(awk 'NR==1 {print \$2}' $ch_quast_tsv)
    echo -ne "quast output\n" >> \$prefix.assemblyStats.txt
    less $ch_quast_tsv >> \$prefix.assemblyStats.txt

    echo -ne "\n completeness score\n" >> \$prefix.assemblyStats.txt
    $auto_busco

    echo -ne "merqury quality score\n" >> \$prefix.assemblyStats.txt
    awk '{ print \$4 }' $ch_merqury >> \$prefix.assemblyStats.txt
    """
}
