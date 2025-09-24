###
#This file aim to look through an entire data folder with nested
#folders and to make two lists out of the data sets, one called
#good_files.txt and the other one as bad_files.txt
###

#Assigning the relative paths to the datafile folder and the filepath
#of the listing results
filepath="../secondolotto_1/"
goodchips="./file_lists/good_chips.txt"
badchips="./file_lists/bad_chips.txt"
goodfiles="./file_lists/good_files.txt"
badfiles="./file_lists/bad_files.txt"
#Final output file of processed datas
processeddata="./processed_data.txt"

#Third try
#
#Getting the precessed data file ready
echo "N,M,Chip#,Offset,Ch,TRANS,WIDTH" > "$processeddata"
#
#Walking and filtering the right chips directories
for Chip in $(find "$filepath" -path "*__[0-9]*/*_Summary/Chip*" -type d -name "Chip_*")
do
    #To use grep on a directory you must use the "" to format as a string
    echo "$Chip" | grep "ERR" >> "$badchips"
    chiptemp=$(echo "$Chip" | grep -v "ERR")
    echo "$chiptemp" >> "$goodchips"
    #Walking through everyfile to list them and take the data out
    for file in $(find "$chiptemp" -path "*/S_curve/*" -type f -name "Ch*.txt")
    do
        #First check: empty file or not
        if [ ! -s "$file" ];
        then
            echo "$file" >> "$badfiles"
        else
            #Trying to get the data out of the file: transition point and width
            trans=$(head -n 1 "$file" | cut -d " " -f 2)
            width=$(head -n 1 "$file" | cut -d " " -f 3)
            #Second check: the format of the file, it has to be good or to get discarded
            if [[ -z $trans && -z $width ]]; #double parenthesis because it's a boolean operation, we could write -a to say AND, while -z means NOT
            then
                #If it's true, it means that trans and width cathed no numeric values
                echo "$file" >> "$goodfiles"
            else
                #Getting the information out of the file name, now that we know it's a good one
                numbers=$(echo "$file" | grep -o "[0-9]\+" | tr "\n" ",")
                echo "$numbers"",""$trans"",""$width" >> "$processeddata"
            fi
        fi
    done
done

#Old filter
#lines=$(wc -l "$file" | tr -s " " | cut -d " " -f 2)
#if [ "$lines" -eq 0 ];

#Old nested loop
: << COMMENT
for file in $(find $(cat "$goochips") -path "*/S_curve/*" -type f -name "Ch*.txt")
do
    #Check of the format of the file, it has to be good or get discarded
    lines=$(wc -l "$file" | tr -s " " | cut -d " " -f 2)
    if (( lines == 0 ));
    then
        echo "$file" >> "$badfiles"
    else
        echo "$file" >> "$goodfiles"
        #Data cleaning: transition point and width
        trans=$(head -n 1 "$file" | cut -d " " -f 2)
        width=$(head -n 1 "$file" | cut -d " " -f 3)
        echo "$trans"
    fi
done
COMMENT

: << COMMENT
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
COMMENT

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