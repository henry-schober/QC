process OUTPUT_FORMAT {
    label 'process_low'

    input:
    tuple val(meta), path(input_file)

    output:
    path("*qc.tsv")       , emit: tsv
   
    script: 
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
# Extract the necessary values from the input file
assembly=\$(grep -m 1 "Assembly" "$input_file" | awk '{print \$2}')
contigs=\$(grep -m 1 "# contigs" "$input_file" | awk '{print \$6}')
largest_contig=\$(grep -m 1 "Largest contig" "$input_file" | awk '{print \$3}')
total_length=\$(grep -m 1 "^Total length" "$input_file" | awk '{print \$6}')
gc_percent=\$(grep -m 1 "GC (%)" "$input_file" | awk '{print \$3}')
n50=\$(grep -m 1 "^N50" "$input_file" | awk '{print \$2}')
n90=\$(grep -m 1 "^N90" "$input_file" | awk '{print \$2}')
aun=\$(grep -m 1 "auN" "$input_file" | awk '{print \$2}')
l50=\$(grep -m 1 "L50" "$input_file" | awk '{print \$2}')
l90=\$(grep -m 1 "L90" "$input_file" | awk '{print \$2}')
ns_per_100kbp=\$(grep -m 1 "# N's per 100 kbp" "$input_file" | awk '{print \$6}')

busco_stats=\$(grep "C:" "$input_file" | awk '{print \$1}')
complete_buscos=\$(grep "Complete BUSCOs" "$input_file" | awk '{print \$1}')
single_copy_buscos=\$(grep "single-copy BUSCOs" "$input_file" | awk '{print \$1}')
duplicated_buscos=\$(grep "duplicated BUSCOs" "$input_file" | awk '{print \$1}')
fragmented_buscos=\$(grep "Fragmented BUSCOs" "$input_file" | awk '{print \$1}')
missing_buscos=\$(grep "Missing BUSCOs" "$input_file" | awk '{print \$1}')
total_buscos=\$(grep "Total BUSCO groups searched" "$input_file" | awk '{print \$1}')

num_scaffolds=\$(grep "Number of scaffolds" "$input_file" | awk '{print \$1}')
num_contigs=\$(grep "Number of contigs" "$input_file" | awk '{print \$1}')
scaffold_n50=\$(grep "Scaffold N50" "$input_file" | awk '{print \$1}')
contigs_n50=\$(grep "Contigs N50" "$input_file" | awk '{print \$1}')
percent_gaps=\$(grep "Percent gaps" "$input_file" | awk '{print \$1}')

merqury_score=\$(sed -n '46p' "$input_file" | awk '{print \$1}')


# Output the formatted results
echo -e "Assembly\t$assembly\nNumber of contigs\t$contigs\nLargest contig\t$largest_contig\nTotal length\t$total_length\nGC (%)\t$gc_percent\nN50\t$n50\nN90\t$n90\nauN\t$aun\nL50\t$l50\nL90\t$l90\n# N's per 100 kbp\t$ns_per_100kbp\n\nBUSCO\tC:$(echo $complete_buscos | awk '{printf "%.1f", ($1/$total_buscos)*100}')%[S:$(echo $single_copy_buscos | awk '{printf "%.1f", ($1/$total_buscos)*100}')%,D:$(echo $duplicated_buscos | awk '{printf "%.1f", ($1/$total_buscos)*100}')%],F:$(echo $fragmented_buscos | awk '{printf "%.1f", ($1/$total_buscos)*100}')%,M:$(echo $missing_buscos | awk '{printf "%.1f", ($1/$total_buscos)*100}')%,n:$total_buscos\nComplete and single-copy BUSCOs (S)\t$single_copy_buscos\nComplete and duplicated BUSCOs (D)\t$duplicated_buscos\nFragmented BUSCOs (F)\t$fragmented_buscos\nMissing BUSCOs (M)\t$missing_buscos\nTotal BUSCO groups searched\t$total_buscos\n\nMerqury quality value\t$merqury_score" >> ${prefix}_qc.tsv

    """
}
