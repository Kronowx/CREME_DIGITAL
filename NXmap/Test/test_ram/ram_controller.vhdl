
-- Company: ONERA
-- Engineer: guillaume.gourves@onera.fr
--
-- Create Date: 12.07.2021 13:53:37
-- Design Name:
-- Module Name: ram_controller
-- Project Name: CREME
-- Target Devices: NG-MEDIUM
-- Tool Versions: 2.9.7
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

--library NX;
--use NX.nxPackage.all;

entity ram_controller is
  port
  (
  	CLK	        :   in   std_logic                      -- Horloge de fonctionnement du module
    ;RESET      :   in   std_logic                      --  Reinitialisation du module
  	;DI	        :   in   std_logic_vector(7 downto 0)   -- Donnee a ecrire
  	;DO	        :   out  std_logic_vector(7 downto 0)   -- Donner a lire
  	;AD	        :   in   std_logic_vector(12 downto 0)  -- Adresse a lire ou ecrire
    ;READ_WRITE :   in   std_logic                      -- Commande de lecture ou d'ecriture
    ;WE	        :   in   std_logic                      -- Commande d'activation du module
    ;BUSY       :   out  std_logic                      -- Indicateur d'occupation du module
    ;READY      :   out  std_logic                      -- Indicateur de plein focntionnement du module
    ;START      :   in   std_logic                      -- Pin de lancement d'un traitement du module
  );
end entity;

architecture Behavioral of ram_controller is
  type ram_controller_state is
  (
    STATE_INIT
    ,STATE_IDLE
    ,STATE_START_WRITE
    ,STATE_START_READ
    ,STATE_END_WRITE
    ,STATE_END_READ
    ,STATE_WAIT_CYCLE
    ,STATE_REBOOT_RAM
  );
  signal etat_present : ram_controller_state;
  signal etat_futur   : ram_controller_state;
  signal sig_DI       : std_logic_vector(7 downto 0) := (others => '0');
  signal sig_DO       : std_logic_vector(7 downto 0) := (others => '0');
  signal sig_AD       : std_logic_vector(12 downto 0) := (others => '0');
  signal sig_READY    : std_logic := '0';
  signal sig_WE_RAM   : std_logic := '0';
  signal i_cycle_wait : integer := 0;
begin

  READY <= sig_READY;

  PROCESS_RAM : process (CLK)
  begin
    if RESET = '0' then
      etat_present <= STATE_INIT;
    else
      if rising_edge(CLK) then
        case etat_present is
          when STATE_INIT =>
          sig_DI <= (others => '0');
          sig_DO <= (others => '0');
          sig_READY <= '0';
          i_cycle_wait <= 0;
          etat_present <= STATE_REBOOT_RAM;

          when STATE_REBOOT_RAM =>
            sig_WE_RAM   <=  '1';
            i_cycle_wait <=   2;
            etat_present <= STATE_WAIT_CYCLE;
            if sig_AD = x"FFF" then
              etat_futur <= STATE_IDLE;
            else
              etat_futur   <= STATE_REBOOT_RAM;
            end if;

          when STATE_IDLE =>
            READY <= '1';
            if START = '1' then
              BUSY <= '1';
              sig_AD <= AD;
              if READ_WRITE = '0' then -- lecture demandée
                etat_present <= STATE_START_READ;
              else -- écriture demandee
                sig_DI <= DI;
                etat_present <= STATE_START_WRITE;
              end if;
            end if;

          when STATE_START_WRITE =>
            sig_WE_RAM   <=  '1';
            i_cycle_wait <= 2;
            etat_present <= STATE_WAIT_CYCLE;
            etat_futur   <= STATE_END_WRITE;

          when STATE_END_WRITE =>
            BUSY <= '0';
            sig_WE_RAM <= '0';
            if START = '0' then
              etat_present <= STATE_IDLE;
            end if;

          when STATE_START_READ =>
            sig_WE_RAM   <=  '1';
            i_cycle_wait <= 2;
            etat_present <= STATE_WAIT_CYCLE;
            etat_futur   <= STATE_END_READ;

          when STATE_END_READ =>
            DO <= sig_DO;
            BUSY <= '0';
            sig_WE_RAM <= '0';
            if START = '0' then
              etat_present <= STATE_IDLE;
            end if;

          when STATE_WAIT_CYCLE =>
            i_cycle_wait <= i_cycle_wait - 1;
            if i_cycle_wait <= 0 then
              sig_AD <= std_logic_vector(unsigned(sig_AD)+1);
              etat_present <= etat_futur;
            end if;

          when others =>
            etat_present <= STATE_INIT;

        end case;
      end if;
    end if;
  end process;
end Behavioral;
