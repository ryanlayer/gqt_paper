wget ftp://ftp.hgsc.bcm.edu/DGRP/freeze2_Feb_2013/vcf_files/freeze2.vcf.gz

bcftools view -Ob freeze2.vcf.gz > freeze2.bcf

src/simple_ped.sh \
    -f freeze2.bcf \
    > freeze2.bcf.ped

gqt convert ped -i freeze2.bcf.ped

bcftools stats freeze2.bcf  | grep SN | head -4
## SN, Summary numbers:
## SN    [2]id   [3]key  [4]value
#SN  0   number of samples:  205
#SN  0   number of records:  6146611

gqt convert bcf -i freeze2.bcf -r 6146611 -f 205

plink \
    --make-bed \
    --bcf freeze2.bcf \
    --out freeze2.bcf.plink \
    --allow-extra-chr

DATE=`date "+%Y.%m.%d"`
FP="dgrp.het_f_times.$DATE"
FN=`ls -1 $FP* 2> /dev/null | wc -l`
F="$FP.$FN.txt"
TOOLS="gqt
gqtc
bcf"
for TOOL in $TOOLS
    do
        for i in `seq 1 5`
        do
            ~/src/gqt_paper/src/het_f_times.sh \
                -b freeze2.bcf \
                -i 205 \
                -o $TOOL \
            >> $F
    done
done

DATE=`date "+%Y.%m.%d"`
FP="dgrp.alc_f_times.$DATE"
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
        ~/src/gqt_paper/src/alc_f_times.sh \
            -b freeze2.bcf \
            -i 205 \
            -o $TOOL \
        >> $F
    done
done
