----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.02.2022 10:18:24
-- Design Name: 
-- Module Name: compteur - Behavioral
-- Project Name: 
-- Target Devices: 
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity compteur is
generic(MAX : integer);
port(
    i_clk  : in  std_logic;
    i_rstn : in  std_logic;
    i_en   : in  std_logic;
    o_cnt  : out std_logic
    
    );
end compteur;

architecture Behavioral of compteur is


  signal cnt : integer;

  
begin

  -- Output
  
  -- Main process with asynchronous reset 
  P_bcd: process (i_clk,i_rstn)
  begin
    if (i_rstn = '0') then
      cnt <= 0;
    elsif rising_edge(i_clk) then
      if (i_en = '1') then
        if (cnt = MAX) then
          cnt <= 0;
          o_cnt <= '1';
        else
          cnt <= cnt + 1;
          o_cnt <= '0';
        end if;
      else 
      cnt <= 0;
      o_cnt <= '0';
      end if;
    end if;
    
  end process P_bcd;
    
end Behavioral;