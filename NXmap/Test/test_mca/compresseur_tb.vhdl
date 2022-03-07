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

library std;
use std.textio.all;

entity compresseur_tb is
end compresseur_tb;

architecture Behavioral of compresseur_tb is

  component compresseur is
  	port
  	(
      CLK       : in  std_logic                                           -- Holorge permettant au module de fonctionner (pas de cadence imposé mais plus elle est rapide, plus le compresseur sera rapide)
      ;RESET    : in  std_logic                                           -- Signal de réinitialisation du module.
      ;ENA      : in  std_logic                                           -- Signal de déclenchement de la conversion.
      ;START    : in  std_logic
      ;DONE     : out std_logic := '0'                                    -- Indicateur de la fin de la compression et du changement de format.
      ;DATA_IN  : in  std_logic_vector(23 downto  0)  := (others => '0')  -- Donnees à convertir (format 24 bits).
      ;DATA_OUT : out std_logic_vector(7  downto  0)  := (others => '0')  -- Donnees convertie en sortie de module (format 8 bits).
  	);
  end component;

  signal sig_CLK              : std_logic := '0';
  signal sig_RESET            : std_logic := '0';
  signal sig_ENA              : std_logic := '0';
  signal sig_START            : std_logic := '0';
  signal sig_DONE             : std_logic;
  signal sig_DATA_IN          : std_logic_vector(23 downto  0)  := (others => '0');
  signal sig_DATA_OUT         : std_logic_vector(7 downto  0)   := (others => '0');
  signal sig_DATA_OUT_res     : bit_vector(7 downto  0)   := (others => '0');
  signal sig_value_test       : std_logic_vector(23 downto  0)  := (others => '0');
begin

  TEST_COMPRESSEUR :  compresseur port map
  (
      CLK         => sig_CLK
      ,RESET      => sig_RESET
      ,ENA        => sig_ENA
      ,START      => sig_START
      ,DONE       => sig_DONE
      ,DATA_IN    => sig_DATA_IN
      ,DATA_OUT   => sig_DATA_OUT
  );

  process
  begin
  	sig_CLK <= not(sig_CLK);
  	wait for 100 ns;
  end process;

  process
    file file_RESULTS : text;
    variable v_OLINE     : line;
    constant DATA_OUT_size      : natural := 8;
    constant DATA_IN_size       : natural := 24;
    constant DATA_IN_msg        : string := "DATA_IN : ";
    constant DATA_OUT_msg        : string := "DATA_OUT : ";
    constant SPACE_msg        : string := " ";
  begin
    file_open(file_RESULTS, "./output_results.txt", write_mode);
    sig_value_test <= (others => '0');
    report "Reinitialisation du module";
    sig_ENA     <= '0';
    sig_DATA_IN <= (others => '0');
    sig_RESET   <= '1';
    wait for 1 ms;
    report "Activation du module";
    sig_RESET <= '0';
    sig_ENA <= '1';
    wait for 1 ms;
    report "Lancement du test du module";
    test_loop : for i in 0 to (2**24)-1 loop
      sig_DATA_IN <= std_logic_vector(unsigned(sig_value_test) + i);
      sig_START <= '1';
      wait until sig_DONE = '1';
      sig_START <= '0';
      sig_DATA_IN <= (others => '0');
      write(v_OLINE, DATA_IN_msg, right, DATA_IN_msg'length);
      write(v_OLINE, to_bitvector(sig_DATA_IN), right, sig_DATA_IN'length);
      write(v_OLINE, SPACE_msg, right, SPACE_msg'length);
      write(v_OLINE, DATA_OUT_msg, right, DATA_OUT_msg'length);
      write(v_OLINE, to_bitvector(sig_DATA_OUT), right, sig_DATA_OUT'length);
      writeline(file_RESULTS, v_OLINE);
    end loop test_loop;
    file_close(file_RESULTS);
    report "Fin du test";
    wait;
  end process;

end Behavioral;
