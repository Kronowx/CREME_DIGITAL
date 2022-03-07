## @package Synthese
# Routine python permetant de lancer la première étape de synthese.
# @author : guillaume.gourves@onera.fr
# @date : 30/08/2021
#
# Fichier permettant de déclencher une synthétisation des fichier Verilog et VHDL
# représentant la partie logiciel de la charge utile.

import sys
import traceback
from nxmap import *

# Creation du projet.
p = createProject('.')

# Selection de la cible.
p.setVariantName('NG-MEDIUM')

# Ajout des fichiers permettant la synthèse du système.
p.addFile('pll.vhdl')

# Sélection de la cellule haute pour la synthtisation.
p.setTopCellName('pll')

# Lancement de la synthétisation.
p.progress('Synthesize', 1)
p.destroy()
