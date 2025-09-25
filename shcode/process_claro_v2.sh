#!/bin/bash
# secondolotto_1/Station_N__M/Station_N__M_Summary/Chip_LLL/S_curve/Ch_C_offset_?_Chip_LLL.txt
# 40911 files with valid data processed
# real	7m33.800s
# user	6m47.152s
# sys	10m13.151s

# ./BASH/process_claro.sh secondolotto_1  86,24s user 306,55s system 211% cpu 3:05,51 total
#!/bin/bash
# Script ottimizzato per elaborare file "Ch_?_offset_?_Chip_???.txt"

# Controllo degli argomenti
if [[ -z $1 ]]; then
	echo "Please, provide the top directory to be processed"
	echo "Usage: $0 <directory> [output_file]"
	exit 1
fi

OUTFILE="${2:-./claro_processed.txt}"
FFILEIN="./claro_files.txt"
FFILEOUT="./claro_good_files.txt"

# Trova i file da elaborare (solo se non esiste già la lista)
if [[ ! -f $FFILEIN ]]; then
	echo "+  Finding files to be processed"
	find "$1" -path "*__[0-9]*/*_Summary/Chip_???/S_curve/*" -type f -name "Ch_?_offset_?_Chip_???.txt" > "$FFILEIN"
else
	echo "+  Using $FFILEIN list"
fi

# Conta i file da elaborare
NFILES=$(wc -l < "$FFILEIN")
echo "$NFILES files to process..."

# Sovrascrivi il file di output e scrivi l'intestazione
echo "N,M,Chip#,Offset,Ch,TRANS,WIDTH" > "$OUTFILE"
echo "N,M,Chip#,Offset,Ch,TRANS,WIDTH" > "claro_bad.txt"

COUNTER=0

# Elabora ogni file
while IFS= read -r FILENAME; do
	# Estrai numeri significativi dal percorso del file
	NMLOC=$(echo "$FILENAME" | sed -E 's/[^0-9]+/ /g' | awk '{print $2","$3","$6","$8","$7}')

	# Estrai i valori di TRANS e WIDTH, escludendo file con dati non validi
	VALUES=$(awk 'NR==1 && !/search|dati|monotona/ {print $2","$3}' "$FILENAME" | tr -d '-')

	if [[ -n $VALUES ]]; then
		echo "$NMLOC,$VALUES" >> "$OUTFILE"
		echo "$FILENAME" >> "$FFILEOUT"
		((COUNTER++))
	else
		echo "$FILENAME" >> "claro_bad.txt"
	fi

	# Output di stato ogni 1000 file
	if (( COUNTER % 1000 == 0 )); then
		echo "   $COUNTER files processed"
	fi
done < "$FFILEIN"

echo -e "\n$COUNTER files with valid data processed."