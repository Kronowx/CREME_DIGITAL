----------------------------------------------------------------------------------
-- Company:   ONERA
-- Engineer:  guillaume.gourves@onera.fr
--
-- Create Date: 28.07.2021 08:42:22
-- Design Name:
-- Module Name: package_simple_spi - Behavioral
-- Project Name: CREME
-- Target Devices: NG-MEDIUM
-- Tool Versions: Nxmap3
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: Thanks to the author of Simple-spi Core
-- Specification -> Richard Herveille (rherveille@opencores.org)
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package pckg_simple_spi is
  constant RegSPCR :std_logic_vector(1 downto 0):= "00"; --! Control Register
  constant RegSPSR :std_logic_vector(1 downto 0):= "01"; --! Status Register
  constant RegSPDR :std_logic_vector(1 downto 0):= "10"; --! Data Register
  constant RegSPER :std_logic_vector(1 downto 0):= "11"; --! Extensions Register
end pckg_simple_spi;

--package body pckg_i2c_master_core is
--end pckg_i2c_master_core;
