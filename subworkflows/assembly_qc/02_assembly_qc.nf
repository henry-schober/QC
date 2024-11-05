include { QUAST } from '../../modules/local/quast'  
include { BUSCO } from '../../modules/nf-core/busco/main'  
include { MERQURY } from '../../modules/nf-core/merqury/main'  
include { COMPLEASM } from '../../modules/local/compleasm'
include { MERYL_COUNT } from '../../modules/nf-core/meryl/count/main'

workflow ASSEMBLY_QC {

    take:
        ch_assembly // channel: [ val(meta), path(ch_assembly) ]
        ch_data

    main:

    ch_versions = Channel.empty() 

    // run quast
    QUAST(ch_assembly)
    ch_versions = ch_versions.mix(QUAST.out.versions)

    // run BUSCO or compleasm
    if (params.busco == true) {
        BUSCO(ch_assembly, params.busco_lineage, [], [])
        ch_busco_full_table = BUSCO.out.full_table
        ch_versions = ch_versions.mix(BUSCO.out.versions)
    }

    if (params.compleasm == true) {
        COMPLEASM(ch_assembly, params.compleasm_lineage)
        if (params.busco == false) {
            ch_busco_full_table = Channel.empty() 
        }
    }
    // run meryl and then merqury

    if (params.merqury == true) {
        MERYL_COUNT(ch_data, params.kmer_num)
    ch_assembly
            .combine(MERYL_COUNT.out.meryl_db)
            .set{ch_input_merqury}

    ch_input_merqury
        .combine(genome_size_est)
        .set { merqury_paths }

    MERQURY(merqury_paths, params.tolerable_collision)
    ch_versions = ch_versions.mix(MERQURY.out.versions)
    }

    emit:
        ch_quast
        ch_busco
        ch_merqury
        ch_busco_full_table
        
    versions = ch_versions                     // channel: [ versions.yml ]
}


