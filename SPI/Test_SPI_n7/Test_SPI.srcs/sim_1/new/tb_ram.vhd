----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.04.2022 16:27:53
-- Design Name: 
-- Module Name: tb_ram - Behavioral
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
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity ram_intel_tb is
end;

architecture bench of ram_intel_tb is

  component ram_intel
     PORT
     (
        CLK: IN   std_logic;
        RST: IN   std_logic;
        data_i:  IN   std_logic_vector (31 DOWNTO 0);
        read_address:   IN   integer RANGE 0 to 255;
        we:    IN   std_logic;
        FLAG_enable: IN   std_logic;
        data_o:     OUT  std_logic_vector (20 DOWNTO 0)
     );
  end component;

  signal CLK: std_logic:='0';
  signal RST: std_logic;
  signal data_i: std_logic_vector (31 DOWNTO 0);
  signal read_address: integer RANGE 0 to 255;
  signal we: std_logic;
  signal FLAG_enable: std_logic;
  signal data_o: std_logic_vector (20 DOWNTO 0) ;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: ram_intel port map ( CLK          => CLK,
                            RST          => RST, 
                            data_i       => data_i,
                            read_address => read_address,
                            we           => we,
                            FLAG_enable  => FLAG_enable,
                            data_o       => data_o );

  stimulus: process
  begin
  
    -- Put initialisation code here
    RST <='0';
    wait for 51 ns ;
    RST <='1';
    wait for 11 ns ;
    data_i <=x"000002A0";
    FLAG_enable <='1';
    we<='1';
    wait for 51 ns ;
    FLAG_enable <='0';
    wait for 51 ns ;
    data_i <=x"000001A0";
    FLAG_enable <='1';
    we<='1';
    wait for 51 ns ;
    FLAG_enable <='0';
    -- Put test bench stimulus code here
    

    wait;
  end process;

PROCESS_CLOCK : process
begin
  CLK <= not(CLK);
  wait for 5 ns;
end process;

end;