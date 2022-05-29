----------------------------------------------------------------------------------
-- Company: ONERA
-- Engineer: guillaume.gourves@onera.fr
--
-- Create Date: 15.06.2021 10:44:45
-- Design Name:
-- Module Name: wishbone_driver - Behavioral
-- Project Name: CREME
-- Target Devices: NG-MEDIUM
-- Tool Versions: nxmap3
-- Description:
--
-- Dependencies: Wishbone B4 (.pdf)
--
-- Revision: B4
-- Revision 0.01 - File Created
-- Additional Comments:
-- This Modelisation is based by WISHBONE System-on-Chip (SoC)Interconnection
-- Architecturefor Portable IP Cores (Document Title : Wishbone B4)
-- Thank to OpenCores Communauty !!
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

entity WISHBONE_MASTER is --wishbone master (seulement single read/write)
  port
  (-- il n'y a pas de signal wb_sel, si besoin sur un controlleur relier cet entree a un signal "1111..."
    CLK          : in    std_logic;                      --! Clock pin
    RESET_BAR    : in    std_logic;                     --! Reset pin for initialisation

    START        : in    std_logic;                     --! Start pin for activate transmission
    RD_WR        : in    std_logic;                     --! Start pin for activate transmission
    REG_ADDR     : in    std_logic_vector(1 downto 0);  --! Vecteur permettant de temporiser le registre d'adresse
    REG_DATA     : in    std_logic_vector(7 downto 0);  --! Vecteur permettant de temporiser le registre d'adresse                    --! Receive pin for CAN
    PORT_0_READ  : out   std_logic_vector(7 downto 0);
    PORT_FREE    : out   std_logic;                     --! Output which indicate that the time has elapsed

    WB_DAT_I     : in   std_logic_vector(7 downto 0);
    WB_DAT_O     : out  std_logic_vector(7 downto 0);
    WB_CYC_O     : out  std_logic;
    WB_STB_O     : out  std_logic;
    WB_ADR_O     : out  std_logic_vector(1 downto 0);
    WB_WE_O      : out  std_logic;
    WB_ACK_I     : in   std_logic
  );
end WISHBONE_MASTER;

architecture Behavioral of WISHBONE_MASTER is

type wishbone_master_state is
  (
    IDLE
    ,BUS_REQUEST_WRITE
    ,BUS_REQUEST_READ
    ,WAIT_FOR_ACK_WRITE
    ,WAIT_FOR_ACK_READ
  );

  signal etat : wishbone_master_state;
begin

PROCESS_WISHBONE_MASTER : process (CLK)
	begin
     if rising_edge(CLK) then
         if RESET_BAR='0' then   -- On réinitialisde le tout.
                WB_DAT_O <= (others => 'Z');
                WB_CYC_O <='0';
                WB_STB_O <= '0';
                WB_ADR_O <= (others => 'Z');
                WB_WE_O <= '0';
                PORT_FREE <= '0'; -- put at 1 to check if the value change in the tb : 0 is the good one
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
                    if START = '1' then
                        PORT_FREE <= '0';
                        if RD_WR = '1' then
                            etat <= BUS_REQUEST_WRITE;
                        else
                            etat <= BUS_REQUEST_READ;
                        end if;
                    end if;

                WHEN BUS_REQUEST_WRITE =>   -- request write et read sont quasiment pareil a la difference de we
                    if START = '0' then     -- On attend que le demandeur relache le START (evite les écritures multiples)
                      WB_ADR_O <= REG_ADDR; -- MASTER presents a valid address on [ADR_O()] and [TGA_O()].
                      WB_DAT_O <= REG_DATA; -- MASTER presents valid data on [DAT_O()] and [TGD_O()].
                      WB_WE_O <= '1';       -- MASTER asserts [WE_O] to indicate a WRITE cycle.
                      WB_CYC_O <='1';       -- MASTER asserts [CYC_O] and [TGC_O()] to indicate the start of the cycle.
                      WB_STB_O <= '1';      -- MASTER asserts [STB_O] to indicate the start of the phase.
                      etat <= WAIT_FOR_ACK_WRITE;
                    end if;

                WHEN BUS_REQUEST_READ =>
                    if START = '0' then     -- On attend que le demandeur relache le START (evite les lectures multiples)
                      WB_ADR_O <= REG_ADDR; -- MASTER presents a valid address on [ADR_O()] and [TGA_O()].
                      WB_WE_O <= '0';       -- MASTER negates [WE_O] to indicate a READ cycle.
                      WB_CYC_O <='1';       -- MASTER asserts [CYC_O] and [TGC_O()] to indicate the start of the cycle.
                      WB_STB_O <= '1';      -- MASTER asserts [STB_O] to indicate the start of the phase.
                      etat <= WAIT_FOR_ACK_READ;
                    end if;

                WHEN WAIT_FOR_ACK_WRITE =>
                    if(WB_ACK_I = '1') then   -- MASTER monitors [ACK_I], and prepares to terminate the cycle.
                        etat <=  IDLE;
                        WB_CYC_O <='0';       -- MASTER negates [CYC_O] to indicate the end of the cycle.
                        WB_STB_O <= '0';      -- MASTER negates [STB_O] to indicate the end of the cycle.
                    end if;

                WHEN WAIT_FOR_ACK_READ =>
                    if(WB_ACK_I = '1') then   -- MASTER monitors [ACK_I], and prepares to latch data on [DAT_I()] and [TGD_I()].
                        etat <=  IDLE;
                        PORT_0_READ <= WB_DAT_I;--lecture et retransmission
                        WB_CYC_O <='0';       -- MASTER negates [CYC_O] to indicate the end of the cycle.
                        WB_STB_O <= '0';      -- MASTER negates [STB_O] to indicate the end of the cycle.
                    end if;

                when others => -- Si on est l�  : c'est qu'il y a baleine sous cailloux!
                    etat <= IDLE;

            end case;
        end if;
    end if;
end process;



end Behavioral;
