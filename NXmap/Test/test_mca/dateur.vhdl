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

entity dateur is
    Port (
    DATE_SEC      : out std_logic_vector(31 downto 0) -- Registre indiquant l'heurs en seconde.
    ;DATE_NSEC    : out std_logic_vector(31 downto 0) -- Registre indiquant l'heure en nanoseconde.
    ;DATE_SYNC    : in  std_logic_vector(31 downto 0) -- Registre d'initialisation de l'holorge.
    ;ENA_SYNC     : in  std_logic                     -- Pin pour le reglage de l'horloge.
    ;RESET        : in  std_logic                     -- Pin pour la reinitialisation.
    ;CLK_50_MHZ   : in  std_logic                     -- Horloge obligatoire pour le bon fonctionnement du module.
    );
end dateur;

architecture Behavioral of dateur is

  signal signal_Compteur_50MHz  : std_logic_vector (31 downto 0) := (others => '0'); -- Compteur qui aura une résolution de 20ns.
  signal signal_Compteur_1Hz    : std_logic_vector (31 downto 0) := (others => '0'); -- Compteur qui aura une résolution de 1s.

begin

  DATE_SEC <= signal_Compteur_1Hz;
  DATE_NSEC <= signal_Compteur_50MHz;

  TIME_NANOSEC_PROCESSUS : process(CLK_50_MHZ)
  begin
  if(RESET='1') then
      signal_Compteur_50MHz <= (others => '0');
      signal_Compteur_1Hz   <= (others => '0');
  elsif rising_edge(CLK_50_MHZ) then
      if ENA_SYNC='1' then -- Initialisation du registre des secondes et réinitialisation du registre des nano seconde.
          signal_Compteur_50MHz <= (others => '0');
          signal_Compteur_1Hz   <= DATE_SYNC;
      elsif unsigned(signal_Compteur_50MHz) >= 1000000000 then -- au bout de 50 Million front montant on incremente de 1 seconde.
          signal_Compteur_50MHz <= (others => '0');
          signal_Compteur_1Hz   <= std_logic_vector(unsigned(signal_Compteur_1Hz) + 1);
      else
          signal_Compteur_50MHz <= std_logic_vector(unsigned(signal_Compteur_50MHz) + 20); -- A chaque coup d'horloge, on incremente de 20 ns.
      end if;
  end if;
  end process;

end Behavioral;
