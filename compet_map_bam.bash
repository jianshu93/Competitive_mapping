#!/bin/bash
### Jianshu Zhao (jianshu.zhao@gatech.edu)
### competitive mapping and extracing of MAG bam file for recruitment plot ().
### dependencies:
### seqtk, samtools and bowtie2/bwa，all can be installed via conda


## default settings
threads=$(nproc)
dir_mag=./MAG
reads1=./reads_R1.fastq.gz
reads2=./reads_R2.fastq.gz
output=./output
intleav=./interleave.fastq.gz
mapping="minimap2"

while getopts ":d:o:(r1):(r2):i:m:T:h" option
do
	case $option in
		d) dir_mag=$OPTARG;;
        r1) reads1=$OPTARG;;
        r2) reads2=$OPTARG;;
        i) intleav=$OPTARG;;
        o) output=$OPTARG;;
        T) threads=$OPTARG;;
        m) mapping=$OPTARG;;
        \?) echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		:) echo "Option -$OPTARG requires an argument." >&2
		    exit 1
			;;
		h) 
           echo "usage: compet_map_bam.bash -d ./MAGs -r1 ./reads_R1.fastq -r2 ./reads_R2.fastq -T 12 -o ./bam_out
                or 
                usage: compet_map_bam.bash -d ./MAGs -i interleaved.fastq -T 12 -o ./bam_out
           
                options:
                -d directory contains MAG in fasta format, must ends with .fasta in the name
                -r1 forward reads to map to the the MAG collection, can be gzipped format
                -r2 reverse reads to map to the the MAG collection, can be gzipped format
                -i interleaved reads to map to the MAG collection, can be gzipped format
                -o output directory to store each bam file for each MAG
                -T number of threas to use for mapping and also format tranformation
                -m mapping method, default bwa, bowtie2 is also supported but there
                    are known bug for it if using --threads value larger than 1
                "
            exit 1
            ;;
	esac
done

if [ -d "$dir_mag" ]; then
    echo "$dir exists" 
else
    echo "$dir does not exist, please offer a directory that exists"
    exit 1
fi

if test -f "$intleav"; then
    echo "$intleav exists."
    if (file $intleav | grep -q "gzip compressed") ; then
        $(gunzip $intleav)
    fi
else
	echo "$intleav does not exists."
    if test -f "$reads1"; then
        echo "$reads1 exists."
        if (file $reads1 | grep -q "gzip compressed") ; then
            $(gunzip $reads1)
        fi
    else
	    echo "$reads1 does not exists."
	    exit 1
    fi
    if test -f "$reads2"; then
        echo "$reads2 exists."
        if (file $reads2 | grep -q "gzip compressed") ; then
            $(gunzip $reads2)
        fi
    else
	    echo "$reads2 does not exists."
	    exit 1
    fi
fi

if [ -d "$output" ] 
then
    echo "Directory $output already exists. Please offer a new directory"
    exit 1
else
    echo "making directory $output ..."
    $(mkdir $output)
fi

echo "Rename MAG headers and do reads mapping"
dfiles="${dir_mag}/*.fasta"
for F in $dfiles; do
	BASE=${F##*/}
	SAMPLE=${BASE%.*}
    $(./dependencies/seqtk_linux rename $F ${SAMPLE}. > ${output}/${SAMPLE}.fasta)
    $(grep -E '^>' ${output}/${SAMPLE}.fasta | sed 's/>//' | awk '{print $1}' | tr '\n' ' ' > ${output}/${SAMPLE}_rename.txt)
    $(cat ${output}/${SAMPLE}.fasta >> ${output}/all_mags_rename.fasta)
    ## $(rm ${output}/${SAMPLE}.renamed.fasta)
done

if [[ "$mapping" == "bowtie2" ]]; then
    echo "Indexing reference genomes using bowtie2-build"
    $(bowtie2-build --threads $threads ${output}/all_mags_rename.fasta ${output}/all_mags_rename)
    echo "Indexing done"
    if [ -z "$intleav" ]; then
        echo "Doing reads mapping using forward and reverse reads"
        $(bowtie2 -x ${output}/all_mags_rename -f -1 $reads1 -2 $reads2 -S ${output}/all_mags_rename.sam --threads $threads)
    else
        echo "Doing reads mapping using interleaved reads"
        $(bowtie2 -x ${output}/all_mags_rename -f --interleaved $intleav -S ${output}/all_mags_rename.sam --threads $threads)
    fi
    $(rm ${output}/all_mags_rename.fasta)
elif [[ "$mapping" == "bwa" ]]; then
    echo "Indexing reference genomes using bwa index"
    $(./dependencies/bwa_linux index ${output}/all_mags_rename.fasta)
    echo "Indexing done"
    if [ -z "$intleav" ]; then
        echo "Doing reads mapping using forward and reverse reads"
        $(./dependencies/bwa_linux mem -t $threads ${output}/all_mags_rename $reads1 $reads2 > ${output}/all_mags_rename.sam)
    else
        echo "Doing reads mapping using interleaved reads"
        $(./dependencies/bwa_linux mem -p -t $threads -v 1 ${output}/all_mags_rename.fasta $intleav > ${output}/all_mags_rename.sam)
    fi
    $(rm ${output}/all_mags_rename.fasta)
elif [[ "$mapping" == "minimap2" ]]; then
    if [ -z "$intleav" ]; then
        echo "Doing reads mapping using forward and reverse reads"
        $(./dependencies/minimap2_linux -ax sr -t $threads -o ${output}/all_mags_rename.sam ${output}/all_mags_rename.fasta $reads1 $reads2)
    else
        echo "Doing reads mapping using interleaved reads"
        $(./dependencies/minimap2_linux -ax sr -t $threads -o ${output}/all_mags_rename.sam ${output}/all_mags_rename.fasta $intleav)
    fi
    $(rm ${output}/all_mags_rename.fasta)
else
    echo "not supported mapping method"
fi
echo "reads mapping done"

if ! command -v samtools &> /dev/null
then
    $(./dependencies/samtools_linux view -bS -@ $threads ${output}/all_mags_rename.sam > ${output}/all_mags_rename.bam)
    $(rm ${output}/all_mags_rename.sam)
    $(./dependencies/samtools_linux sort -@ $threads -O bam -o ${output}/all_mags_rename_sorted.bam ${output}/all_mags_rename.bam)
    $(rm ${output}/all_mags_rename.bam)
    echo "extracting bam files for each genome"
    dfiles_rename="${output}/*_rename.txt"
    $(./dependencies/samtools_linux index ${output}/all_mags_rename_sorted.bam)
    for F in $dfiles_rename; do
        BASE=${F##*/}
	    SAMPLE=${BASE%_*}
        $(./dependencies/samtools_linux view -@ $threads -bS ${output}/all_mags_rename_sorted.bam $(cat $F) > ${output}/${SAMPLE}.sorted.bam)
        $(rm $F)
    done
else
    $(samtools view -bS -@ $threads ${output}/all_mags_rename.sam > ${output}/all_mags_rename.bam)
    $(rm ${output}/all_mags_rename.sam)
    $(samtools sort -@ $threads -O bam -o ${output}/all_mags_rename_sorted.bam ${output}/all_mags_rename.bam)
    $(rm ${output}/all_mags_rename.bam)
    echo "extracting bam files for each genome"
    dfiles_rename="${output}/*_rename.txt"
    $(samtools index ${output}/all_mags_rename_sorted.bam)
    for F in $dfiles_rename; do
        BASE=${F##*/}
	    SAMPLE=${BASE%_*}
        $(samtools view -@ $threads -bS ${output}/all_mags_rename_sorted.bam $(cat $F) > ${output}/${SAMPLE}.sorted.bam)
        $(rm $F)
    done
fi
#$(ls $dfiles_rename | parallel -j $processors "./dependencies/samtools_linux view -bS ${output}/all_mags_rename_sorted.bam $(cat {}) > ${output}/{_}.sorted.bam")
echo "All done"