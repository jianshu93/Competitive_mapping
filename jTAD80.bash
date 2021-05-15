#!/bin/bash

### Jianshu Zhao (jianshu.zhao@gatech.edu)
### justfied TAD80 (Truncated average depth 80%) for coverage depth of MAGs based on competitive mapping
### The original publication is here: https://sfamjournals.onlinelibrary.wiley.com/doi/abs/10.1111/1462-2920.15112
### this is an improvement of the original publication because original method
### does not fillter mapped reads according to query coverage and indentity. 
### Mapping was also not done in a competitive way to avoid overestimation of mapped reads
### due to closely related MAGs (population genomes)
### We called it justified TAD80, jTAD80. This is consistent with the CoverM trimmed_mean metric (TMD80)
### (coverm option:-m trimmed_mean --trim-min 0.1 --trim-max 0.9 --min-read-percent-identity 0.95 --min-read-aligned-percent 0.75 --min-covered-fraction 0)

processors=$(nproc)
map_out=./bam_out
coverage=75
identity=95
jTAD=0.8
output=./output.txt
while getopts ":d:o:(cov):(id):p:j:h" option
do
	case $option in
		d) map_out=$OPTARG;;
        cov) coverage=$OPTARG;;
        id) identity=$OPTARG;;
        o) output=$OPTARG;;
        p) processors=$OPTARG;;
        j) jTAD=$OPTARG;;
        \?) echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		:) echo "Option -$OPTARG requires an argument." >&2
		    exit 1
			;;
		h) 
           echo "usage: jTAD80.bash -d ./bam_out -o output.txt -p 8 -cov 75 -id 95 -j 0.8
            
            -d directory contains output from competative mapping, fasta file and
                sorted bam file for that fasta (sorted by reference)
            -cov coverage faction of mapped reads to be filtered, default 75 (75%)
            -id identity of mapped reads to be filtered, default 95 (95%)
            -o output file for jTAD80 index for each genome in the input directory
            -p number of processors to run for each genome
            -j justified TAD central range to consider, between 0 and 1, default 0.8
            "
            exit 1
            ;;
	esac
done

dfiles="${map_out}/*.fasta"

$(ls $dfiles | parallel -j $processors "./dependencies/samtools_linux sort -n -O bam -o {.}_byread.sorted.bam {.}.sorted.bam")
byreads_bam="${map_out}/*_byread.sorted.bam"
$(ls $byreads_bam | parallel -j $processors "./dependencies/filterbam_linux --in {} --out {_}_filter.sorted.bam --minCover $coverage --minId $identity")
$(rm $byreads_bam)
filtered_bam="${map_out}/*_filter.sorted.bam"
$(ls $filtered_bam | parallel -j $processors "./dependencies/samtools_linux sort -O bam -o {_}_final.sorted.bam {}")
$(rm $filtered_bam)
final_bam="${map_out}/*_final.sorted.bam"
$(ls $final_bam | parallel -j $processors "/dependencies/bedtools_linux genomecov -ibam {} -bga > {_}_depth.all.txt")
all_depth="${map_out}/*_depth.all.txt"

$(ls $all_depth | parallel -j $processors "grep -E '^{_}.' {} > {_}.depth.txt")
${rm $all_depth}
depth="${map_out}/*.depth.txt"
$(ls $depth | parallel -j $processors "../dependencies/BedGraph.tad.rb -i {} -r $jTAD > {.}_jTAD.txt")

TAD_out="${map_out}/*_jTAD.txt"
echo "genome_name"$'\t'"TAD" > $output
for F in $TAD_out; do
    BASE=${F##*/}
	SAMPLE=${BASE%_*}
    echo -n "$SAMPLE"$'\t' >> $output
    cat $F >> $output
done

echo "Calculation of TAD done!"