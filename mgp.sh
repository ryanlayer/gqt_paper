wget ftp://ftp-mouse.sanger.ac.uk/current_snps/mgp.v4.snps.dbSNP.vcf.gz

bcftools view -Ob mgp.v4.snps.dbSNP.vcf.gz > mgp.v4.snps.dbSNP.bcf

src/simple_ped.sh \
    -f mgp.v4.snps.dbSNP.bcf \
    > mgp.v4.snps.dbSNP.bcf.ped

gqt convert ped -i mgp.v4.snps.dbSNP.bcf.ped

bcftools stats mgp.v4.snps.dbSNP.bcf  | grep SN
## The command line was: bcftools stats  mgp.v4.snps.dbSNP.vcf.gz
#ID  0   mgp.v4.snps.dbSNP.vcf.gz
## SN, Summary numbers:
## SN    [2]id   [3]key  [4]value
#SN  0   number of samples:  28
#SN  0   number of records:  68139950

gqt convert bcf -i mgp.v4.snps.dbSNP.bcf -r 68139950 -f 28

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
