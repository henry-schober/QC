include { ALIGN } from '../../modules/local/purgehap' 
include { HISTOGRAM } from '../../modules/local/purgehap' 
include { PURGE } from '../../modules/local/purgehap' 

workflow HAPS {

    take:
        assembly
        subreads
        
    main:
    ch_versions = Channel.empty()

        if (!(params.low && params.mid && params.high)) {

        ALIGN(assembly, subreads)
        HISTOGRAM(assembly, ALIGN.out.aligned)
        assemblies_polished_purged      = Channel.empty()

        } else if (params.low && params.mid && params.high){

        PURGE(params.low, params.mid, params.high, assembly, params.gencov)
        assemblies_polished_purged      = PURGE.out.purged           
        
        }

    emit:
        assemblies_polished_purged
        
    versions = ch_versions                     // channel: [ versions.yml ]
}