###
#This file aim to look through an entire data folder with nested
#folders and to make two lists out of the data sets, one called
#good_files.txt and the other one as bad_files.txt
###

#Assigning the relative paths to the datafile folder and the filepath
#of the listing results
filepath="../../data/secondolotto_1/"
badchips="../../outdata/file_lists/bad_chips.txt"
goodfiles="../../outdata/file_lists/good_files.txt"
badfiles="../../outdata/file_lists/bad_files.txt"
#Initializing output file
: > ./file_lists/bad_files.txt
#Final output file of processed datas
processeddata="../../outdata/processed_claro.csv"

#Fourth try
#
#Check if there is any bad chips list already 
if [[ ! -s "$badchips" || ! -f "$badchips" ]];
then
    #Initializing the output file
    : > ./file_lists/bad_chips.txt
	echo "+  Finding bad chips folders"
	find "$filepath" -path "*__[0-9]*/*_Summary/*" -type d -name "Chip*ERR*" > "$badchips"
else
	echo "+  Already existing $badchips list"
fi
#Check if there is any good file list already, this is Professor's if statement, it does not check empty or bad files though
if [[ ! -s "$goodfiles" ]];
then
    #Initializing files
    : > ./file_lists/good_files.txt

	echo "+  Finding fitting files and processing them"
    #Getting the precessed data file ready
    echo "N,M,Chip#,Offset,Ch,TRANS,WIDTH" > "$processeddata"
    while IFS= read -r -d "" file;
    do
        [[ -z "$file" ]] && continue
        if [[ ! -s "$file" ]];
        then
            echo "$file" >> "$badfiles"
            continue
        fi

        #Trying to get the data out of the file: transition point and width
        trans=$(head -n 1 "$file" | cut -f 2)
        width=$(head -n 1 "$file" | cut -f 3)
        #Second check: the format of the file, it has to be good or to get discarded
        if [[ -z $trans || -z $width ]]; #double parenthesis because it's a boolean operation, we could write -a to say AND, while -z means NOT
        then
            #If it's true, it means that trans and width cathed no numeric values
            echo "$file" >> "$badfiles"
            continue
        else
            #Getting the information out of the file name, now that we know it's a good one
            numbers=$(grep -o "[0-9]\+" <<< "$file" | tr "\n" ",")
            echo "$file" >> "$goodfiles"
            echo "${numbers%,},$trans,$width" >> "$processeddata" #removing the exceeding "," with %,
        fi
    done < <(find "$filepath" -path "*__[0-9]*/*_Summary/Chip_???/S_curve/*" -type f -name "Ch_?_offset_?_Chip_???.txt" -print0)
else
	echo "+  Using $goodfiles list"
    #Getting the precessed data file ready
    echo "N,M,Chip#,Offset,Ch,TRANS,WIDTH" > "$processeddata"
    #Walking and filtering the right chips directories
    while IFS= read -r file;
    do
        #Trusting the already existing file list, there's no need to check the file format and the data inside of it
        trans=$(head -n 1 "$file" | cut -f 2)
        width=$(head -n 1 "$file" | cut -f 3)
        numbers=$(echo "$file" | grep -o "[0-9]\+" | tr "\n" ",")
        echo "$numbers,$trans,$width" >> "$processeddata"
        echo "$file" >> "$goodfiles"
    done < "$goodfiles"
fi

: << COMMENT
#
#Walking and filtering the right chips directories
for file in $(cat "$goodfiles")
do
    #First check: empty file or not
    if [[ ! -s "$file" || ! -f "$file" ]];
    then
        echo "$file" >> "$badfiles"
    else
        #Trying to get the data out of the file: transition point and width
        trans=$(head -n 1 "$file" | cut -f 2)
        width=$(head -n 1 "$file" | cut -f 3)
        #Second check: the format of the file, it has to be good or to get discarded
        if [[ -z $trans && -z $width ]]; #double parenthesis because it's a boolean operation, we could write -a to say AND, while -z means NOT
        then
            #If it's true, it means that trans and width cathed no numeric values
            echo "$file" >> "$badfiles"
        else
            #Getting the information out of the file name, now that we know it's a good one
            numbers=$(echo "$file" | grep -o "[0-9]\+" | tr "\n" ",")
            echo "$numbers,$trans,$width" >> "$processeddata"
            echo "$file" >> "$goodfiles"
        fi
    fi
done
COMMENT

#Third try
: << COMMENT
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
                echo "$file" >> "$badfiles"
            else
                #Getting the information out of the file name, now that we know it's a good one
                numbers=$(echo "$file" | grep -o "[0-9]\+" | tr "\n" ",")
                echo "$numbers"",""$trans"",""$width" >> "$processeddata"
                echo "$file" >> "$goodfiles"
            fi
        fi
    done
done
COMMENT

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

#Second try
: << COMMENT
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