----------------------------------------------------------------------------------
-- Company:   ONERA
-- Engineer:  guillaume.gourves@onera.fr
--
-- Create Date: 28.07.2021 08:42:22
-- Design Name:
-- Module Name: package_i2c_master - Behavioral
-- Project Name: CREME
-- Target Devices: NG-MEDIUM
-- Tool Versions: Nxmap3
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: Thanks to the author of I2C-Master Core
-- Specification -> Richard Herveille (rherveille@opencores.org)
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package pckg_i2c_master_core is
  --------Adresse registre ---------------------
  constant PRERlo : std_logic_vector(2 downto 0)  :=  "000"; -- Clock Prescale register lo-byte
  constant PRERhi : std_logic_vector(2 downto 0)  :=  "001"; -- Clock Prescale register hi-byte
  constant CTR    : std_logic_vector(2 downto 0)  :=  "010"; -- Control register
  constant TXR    : std_logic_vector(2 downto 0)  :=  "011"; -- Transmit register
  constant RXR    : std_logic_vector(2 downto 0)  :=  "011"; -- Receive register
  constant CR     : std_logic_vector(2 downto 0)  :=  "100"; -- Command register
  constant SR     : std_logic_vector(2 downto 0)  :=  "100"; -- Status register
  -----Valeur des registre---------------------
  constant prescalerbin : std_logic_vector(15 downto 0) := "0000000110010000";
  constant ctrInit : std_logic_vector(7 downto 0)       := "11000000";
end pckg_i2c_master_core;

package body pckg_i2c_master_core is

end pckg_i2c_master_core;
