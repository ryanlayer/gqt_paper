INDS="100
500
1000
5000
10000
100000"

SIZE=1e8

for POP in $INDS
do
    HAP=`calc $POP*2`
    $HOME/src/macs/macs $HAP $SIZE -T -t .001 -r .001 2>/dev/null \
        | src/macs_hap_to_vcf.py $POP \
    | bcftools view -Ob > $POP.$SIZE.var.bcf
done

bcftools index 100.1e8.var.bcf
gqt convert bcf -i 100.1e8.var.bcf
gqt convert ped -i 100.1e8.var.bcf

bcftools index 500.1e8.var.bcf
gqt convert bcf -i 500.1e8.var.bcf
gqt convert ped -i 500.1e8.var.bcf

bcftools index 1000.1e8.var.bcf
gqt convert bcf -i 1000.1e8.var.bcf
gqt convert ped -i 1000.1e8.var.bcf

bcftools index 5000.1e8.var.bcf
gqt convert bcf -i 5000.1e8.var.bcf
gqt convert ped -i 5000.1e8.var.bcf

bcftools index 10000.1e8.var.bcf
gqt convert bcf -i 10000.1e8.var.bcf
gqt convert ped -i 10000.1e8.var.bcf

bcftools index 100000.1e8.var.bcf
gqt convert bcf -i 100000.1e8.var.bcf
gqt convert ped -i 100000.1e8.var.bcf

plink \
    --make-bed \
    --bcf 100.1e8.var.bcf \
    --out 100.1e8.var.bcf.plink \
    --allow-extra-chr

plink \
    --make-bed \
    --bcf 500.1e8.var.bcf \
    --out 500.1e8.var.bcf.plink \
    --allow-extra-chr

plink \
    --make-bed \
    --bcf 1000.1e8.var.bcf \
    --out 1000.1e8.var.bcf.plink \
    --allow-extra-chr

plink \
    --make-bed \
    --bcf 5000.1e8.var.bcf \
    --out 5000.1e8.var.bcf.plink \
    --allow-extra-chr

plink \
    --make-bed \
    --bcf 10000.1e8.var.bcf \
    --out 10000.1e8.var.bcf.plink \
    --allow-extra-chr

plink \
    --make-bed \
    --bcf 100000.1e8.var.bcf \
    --out 100000.1e8.var.bcf.plink \
    --allow-extra-chr

DATE=`date "+%Y.%m.%d"`
FP="sim.het_f_times.$DATE"
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
                -b $IND.1e8.var.bcf \
                -i $IND \
                -o $TOOL \
            >> $F
        done
    done
done

DATE=`date "+%Y.%m.%d"`
FP="sim.alc_f_times.$DATE"
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
                -b $IND.1e8.var.bcf \
                -i $IND \
                -o $TOOL \
            >> $F
        done
    done
done
