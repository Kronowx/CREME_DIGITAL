----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.04.2022 16:34:28
-- Design Name: 
-- Module Name: Histogram - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Histogram is
Port (  CLK                 : in std_logic  --! Signal d'horloge permettant a ce module de fonctionner.
        ;RESET_BAR          : in std_logic  --! Signal de reinitialisation de ce module
        ;PULSE_SHAPER_FAST  : in std_logic  --! Signal déclencheur d'un transfert SPI.
        ;HISTO_ACQ          : in std_logic  --! Signal déclencheur d'un transfert SPI.
        ;MOSI               : out std_logic --! MOSI en sortie du module SPI
        ;MISO               : in std_logic  --! MISO en sortie du module SPI
        ;read_address       : in  integer RANGE 0 to 255 --! adresse de lecture de la RAM
        ;we                 : in std_logic --! 1 on �crit 0 on lit 
        ;data_o             : out  std_logic_vector (20 DOWNTO 0) --! donn�e en sortie lorsqu'on lit
);
end Histogram;

architecture Behavioral of Histogram is

  signal sig_RESET_BAR      :  std_logic :='0';
  signal sig_HISTO_SIGNAL   :  std_logic;
  signal sig_SAMPLE         :  std_logic_vector(31 downto 0);
  signal sig_SCK            :  std_logic :='0';
  signal sig_FLAG_RAM      :  std_logic :='0';
  
  signal sig_DATA_SIZE      :  std_logic_vector(1 downto 0) :=  (others => '0');
    
  signal write_address      : integer RANGE 0 to 1023;



component SPI_CONTROLER
  Port
    (
        CLK                 : in std_logic  --! Signal d'horloge permettant a ce module de fonctionner.
        ;RESET_BAR          : in std_logic  --! Signal de reinitialisation de ce module
        ;PULSE_SHAPER_FAST  : in std_logic  --! Signal déclencheur d'un transfert SPI.
        ;HISTO_ACQ          : in std_logic  --! Signal déclencheur d'un transfert SPI.
        ;HISTO_SIGNAL       : out std_logic  --! Signal déclencheur d'un transfert SPI.
        ;SAMPLE             : out std_logic_vector (31 downto 0)
        ;SCK                : out std_logic --! Clock en sortie du module SPI
        ;MOSI               : out std_logic --! MOSI en sortie du module SPI
        ;MISO               : in std_logic  --! MISO en sortie du module SPI
        ;FLAG_RAM            : out std_logic --! Flag d'envoie dans la RAM
    );
  end component;


component ram_intel is
   PORT
   (
      CLK: IN   std_logic;
      data_i:  IN   std_logic_vector (31 DOWNTO 0);
       RST: IN   std_logic;
      --write_address:  IN   integer RANGE 0 to 255;
      read_address:   IN   integer RANGE 0 to 255;
      we:    IN   std_logic;
      FLAG_enable: IN   std_logic; -- provient du spi
      data_o:     OUT  std_logic_vector (20 DOWNTO 0)
   );
 end component;

begin

SPI_CONTROLER_CREME : SPI_CONTROLER port map
  (
    CLK=> CLK
    ,RESET_BAR=>sig_RESET_BAR
    ,PULSE_SHAPER_FAST=>PULSE_SHAPER_FAST
    ,HISTO_ACQ=>HISTO_ACQ
    ,HISTO_SIGNAL=>sig_HISTO_SIGNAL
    ,SAMPLE=>sig_SAMPLE
    ,SCK=>sig_SCK
    ,MOSI=>MOSI
    ,MISO=>MISO
    ,FLAG_RAM=>sig_FLAG_RAM
  );
  
  RAM : ram_intel port map
  (
      CLK => CLK,
      data_i => sig_SAMPLE,
      RST=>RESET_BAR,
      read_address => read_address,
      we => we,
      FLAG_enable => sig_FLAG_RAM,
      data_o => data_o
  );





end Behavioral;
