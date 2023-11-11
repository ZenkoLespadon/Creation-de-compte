#!/bin/bash


if [ $# -ne 1 ]
then
    echo "Usage: $0 nom_fichier"
    exit 1
fi

sudo groupadd annee1
sudo groupadd annee2
sudo groupadd annee3

# Parcours le fichier ligne par ligne
while read ligne
do
    # Sépare les différentes informations en utilisant le caractère ":" comme délimiteur
    IFS=":" read nom prenom annee_formation numero_telephone date_naissance <<< "$ligne"
    # Calcule la somme des groupes de deux chiffres constituant le numéro de téléphone
    somme=0
    for nombre in $numero_telephone 
    do
	    somme=$((somme+nombre))
    done
    # Génère un caractère spécial au hasard
    caracteres_speciaux="!@#$%^&*"
    caractere_special=$(echo "$caracteres_speciaux" | fold -w1 | shuf | head -n1)
    # Récupère la première lettre du mois de naissance
    mois=$(echo "$date_naissance" | cut -d "/" -f2)
    mois_initial=$(echo "$mois" | tr '[:upper:]' '[:lower:]' | cut -c1)
    # Génère le mot de passe en utilisant les informations précédemment récupérées
    mot_de_passe=$(echo "$nom" | fold -w1 | shuf | head -n1 | tr '[:lower:]' '[:upper:]')
    mot_de_passe="$mot_de_passe$(echo "$prenom" | fold -w1 | shuf | head -n1 | tr  '[:upper:]' '[:lower:]')"
    mot_de_passe="$mot_de_passe$somme$caractere_special$mois_initial"
    # Crée l'utilisateur avec le mot de passe généré et l'ajoute au groupe de son année de formation
    login=$(echo "${prenom:0:1}" | tr '[:lower:]' '[:upper:]')
    login="$login"_"$nom"
    sudo useradd -m -G "annee$annee_formation" "$login"
    echo "$login:$mot_de_passe" >> "fichier_id.txt"
    # Ajoute l'utilisateur au fichier de son année de formation
    echo "$nom:$prenom:"$login":$mot_de_passe" >> "utilisateurs_annee$annee_formation.txt"
    
done < "$1"


# Crée les comptes test et les intégrer aux groupes de leurs années
sudo useradd -m -G annee1 "TestAnnee1"
echo "TestAnnee1:annee1" >> "fichier_id.txt"
echo "annee1:TestAnnee1" >> "utilisateurs_annee1.txt"

sudo useradd -m -G annee2 "TestAnnee2"
echo "TestAnnee2:annee2" >> "fichier_id.txt"
echo "annee2:TestAnnee2" >> "utilisateurs_annee2.txt"

sudo useradd -m -G annee3 "TestAnnee3"
echo "TestAnnee3:annee3" >> "fichier_id.txt"
echo "annee3:TestAnnee3" >> "utilisateurs_annee3.txt"

sudo chpasswd <  "fichier_id.txt"