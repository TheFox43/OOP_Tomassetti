###
#This file aim to look through an entire data folder with nested
#folders and to make two lists out of the data sets, one called
#good_files.txt and the other one as bad_files.txt
###

#Assigning the relative paths to the datafile folders and
#to the folder where we would like to store the results
filepath="../secondolotto_1/"
goodchips="./file_lists/good_chips.txt"
badchips="./file_lists/bad_chips.txt"
goodfiles="./file_lists/good_files.txt"
badfiles="./file_lists/bad_files.txt"

#Second try
for Chip in $(find "$filepath" -type d -name "Chip_*")
do
    #To use grep on a directory you must use the "" to format as a string
    echo "$Chip" | grep "ERR" >> "$badchips"
    echo "$Chip" | grep -v "ERR" >> "$goodchips"
done
for file in $(find $(cat "$goodchips") -type f -name "Ch*.txt")
do
    #Find the number of lines inside the file, tr and cut to get just the number
    lines=$(wc -l "$file" | tr -s " " | cut -d " " -f 2)
    if (( lines == 0 ));
    then
        echo "$file" >> "$badfiles"
    else
        echo "$file" >> "$goodfiles"
    fi
done

#First try
: <<COMMENT
#Walkthrough of every sub-directory
#
#First of all by checking how many of them do we have,
#here we isolate just the 1-depth subdirectories with -d and */
ndir=$(ls -d -1 $filepath*/ | wc -l)
((ndir--))
echo $ndir
#Then we walk through the subdirectories, one at a time
for sub1 in $(ls -d -1 $filepath*/)
do
    #echo $sub1
    for sub2 in $(ls -d $sub1*/)
    do
        #echo $sub2path
        for sub3 in $(ls -d $sub2*/)
        do
            #echo $sub3
            for sub4 in $(ls $sub3*/)
            do
                find $sub4 -name "*ERR*.txt" >> $badfiles
                #echo "Listing "$sub4
            done
        done
    done
done
COMMENT