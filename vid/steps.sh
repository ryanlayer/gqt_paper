#!/bin/bash
#gqt convert ped -i 1kg.phase3.ped
slow_roll()
{
    S=$1
    C=`echo $S | tr '\' ' '`
    echo -n "$ "
    for i in `seq 0 ${#S}`
    do
        echo -n "${S:$i:1}"
        sleep 0.1
    done
    echo
    eval $C
}

cd $1
#clear
#echo -n "$ "
#sleep 1
#clear
#slow_roll "git clone https://github.com/samtools/htslib.git"
#slow_roll "cd htslib"
#slow_roll "make"
#slow_roll "cd .."
#echo -n "$ "
#sleep 1
#clear
#slow_roll "wget http://www.sqlite.org/2014/sqlite-amalgamation-3080701.zip"
#slow_roll "unzip sqlite-amalgamation-3080701.zip"
#echo -n "$ "
#sleep 1
#clear
#slow_roll "git clone https://github.com/ryanlayer/gqt.git"
#slow_roll "cd gqt"
#slow_roll "make"
#slow_roll "cd .."
#echo -n "$ "
#sleep 1
#clear
#slow_roll "wget --trust-server-names http://bit.ly/gqt_bcf"
#slow_roll "bcftools index chr11.11q14.3.bcf"
slow_roll "gqt/bin/gqt convert bcf -i chr11.11q14.3.bcf"
echo -n "$ "
sleep 1
clear
slow_roll "gqt/bin/gqt convert ped -i chr11.11q14.3.bcf"
echo -n "$ "
sleep 1
clear
slow_roll "bcftools query -l chr11.11q14.3.bcf"
echo -n "$ "
sleep 1
clear
slow_roll "gqt/bin/gqt query \ 
    -i chr11.11q14.3.bcf.gqt \ 
    -p \"Sample_ID ='NA12878'\" \ 
    -g \"count(HOMO_ALT)==1\" \ 
    -c"
echo -n "$ "
sleep 1
clear
slow_roll "gqt/bin/gqt query \ 
    -i chr11.11q14.3.bcf.gqt \ 
    -p \"Sample_ID ='NA12878'\" \ 
    -g \"count(HOMO_ALT)==1\" \ 
    | less -S"
echo -n "$ "
sleep 1
clear
slow_roll "wget --trust-server-names http://bit.ly/gqt_ped"
slow_roll "head 1kg.phase3.ped"
slow_roll "gqt/bin/gqt convert ped -i chr11.11q14.3.bcf -p 1kg.phase3.ped"
clear
slow_roll "ls"
echo -n "$ "
sleep 1
clear
slow_roll "gqt/bin/gqt query \ 
    -i chr11.11q14.3.bcf.gqt \ 
    -d 1kg.phase3.ped.db \ 
    -p \"Population ='GBR'\" \ 
    -g \"maf()>0.1\" \ 
    -c"
echo -n "$ "
sleep 1
clear
slow_roll "gqt/bin/gqt query \ 
    -i chr11.11q14.3.bcf.gqt \ 
    -d 1kg.phase3.ped.db \ 
    -p \"Population ='GBR'\" \ 
    -g \"maf()>0.1\" \ 
    -p \"Population in ('YRI','LWK','GWD','MSL','ESN','ASW','ACB')\" \ 
    -g \"maf()<0.01\" \ 
    -c"
echo -n "$ "
sleep 1
clear
slow_roll "wget --trust-server-names http://bit.ly/gqt_genes"
slow_roll "gqt/bin/gqt query \ 
    -i chr11.11q14.3.bcf.gqt \ 
    -d 1kg.phase3.ped.db \ 
    -p \"Population ='GBR'\" \ 
    -g \"maf()>0.1\" \ 
    -p \"Population in ('YRI','LWK','GWD','MSL','ESN','ASW','ACB')\" \ 
    -g \"maf()<0.01\" \ 
    | bedtools intersect -a genes.bed -b stdin \ 
    > GBR_not_AFR_genes.bed"

slow_roll "head GBR_not_AFR_genes.bed"

slow_roll "cat GBR_not_AFR_genes.bed | cut -f4 | sort | uniq -c"
