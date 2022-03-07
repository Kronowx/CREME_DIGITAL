Notice d'utilisation des fichiers sources
========

| Projet  | CREME                       |
| :-------| ---------------------------:|
| Date    | 22/09/2021                  |
| Auteur  | Guillaume.Gourves@onera.fr  |
| Version | v1.0                        |

# Introduction

Fonctionnement I2C :

--------------------------------------------------------------------------------------------------------------

	Fonctionnement général :

		Séquence pour écrire :
		    -Faire le RESET
			-Mettre en place le prescaler si besoin (on ne peut pas mettre le prescaler à 0 ou à 1  car cela ne fonctionne pas problème dans le code verilog il faut commencer à 2)
			-Générer la commande du START (registre CR)
			-Donner l'adresse du slave et dire que l'on veut écrire (registre TXR et CR)
			-Reception de l'acquittement du slave
			-écrire la donnée
			-Reception acquittement du slave
			-Générer la commmande STOP (registre CR)

		Séquence pour lire :
			-Mettre en place le prescaler si besoin (on ne peut pas mettre le prescaler à 0 ou à 1  car cela ne fonctionne pas problème dans le code verilog il faut commencer à 2)
			-Générer la commande du START (registre CR)
			-Donner l'adresse du slave et dire que l'on veut écrire (registre TXR et CR)
			-Reception de l'acquittement du slave
			-Donner l'adresse de la mémoire ou sera stocké le message recu
			-Reception de l'acquittement du slave
			-Re-générer la commande du START (registre CR)
			-Donner l'adresse du slave et dire que l'on veut lire (registre TXR et CR)
			-Reception de l'acquittement du slave
			-Lire la donnée
			-Ecire un non-acquittement(NACK)(inverse de l'acquittement) pour indiquer la fin du transfert
			-Générer la commmande STOP (registre CR)

--------------------------------------------------------------------------------------------------------------

Passer du programme NanoXplore à  la simulation :
    -Reprendre le test bench pour avoir le reset et l'appui du bouton
	- Il faut enlever le block Nx_BD et la library NX.nxPackage.all
	-Rajouter la ligne sig_reset<=not(RESET) car sur nanoXplore le boutton est inactif quand il est à 1 et actif quand il est à 0
	-Changer if (BOUTTON_1='0' and transmiting_1='0') then et if boutton_1='1' then par (BOUTTON_1='1' and transmiting_1='0') et if boutton_1='0' then
	-On doit changer la ligne sda <= sig_sda_pad_o when (sig_sda_pad_en = '0') else '1'; par sda <= sig_sda_pad_o when (sig_sda_pad_en = '0') else 'H';
	-On doit changer la ligne scl <= sig_scl_pad_o when (sig_scl_pad_en = '0') else '1'; par scl <= sig_scl_pad_o when (sig_scl_pad_en = '0') else 'H';

--------------------------------------------------------------------------------------------------------------

# Fichiers nécessaires

Les fichiers nécessaire sont les suivants :
* ./../../OpenCores/i2c/timescale.v
* ./../../OpenCores/i2c/i2c_master_top.v
* ./../../OpenCores/i2c/i2c_master_defines.v
* ./../../OpenCores/i2c/i2c_master_byte_ctrl.v
* ./../../OpenCores/i2c/i2c_master_bit_ctrl.v
* ./wishbone_driver.vhd
* ./I2C_TOP_TOP_TOP.vhd
* ./I2C_TOP_TOP.vhd
* ./ram.vhd

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
| .                 | .                 || .                     | .                     |
| .                 | .                 || .                     | .                     |
| .                 | .                 || .                     | .                     |
| .                 | .                 || .                     | .                     |
| .                 | .                 || .                     | .                     |
| B0_05P (SDA)      | B0_05N (SCL)      || .  									 | .    								 |
| .                 | .                 || .                     | .                     |
| .                 | .                 || .                     | .                     |
| GND               | GND               || GND                   | GND                   |


j'utilisais B0_05N pour la SCL, B0_05P pour le SDA.
On peut bien sur prendre d'autre PIN et meme choisir d'autres bank.

j'utilisais 2 boutons :
pour le reset RST : B10_12P   bouton au centre
pour lancer la trame BOUTON_1 : B10_7P bouton au centre


bank 0 : 3.3V
bank 10 : 1.8V
bank 12 : 2.5V

toutes ces info se retrouvent dans les docs devkit_board et devkit_user_guide
