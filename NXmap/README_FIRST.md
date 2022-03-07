Notice d'utilisation des fichiers sources
===
*****************************************

| Projet  | CREME                       |
| :-------| ---------------------------:|
| Date    | 22/09/2021                  |
| Auteur  | Guillaume.Gourves@onera.fr  |
| Version | v1.0                        |

****************************************

# Introduction
Ce dossier ainsi que les sous dossiers contiennent  un ensemble de fichier sours Verilog/VHDL régider de manière à être synthétisable pour une cible de type NG-Medium (NanoXplore).

# Logiciels nécessaires
Pour synthétiser les exemples ou programmes, nous aurons besoin des logiciels propriétaires suivants :
* Nxmap : Environnement graphique pour synthétiser/router/implémenter des fichier Verilog et VHDL sur cible NG-Medium. (source : https://download.nanoxplore.com/index.php/nxmap3/ ). Ce logiciel contient aussi Nxpython qui est logiciel similaire à python mais avec des module propre permettant de réaliser les même tâche que nxmap mais au travers de scrip python (inclut dans l'installation de nxmap3).
* NxBase : NxBase permet de transferé le bitstream réalisé par NxMap vers un FPGA NanoXplore. (source : https://download.nanoxplore.com/index.php/nxbase2/).
* Un editeur de texte : Nous recommandons l'éditeur Atom qui est très polivalent (source : https://atom.io/).  

# Organisation des projets :

Les dossiers projet sont organiser de la manière suivante :
* Les fichiers sources se situeront à la racine du dossier.
* Un script python se joint au dossier au dossier pour proposer une synthèse à partir d'une console nxPython.
* Un fichier README.md explicant l'objectif du projet, les fichiers nécessaires (dont les fichiers ne se situant pas à la racine du dossier) ainsi que les résultat à attendre.

L'objectif étant que l'utilisateur lise en premier lieu les README.md pour qu'il puisse bien prendre consience du projet et de réaliser rapidement des tests.

# Lancement de la Synthese et implementation

Un ou un ensemble de script python (.py) seront présent dans chaque projet. Pour les lancer, démarrez une console nxpython (en tapant juste dans un terminal "nxpython") et executez la commande suivante :

~~~
exec(open("<nom du script>.py").read())
~~~

Chaque dossier comportera au minimum un script "build_bitstream.py" pour effectuer la synthèse.

Le résultat en sortie du lancement de ce script sera un <fichier>.nxb. Pour flasher le bitstream, tapez la commande suivante :

~~~
sudo nxbase -i <fichier>.nxb
~~~
