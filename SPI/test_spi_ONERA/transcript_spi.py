import sys
import traceback
from nxmap import *
p = createProject()
p.destroy()
p = createProject('/home/local/Documents/NxMapProject/TEST_SPI/spi_64')
p.setVariantName('NG-MEDIUM')
p.addFile('simple_spi_top.v')
p.addFile('ram.vhd')
p.addFile('fifo4.v')
p.addFile('SPI_TOP_TOP_TOP.vhd')
p.addFile('wishbone_driver.vhdl')
p.addFile('timescale.v')
p.addFile('SIMPLE_SPI_TOP_TOP.vhd')
p.setTopCellName('SPI_TOP_TOP_TOP')
p.setOption('ManageAsynchronousReadPort', 'Yes')
p.progress('Synthesize', 2)
p.clearPads()
pads = { 'BOUTTON_1' : {'location': 'IOB10_D07P'} , 'CLK' : {'location': 'IOB12_D09P'} , 'MISO' : {'location': 'IOB12_D07N'} , 'MOSI' : {'location': 'IOB12_D07P'} , 'RESET' : {'location': 'IOB10_D12P'} , 'SCK' : {'location': 'IOB12_D08N'} }
p.addPads(pads)
p.clearBanks()
banks = { 'IOB10' : { 'voltage': '1.8V'}, 'IOB12' : { 'voltage': '2.5V'}}
p.addBanks(banks)
p.progress('Route', 3)
p.generateBitstream('/home/local/Documents/NxMapProject/TEST_SPI/spi_64/SPI_TOP_TOP_TOP_1.nxb')
