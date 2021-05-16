# Competitive_mapping

This is a wrapper for competitive reads mapping against a collection of genomes or metagenomic assembled genomes (MAGs).


```
git clone https://github.com/jianshu93/Competitive_mapping
cd Competitive_mapping
chmod a+x ./compet_map_bam.bash
gunzip ./demo_input/T4AerOil_sbsmpl5.fa.gz

### 1.competetive reads mapping
./compet_map_bam.bash -d ./demo_input/MAG -i ./demo_input/T4AerOil_sbsmpl5.fa -T 24 -o ./bam_out -m bwa

### 2.calculation of justified TAD80
./jTAD80.bash -d ./bam_out -o output.txt -p 24 -cov 75 -id 95 -j 0.8 

```

1. In output directory you will have sorted bam files for each genome and also a big sorted bam file for all genomes. Those bam files for each genome can be used for recuitment plot (https://github.com/KGerhardt/RecruitPlotEasy). The big bam file can be used for calculation of coverage depth et.al. using CoverM (https://github.com/wwood/CoverM)
2. Justified TAD80 is based on BedGraph.tad.rb in eveomics () but mapped reads are filtered before calculating.
3. The filtered bam files in step 2 can be directly used for variant calling. Softwares such as freebayes (https://github.com/freebayes/freebayes) and GATK (https://github.com/broadinstitute/gatk) can be used. For example:
```
freebayes -f ./bam_out_demo/lab5_MAG.001.fasta lab5_MAG.001.filtered.sorted.bam > lab5_MAG.001.vcf
```
# Comparison with existing tools: coverm v0.6.0

|  genome | jTAD80  | trimmed_mean 80  |
|---|---|---|
|   |   |   |
|   |   |   |
|   |   |   |


# Dependencies
bwa, seqtk, filterBam, ruby, samtools, bedtools are required for this pipeline. freebayes can also be installed via conda:
```
conda install -c bioconda bwa freebayes samtools bedtools seqtk
```
# MacOS

All dependencies can be installed cond except filterBam. You may need to install gnu-coreutils, gawk, ggrep, gsed et.al. first via brew:
```
brew install coreutils
brew install gawk
brew install ggrep
```

# Reference
Garrison, Erik and Gabor Marth. 2012. “Haplotype-Based Variant Detection From Short-Read Sequencing.” 1–9. Retrieved (https://arxiv.org/abs/1207.3907).
Li, Heng et al. 2009. “The Sequence Alignment/Map Format and SAMtools.” Bioinformatics 1–2.
Quinlan, Aaron R. and Ira M. Hall. 2010. “BEDTools: a Flexible Suite of Utilities for Comparing Genomic Features.” Bioinformatics 26(6):841–42.





