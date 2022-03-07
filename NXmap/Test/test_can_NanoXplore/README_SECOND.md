Notice d'utilisation des fichiers sources
========

| Projet  | CREME                       |
| :-------| ---------------------------:|
| Date    | 22/09/2021                  |
| Auteur  | Guillaume.Gourves@onera.fr  |
| Version | v1.0                        |

# Introduction
 L'objectif de ce test est de controler le bon fonctionnement le l'IP CAN fournit par la fondation OPENCORES.org. (Sujet de stage Joffrey DOLY).

# Fichiers necessaire

Les fichiers sources necessaire a inclure dans ce projet sont les suivant :

* ./can_controller.vhd
* ./nano_R.vhd
* ./nano_T.vhd
* ./test_complet_nano.vhd
* ./wishbone_driver.vhdl
* ../../OpenCores/can/trunk/verilog/can_acf.v
* ../../OpenCores/can/trunk/verilog/can_bsp.v
* ../../OpenCores/can/trunk/verilog/can_btl.v
* ../../OpenCores/can/trunk/verilog/can_crc.v
* ./can_defines.v
* ../../OpenCores/can/trunk/verilog/can_fifo.v
* ../../OpenCores/can/trunk/verilog/can_ibo.v
* ../../OpenCores/can/trunk/verilog/can_register_asyn_syn.v
* ../../OpenCores/can/trunk/verilog/can_register_asyn.v
* ../../OpenCores/can/trunk/verilog/can_register_syn.v
* ../../OpenCores/can/trunk/verilog/can_register.v
* ../../OpenCores/can/trunk/verilog/can_registers.v
* ../../OpenCores/can/trunk/verilog/can_top.v

Décommenter le define IF_WISHBONE dans can_define

# Cablage a effectuer

bank 12 : 09P pour la clock 25Mhz

sur la bank 0 pour les 5 pins de Tx et Rx :

| Pin bank 0 gauche | Pin bank 0 droite     || Pin bank 12 gauche | Pin bank 12 droite   |
| :-:               | :-:                   || :-:                | :-:                  |
| .                 | .                     || .                  | .                    |
| B0_02N            | .                     || .                  | .                    |
| .                 | .                     || .                  | .                    |
| .                 | .                     || .                  | .                    |
| .                 | .                     || .                  | .                    |
| .                 | .                     || .                  | .                    |
| B0_05P            | B0_05N                || .                  | .                    |
| B0_07P            | B0_07N                || .                  | .                    |
| .                 | .                     || .                  | .                    |
| GND               | GND                   || GND                | GND                  |



# Resultats attendus

le top est test_complet_nano, le principe est d'instancier 2 can_controlleur,
 * appuie du bouton de reset pour reset tout le système
 * sur l'appui d'un bouton T le controlleur "T" envoie une trame predefinie
 * sur l'appui d'un bouton R le controlleur "R" lit dans ses registre de reception et renvoie au premier ce qu'il y a dedans

les trames se transmettent a 125Kbit/s
si la deuxieme trame à l'oscilloscope correspond a la trame predefinie alors le fonctionnement alors l'ensemble lecture/ecriture, transmission/reception fonctionne correctement



j'utilisais B0_02N pour RX (pin pour oscilloscope) et les 4 autres pour les 2 TX_i et 2 TX_o (sa aurait été plus simple de faire seulement les 2 tx et retransmettre le RX au nano_R et nano_T mais c'est pas grave)
l'important est de croiser les TX_i avec les TX_o

il les 3 boutons pour RST, BOUTON_T et BOUTON_R j'utilisais :
RST : B10_12P   bouton au centre
BOUTON_T : B10_07P  a gauche
BOUTON_R : B10_07N  a droite

bank 0 : 3.3V
bank 10 : 1.8V
bank 12 : 2.5B

toute ces information se situent dans les documentations devkit_board et devkit_user_guide
