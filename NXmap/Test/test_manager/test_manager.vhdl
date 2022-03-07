----------------------------------------------------------------------------------
-- Company: ONERA Toulouse
-- Engineer: guillaume.gourves@onera.fr
--
-- Create Date: 05.07.2021 11:07:56
-- Design Name:
-- Module Name: global_manager - Behavioral
-- Project Name: CREME
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: Module prevu pour s'interconnecter entre le module CAN_OPEN
--
----------------------------------------------------------------------------------

-- Librairies necessaire
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity global_manager is port
    (
      CLK                       : in  std_logic
      ;RST                       : in  std_logic
      ;DATA_INPUT_CMD_ARG       : in std_logic_vector(55 downto 0)
      ;FLAG_HeartBeat            : in std_logic
      ;FLAG_DumpMEM              : in std_logic
      ;FLAG_ReadCONFIG           : in std_logic
      ;FLAG_SetCONFIG            : in std_logic
      ;FLAG_SetTIME              : in std_logic
      ;BUSY                      : out  std_logic
      ;EN                        : in  std_logic
      ;RTC_SET                   : out  std_logic
      ;RTC_BUSY_FLAG             : in  std_logic
      ;RTC_CONFIRM_FLAG          : in  std_logic
      ;RTC_DATA                  : out  std_logic_vector(31 downto 0)
      ;DumpMEM_SET               : out  std_logic
      ;DumpMEM_BUSY_FLAG         : in  std_logic
      ;DumpMEM_CONFIRM_FLAG      : in  std_logic
      ;DumpMEM_DATA              : out  std_logic_vector(47 downto 0)
      ;CONFIG_SET                : out  std_logic
      ;CONFIG_READ_SET           : out  std_logic
      ;CONFIG_BUSY_FLAG          : in  std_logic
      ;CONFIG_CONFIRM_FLAG       : in  std_logic
      ;CONFIG_DATA               : out  std_logic_vector(55 downto 0)
    );
end global_manager;

architecture Behavioral of global_manager is

  type global_manager_state is --les different etats du driver
  (
    WAIT_ENABLE
    ,INIT
    ,IDLE
    ,MANAGE_SetTIME
    ,MANAGE_SetTIME_END
    ,MANAGE_DumpMEM
    ,MANAGE_DumpMEM_END
    ,MANAGE_SetCONFIG
    ,MANAGE_SetCONFIG_END
    ,MANAGE_ReadCONFIG
    ,MANAGE_ReadCONFIG_END
  );
  signal etat, etat_futur : global_manager_state;
  signal signal_FLAG_REGISTER : std_logic_vector(4 downto 0);

begin

  signal_FLAG_REGISTER(0) <= FLAG_HeartBeat;
  signal_FLAG_REGISTER(1) <= FLAG_DumpMEM;
  signal_FLAG_REGISTER(2) <= FLAG_ReadCONFIG;
  signal_FLAG_REGISTER(3) <= FLAG_SetCONFIG;
  signal_FLAG_REGISTER(4) <= FLAG_SetTIME;

  PROCESS_GLOBAL_MANAGER : process(CLK) is
  begin
    if RST = '1' then
      etat <= INIT;
    else
      case etat is
        when INIT =>
        etat <= WAIT_ENABLE;
        BUSY <= '1';

        when WAIT_ENABLE =>
        if EN = '1' then
          etat <= IDLE;
          BUSY <= '0';
        end if;

        when IDLE =>
          if EN = '1' then
            -- On regarde si il y a une tache a accomplir (AF : voir si on ne peut pas simplifier la comparaison).
            if signal_FLAG_REGISTER /= b"00000" then
              BUSY <= '1';
              if FLAG_HeartBeat = '1' then
                etat <= IDLE;

              elsif FLAG_DumpMEM = '1' then
                DumpMEM_DATA <= DATA_INPUT_CMD_ARG(55 downto 8);
                etat <= MANAGE_DumpMEM;

              elsif FLAG_ReadCONFIG = '1' then
                CONFIG_DATA <= DATA_INPUT_CMD_ARG;
                etat <= MANAGE_ReadCONFIG;

              elsif FLAG_SetCONFIG = '1' then
                CONFIG_DATA <= DATA_INPUT_CMD_ARG;
                etat <= MANAGE_SetCONFIG;

              elsif FLAG_SetTIME = '1' then
                RTC_DATA <= DATA_INPUT_CMD_ARG(55 downto 24);
                etat <= MANAGE_SetTIME;
              end if;
            end if;
          end if;

        when MANAGE_SetTIME =>
          if RTC_BUSY_FLAG = '0' then
            RTC_SET <= '1';
            etat <= MANAGE_SetTIME_END;
          end if;

        when MANAGE_SetTIME_END =>
          if RTC_CONFIRM_FLAG = '1' then
            BUSY <= '0';
            RTC_SET <= '0';
            RTC_DATA <= (others => '0');
            etat <= IDLE;
          end if;

        when MANAGE_DumpMEM =>
          if DumpMEM_BUSY_FLAG = '0' then
            DumpMEM_SET <= '1';
            etat <= MANAGE_DumpMEM_END;
          end if;

        when MANAGE_DumpMEM_END =>
          if DumpMEM_CONFIRM_FLAG = '1' then
            BUSY <= '0';
            DumpMEM_SET <= '0';
            DumpMEM_DATA <= (others => '0');
            etat <= IDLE;
          end if;

        when MANAGE_ReadCONFIG =>
          if CONFIG_BUSY_FLAG = '0' then
            CONFIG_READ_SET <= '1';
            etat <= MANAGE_ReadCONFIG_END;
          end if;

        when MANAGE_ReadCONFIG_END =>
          if CONFIG_CONFIRM_FLAG = '1' then
            BUSY <= '0';
            CONFIG_READ_SET <= '0';
            CONFIG_DATA <= (others => '0');
            etat <= IDLE;
          end if;

        when MANAGE_SetCONFIG =>
          if CONFIG_BUSY_FLAG = '0' then
            CONFIG_SET <= '1';
            etat <= MANAGE_SetCONFIG_END;
          end if;

        when MANAGE_SetCONFIG_END =>
          if CONFIG_CONFIRM_FLAG = '1' then
            BUSY <= '0';
            CONFIG_SET <= '0';
            CONFIG_DATA <= (others => '0');
            etat <= IDLE;
          end if;

        when others =>
          etat <= INIT;


      end case;
    end if;
  end process;

end Behavioral;
