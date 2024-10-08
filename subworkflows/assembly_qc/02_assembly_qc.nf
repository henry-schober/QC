include { QUAST } from '../../modules/local/quast'  
include { BUSCO } from '../../modules/nf-core/busco/main'  
include { MERQURY } from '../../modules/nf-core/merqury/main'  
include { COMPLEASM } from '../../modules/local/compleasm'

workflow ASSEMBLY_QC {

    take:
        assemblies // channel: [ val(meta), path(assemblies) ]
        summarytxt // channel from params.summarytxt
        ch_quast
        ch_busco
        ch_merqury
        genome_size_est
        ch_meryl
        meryl_repk

    main:

    ch_versions = Channel.empty() 

    // run quast
    QUAST(assemblies)
    ch_quast
        .concat(QUAST.out.results)
        .set { ch_quast }
    ch_versions = ch_versions.mix(QUAST.out.versions)

    // run BUSCO or compleasm
    if (params.busco == true) {
        BUSCO(assemblies, params.busco_lineage, [], [])
        ch_busco
            .concat(BUSCO.out.short_summaries_txt)
            .set { ch_busco } 
        ch_busco_full_table = BUSCO.out.full_table
        ch_versions = ch_versions.mix(BUSCO.out.versions)
    }

    if (params.compleasm == true) {
        COMPLEASM(assemblies, params.compleasm_lineage)
        ch_busco 
            .concat(COMPLEASM.out.txt)
            .set { ch_busco } 
        if (params.busco == false) {
            ch_busco_full_table = Channel.empty() 
        }
    }

    assemblies
        .combine(ch_meryl)
        .set { ch_input_merqury }

    ch_input_merqury
        .combine(genome_size_est)
        .set { merqury_paths }

    MERQURY(merqury_paths, params.tolerable_collision)
    ch_merqury
        .concat(MERQURY.out.assembly_qv)
        .set { ch_merqury }
    ch_versions = ch_versions.mix(MERQURY.out.versions)

    emit:
        ch_quast
        ch_busco
        ch_merqury
        ch_busco_full_table
        
    versions = ch_versions                     // channel: [ versions.yml ]
}


