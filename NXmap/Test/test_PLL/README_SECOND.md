Notice d'utilisation des fichiers sources
========

| Projet  | CREME                       |
| :-------| ---------------------------:|
| Date    | 22/09/2021                  |
| Auteur  | Guillaume.Gourves@onera.fr  |
| Version | v1.0                        |

# Introduction
Ce projet à pour objectifs de tester l'instanciation des PLLs disponible sur le NG-Medium, Nous prendrons comme source d'horloge l'oscilateur présent sur la carte d'évaluation qui à une fréquence de 25 MHz. (pin B12D09P)

# Fichiers nécessaires
Les fichiers nécessaire sont les suivants :
* pll.vhd

# Cablage a effectuer

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
| .                 | .                 || B12_D07P (ck12_5MHz)  | B12_D07N (ck50MHz)    |
| .                 | .                 || .                     | .                     |
| .                 | .                 || .                     | .                     |
| GND               | GND               || GND                   | GND                   |


# Résultats attendus

  Une fois le bitstream chargé et la diode LD20 (READY) allumée (indiquant que la PLL est vérouillée), positionnez deux sonde d'ocsilloscope sur la carte d'évaluation sur la pin B12D07P pour observer un signal carrée à fréquence de 12.5MHz, la pin B12D07N pour observer un signal de 50 MHz.
