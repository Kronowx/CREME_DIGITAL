----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.07.2021 09:52:49
-- Design Name: 
-- Module Name: wishbone_driver - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity wishbone_driver is --wishbone master (seeulement single read/write)
    port (-- il n'y a pas de signal wb_sel, si besoin sur un controlleur relier cet entrÈe ‡ un signal "1111..." 
        CLK           : in    std_logic;                      --! Clock pin                   --! Reset pin for initialisation                    --! Reset pin for initialisation
        RESET_BAR    : in    std_logic;                     --! Reset pin for initialisation
        
        START  : in    std_logic;                     --! Start pin for activate transmission
        RD_WR  : in    std_logic;                     --! Start pin for activate transmission
        REG_ADDR     : in    std_logic_vector(2 downto 0);  --! Vecteur permettant de temporiser le registre d'adresse
        REG_DATA     : in    std_logic_vector(7 downto 0);  --! Vecteur permettant de temporiser le registre d'adresse                    --! Receive pin for CAN
        PORT_0_READ : out std_logic_vector(7 downto 0);
        PORT_FREE    : out   std_logic;                     --! Output which indicate that the time has elapsed
       
       WB_DAT_I             : in std_logic_vector(7 downto 0);
       WB_DAT_O             : out std_logic_vector(7 downto 0);
       WB_CYC_O             : out std_logic;
       WB_STB_O             : out std_logic;
       WB_ADR_O             : out std_logic_vector(2 downto 0);
       WB_WE_O              : out std_logic;
       WB_ACK_I             : in std_logic
       );
end wishbone_driver;

architecture Behavioral of wishbone_driver is



type behavior_state is
  (
    IDLE,
    BUS_REQUEST_WRITE,
    BUS_REQUEST_READ,
    WAIT_FOR_ACK,
    READ
    
  );
  signal etat, etat_futur : behavior_state;
begin


PROCESS_WRITE : process (CLK)
	begin
     if rising_edge(CLK) then
         if RESET_BAR='0' then   -- On r√©initialisde le tout.
                WB_DAT_O <= (others => 'Z');
                WB_CYC_O <='0';
                WB_STB_O <= '0';
                WB_ADR_O <= (others => 'Z');
                WB_WE_O <= '0';
                PORT_FREE <= '0';
                etat <= IDLE;
         else
            case etat is
               
                when IDLE => -- Attente d'une instruction
                   WB_DAT_O <= (others => 'Z');
                    WB_CYC_O <='0';
                    WB_STB_O <= '0';
                    WB_ADR_O <= (others => 'Z');
                    WB_WE_O <= '0';
                    PORT_FREE <= '1';
                    if START = '1' then--il faut que start soit haut pendant assez longtemps pour que le driver
                        PORT_FREE <= '0';
                        if RD_WR = '1' then--  detecte mais pas trop pour pas qu'il fasse 2 ecriture/lecture 
                            etat <= BUS_REQUEST_WRITE;-- il ne faut pas reessayer d'ecrire avant que le driver aie eu le temps de passer port_free a 0
                        else 
                            etat <= BUS_REQUEST_READ;
                        end if;
                    end if;       
                
                WHEN BUS_REQUEST_WRITE =>--request write et read sont quasiment pareil a la difference de we
                    PORT_FREE <= '0';
                    WB_DAT_O <= REG_DATA;
                    WB_CYC_O <='1';
                    WB_STB_O <= '1';
                    WB_ADR_O <= REG_ADDR;
                    WB_WE_O <= '1';
                    etat <= WAIT_FOR_ACK;
                    etat_futur <= IDLE;
                    
                WHEN BUS_REQUEST_READ =>
                    PORT_FREE <= '0';
                    WB_CYC_O <='1';
                    WB_STB_O <= '1';
                    WB_ADR_O <= REG_ADDR;
                    WB_WE_O <= '0';
                    etat <= WAIT_FOR_ACK;
                    etat_futur <= READ;--il faut lire apres reception du ack
                
                WHEN WAIT_FOR_ACK =>
                    if(WB_ACK_I = '1') then
                        etat <=  etat_futur;
                        WB_CYC_O <='0';
                        WB_STB_O <= '0';
                    end if;
                
                WHEN READ =>
                    PORT_0_READ <= WB_DAT_I;--lecture et retransmission
                    etat <= IDLE;
                
                when others => -- Si on est l√  : c'est qu'il y a baleine sous cailloux!
                --          etat <= INIT;
            
            end case;
        end if;
    end if;
end process;



end Behavioral;
