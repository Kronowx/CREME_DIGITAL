library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity Histogram_tb is
end;

architecture bench of Histogram_tb is

  component Histogram
  Port (  CLK                 : in std_logic
          ;RESET_BAR          : in std_logic
          ;PULSE_SHAPER_FAST  : in std_logic
          ;HISTO_ACQ          : in std_logic
          ;MOSI               : out std_logic
          ;MISO               : in std_logic
          ;read_address       : in  integer RANGE 0 to 255
          ;we                 : in std_logic
          ;data_o             : out  std_logic_vector (20 DOWNTO 0)
  );
  end component;

  signal CLK: std_logic:='0';
  signal RESET_BAR: std_logic;
  signal PULSE_SHAPER_FAST: std_logic;
  signal HISTO_ACQ: std_logic:='0';
  signal MOSI: std_logic;
  signal MISO: std_logic:='0';
  signal read_address: integer RANGE 0 to 255;
  signal we: std_logic;
  signal data_o: std_logic_vector (20 DOWNTO 0) ;

begin

  uut: Histogram port map ( CLK               => CLK,
                            RESET_BAR         => RESET_BAR,
                            PULSE_SHAPER_FAST => PULSE_SHAPER_FAST,
                            HISTO_ACQ         => HISTO_ACQ,
                            MOSI              => MOSI,
                            MISO              => MISO,
                            read_address      => read_address,
                            we                => we,
                            data_o            => data_o );



MISO <= MOSI;


PROCESS_CLOCK : process
begin
  CLK <= not(CLK);
  wait for 5 ns;
end process;

PROCESS_PULSE : process
begin
  wait for 99 ns;
  PULSE_SHAPER_FAST <= '0';
  wait for 100 ns;
  PULSE_SHAPER_FAST <= '1';
  wait for 100 ns;
  PULSE_SHAPER_FAST <= '0';
  wait for 100 ns;
  PULSE_SHAPER_FAST <= '1';
wait;
end process;

  PROCESS_TB2 : process
begin
  RESET_BAR <= '0';             -- On lance la procédure de RESET
  wait for 10 us;                  -- Pendant un temps
  RESET_BAR <= '1';             -- On relache le Reset
  wait for 1 us;
  we<='1';
  wait for 1 us;
  
  HISTO_ACQ <= '1';
  wait for 50 ns;
  HISTO_ACQ <= '0';
  wait for 50 ns;
  HISTO_ACQ <= '1';
  wait for 50 ns;
  HISTO_ACQ <= '0';
  wait;

end process;
  
  
  
  end bench;
  