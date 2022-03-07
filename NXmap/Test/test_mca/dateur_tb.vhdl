----------------------------------------------------------------------------------
-- Company: ONERA Toulouse
-- Engineer: guillaume.gourves@onera.for
--
-- Create Date: 10/11/2021
-- Design Name: Dateur
-- Module Name:
-- Project Name: CREME
-- Target Devices: NG-MEDIUM (NanoXplore)
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

-- Include library.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dateur_tb is
end dateur_tb;

architecture Behavioral of dateur_tb is

  component dateur is
  	port
  	(
      DATE_SEC      : out std_logic_vector(31 downto 0)
      ;DATE_NSEC    : out std_logic_vector(31 downto 0)
      ;DATE_SYNC    : in  std_logic_vector(31 downto 0)
      ;ENA_SYNC     : in  std_logic
      ;RESET        : in  std_logic
      ;CLK_50_MHZ   : in  std_logic  -- horloge obligatoire pour le bon fonctionnement du module
  	);
  end component;

  signal sig_CLK              : std_logic := '0';
  signal sig_RESET            : std_logic := '0';
  signal sig_ENA_SYNC         : std_logic := '0';
  signal sig_DATE_SYNC        : std_logic_vector(31 downto 0) := (others => '0');
  signal sig_DATE_SEC         : std_logic_vector(31 downto 0) ;
  signal sig_DATE_NSEC        : std_logic_vector(31 downto 0) ;

begin

  TEST_DATEUR :  dateur port map
  (
      DATE_SEC    => sig_DATE_SEC
      ,DATE_NSEC  => sig_DATE_NSEC
      ,DATE_SYNC  => sig_DATE_SYNC
      ,ENA_SYNC   => sig_ENA_SYNC
      ,RESET      => sig_RESET
      ,CLK_50_MHZ => sig_CLK
  );

  process
  begin
  	sig_CLK <= not(sig_CLK);
  	wait for 10 ns;
  end process;

  process
  begin
    -- Reinitialisation du module
    sig_ENA_SYNC  <= '0';
    sig_DATE_SYNC <= (others => '0');
    sig_RESET <= '1';
    wait for 1 ms;
    sig_RESET <= '0';
    wait for 100 ms;
    -- Initialisation de l'horloge
    sig_DATE_SYNC <= std_logic_vector(to_unsigned(3600, 32));
    sig_ENA_SYNC <= '1';
    wait for 1 us;
    sig_ENA_SYNC <= '0';
    wait;
  end process;
end Behavioral;
