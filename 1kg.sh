wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/*vcf.gz
wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/supporting/vcf_with_sample_level_annotation/*vcf.gz

for F in `ls *.vcf.gz`
do
    B=`basename $1 .vcf.gz`
    bcftools reheader -h new.header $F | bcftools view -Ob > $B.bcf
    bcftools index $B.bcf
done
 
bcftools concat -Ob \
    -o ALL.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr10.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr11.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr12.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr13.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr14.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr15.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr16.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr17.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr18.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr19.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr1.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr20.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr21.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr22.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr2.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr3.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr4.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr5.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr6.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr7.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr8.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chr9.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf \
    ALL.chrX.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf

OVCF=ALL.phase3_shapeit2_mvncall_integrated_v5_extra_anno.20130502.genotypes.bcf
export BCFTOOLS_PLUGINS="$HOME/src/bcftools/plugins/"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/src/htslib"

#100
S=`bcftools view $OVCF\
    | grep -m 1 "#CHROM" \
    | cut -f10- \
    | tr '\t' '\n' \
    | ~/bin/reservoir_sampling 100 \
    | tr '\n' ',' \
    | sed -e "s/,$//"`

bcftools view -s $S $OVCF \
    | bcftools plugin fill-AN-AC \
    | bcftools view -Ob -c 1 \
    > 100.bcf
bcftools index 100.bcf

#500
S=`bcftools view $OVCF\
    | grep -m 1 "#CHROM" \
    | cut -f10- \
    | tr '\t' '\n' \
    | ~/bin/reservoir_sampling 500 \
    | tr '\n' ',' \
    | sed -e "s/,$//"`

bcftools view -s $S $OVCF \
    | bcftools plugin fill-AN-AC \
    | bcftools view -Ob -c 1 \
    > 500.bcf
bcftools index 500.bcf

#1000
S=`bcftools view $OVCF\
    | grep -m 1 "#CHROM" \
    | cut -f10- \
    | tr '\t' '\n' \
    | ~/bin/reservoir_sampling 1000 \
    | tr '\n' ',' \
    | sed -e "s/,$//"`

bcftools view -s $S $OVCF \
    | bcftools plugin fill-AN-AC \
    | bcftools view -Ob -c 1 \
    > 1000.bcf
bcftools index 1000.bcf

ln -s $OVCF 2504.bcf
bcftools index 2504.bcf

gqt convert bcf -i 100.bcf
gqt convert ped -i 100.bcf

gqt convert bcf -i 500.bcf
gqt convert ped -i 500.bcf

gqt convert bcf -i 1000.bcf
gqt convert ped -i 1000.bcf

gqt convert bcf -i 2504.bcf
gqt convert ped -i 2504.bcf

plink \
    --make-bed \
    --bcf 100.bcf \
    --out 100.bcf.plink \
    --allow-extra-chr

plink \
    --make-bed \
    --bcf 500.bcf \
    --out 500.bcf.plink \
    --allow-extra-chr

plink \
    --make-bed \
    --bcf 1000.bcf \
    --out 1000.bcf.plink \
    --allow-extra-chr

plink \
    --make-bed \
    --bcf 2504.bcf \
    --out 2504.bcf.plink \
    --allow-extra-chr

INDS="100
500
1000
2504"
DATE=`date "+%Y.%m.%d"`
FP="onekg.het_f_times.$DATE"
FN=`ls -1 $FP* 2> /dev/null | wc -l`
F="$FP.$FN.txt"
TOOLS="gqt
gqtc
bcf"
for TOOL in $TOOLS
do
    for IND in $INDS
    do
        for i in `seq 1 5`
        do
            src/het_f_times.sh \
                    -b $IND.bcf \
                    -i $IND \
                    -o $TOOL \
            >> $F
            done
    done
done

INDS="100
500
1000
2504"
DATE=`date "+%Y.%m.%d"`
FP="onekg.alc_f_times.$DATE"
FN=`ls -1 $FP* 2> /dev/null | wc -l`
F="$FP.$FN.txt"
TOOLS="gqt
gqtc
bcf
plink"
for TOOL in $TOOLS
do
    for IND in $INDS
    do
        for i in `seq 1 5`
        do
            src/alc_f_times.sh \
                    -b $IND.bcf \
                    -i $IND \
                    -o $TOOL \
            >> $F
            done
    done
done
