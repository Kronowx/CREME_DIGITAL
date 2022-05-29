----------------------------------------------------------------------------------
-- Company: ONERA
-- Engineer: guillaume.gourves@onera.fr
--
-- Create Date: 20.07.2018 10:55:35
-- Design Name:
-- Module Name: tb_TOP_basic - Behavioral
-- Project Name: CREME
-- Target Devices: NG-MEDIUM (NanoXplore)
-- Tool Versions: NxMap3
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
use ieee.std_logic_textio.all;
use STD.textio.all;
use ieee.numeric_std.all;

entity tb_SPI_PERIPHERAL is
end tb_SPI_PERIPHERAL;

architecture Behavioral of tb_SPI_PERIPHERAL is
  signal sig_CLK            :  std_logic :='0';
  signal sig_RESET_BAR      :  std_logic :='0';
  signal sig_START          :  std_logic :='0';                     --! Start pin for activate transmission
  signal sig_PORT_READ      :  std_logic_vector(31 downto 0) :=  (others => '0');
  signal sig_PORT_WRITE     :  std_logic_vector(31 downto 0) :=  (others => '0');
  signal sig_PORT_FREE      :  std_logic :='0'; -- correspond � l'ack
  signal sig_DATA_SIZE      :  std_logic_vector(1 downto 0) :=  (others => '0');
  signal sig_SCK            :  std_logic :='0';
  signal sig_MOSI           :  std_logic :='0';
  signal sig_MISO           :  std_logic :='0';
   signal cnt           :  integer :=0; --essaye pour le txt
      signal i           :  integer :=0; --essaye pour le txt

type integerFileType is file of Integer;
file data_out :integerFileType;
file file_lu_recu    : text open write_mode is "lu_recu.txt"; 
component SPI_PERIPHERAL is
  port
    (
      CLK : in std_logic
      ;RESET_BAR : in std_logic
      ;START        : in    std_logic                     --! Start pin for activate transmission
      ;PORT_READ  : out   std_logic_vector(31 downto 0) --!Port
      ;PORT_WRITE : in   std_logic_vector(31 downto 0)
      ;PORT_FREE    : out   std_logic -- correspond � l'ack
      ;DATA_SIZE  : in std_logic_vector(1 downto 0) -- 00 -> 8 bits, 01 -> 16 bits, 10 -> 24bits, 11 -> 32 bits.
      ;SCK  : out std_logic --! Clock en sortie du module SPI
      ;MOSI : out std_logic --! MOSI en sortie du module SPI
      ;MISO : in std_logic  --! MISO en sortie du module SPI
    );
end component;

begin

evaluate_SPI_PERIPHERAL : SPI_PERIPHERAL
Port map
(
  CLK           => sig_CLK,
  RESET_BAR     => sig_RESET_BAR,
  START         => sig_START,
  PORT_READ     => sig_PORT_READ,
  PORT_WRITE    => sig_PORT_WRITE,
  DATA_SIZE     => sig_DATA_SIZE,
  PORT_FREE     => sig_PORT_FREE,
  SCK           => sig_SCK,
  MOSI          => sig_MOSI,
  MISO          => sig_MISO
);

sig_MISO <= sig_MOSI; -- Loopback


process

variable fstatus: FILE_OPEN_STATUS;


variable v_ILINE : line;
variable v_OLINE : line;

variable V_PORT_READ : std_logic_vector(31 downto 0);   
variable V_PORT_WRITE : std_logic_vector(31 downto 0); 

begin

file_open(fstatus,data_out, "lu_recu.txt", write_mode);
for i in 1 to 2 loop
        write(data_out, i);
        --writeline(file_lu_recu,V_OLINE);
      end loop;
file_close(file_lu_recu);
end process;
    

PROCESS_CLOCK : process
begin
  sig_CLK <= not(sig_CLK);
  wait for 5 ns;
end process;

PROCESS_TB : process
begin


  sig_RESET_BAR <= '0';             -- On lance la procédure de RESET
  wait for 100 us;                  -- Pendant un temps
  sig_RESET_BAR <= '1';             -- On relache le Reset
  wait until sig_PORT_FREE = '1';-- On attend que le module SPI_PERIPHERAL soit disponible
     
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"03030303"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  -- Ecriture d'un paquet de 16 bits
  sig_PORT_WRITE <= x"03030303";
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  -- Ecriture d'un paquet de 24 bits
  sig_PORT_WRITE <= x"03030303";
  sig_DATA_SIZE <= "10";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  -- Ecriture d'un paquet de 32 bits
  sig_PORT_WRITE <= x"03030303";
  sig_DATA_SIZE <= "00";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"57575757"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"57575757"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"57575757"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"57575757"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"57575757"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"57575757"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
------------------------------------------------------------
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
    -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
   sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
    -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
   sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
    -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
   sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
    -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1'; sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
    -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
   sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
    -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1'; sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
    -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
   sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
    -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
   sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
    -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1'; sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
    -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
   sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
    -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
   sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
    -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
   sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
    -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1'; sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
    -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
   sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
    -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
   sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
    -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
   sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
    -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
   sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
    -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "11";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  -- Ecriture d'un paquet de 8 bits
  sig_PORT_WRITE <= x"01010101"; --A5A5A5A5
  sig_DATA_SIZE <= "01";
  sig_START <= '1';
  wait until sig_PORT_FREE = '0';
  sig_START <= '0';
  wait until sig_PORT_FREE = '1';
  
  
  
  
  
  wait;

end process;
end Behavioral;
