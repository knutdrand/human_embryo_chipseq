#!/bin/bash

# set the path to as file for narrowPeak. Locate it in your UCSC source code directory or google...
asfile=narrowPeak.as

which bedToBigBed &>/dev/null || { echo "bedToBigBed not found! Download: <http://hgdownload.cse.ucsc.edu/admin/exe/>"; exit 1; }

if [ $# -lt 2 ];then
    echo "Need 2 parameters! <narrowPeak> <chrom info>"
    exit
fi

F=$1
G=$2

bedtools slop -i ${F} -g ${G} -b 0 | ./bedClip stdin ${G} ${F}.clip

# fix scores over 1000
perl -pi -e 'chomp;@_=split;if ($_[4]>1000) {$_[4]=1000} $_=join("\t",@_)."\n"' ${F}.clip

bedToBigBed ${F}.clip $G ${F/.bed/}.bb

rm -f ${F}.clip
