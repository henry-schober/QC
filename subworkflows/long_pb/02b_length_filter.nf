include { BIOAWK } from '../../modules/nf-core/bioawk/main'
include { NANOPLOT } from '../../modules/nf-core/nanoplot/main'

workflow LENGTH_FILT3 {

    take:
  
        decontam_reads  // channel: [ val(meta), [ decontam reads ] ] 
        decontam_reads_no_meta
    main:
    
    ch_versions = Channel.empty()

        // if statement for if min_read_length exists for length filter
        if(params.min_readlength > 0){
            BIOAWK(decontam_reads)

            BIOAWK.out.output
                .map { file -> tuple([id:file.baseName, single_end:true], file)  }
                .set { longreads }

            NANOPLOT(longreads)

            no_meta_longreads = BIOAWK.out.output  // channel: [ val(meta), path(decontam+length filtered fastq) ]
        }
        else{
            longreads = decontam_reads  // channel: [ val(meta), path(decontaminated fastq) ]
            no_meta_longreads = decontam_reads_no_meta
        }

    emit:
        longreads
        no_meta_longreads

    versions = ch_versions                     // channel: [ versions.yml ]
}
