C'est le test le plus complet avec la NG-Medium communicant avec la Zedboard

il faut donc flasher la partie_NanoXplore sur la NG-Medium et flasher la partie_Zedboard sur la zedboard sans oublier les fichier can opencores dans les 2 parties
le fichier de contrainte pour zedboard est dans le dossier

-appui d'un bouton reset sur les 2 cartes
-appui d'un bouton T sur la nanoXplore pour ecrire dans une RAM 4 trames et demander l'envoi au can_ram
-appui d'un bouton R sur la zedboard pour qu'elle renvoie tout ce qu'il ya dans sa fifo de reception

la transmission se fait a 125Kbit/s

(le module nano_R de la zedboard est different de precedament, il vide la fifo trame par trame au lieu d'en faire juste une seule)

normalement la 2eme trame sur le bus (celle renvoyé par la zedboard) correspond a celle ecrite dans test_can_ram de la partie_NanoXplore.
cela permet de valider le fonctionnement de lecture/ecriture registe, transmission/reception de trames, NX_RAM et du vidage de la FIFO en meme temps
bien que toute ses parties aie été testé individuellement sur NanoXplore plus tot 

------------------POUR NANOXPLORE----------------------------

bank 12 : 09P pour la clock 25Mhz

sur la bank 0 pour les 3 pins de Tx et Rx : 

.       .
B0_02N  .
.       .    
.       .
.       .
.       .
B0_05P  .
B0_07P  .     
.       .
GND     GND

j'utilisais B0_02N pour RX (pin pour oscilloscope), B0_05P pour TX_i, B0_D07P pour TX_o

il les 2 boutons pour RST, BOUTON_T j'utilisais :
RST : B10_12P   bouton au centre
BOUTON_T : B10_07P  a gauche

bank 0 : 3.3V
bank 10 : 1.8V
bank 12 : 2.5B

toute ces info se retrouvent dans les docs devkit_board et devkit_user_guide

-------------POUR ZEDBOARD--------------------

le fichier de contrainte est fourni, ce qu'il faut savoir c'est que la clock de la zedboard est sur Y9 à 100MHz
(le prescaler est donc 4 fois plus grand sur zedboard)

JC2P pour TX_i, JA1 pour TX_o

2 bouton : RST et BOUTON_R
RST : N15 (a gauche)
BOUTON_R : R19 (a droite)


---------------------------------------------

pour brancher les 2 cartes il faut croiser les TX_o et les TX_i (l'emulation du transceiver (le RX) se fait en interne des 2 cartes, via ces 2 signaux)
donc B0_07P avec JC2P et B0_05P avec JA1




