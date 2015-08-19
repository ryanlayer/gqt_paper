wget ftp://ftp.hgsc.bcm.edu/DGRP/freeze2_Feb_2013/vcf_files/freeze2.vcf.gz

LC_ALL=C
bcftools view freeze2.vcf.gz \
    | awk '$0~"^#" { print $0; next } { print $0 | "sort -k1,1V -k2,2n" }' \
    | bcftools view -Oz \
    > freeze2.sort.vcf.gz
bcftools index freeze2.sort.vcf.gz
bcftools view -Ob freeze2.sort.vcf.gz > freeze2.bcf
bcftools index freeze2.bcf
gqt convert bcf -i freeze4.bcf
gqt convert ped -i freeze2.bcf

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
