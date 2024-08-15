process EXTRACT_LR {
    tag "$meta.id"
    label 'process_low'

    container 'emilytrybulec/genassembly:kmer'

    input:
    tuple val(meta), path(gce2log)

    output:
    path("shortenedSizeFinal.txt")        , emit: genome_size_est
    path("standardSizeFinal.txt")     , emit: standard_fmt_est    

    script: 
    def number
    """
    tail -3 $gce2log | awk '{print \$5}' > scientificSize.txt
    less scientificSize.txt | awk -F"E" 'BEGIN{OFMT="%10.10f"} {print \$1 * (10 ^ \$2)}' > standardSize.txt 
    
    head -1 standardSize.txt > mid_size.txt
    sed 's:\.[^|]*::g' mid_size.txt > standardSizeFinal.txt
    
    head -1 standardSizeFinal.txt | numfmt --to=si > shortenedSizeFinal.txt
    """
}
