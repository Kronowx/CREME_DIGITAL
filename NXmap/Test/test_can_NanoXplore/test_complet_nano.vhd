----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.07.2021 11:07:56
-- Design Name: 
-- Module Name: test_complet_nano - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_complet_nano is port (
    CLK: in std_logic;
    RST: in std_logic;
    
    BOUTON_T : in std_logic; --bouton pour lancer la premiere transmission
    BOUTON_R : in std_logic; --bouton pour lancer la retransmission du 2eme controlleur
    
    --il faut relier avec des fils comme ceci
    TX_i_T : in std_logic;  -----------|
--                                     |  
    TX_o_T : out std_logic; -----|     |
    TX_i_R : in std_logic;  -----|     |
--                                     |
    TX_o_R : out std_logic; -----------|
    
    RX : out std_logic --pin ou il faut brancher l'oscilloscope
    
    );
    
end test_complet_nano;

architecture Behavioral of test_complet_nano is

signal sig_TX_o_T : std_logic;
signal sig_TX_o_R : std_logic;

component nano_T port(
    CLK : in std_logic;
    RST_CAN : in std_logic;
    
    BOUTON : in std_logic;
    
    TX_i : in std_logic;
    TX_o : out std_logic
);
end component;

component nano_R port(
    CLK : in std_logic;
    RST_CAN : in std_logic;
    
    BOUTON : in std_logic;
    
    TX_i : in std_logic;
    TX_o : out std_logic
);
end component;

begin

TX_o_T <= sig_TX_o_T;
TX_o_R <= sig_TX_o_R;
RX <= sig_TX_o_T and sig_TX_o_R; --sur le RX pour l'oscillo on sort ce qu'il y aurait "réelement" sur le bus

nano_T_1 : nano_T port map(
    CLK => CLK,
    RST_CAN => RST,
    BOUTON => BOUTON_T,
    TX_i => TX_i_T,
    TX_o => sig_TX_o_T
);

nano_R_1 : nano_R port map(
    CLK => CLK,
    RST_CAN => RST,
    BOUTON => BOUTON_R,
    TX_i => TX_i_R,
    TX_o => sig_TX_o_R
);


end Behavioral;
