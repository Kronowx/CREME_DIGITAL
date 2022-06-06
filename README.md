# CREME_DIGITAL

## PARTIE SPI
### DESCRIPTION
#### Bloc SPI top 
- SPI Master permettant de dialoguer avec un slave
- Boite noire : attention à ne pas modifier le code dans ce bloc

#### Bloc Whisbone Driver
- Permet de standardiser tous les signaux provenant de n’importe quelles IP
- L’explication de ce bloc en détail se trouve dans le rapport de février 2021/2022.

#### Bloc SPI Peripheral : C’est le maitre SPI (combiné avec le wishbone)
- Top level des bloc précédents qui permet de les connecter
- Possède une machine d’état (les explications se trouve entre les lignes 254 à 259 du bloc SPI Peripheral) mais il sert en gros à transmettre des données comme le ferait une transmission SPI.

#### Bloc SPI Controller :
- Sert à acquérir les données issus du détecteur de particules
- Lorsque nous détectons une particule (PULSE_SHAPER_FAST) alors le code se lance et nous commençons la phase d’acquisition.
- Il faut générer un flag afin de pouvoir écrire dans la RAM (FLAG_RAM) qui sera une entrée du bloc histogram
- La voie choisie est la 00000008 (voir capteur de radiation)
- sig_DATA_SIZE <= "00" car nous prenons que 8 bits de données

#### Bloc RAM_intel :
- RAM issue d’Intel modifié par rapport à nos besoins
- Chaque valeurs des mesures de particules sont converties en adresse ce qui nous permet de directement remplir la RAM tel un histogramme (par exemple si on mesure une radiation = 6, alors l’adresse 6 va itérer une seule fois, etc, etc..)

#### Bloc ram : 
- Bloc de nanoxplore à garder qui permettra de tester la ram plus tard sous nanoxplore.

### TO_DO_LIST
- [ ] finir le code de l'histogramme en intégrant la ram dans le code 
- [ ] simuler un SPI slave pour le testbench
- [ ] intégrer également la RT-Clock afin de dater les mesures de radiations


## PARTIE I2C
#### I2C_CONTROLER
- écauche machine d'état de housekeeping
- fichier à modifier pour finir le housekeeping

#### I2C_PERIPHERAL
- machine détat d'i2c utilisant les blocs wishbone
- lecture ET ecriture testé avec des testbench et fonctionnel

####

### TO_DO_LIST
- [ ] compléter la machine de housekeeping (I2C_CONTROLER.vhdl) avec les vrais capteurs et leur procédure de communication
- [ ] intégrer une procédure d'écriture utilisable avant une lecture dans le cas ou pour acceder aux donnés du capteur il soit nécessaire de préciser le registre dans laquelle est stocké la donné
- [ ] intégrer un déclenchement périodique par la rt_clock au housekeeping 
- [ ] intégrer une mémoire ou stocker les donnés datées
- [ ] mettre en place un système d'alarme qui prévient l'utilisateur dans le cas ou on dépasse des seuils sur la lecture de certains capteurs (courants/température...)
- [ ] mettre en place un déclenchement de housekeeping sous demande de l'utilisateur
