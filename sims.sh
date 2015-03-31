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

bcftools stats 100.1e8.var.bcf | grep SN
# # SN, Summary numbers:
# # SN   [2]id   [3]key  [4]value
# SN 0   number of samples:  100
# SN 0   number of records:  588830

bcftools stats 500.1e8.var.bcf | grep SN
## SN, Summary numbers:
## SN    [2]id   [3]key  [4]value
#SN  0   number of samples:  500
#SN  0   number of records:  752295

bcftools stats 1000.1e8.var.bcf | grep SN
## SN, Summary numbers:
## SN    [2]id   [3]key  [4]value
#SN  0   number of samples:  1000
#SN  0   number of records:  816284

bcftools stats 5000.1e8.var.bcf | grep SN
## SN, Summary numbers:
## SN   [2]id   [3]key  [4]value
#SN 0   number of samples:  5000
#SN 0   number of records:  977108

bcftools stats 10000.1e8.var.bcf | grep SN
## SN, Summary numbers:
## SN    [2]id   [3]key  [4]value
#SN  0   number of samples:  10000
#SN  0   number of records:  1047031

bcftools stats 100000.1e8.var.bcf | grep SN
## SN, Summary numbers:
## SN    [2]id   [3]key  [4]value
#SN  0   number of samples:  100000
#SN  0   number of records:  2052387

gqt convert bcf -i 100.1e8.var.bcf -r 588830 -f 100

gqt convert bcf -i 500.1e8.var.bcf -r 752295 -f 500

gqt convert bcf -i 1000.1e8.var.bcf -r 816284 -f 1000

gqt convert bcf -i 5000.1e8.var.bcf -r 977108 -f 5000

gqt convert bcf -i 10000.1e8.var.bcf -r 1047031 -f 10000

gqt convert bcf -i 100000.1e8.var.bcf -r 2052387 -f 100000

for BCF in `ls *bcf`
do
    $HOME/src/gqt/scripts/simple_ped.sh -f $BCF > $BCF.ped
    echo $BCF
    time gqt convert ped -i $BCF.ped
done

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
