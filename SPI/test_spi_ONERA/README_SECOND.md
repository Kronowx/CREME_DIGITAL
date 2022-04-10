Notice d'utilisation des fichiers sources
========

| Projet  | CREME                       |
| :-------| ---------------------------:|
| Date    | 22/09/2021                  |
| Auteur  | Guillaume.Gourves@onera.fr  |
| Version | v1.0                        |

# Introduction

Stage 2021 Tanguy LECONTE

Fonctionnement SPI :

--------------------------------------------------------------------------------------------------------------
	Fonctionnement général :

		Séquence pour écrire :
		   -Faire le RESET
			-Indiquer que le bus est disponible et dire que on est le master (SPCR)
			-Mettre en place le prescaler avec les 2 derniers bits de SPCR et SPER
			-écrire la donnée dans SPDR. Elle s'envoie automatiquement dès que le registre SPDR est rempli

		Séquence pour lire :
			-Lire la donnée dans SPDR
			-Mettre la donnée recu dans une RAM


--------------------------------------------------------------------------------------------------------------

Passer du programme NanoXplore à la simulation :
	-Reprendre le test bench pour avoir le reset et l'appui du bouton
	- Il faut enlever le block Nx_BD et la library NX.nxPackage.all
	-Rajouter la ligne sig_reset<=not(RESET) car sur nanoXplore le boutton est inactif quand il est à 1 et actif quand il est à 0
	-Changer if (BOUTTON_1='0' and transmiting_1='0') then et if boutton_1='1' then par (BOUTTON_1='1' and transmiting_1='0') et if boutton_1='0' then
	-enlever le fichier nanoXplore pour la RAM

--------------------------------------------------------------------------------------------------------------

# Fichiers nécessaires

Les fichiers nécessaire sont les suivants :
* ./SPI_DRIVER.vhd
* ./SPI_CONTROLER.vhdl
* ./ram.vhd
* ./wishbone_master.vhdl
* ./../../OpenCores/test_SPI/simple_spi_top.v
* ./../../OpenCores/test_SPI/fifo4.v
* ./../../OpenCores/test_SPI/timescale.v


# Cablage a effectuer

Faire le fichier constaint sur NanoXplore

bank 12 : 09P pour la clock 25Mhz

LED Utilisateur (Bank 1 et Bank1 concernes) :

| LED     | Pin (signal)      |
| :-:     | :-:               |
| LD1_N   | B0_D01P (nready)  |
| LD2_N   | .                 |
| LD3_N   | .                 |
| LD4_N   | .                 |
| LD5_N   | .                 |
| LD6_N   | .                 |
| LD7_N   | .                 |
| LD8_N   | .                 |
| GND     | GND               |


Connecteur de test de la carte d'évaluation (Bank 0 et Bank12 concernes) :

| Pin bank 0 TP1    | Pin bank 0 TP2    || Pin bank 12 TP3       | Pin bank 12 TP4       |
| :-:               | :-:               || :-:                   | :-:                   |
| .                 | .                 || .                     | .                     |
| B0_02N (MCLK)     | .                 || .                     | .                     |
| .                 | .                 || .                     | .                     |
| .                 | .                 || .                     | .                     |
| .                 | .                 || .                     | .                     |
| .                 | .                 || .                     | .                     |
| B0_05P (MISO)     | B0_05N (MOSI)     || .  									 | .    								 |
| .                 | .                 || .                     | .                     |
| .                 | .                 || .                     | .                     |
| GND               | GND               || GND                   | GND                   |

J'utilisais B0_05N pour la MISO, B0_05P pour le MOSI et B0_02N pour la SCL.
On peut bien sur prendre d'autre PIN et meme choisir d'autres bank.

j'utilisais 2 boutons :
pour le reset RST : B10_12P   bouton au centre
pour lancer la trame BOUTON_1 : B10_7P bouton au centre

bank 0 : 3.3V
bank 10 : 1.8V
bank 12 : 2.5V

toute ces info se retrouvent dans les docs devkit_board et devkit_user_guide

----------------------------------------------------------------------------------------------------------------------

Pour refaire la trame poubelle (si besoin on sait jamais)

    -Décommentez toutes la machine à état dans le bloc SIMPLE_SPI_TOP_TOP
    -Décommentez aussi les lignes PORT_0_READ<=sig_port_read; et PORT_FREE<=sig_port_free ;
    -Dans l'instanciation du wishbone Driver remplacer :         
        START => START,                    
        RD_WR => RD_WR,                   
        REG_ADDR     => REG_ADDR,
        REG_DATA     => REG_DATA,
        PORT_0_READ => PORT_0_READ,
        PORT_FREE    => PORT_FREE,
    par :
        START=> sig_start,
        RD_WR=> sig_rd_wr,
        REG_ADDR=>sig_addr,
        REG_DATA=>sig_data,
        PORT_0_READ=>sig_port_read
        PORT_FREE=>sig_port_free
