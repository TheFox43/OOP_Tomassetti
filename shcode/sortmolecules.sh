#Calcolo numero di file molecules
#
#Assegniamo il path a relativo ai file
path='../data_shell/molecules/'
N=$(wc -l "$path"*.pdb | wc -l | tr -d ' ')
#wc aggiunge la riga del total, a noi non serve
((N--))
echo $N

#Ordinamento e stampa lista dei file molecule in ordine di grandezza
#
#Prende i file, li ordine per grandezza, comprime gli spazi di output di wc tramite tr
#toglie i numeri con cut e salva in list
list=$(wc -l $path*.pdb | sort -n | tr -s ' ' | cut -d ' ' -f 3 | head -n $N)
#Isolamento del nome, sappiamo che per togliere path con cut abbiamo / come delimter,
#sappiamo la posizione ossia il numero di / + 1, poi puliamo il tipo di file toglindo dopo il punto, serve un ciclo che echo stampa solo il primo oggetto
for listed in $list
do
    echo $listed | cut -d "/" -f 4 | cut -d "." -f 1 >> ./sortedmolecules.txt
done
cat ./sortedmolecules.txt