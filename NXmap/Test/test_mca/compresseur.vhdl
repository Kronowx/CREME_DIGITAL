----------------------------------------------------------------------------------
-- Company: ONERA Toulouse
-- Engineer: guillaume.gourves@onera.for
--
-- Create Date: 10/11/2021
-- Design Name: Compresseur
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

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity compresseur is
    Port
    (
    CLK       : in  std_logic                                           -- Holorge permettant au module de fonctionner (pas de cadence imposé mais plus elle est rapide, plus le compresseur sera rapide)
    ;RESET    : in  std_logic                                           -- Signal de réinitialisation du module.
    ;ENA      : in  std_logic                                           -- Signal de déclenchement de la conversion.
    ;START    : in  std_logic
    ;DONE     : out std_logic := '0'                                    -- Indicateur de la fin de la compression et du changement de format.
    ;DATA_IN  : in  std_logic_vector(23 downto  0)  := (others => '0')  -- Donnees à convertir (format 24 bits).
    ;DATA_OUT : out std_logic_vector(7  downto  0)  := (others => '0')  -- Donnees convertie en sortie de module (format 8 bits).
    ); -- sortie sous format 8 bits
end compresseur;

architecture Behavioral of compresseur is
type compresseur_state is (E0, E1, E2);
signal etatp        : compresseur_state;
signal n            : integer range 0 to 24 ;
signal exposant     : std_logic_vector (4 downto 0); -- 5 bits d'exposant permettant de representer l'entree
signal mantisse     : std_logic_vector (2 downto 0); -- 3 bits de mantisse pour avoir une bonne precision
--signal data_intermediaire : std_logic_vector (23 downto 0);

begin

process(CLK)
begin
  if (RESET = '1') then
      etatp     <= E0;
      DATA_OUT  <= (others => '0');
  else
    if ENA = '1' and rising_edge(CLK) then
      case etatp is
          when E0 =>
            if START = '1' then
              etatp <= E1;
              DATA_OUT <= (others => '0');
          	  DONE <= '0';
          	  exposant <= (others => '0');
          	  mantisse <= (others => '0');
            end if;
          when E1 =>
            etatp <= E2;
            if unsigned(DATA_IN) < 64 then
              n <= 0;
              exposant <= DATA_IN(7 downto 3);
              mantisse <= DATA_IN(2 downto 0);
            elsif unsigned(DATA_IN) < 80 then
              n <= 1;
              exposant <= "01000";
              mantisse <= DATA_IN(3 downto 1);
            elsif unsigned(DATA_IN) < 96 then
              n <= 2;
              exposant <= "01001";
              mantisse <= DATA_IN(3 downto 1);
            elsif unsigned(DATA_IN) < 112 then
              n <= 3;
              exposant <= "01010";
              mantisse <= DATA_IN(3 downto 1);
            elsif unsigned(DATA_IN) < 128 then
              n <= 4;
              exposant <= "01011";
              mantisse <= DATA_IN(3 downto 1);
            elsif unsigned(DATA_IN) < 160 then
              n <= 5;
              exposant <= "01100";
              mantisse <= DATA_IN(4 downto 2);
            elsif unsigned(DATA_IN) < 192 then
              n <= 6;
              exposant <= "01101";
              mantisse <= DATA_IN(4 downto 2);
            elsif unsigned(DATA_IN) < 224 then
              n <= 7;
              exposant <= "01110";
              mantisse <= DATA_IN(4 downto 2);
            elsif unsigned(DATA_IN) < 256 then
              n <= 8;
              exposant <= "01111";
              mantisse <= DATA_IN(4 downto 2);
            elsif unsigned(DATA_IN) < 320 then
              n <= 9;
              exposant <= "10000";
              mantisse <= DATA_IN(5 downto 3);
            elsif unsigned(DATA_IN) < 384 then
              n <= 10;
              exposant <= "10001";
              mantisse <= DATA_IN(5 downto 3);
            elsif unsigned(DATA_IN) < 512 then
              n <= 11;
              exposant <= "10010";
              mantisse <= DATA_IN(6 downto 4);
            elsif unsigned(DATA_IN) < 768 then
              n <= 12;
              exposant <= "10011";
              mantisse <= DATA_IN(7 downto 5);
            elsif unsigned(DATA_IN) < 1280 then
              n <= 13;
              exposant <= "10100";
              mantisse <= DATA_IN(8 downto 6);
            elsif unsigned(DATA_IN) < 2304 then
              n <= 14;
              exposant <= "10101";
              mantisse <= DATA_IN(9 downto 7);
            elsif unsigned(DATA_IN) < 4350 then
              n <= 15;
              exposant <= "10110";
              mantisse <= DATA_IN(10 downto 8);
            elsif unsigned(DATA_IN) < 8448 then
              n <= 16;
              exposant <= "10111";
              mantisse <= DATA_IN(11 downto 9);
            elsif unsigned(DATA_IN) < 16640 then
              n <= 17;
              exposant <= "11000";
              mantisse <= DATA_IN(12 downto 10);
            elsif unsigned(DATA_IN) < 33024 then
              n <= 18;
              exposant <= "11001";
              mantisse <= DATA_IN(13 downto 11);
            elsif unsigned(DATA_IN) < 65792 then
              n <= 19;
              exposant <= "11010";
              mantisse <= DATA_IN(14 downto 12);
            elsif unsigned(DATA_IN) < 131328 then
              n <= 20;
              exposant <= "11101";
              mantisse <= DATA_IN(15 downto 13);
            elsif unsigned(DATA_IN) < 262400 then
              n <= 21;
              exposant <= "11100";
              mantisse <= DATA_IN(16 downto 14);
            elsif unsigned(DATA_IN) < 524288 then
              n <= 22;
              exposant <= "11101";
              mantisse <= DATA_IN(17 downto 15);
            elsif unsigned(DATA_IN) < 2621440 then
              n <= 23;
              exposant <= "11110";
              mantisse <= DATA_IN(20 downto 18);
            elsif unsigned(DATA_IN) < 19398656 then
              n <= 24;
              exposant <= "11111";
              mantisse <= DATA_IN(23 downto 21);
            end if;
          when E2 =>
            DATA_OUT <= exposant & mantisse;
            DONE <= '1';
            if START = '1' then
              etatp <= E0;
            end if;
      end case;
     end if;
    end if;
end process;
end Behavioral;
