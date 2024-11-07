include { QUAST } from '../../modules/local/quast'  
include { BUSCO } from '../../modules/nf-core/busco/main'  
include { MERQURY } from '../../modules/nf-core/merqury/main'  
include { COMPLEASM } from '../../modules/local/compleasm'
include { MERYL_COUNT } from '../../modules/nf-core/meryl/count/main'

workflow ASSEMBLY_QC {

    take:
        ch_assembly // channel: [ val(meta), path(ch_assembly) ]
        ch_reads
        ch_genome_size

    main:

    ch_versions = Channel.empty() 

    // run quast
    QUAST(ch_assembly)
    ch_versions = ch_versions.mix(QUAST.out.versions)
    ch_quast = QUAST.out.results

    // run BUSCO or compleasm
    if (params.busco == true) {
        BUSCO(ch_assembly, params.busco_lineage, [], [])
        ch_busco_full_table = BUSCO.out.full_table
        ch_versions = ch_versions.mix(BUSCO.out.versions)
        ch_busco = BUSCO.out.short_summaries_txt
    }
    if (params.compleasm == true) {
        COMPLEASM(ch_assembly, params.compleasm_lineage)
        if (params.busco == false) {
            ch_busco_full_table = Channel.empty()
            ch_busco = COMPLEASM.out.txt 
        }
    }
    // run meryl and then merqury

    if (params.merqury == true) {
        MERYL_COUNT(ch_reads, params.kmer_num)
    ch_assembly
            .combine(MERYL_COUNT.out.meryl_db)
            .set{ch_input_merqury}

    ch_input_merqury
        .combine(ch_genome_size)
        .set { merqury_paths }

    MERQURY(merqury_paths, params.tolerable_collision)
    ch_versions = ch_versions.mix(MERQURY.out.versions)
    }
    MERQURY.out.assembly_qv
            .set{ch_merqury}

    emit:
        ch_quast
        ch_busco
        ch_busco_full_table
        ch_merqury
        
        
    versions = ch_versions                     // channel: [ versions.yml ]
}


