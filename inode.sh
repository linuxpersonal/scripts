#!/bin/bash

## Inode Script

function_column () {
    printf "%-18s %-14s %-14s\n\n" $1 $2 $3  
}

if [ ! -z $1 ]; then 
    dir=$1
    if [ ! -d $dir ]; then
        printf "\nError: Unable to locate directory $dir\n\n"
        exit 1
    fi  
else 
    dir=$(pwd) 
fi

totals=$(du -sh $dir 2>/dev/null| awk '{print $1}' | tail -n1)
files=$(find $dir -maxdepth 1 -type f | wc -l)
totali=0

cd $dir

printf "\nInode Stats for $dir\n"
echo -e "\n--------------------------------------------\n"
function_column "Directory" "Inodes" "Size"

function_column "curdir" $files "-" 

IFS=$'\n'

for i in $(ls $dir); do

    if [ -d $i ]; then

    result=$(find $i | wc -l)   
    size=$(du -sh $i 2>/dev/null| awk '{print $1}' | tail -n1)
    
    printf "%-18s %-14s %-14s\n" $i $(($result-1)) $size
    totali=$(($totali+$result))

    fi  

done

echo -e "\n--------------------------------------------\n"
function_column "Total" $((totali+files)) $totals

