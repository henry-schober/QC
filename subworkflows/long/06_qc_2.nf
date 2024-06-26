include { QUAST } from '../../modules/local/quast'  
include { BUSCO } from '../../modules/nf-core/busco/main' 
include { PYCOQC } from '../../modules/nf-core/pycoqc/main'  
include { MINIMAP2_INDEX } from '../../modules/nf-core/minimap2/index/main' 
include { MINIMAP2_ALIGN } from '../../modules/nf-core/minimap2/align/main'  
include { MERYL_COUNT } from '../../modules/nf-core/meryl/count/main' 
include { MERQURY } from '../../modules/nf-core/merqury/main' 
include { SAMTOOLS_INDEX } from '../../modules/nf-core/samtools/index/main' 
include { BWAMEM2_INDEX } from '../../modules/nf-core/bwamem2/index/main' 
include { BWAMEM2_MEM } from '../../modules/nf-core/bwamem2/mem/main' 

workflow QC_2 {

    take:
        polished_assemblies // channel: [ val(meta), path(flye assembly.fasta) ]
        fastq_filt // channel: [ val(meta), path(filtered reads) ]
        summarytxt // channel from params.summarytxt
        ch_quast
        ch_busco
        ch_merqury
        shortreads
        ch_align_paf
        genome_size_est
        ch_meryl
        no_meta_fq

    main:

    ch_versions = Channel.empty() 

    if ( params.shortread == true ) {
        BWAMEM2_INDEX(polished_assemblies)

        shortreads
            .concat(BWAMEM2_INDEX.out.index)
            .set{bwa}

        BWAMEM2_MEM(bwa, params.samtools_sort)
    }

    if ( params.longread == true ){
        
        // build index
        MINIMAP2_INDEX(polished_assemblies)
        ch_versions = ch_versions.mix(MINIMAP2_INDEX.out.versions)
        ch_index = MINIMAP2_INDEX.out.index

        polished_assemblies
            .combine(no_meta_fq)
            .set{align_ch}

        // align reads
        MINIMAP2_ALIGN(align_ch, params.bam_format, params.cigar_paf_format, params.cigar_bam)
        
        ch_bam = MINIMAP2_ALIGN.out.bam

        ch_align_paf
            .concat(MINIMAP2_ALIGN.out.paf)
            .set { paf_alignment } }
        
        // run quast
        QUAST(
            polished_assemblies
        )
        ch_quast
            .concat(QUAST.out.results)
            .set { ch_quast }
        ch_versions = ch_versions.mix(QUAST.out.versions)

        // run BUSCO
        BUSCO(polished_assemblies, params.busco_lineage, [], [])
        ch_busco
            .concat(BUSCO.out.short_summaries_txt)
            .set { ch_busco }

        ch_busco_full_table = BUSCO.out.full_table

        ch_versions = ch_versions.mix(BUSCO.out.versions)
    if ( params.longread == true ){
        SAMTOOLS_INDEX (MINIMAP2_ALIGN.out.bam)
        ch_sam = SAMTOOLS_INDEX.out.sam
    } else if ( params.shortread == true ){ 
        SAMTOOLS_INDEX (BWAMEM2_MEM.out.bam)
        ch_sam = SAMTOOLS_INDEX.out.sam }

    if ( params.summary_txt_file == true ) {
        ch_summarytxt = summarytxt.map { file -> tuple(file.baseName, file) }

        PYCOQC (
            ch_summarytxt, MINIMAP2_ALIGN.out.bam, SAMTOOLS_INDEX.out.bai
        )
        ch_versions = ch_versions.mix(PYCOQC.out.versions)
    } else {
            ch_summarytxt = Channel.empty()
    }

        polished_assemblies
            .combine(ch_meryl)
            .set{ch_input_merqury}

        ch_input_merqury
            .combine(genome_size_est)
            .set{merqury_paths}

        MERQURY (
            merqury_paths, params.tolerable_collision
        )
        ch_merqury
            .concat(MERQURY.out.assembly_qv)
            .set { ch_merqury }
        ch_versions = ch_versions.mix(MERQURY.out.versions)

    emit:
        ch_index
        ch_bam
        paf_alignment
        ch_quast
        ch_busco
        ch_merqury
        ch_busco_full_table

                
    versions = ch_versions                     // channel: [ versions.yml ]
}
