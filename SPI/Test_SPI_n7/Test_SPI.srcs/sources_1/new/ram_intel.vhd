LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
ENTITY ram_intel IS
   PORT
   (
      CLK: IN   std_logic;
      RST: IN   std_logic;
      data_i:  IN   std_logic_vector (31 DOWNTO 0); --! donnée qui provient du SPI
      --write_address:  IN   integer RANGE 0 to 255;
      read_address:   IN   integer RANGE 0 to 255; --! numéro de la ligne qu'on veut lire
      we:    IN   std_logic; --! 1 on écrit 0 on lit 
      FLAG_enable: IN   std_logic; --! provient du spi
      data_o:     OUT  std_logic_vector (20 DOWNTO 0) --! donnée en sortie lorsqu'on lit
   );
  
   
   
END ram_intel;
ARCHITECTURE rtl OF ram_intel IS
   TYPE mem IS ARRAY(0 TO 255) OF std_logic_vector(20 DOWNTO 0);
   SIGNAL ram_block : mem;
   SIGNAl write_address1 : integer RANGE 0 to 255;
--   SIGNAl write_address2: integer RANGE 0 to 255;
--   SIGNAl write_address3 : integer RANGE 0 to 255;
--   SIGNAl write_address4 : integer RANGE 0 to 255;
   
BEGIN
write_address1 <= to_integer(unsigned(data_i(11 downto 4))); --! convert 
--write_address2 <= to_integer(unsigned(data_i(23 downto 16)));
--write_address3 <= to_integer(unsigned(data_i(15 downto 8)));
--write_address4 <= to_integer(unsigned(data_i(7 downto 0)));
   PROCESS (CLK)
   BEGIN
    
      IF rising_edge(CLK) THEN
        IF RST='1' then
        ram_block <= (others=>"000000000000000000000");
        
        ELSIF FLAG_enable='1' THEN
            IF (we = '1') THEN
                ram_block(write_address1) <= std_logic_vector(unsigned(ram_block(write_address1))+1);
                --ram_block(write_address2) <= std_logic_vector(unsigned(ram_block(write_address2))+1); --! Si data > 8 bits
                --ram_block(write_address3) <= std_logic_vector(unsigned(ram_block(write_address3))+1);
                --ram_block(write_address4) <= std_logic_vector(unsigned(ram_block(write_address4))+1);
            ELSE
                data_o <= ram_block(read_address);
            END IF; 
      END IF;
      END IF;
   END PROCESS;
   
END rtl;