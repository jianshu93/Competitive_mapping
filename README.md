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

Sample data from Karthikeyan et.al.,2021, Env.Sci.Tech.
```
coverm genome -d ./bam_out/ -x fasta -b ./bam_out/all_mags_rename_sorted.bam -m trimmed_mean --trim-min 0.1 --trim-max 0.9 --min-read-percent-identity 0.95 --min-read-aligned-percent 0.75
```
| genome_name    | jTAD80      | Trimmed_Mean80 |
|----------------|-------------|----------------|
| MaxBin.001     | 237.6306129 | 237.69215      |
| MaxBin.012     | 102.6480596 | 102.73         |
| MaxBin.035_sub | 6.394396129 | 6.6497817      |
| MaxBin.047     | 22.70832466 | 22.750353      |
| MaxBin.051     | 12.87198109 | 13.105129      |
| MetaBAT.009    | 9.244269553 | 9.455999       |
| MetaBAT.015    | 20.03221762 | 20.185205      |
| MetaBAT.016    | 25.42493589 | 25.41395       |
| MetaBAT.017    | 11.62968809 | 11.843799      |
| MetaBAT.019    | 12.98588635 | 13.086388      |
| MetaBAT.024    | 24.59416783 | 24.556606      |
| MetaBAT.026    | 23.39601346 | 23.39584       |
| MetaBAT.027    | 11.30858459 | 11.446535      |
| MetaBAT.029    | 11.71779875 | 11.882411      |
| MetaBAT.030    | 9.325849312 | 9.539687       |



# Dependencies
bwa, seqtk, filterBam, ruby, samtools, bedtools are required for this pipeline. freebayes can also be installed via conda:

filterBam is introduced here: ftp://188.44.46.157/New/augustus.2.7/auxprogs/filterBam/doc/filterBam.pdf
It can be compiled under augustus(https://github.com/Gaius-Augustus/Augustus)
```
conda install -c bioconda bwa freebayes samtools bedtools seqtk
```
# MacOS

All dependencies can be installed cond except filterBam. You may need to install gnu-coreutils, gawk, ggrep, gsed et.al. first via brew:
```
brew install coreutils
brew install gawk
brew install ggrep
brew install gsed
```

# Reference
Li, H and R Durbin. 2009. “Fast and Accurate Short Read Alignment with Burrows-Wheeler Transform.” 25(14):1754–60.

Li, Heng et al. 2009. “The Sequence Alignment/Map Format and SAMtools.” Bioinformatics 25(16):2078–79.

Quinlan, Aaron R. and Ira M. Hall. 2010. “BEDTools: a Flexible Suite of Utilities for Comparing Genomic Features.” Bioinformatics 26(6):841–42.
Garrison, Erik and Gabor Marth. 2012. “Haplotype-Based Variant Detection From Short-Read Sequencing.” 1–9. Retrieved (https://arxiv.org/abs/1207.3907).

Li, Heng et al. 2009. “The Sequence Alignment/Map Format and SAMtools.” Bioinformatics 1–2.

Smruthi Karthikeyan, Minjae K. P. H.-R. J. K. H. J. C. S. W. A. O. M. H. J. E. K. A. K. T. K. 2020. “Integrated Omics Elucidate the Mechanisms Driving the Rapid Biodegradation of Deepwater Horizon Oil in Intertidal Sediments Undergoing Oxic−Anoxic Cycles.” Environmental Science & Technology 54(16):1–12.






