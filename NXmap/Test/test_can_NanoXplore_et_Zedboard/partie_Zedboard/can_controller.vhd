----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.06.2021 13:46:03
-- Design Name: 
-- Module Name: can_controller - Behavioral
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

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

--library NX;
--use NX.nxPackage.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;




--can_controller regroupe un wishbone driver et un can_top
entity can_controller is
    port(
        
        CLK : in std_logic;
        CLK_DRIVER : in std_logic;  --clk pour echanges wishbone
        RESET_BAR : in std_logic;   --reset sur 0
    
        START  : in    std_logic;                     --! Start pin for activate transmission
        RD_WR  : in    std_logic;                     --0 pour lire 1 pour ecrire
        REG_ADDR     : in    std_logic_vector(7 downto 0);  --adresse du registre à lire/ecrire
        REG_DATA     : in    std_logic_vector(7 downto 0);  --data à acrire                    
        PORT_0_READ : out std_logic_vector(7 downto 0);     --data lu
        PORT_FREE    : out   std_logic;                 --1 : on peut faire une lecture/ecriture
                                                        --0 : il faut attendre que celle en cours finisse   
                                                        --voir commentaires dans process wishbone_driver pour subtilités
        
        RX : in std_logic;          --entrée coté bus CAN
        TX : out std_logic;         --sortie coté bus CAN
        BUS_OFF_ON : out std_logic;     --signal defini can_top et non SJA1000, faut voir a quoi ils servent
        IRQ_ON : out std_logic;         --idem
        CLK_OUT : out std_logic         --sortie de la CLK apres passage dans le divider
        
    
    );
end can_controller;

architecture Behavioral of can_controller is
  signal sig_wb_dat_i             : std_logic_vector(7 downto 0);
  signal sig_wb_dat_o             : std_logic_vector(7 downto 0);
  signal sig_wb_cyc_o             : std_logic;
  signal sig_wb_stb_o             : std_logic;
  signal sig_wb_adr_o             : std_logic_vector(7 downto 0);
  signal sig_wb_we_o              : std_logic;
  signal sig_wb_ack_i             : std_logic;
  
  signal reset_inv : std_logic;
  signal reset_inv_ls : std_logic; --low skew pour le can_top
  
  
  component can_top
  port
  (
     wb_clk_i : in std_logic;
    wb_rst_i  : in std_logic;
    wb_dat_i  : in std_logic_vector(7 downto 0);
    wb_dat_o  : out std_logic_vector(7 downto 0);
    wb_cyc_i  : in std_logic;
    wb_stb_i  : in std_logic;
    wb_we_i   : in std_logic;
    wb_adr_i  : in std_logic_vector(7 downto 0);
    wb_ack_o  : out std_logic;
      clk_i       : in    std_logic;                    
      rx_i        : in    std_logic;                     
      tx_o        : out   std_logic;                    
      bus_off_on  : out   std_logic;                    
      irq_on      : out   std_logic;                   
      clkout_o    : out   std_logic                     
  );
  end component;
  
  component wishbone_driver
  generic(N_ADDR : integer; N_DATA : integer);
  port(
        CLK           : in    std_logic;                   
        RESET_BAR    : in    std_logic;                     
        
        START  : in    std_logic;                    
        RD_WR  : in    std_logic;                   
        REG_ADDR     : in    std_logic_vector(N_ADDR-1 downto 0); 
        REG_DATA     : in    std_logic_vector(N_DATA-1 downto 0); 
        PORT_0_READ : out std_logic_vector(N_DATA-1 downto 0);
        PORT_FREE    : out   std_logic;                     
       
       
       WB_DAT_I             : in std_logic_vector(N_DATA-1 downto 0);
       WB_DAT_O             : out std_logic_vector(N_DATA-1 downto 0);
       WB_CYC_O             : out std_logic;
       WB_STB_O             : out std_logic;
       WB_ADR_O             : out std_logic_vector(N_ADDR-1 downto 0);
       WB_WE_O              : out std_logic;
       WB_ACK_I             : in std_logic
  );
  end component;
  
  
  
begin

--CKB_0 : NX_BD
--port map (
-- I => reset_inv
--,
-- O => reset_inv_ls
--);

can_top_1 : can_top port map
  (
    wb_clk_i       => CLK_DRIVER,          
    wb_rst_i       => reset_inv,     
    wb_dat_i(7 downto 0)        => sig_wb_dat_o(7 downto 0),       --relier le dat_o du driver au dat_i du can_top 
    wb_dat_o(7 downto 0)        => sig_wb_dat_i(7 downto 0),          
    wb_cyc_i   => sig_wb_cyc_o,
    wb_stb_i    => sig_wb_stb_o,
    wb_we_i => sig_wb_we_o,   
    wb_adr_i(7 downto 0)       => sig_wb_adr_o(7 downto 0),
    wb_ack_o => sig_wb_ack_i,
    clk_i => CLK,   
    rx_i        => RX,         
    tx_o        => TX,         
    bus_off_on  => BUS_OFF_ON, 
    irq_on      => IRQ_ON,      
    clkout_o    => CLK_OUT     
  );
  
driver_1 : wishbone_driver 
generic map(
N_ADDR => 8,        --le can_top marche sur 8 bits addresse 8 bits data
N_DATA => 8)
port map(
        CLK => CLK_DRIVER,                   
        RESET_BAR   => RESET_BAR,                
        
        START => START,                  
        RD_WR => RD_WR,                
        REG_ADDR     => REG_ADDR,
        REG_DATA     => REG_DATA,               
        PORT_0_READ => PORT_0_READ,
        PORT_FREE    => PORT_FREE,                  
       
       
       WB_DAT_I             => sig_wb_dat_i,
       WB_DAT_O             => sig_wb_dat_o,
       WB_CYC_O             => sig_wb_cyc_o,
       WB_STB_O             => sig_wb_stb_o,
       WB_ADR_O             => sig_wb_adr_o,
       WB_WE_O              => sig_wb_we_o,
       WB_ACK_I             => sig_wb_ack_i
    
);

reset_inv <= not(RESET_BAR); --le can top a le reset a 1

end Behavioral;
