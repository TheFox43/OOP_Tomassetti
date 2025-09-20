#Calcolo numero di file molecules
path='../data_shell/molecules/'
N=$(wc -l $path*.pdb | wc -l | tr -d ' ')
((N--))
echo $N

#Ordinamento e stampa lista dei file molecule in ordine di grandezza
wc -l ../data_shell/molecules/*.pdb | sort -n | tr -d ' ' | head -n $N > ./sortedbylines.txt
cat ./sortedbylines.txt
echo "Circa sium"