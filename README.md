# Competitive_mapping

This is a wrapper for competitive reads mapping against a collection of genomes or metagenomic assembled genomes (MAGs).


```
git clone https://github.com/jianshu93/Competitive_mapping
cd Competitive_mapping
chmod a+x ./compet_map_bam.bash
gunzip ./demo_input/T4AerOil_sbsmpl5.fa.gz
./compet_map_bam.bash -d ./demo_input/MAG -i ./demo_input/T4AerOil_sbsmpl5.fa -T 24 -o ./bam_out -m bwa
```

In output directory you will have sorted bam files for each genome and also a big sorted bam file for all genomes. Those bam files for each genome can be used for recuitment plot (https://github.com/KGerhardt/RecruitPlotEasy). The big bam file can be used for calculation of coverage depth et.al. using CoverM (https://github.com/wwood/CoverM)

# MacOS

You may need to install gnu-coreutils, gawk, ggrep, gsed et.al. first via brew:
```
brew install gnu-coreutils
brew install gawk
brew install ggrep
```


