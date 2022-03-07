## @package Synthese
# Routine python permetant de lancer la première étape de synthese.
# @author : guillaume.gourves@onera.fr
# @date : 29/03/2021
#
# Ce fichier est redige a titre experuimentale et s'inspire du GUI de NXMAP3
# il y aura donc des possibilites d'optimisation de ce fichier.

import sys
import traceback
from nxmap import *

# Creation du projet.
p = createProject('.')

# Selection de la cible.
p.setVariantName('NG-MEDIUM')

# Ajout des fichiers permettant la synthèse du système.
p.addFile('test_controleur_can.vhdl')
p.addFile('can_top.v')
p.addFile('can_registers.v')
p.addFile('can_register_syn.v')
p.addFile('can_register_asyn_syn.v')
p.addFile('can_register_asyn.v')
p.addFile('can_register.v')
p.addFile('can_ibo.v')
p.addFile('can_fifo.v')
p.addFile('can_defines.v')
p.addFile('can_crc.v')
p.addFile('can_btl.v')
p.addFile('can_bsp.v')
p.addFile('can_acf.v')
p.addFile('timer_x_bit.vhdl')

# Sélection de la cellule haute pour la synthtisation.
p.setTopCellName('test_controleur_can')

# Lancement de la synthétisation.
p.progress('Synthesize', 1)
p.destroy()
