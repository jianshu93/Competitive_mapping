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
### dependencies: gnu parallel, samtools, coverm, bedtools, ruby

processors=$(nproc)
map_out=./bam_out
coverage=0.75
identity=0.95
jTAD=0.8
output=output.txt
while getopts ":d:o:c:i:p:j:h" option
do
	case $option in
		d) map_out=$OPTARG;;
        c) coverage=$OPTARG;;
        i) identity=$OPTARG;;
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
           echo "usage: jTAD80.bash -d ./bam_out -o output.txt -p 8 -cov 0.75 -id 0.95 -j 0.8
            
            -d directory contains output from competative mapping, fasta file and
                sorted bam file for that fasta (sorted by reference)
            -c coverage faction of mapped reads to be filtered, default 75 (75%)
            -i identity of mapped reads to be filtered, default 95 (95%)
            -o output file for jTAD80 index for each genome in the input directory
            -p number of processors to run for each genome
            -j justified TAD central range to consider, between 0 and 1, default 0.8
            "
            exit 1
            ;;
	esac
done

echo "using identity $identity for filtering"
echo "using coverage $coverage for filtering"
echo "using directory $map_out"

if ! command -v bedtools &> /dev/null
then
    echo "bedtools could not be found, please installed via conda or from source"
    exit
fi


dfiles="${map_out}/*.fasta"

if ! command -v bedtools &> /dev/null
then
    $(ls $dfiles | parallel -j $processors "./dependencies/coverm_darwin filter --bam-files {.}.sorted.bam -o {.}.final -t 2 --min-read-percent-identity $identity --min-read-aligned-percent $coverage")
    final_bam="${map_out}/*.final"
    $(ls $final_bam | parallel -j $processors "./dependencies/bedtools_darwin genomecov -ibam {} -bga > {.}.depth")
else
    $(ls $dfiles | parallel -j $processors "./dependencies/coverm_darwin filter --bam-files {.}.sorted.bam -o {.}.final -t 2 --min-read-percent-identity $identity --min-read-aligned-percent $coverage")
    final_bam="${map_out}/*.final"
    $(ls $final_bam | parallel -j $processors "bedtools genomecov -ibam {} -bga > {.}.depth")
fi

for F in $final_bam; do
    a="$(echo $F | sed s/final/filtered.sorted.bam/)"
    mv "$F" "$a"
done

all_depth="${map_out}/*.depth"
$(ls $all_depth | parallel -j $processors "ggrep -E '^{/.}.' {} > {.}.txt")
$(rm $all_depth)
depth="${map_out}/*.txt"
echo $jTAD
$(ls $depth | parallel -j $processors "./dependencies/BedGraph.tad.rb -i {} -r $jTAD > {.}.jTAD")

TAD_out="${map_out}/*.jTAD"
echo "genome_name"$'\t'"jTAD" > $output
for F in $TAD_out; do
    BASE=${F##*/}
	SAMPLE=${BASE%.*}
    echo -n "$SAMPLE"$'\t' >> $output
    cat $F >> $output
done

echo "Calculation of TAD done!"
