wget ftp://ftp-mouse.sanger.ac.uk/REL-1410-SNPs_Indels/mgp.v4.snps.dbSNP.vcf.gz

bcftools view -Ob mgp.v6.snps.dbSNP.vcf.gz > mgp.v4.snps.dbSNP.bcf

bcftools index mgp.v4.snps.dbSNP.bcf

gqt convert bcf -i mgp.v4.snps.dbSNP.bcf
gqt convert ped -i mgp.v4.snps.dbSNP.bcf

plink \
    --make-bed \
    --vcf mgp.v4.snps.dbSNP.bcf \
    --out mgp.v4.snps.dbSNP.bcf.plink \
    --allow-extra-chr

DATE=`date "+%Y.%m.%d"`
FP="mgp.het_f_times.$DATE"
FN=`ls -1 $FP* 2> /dev/null | wc -l`
F="$FP.$FN.txt"
TOOLS="gqt
gqtc
bcf"
for TOOL in $TOOLS
do
    for i in `seq 1 5`
    do
        src/het_f_times.sh \
            -b mgp.v4.snps.dbSNP.bcf \
            -i 28 \
            -o $TOOL \
        >> $F
    done
done

DATE=`date "+%Y.%m.%d"`
FP="mgp.alc_f_times.$DATE"
FN=`ls -1 $FP* 2> /dev/null | wc -l`
F="$FP.$FN.txt"
TOOLS="gqt
gqtc
bcf
plink"
for TOOL in $TOOLS
do
    for i in `seq 1 5`
    do
        src/alc_f_times.sh \
            -b mgp.v4.snps.dbSNP.bcf \
            -i 28 \
            -o $TOOL \
        >> $F
    done
done
