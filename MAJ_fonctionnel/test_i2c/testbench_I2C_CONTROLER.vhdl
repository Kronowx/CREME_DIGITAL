----------------------------------------------------------------------------------
-- Company          : ONERA TLS/DTIS/AEI
-- Engineer       : guillaume.gourves@onera.fr
--
-- Create Date      : 28.07.2021 10:46:31
-- Design Name      :
-- Module Name      : testbench_I2C_CONTROLER - Behavioral
-- Project Name     :  CREME
-- Target Devices   : NG-MEDIUM NanoXplore
-- Tool Versions: v1.0
-- Description:
--
-- Dependencies:
--
-- Revision: v1.0
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_textio.all;
use STD.textio.all;
use ieee.numeric_std.all;

entity tb_I2C_CONTROLER is
end tb_I2C_CONTROLER;

architecture Behavioral of tb_I2C_CONTROLER is
  constant device_addr      : std_logic_vector(6 downto 0)    :=  "0010000";
  constant device_word_send : std_logic_vector(31 downto 0)   :=  x"A5A5A5A5";

  signal sig_CLK                  :  std_logic :='0';
  signal sig_RESET_BAR            :  std_logic :='0';
  signal sig_START_HOUSEKEEPING   :  std_logic :='0';                     --! Start pin for activate transmission
  signal sig_ACQ_HOUSEKEEPING     :  std_logic :='0';                     --! Start pin for activate transmission
  signal sig_PORT_FREE            :  std_logic :='0';                     --! Start pin for activate transmission
  signal sig_SCL                  :  std_logic;
  signal sig_SDA                  :  std_logic;

component I2C_CONTROLER is
  port
    (
      CLK                     : in std_logic;
      RESET_BAR               : in std_logic;
      START_HOUSEKEEPING      : in std_logic;
      ACQ_HOUSEKEEPING        : out std_logic;
      PORT_FREE               : out std_logic;
      SCL                     : inout std_logic;
      SDA                     : inout std_logic
    );
end component;

component i2c_slave_model is
  Port
    (
      scl : in    std_logic
      ;sda : inout std_logic
    );
end component;

begin
sig_SCL <= 'H';
sig_SDA <= 'H';
  evaluate_I2C_CONTROLER : I2C_CONTROLER
  Port map
  (
    CLK                 => sig_CLK
    ,RESET_BAR          => sig_RESET_BAR
    ,START_HOUSEKEEPING => sig_START_HOUSEKEEPING
    ,ACQ_HOUSEKEEPING   => sig_ACQ_HOUSEKEEPING
    ,PORT_FREE          => sig_PORT_FREE
    ,SCL                => sig_SCL
    ,SDA                => sig_SDA
  );

  simulateur_slave : i2c_slave_model
  Port map
  (
    scl   => sig_SCL
    ,sda  => sig_SDA
  );

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
    wait until sig_PORT_FREE = '1';                  -- Pendant un temps
    sig_START_HOUSEKEEPING  <= '1';
    wait until sig_PORT_FREE = '0';
    sig_START_HOUSEKEEPING  <= '0';
    wait until sig_PORT_FREE = '1';
    wait for 10 ms;
    sig_START_HOUSEKEEPING  <= '1';
    wait until sig_PORT_FREE = '0';
    sig_START_HOUSEKEEPING  <= '0';
    wait until sig_PORT_FREE = '1';
    wait;
  end process;
end Behavioral;
