LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY ram_intel IS
   PORT
   (
      clock: IN   std_logic;
      data_i:  IN   std_logic_vector (31 DOWNTO 0);
      write_address:  IN   integer RANGE 0 to 1023;
      read_address:   IN   integer RANGE 0 to 1023;
      we:    IN   std_logic;
      data_o:     OUT  std_logic_vector (31 DOWNTO 0)
   );
  
   
   
END ram_intel;
ARCHITECTURE rtl OF ram_intel IS
   TYPE mem IS ARRAY(0 TO 1023) OF std_logic_vector(31 DOWNTO 0);
   SIGNAL ram_block : mem;
BEGIN
   PROCESS (clock)
   BEGIN
      IF (clock'event AND clock = '1') THEN
         IF (we = '1') THEN
            ram_block(write_address) <= data_i;
         END IF;
         data_o <= ram_block(read_address);
      END IF;
   END PROCESS;
END rtl;