## Recruitment plot based on Blast
This is wrapper for recuitment plot based on blast based on the recruitment plot function in enevoemics package. You mush have R and Perl installed on your machine. By default perl is installed on Linux and MacOS. You need to install R for plotting. I want to thank Genevie for the first version. Please contact me jianshuzhao@yahoo.com



You can create as many plots as you want parallelly. The blast step take some time. For a metagenomes with 3.0 GB (forwared reads only, unzipped) and 14 reference genomes. It take 2 hours.

blast+ and seqtk must be installed for alignment. If you are using conda, run conda install -c bioconda blast seqtk

Only Interleaved (people also call it merge in bbtools software) reads are supported for now. I will add support for forward and reverse reads.

If you have paired read, use the seqtk software to intleave your reads:

```
conda install seqtk -c bioconda
seqtk mergepe R1.fasta.gz R2.fasta.gz > interleaved.fasta
```

```
  Usage: ./makeRecruitmentPlot.sh database_dir query.fa output_base

  database_dir      directory that contains fasta files (must ends with .fasta) which will be the database [most likely your longer sequence]
  query.fa      Fasta file that will be mapped to the database [most likely your reads]
  output_base   Base name for the blast output and recruitment plots
                blast output:         output_base.blst [Unique matches with over 70% coverage and 50 bp match]
                recruitment object:   output_base.recruitment.out
                recruitment pdf:      output_base.recruitment.pdf
```




### Running using testing data
```
## on Linux
git clone https://github.com/jianshu93/RecruitmentPlot_blast
cd RecruitmentPlot_blast

### Get example interleaved reads data mentioned above, genomes offered are binned and refine from this metagenome
wget http://rothlab.com/Data/T4AerOil_sbsmpl5.fa.gz
mv T4AerOil_sbsmpl5.fa.gz ./demo_input
gunzip ./demo_input/T4AerOil_sbsmpl5.fa.gz
./makeRecruitmentPlot_linux.sh ./demo_input/MAG ./demo_input/T4AerOil_sbsmpl5.fa try

## on MacOS, install homebrew first
brew install grep
git clone https://github.com/jianshu93/RecruitmentPlot_blast
cd RecruitmentPlot_blast
### Get example interleaved reads data mentioned above, genomes offered are binned and refine from this metagenome
wget http://rothlab.com/Data/T4AerOil_sbsmpl5.fa.gz
mv T4AerOil_sbsmpl5.fa.gz ./demo_input
gunzip ./demo_input/T4AerOil_sbsmpl5.fa.gz
./makeRecruitmentPlot.sh ./demo_input/MAG ./demo_input/T4AerOil_sbsmpl5.fa try

```

### See an example for the demo dataset
lab5_MAG_001 recruitment plot
![lab5_MAG 001 recruitment](https://user-images.githubusercontent.com/38149286/124207245-13bbad80-dab3-11eb-84be-ca02ae623a16.jpg)

### Reference

Rodriguez-R, Luis M. and Konstantinos T. Konstantinidis. 2016. “The Enveomics Collection: a Toolbox for Specialized Analyses of Microbial Genomes and Metagenomes.” PeerJ 1–16.