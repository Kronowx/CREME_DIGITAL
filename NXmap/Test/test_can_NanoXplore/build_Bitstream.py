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
p.addFile('./can_controller.vhd')
p.addFile('./nano_R.vhd')
p.addFile('./nano_T.vhd')
p.addFile('./test_complet_nano.vhd')
p.addFile('./wishbone_driver.vhdl')
p.addFile('./../../OpenCores/can/trunk/rtl/verilog/can_acf.v')
p.addFile('./../../OpenCores/can/trunk/rtl/verilog/can_bsp.v')
p.addFile('./../../OpenCores/can/trunk/rtl/verilog/can_btl.v')
p.addFile('./../../OpenCores/can/trunk/rtl/verilog/can_crc.v')
p.addFile('./can_defines.v') #Permet d'éviter de toucher à la source des fichiers de opencore
p.addFile('./../../OpenCores/can/trunk/rtl/verilog/can_fifo.v')
p.addFile('./../../OpenCores/can/trunk/rtl/verilog/can_ibo.v')
p.addFile('./../../OpenCores/can/trunk/rtl/verilog/can_register_asyn_syn.v')
p.addFile('./../../OpenCores/can/trunk/rtl/verilog/can_register_asyn.v')
p.addFile('./../../OpenCores/can/trunk/rtl/verilog/can_register_syn.v')
p.addFile('./../../OpenCores/can/trunk/rtl/verilog/can_register.v')
p.addFile('./../../OpenCores/can/trunk/rtl/verilog/can_registers.v')
p.addFile('./../../OpenCores/can/trunk/rtl/verilog/can_top.v')

# Sélection de la cellule haute pour la synthtisation.
print("Designation du fichier top.")
p.setTopCellName('test_complet_nano')

# On laisse le logiciel gérer les port asynchrone
p.setOption('ManageAsynchronousReadPort', 'Yes')

# Lancement de la synthétisation.
print("Synthetisation niveau 1...")
res = p.progress('Synthesize', 1)
if res == True :
    print("Synthetisation niveau 1 : REUSSI")
else :
    print("Synthetisation niveau 1 : ECHEC")
    exit()



print("Synthetisation niveau 2...")
if res == True :
    print("Synthetisation niveau 2 : REUSSI")
else :
    print("Synthetisation niveau 2 : ECHEC")
    exit()

# Affectation des pins.
print("Affectation des pins - AF")
#p.clearPads()
#pads = { 'ck12_5MHz' : {'location': 'IOB12_D07P'} , 'ck25MHz' : {'location': 'IOB12_D09P'} , 'ck50MHz' : {'location': 'IOB12_D07N'} , 'ready' : {'location': 'IOB12_D09N'} }
#p.addPads(pads)

# Réglable de tension de la banque 12.
print("Réglable de tension de la banque - AF")
#p.clearBanks()
#banks = { 'IOB12' : { 'voltage': '2.5V'}}
#p.addBanks(banks)

# Procedure de routage
print("Routage niveau 1")
res = p.progress('Route', 1)
if res == True :
    print("Routage niveau 1 : REUSSI")
else :
    print("Routage niveau 1 : ECHEC")
    exit()
print("Routage niveau 2")
res = p.progress('Route', 2)
if res == True :
    print("Routage niveau 2 : REUSSI")
else :
    print("Routage niveau 2 : ECHEC")
    exit()
print("Routage niveau 3")
res = p.progress('Route', 3)
if res == True :
    print("Routage niveau 3 : REUSSI")
else :
    print("Routage niveau 3 : ECHEC")
    exit()

# Generation du beatstream.
print("Generation du bitstream...")
res = p.generateBitstream('./test_can_nanoxplore.nxb')
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

# On regroupe les fichier à supprimer
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

""" A commenter uniquement en phase  de mise au point
try :
    shutil.rmtree('logs')
except ValueError:
    print("Impossible de nettoyer le dossier car le dossier logs ne peut pas etre suprimme")
    quit()
"""
print("Fin")
