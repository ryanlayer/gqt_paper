#!/bin/bash

############################################################
#  Program:
#  Author :
############################################################


## BEGIN SCRIPT
usage()
{
    cat << EOF

usage: $0 OPTIONS

OPTIONS can be:
    -h      Show this message
    -b      BCF Filename
    -i      Number of individuals 
    -o      Operation (bcf, gqt, gqtc)
EOF
}

# Show usage when there are no arguments.
if test -z "$1"
then
    usage
    exit
fi

BCF=
SIZE=
OP=

# Check options passed in.
while getopts "h b:i:o:" OPTION
do
    case $OPTION in
        h)
            usage
            exit 1
            ;;
        o)
            OP=$OPTARG
            ;;
        b)
            BCF=$OPTARG
            ;;
        i)
            SIZE=$OPTARG
            ;;
        ?)
            usage
            exit
            ;;
    esac
done

if [ -z $BCF ]
then
    echo "No BCF given"
    usage
    exit 1
fi

if [ -z $SIZE ]
then
    echo "Number of individuals not given"
    usage
    exit 1
fi

if [ -z $OP ]
then
    echo "No operation given"
    usage
    exit 1
fi



if [ ! -f $BCF\.ped.db ]; then
    ~/src/gqt/scripts/simple_ped.sh -f $BCF > $BCF\.ped
    gqt convert ped -i $BCF\.ped
fi

POP=`calc $SIZE/10 | cut -d "." -f1`
AF=`calc $POP/100 | cut -d "." -f1`

if [ $AF -eq 0 ]
then
    AF=1
fi

if [ "$OP" == "gqtc" ]
then
    # GQT
    LAST_NAME=`tail -n $POP $BCF\.ped | head -n 1 | awk '{print $1;}'`
    LAST_ID=`sqlite3 $BCF.ped.db "select Ind_ID from ped where Sample_Name='$LAST_NAME'"`

    CMD="gqt query -i $BCF\.gqt \
         -c \
         -d $BCF\.ped.db \
         -p \"Ind_ID >= $LAST_ID\" \
         -g \"count(HET HOMO_ALT)<=$AF\" "
 
    #echo $CMD

    T="$( sh -c "TIMEFORMAT='%3R'; time $CMD > o" 2>&1)"
    echo -e "$SIZE\tgqtc\t$T"
elif [ "$OP" == "gqt" ]
then
    LAST_NAME=`tail -n $POP $BCF\.ped | head -n 1 | awk '{print $1;}'`
    LAST_ID=`sqlite3 $BCF.ped.db "select Ind_ID from ped where Sample_Name='$LAST_NAME'"`

    CMD="gqt query -i $BCF\.gqt \
         -d $BCF\.ped.db \
         -p \"Ind_ID >= $LAST_ID\" \
         -g \"count(HET HOMO_ALT)<=$AF\" "

    #echo $CMD
    
    T="$( sh -c "TIMEFORMAT='%3R'; time $CMD > o" 2>&1)"
    echo -e "$SIZE\tgqt\t$T"
elif [ "$OP" == "bcf" ]
then
    # BCFTOOLS
    tail -n $POP $BCF\.ped | awk '{print $1}' > .bcftools.keep
    CMD="bcftools view -C $AF -S .bcftools.keep $BCF"

    #echo $CMD

    T="$( sh -c "TIMEFORMAT='%3R'; time $CMD > o" 2>&1)"
    echo -e "$SIZE\tbcf\t$T"
    rm .bcftools.keep
else
    echo "Unknown operation"
fi
