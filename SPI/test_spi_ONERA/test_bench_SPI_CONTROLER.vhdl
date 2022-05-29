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

entity tb_SPI_CONTROLER is
end tb_SPI_CONTROLER;

architecture Behavioral of tb_SPI_CONTROLER is
  signal sig_CLK                :  std_logic :='0';
  signal sig_RESET_BAR          :  std_logic :='0';
  signal sig_PULSE_SHAPER_FAST  : std_logic := '0';
  signal sig_HISTO_ACQ          : std_logic := '0';
  signal sig_HISTO_SIGNAL       : std_logic := '0';
  signal sig_SAMPLE             : std_logic_vector(31 downto 0) := (others => '0');
  signal sig_SCK                :  std_logic  := '0';
  signal sig_MOSI               :  std_logic  := '0';
  signal sig_MISO               :  std_logic  := '0';
  signal sig_FLAG               :  std_logic  := '0';

component SPI_CONTROLER is
  port
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

begin

evaluate_SPI_CONTROLER : SPI_CONTROLER
Port map
(
  CLK                   => sig_CLK,
  RESET_BAR             => sig_RESET_BAR,
  PULSE_SHAPER_FAST     => sig_PULSE_SHAPER_FAST,
  HISTO_ACQ             => sig_HISTO_ACQ,
  HISTO_SIGNAL          => sig_HISTO_SIGNAL,
  SAMPLE                => sig_SAMPLE,
  SCK                   => sig_SCK,
  MOSI                  => sig_MOSI,
  MISO                  => sig_MISO,
  FLAG_RAM              => sig_FLAG--! Flag d'envoie dans la RAM
);

sig_MISO <= sig_MOSI; -- Loopback


PROCESS_CLOCK : process
begin
  sig_CLK <= not(sig_CLK);
  wait for 5 ns;
end process;

PROCESS_PULSE : process
begin
  wait for 100 us;
  sig_PULSE_SHAPER_FAST <= '1';
  wait for 30 ns;
  sig_PULSE_SHAPER_FAST <= '0';
  wait for 100 us;
  sig_PULSE_SHAPER_FAST <= '1';
  wait for 30 ns;
  sig_PULSE_SHAPER_FAST <= '0';
wait;
end process;

PROCESS_TB : process
begin
  sig_RESET_BAR <= '0';             -- On lance la procédure de RESET
  wait for 10 us;                  -- Pendant un temps
  sig_RESET_BAR <= '1';             -- On relache le Reset
  wait until sig_HISTO_SIGNAL = '1';
  wait for 1 us;
  sig_HISTO_ACQ <= '1';
  wait for 50 ns;
  sig_HISTO_ACQ <= '0';
  wait until sig_HISTO_SIGNAL = '1';
  wait for 1 us;
  sig_HISTO_ACQ <= '1';
  wait for 50 ns;
  sig_HISTO_ACQ <= '0';
  wait;

end process;
end Behavioral;
