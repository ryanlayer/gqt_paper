#!/bin/bash

############################################################
#  Program:
#  Author :
############################################################

GQT=gqt

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

POP=`calc $SIZE/10 | cut -d "." -f1`
AF=`calc $POP/100 | cut -d "." -f1`

if [ $AF -eq 0 ]
then
    AF=1
fi

if [ "$OP" == "gqtc" ]
then
    LAST_ID=`sqlite3 $BCF.db "SELECT BCF_ID from ped ORDER BY BCF_ID;" | tail -n $POP | head -n 1;`

    CMD="$GQT query -i $BCF\.gqt \
         -c \
         -d $BCF\.db \
         -p \"BCF_ID >= $LAST_ID\" \
         -g \"count(HET HOM_ALT)<=$AF\" "

    #echo $CMD
 
    T="$( sh -c "TIMEFORMAT='%3R'; time $CMD > o" 2>&1)"
    echo -e "$SIZE\tgqtc\t$T"
elif [ "$OP" == "gqt" ]
then
    LAST_ID=`sqlite3 $BCF.db "SELECT BCF_ID from ped ORDER BY BCF_ID;" | tail -n $POP | head -n 1;`

    CMD="$GQT query -i $BCF\.gqt \
         -p \"BCF_ID >= $LAST_ID\" \
         -g \"count(HET HOM_ALT)<=$AF\" "

    #echo $CMD
    
    T="$( sh -c "TIMEFORMAT='%3R'; time $CMD > o" 2>&1)"
    echo -e "$SIZE\tgqt\t$T"
elif [ "$OP" == "bcf" ]
then
    # BCFTOOLS
    sqlite3 $BCF.db "SELECT BCF_ID,BCF_Sample from ped ORDER BY BCF_ID;" \
    | tail -n $POP \
    | cut -d "|" -f2 \
    > .bcftools.keep

    CMD="bcftools view -C $AF -S .bcftools.keep $BCF"

    #echo $CMD

    T="$( sh -c "TIMEFORMAT='%3R'; time $CMD > o" 2>&1)"
    echo -e "$SIZE\tbcf\t$T"
    rm .bcftools.keep
else
    echo "Unknown operation"
fi
