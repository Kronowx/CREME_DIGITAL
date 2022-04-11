## @package build_Bitstream
# Routine python permetant de lancer la première étape de synthese.
# @author : guillaume.gourves@onera.fr
# @date : 29/03/2021
#
# Ce fichier est redige a titre experuimentale et s'inspire du GUI de NXMAP3
# il y aura donc des possibilites d'optimisation de ce fichier.

import sys
import traceback

# Import de bibliotheque permettant la manipulation de fichier
import os
import shutil

from nxmap import *

# Creation du projet.
print("Creation du projet a la racine.")
p = createProject('.')

# Selection de la cible.
print("Sélection de la cible : NG-MEDIUM.")
p.setVariantName('NG-MEDIUM')

# Ajout des fichiers permettant la synthèse du système.
print("Ajout des fichiers pour la synthétisation.")
p.addFile('./../../OpenCores/i2c/timescale.v')
p.addFile('./ram.vhd')
p.addFile('./wishbone_driver.vhd')
p.addFile('./../../OpenCores/i2c/i2c_master_top.v')
p.addFile('./../../OpenCores/i2c/i2c_master_defines.v')
p.addFile('./../../OpenCores/i2c/i2c_master_byte_ctrl.v')
p.addFile('./../../OpenCores/i2c/i2c_master_bit_ctrl.v')
p.addFile('./I2C_CONTROLER.vhd')
p.addFile('./I2C_PERIPHERAL.vhd')

p.setOption('ManageAsynchronousReadPort', 'Yes')

# Sélection de la cellule haute pour la synthtisation.
print("Designation du fichier top.")
p.setTopCellName('I2C_CONTROLER')

# Lancement de la synthétisation.
print("Synthetisation niveau 1...")
res = p.progress('Synthesize', 1)
if res == True :
    print("Synthetisation niveau 1 : REUSSI")
else :
    print("Synthetisation niveau 1 : ECHEC")
    exit()

print("Synthetisation niveau 2...")
res = p.progress('Synthesize', 2)
if res == True :
    print("Synthetisation niveau 2 : REUSSI")
else :
    print("Synthetisation niveau 2 : ECHEC")
    exit()

# Affectation des pins.
print("Affectation des pins.")
p.clearPads()
pads = { 'BOUTTON_1' : {'location': 'IOB10_D07P'} , 'CLK' : {'location': 'IOB12_D09P'} , 'RESET' : {'location': 'IOB10_D12P'} , 'SCL' : {'location': 'IOB0_D05N'} , 'SDA' : {'location': 'IOB0_D05P'} }
p.addPads(pads)

# Réglable de tension des banques
p.clearBanks()
banks = { 'IOB10' : { 'voltage': '1.8V'}, 'IOB12' : { 'voltage': '2.5V'}, 'IOB0' : { 'voltage': '3.3V'}}
p.addBanks(banks)


print("Réglable de tension de la banque 12.")
p.clearBanks()
banks = { 'IOB12' : { 'voltage': '2.5V'}}
p.addBanks(banks)

# Procedure de routage
print("Routage niveau 1...")
res = p.progress('Route', 1)
if res == True :
    print("Routage niveau 1 : REUSSI")
else :
    print("Routage niveau 1 : ECHEC")
    exit()
print("Routage niveau 2...")
res = p.progress('Route', 2)
if res == True :
    print("Routage niveau 2 : REUSSI")
else :
    print("Routage niveau 2 : ECHEC")
    exit()
print("Routage niveau 3...")
res = p.progress('Route', 3)
if res == True :
    print("Routage niveau 3 : REUSSI")
else :
    print("Routage niveau 3 : ECHEC")
    exit()

# Generation du beatstream.
print("Generation du bitstream...")
res = p.generateBitstream('./test_i2c.nxb')
if res == True :
    print("Generation du bitstream : REUSSI")
else :
    print("Generation du bitstream : ECHEC")
    exit()

# Cloture du projet.
print("Destruction du projet")
p.destroy()

# Nettoyage du dossier (pour Git)
print("Nettoyage du dossier")

# Extension à supprimer
fileExt = r".nym"
fileDir =r"."

# On nettoie les fichiers intermediare pour garder un dossier propre et versionnable.
file_remove = [os.path.join(fileDir, _) for _ in os.listdir(fileDir) if _.endswith(fileExt)]
nb_file_remove = len(file_remove)

print("Fichiers à supprimer : ", nb_file_remove)
print(file_remove)

for i in range(0, nb_file_remove) :
    try :
        os.remove(file_remove[i])
    except ValueError:
        if os.path.exists(file_remove[i]):
            {
                print("Impossible de nettoyer le dossier car le fichier", file_remove[i], "ne peut pas etre supprime")
            }
        else:
            {
                print("Impossible de nettoyer le dossier car le fichier", file_remove[i], "n'existe pas")
            }
        exit()

try :
    shutil.rmtree('logs')
except ValueError:
    print("Impossible de nettoyer le dossier car le dossier logs ne peut pas etre suprimme")
    exit()

print("Fin")
