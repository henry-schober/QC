process OUTPUT_FORMAT {
    label 'process_low'

    input:
    path(input_file)

    output:
    path("qc.tsv")       , emit: tsv
   
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
echo -e "Assembly\t\$assembly" >> ${prefix}_qc.tsv
echo -e "Number of contigs\t\$contigs" >> ${prefix}_qc.tsv
echo -e "Largest contig\t\$largest_contig" >> ${prefix}_qc.tsv
echo -e "Total length\t\$total_length" >> ${prefix}_qc.tsv
echo -e "GC (%)\t\$gc_percent" >> ${prefix}_qc.tsv
echo -e "N50\t\$n50" >> ${prefix}_qc.tsv
echo -e "N90\t\$n90" >> ${prefix}_qc.tsv
echo -e "auN\t\$aun" >> ${prefix}_qc.tsv
echo -e "L50\t\$l50" >> ${prefix}_qc.tsv
echo -e "L90\t\$l90" >> ${prefix}_qc.tsv
echo -e "# N's per 100 kbp\t\$ns_per_100kbp" >> ${prefix}_qc.tsv
echo >> ${prefix}_qc.tsv
echo -e "BUSCO\tC:\$(echo \$complete_buscos | awk '{printf "%.1f", (\$1/\$total_buscos)*100}')%[S:\$(echo \$single_copy_buscos | awk '{printf "%.1f", (\$1/\$total_buscos)*100}')%,D:\$(echo \$duplicated_buscos | awk '{printf "%.1f", (\$1/\$total_buscos)*100}')%],F:\$(echo \$fragmented_buscos | awk '{printf "%.1f", (\$1/\$total_buscos)*100}')%,M:\$(echo \$missing_buscos | awk '{printf "%.1f", (\$1/\$total_buscos)*100}')%,n:\$total_buscos,E:15.5%" >> ${prefix}_qc.tsv
echo -e "Complete BUSCOs (C)\t\$complete_buscos" >> ${prefix}_qc.tsv
echo -e "Complete and single-copy BUSCOs (S)\t\$single_copy_buscos" >> ${prefix}_qc.tsv
echo -e "Complete and duplicated BUSCOs (D)\t\$duplicated_buscos" >> ${prefix}_qc.tsv
echo -e "Fragmented BUSCOs (F)\t\$fragmented_buscos" >> ${prefix}_qc.tsv
echo -e "Missing BUSCOs (M)\t\$missing_buscos" >> ${prefix}_qc.tsv
echo -e "Total BUSCO groups searched\t\$total_buscos" >> ${prefix}_qc.tsv
echo >> ${prefix}_qc.tsv
echo -e "Merqury quality value\t\$merqury_score" >> ${prefix}_qc.tsv

    """
}
