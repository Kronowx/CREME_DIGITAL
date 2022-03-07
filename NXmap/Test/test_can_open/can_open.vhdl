----------------------------------------------------------------------------------
-- Company: ONERA Toulouse
-- Engineer: guillaume.gourves@onera.fr
--
-- Create Date: 05.07.2021 11:07:56
-- Design Name:
-- Module Name: can_controler - Behavioral
-- Project Name: CREME
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

-- Librairies necessaiere
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity can_open is port
    (
      CLK                       : in  std_logic;
      RST                       : in  std_logic;
      CAN_OPEN_WAKEUP           : in  std_logic;
      CAN_OPEN_RAM_READ_ADRESS  : in  std_logic_vector(12 downto 0);
      DATA_OUTPUT_CMD_ARG       : out std_logic_vector(55 downto 0);
      FLAG_ReqTM                : out std_logic;
      FLAG_ReqTM_CONFIRM        : in  std_logic;
      FLAG_HeartBeat            : out std_logic;
      FLAG_DumpMEM              : out std_logic;
      FLAG_ReadCONFIG           : out std_logic;
      FLAG_SetCONFIG            : out std_logic;
      FLAG_SetTIME              : out std_logic;
      FLAG_MANAGER_BUSY         : in  std_logic
    );
end can_open;

architecture Behavioral of can_open is

  component can_operator port(
    CLK           : in std_logic;
    CLK_DRIVER    : in std_logic;  --clk pour echanges wishbone
    RESET_BAR     : in std_logic;   --reset sur 0

    PUSH_CAN_OPEN_TO_SEND : in std_logic;

    START         : in    std_logic;                     --! Start pin for activate transmission
    BUSY          : out   std_logic;                      --! Permet de confirmer la prise en compte de décodage de la trame CAN.
    RD_WR         : in    std_logic;                     --0 pour lire 1 pour ecrire
    REG_ADDR      : in    std_logic_vector(7 downto 0);  --adresse du registre � lire/ecrire
    REG_DATA      : in    std_logic_vector(7 downto 0);  --data � acrire
    PORT_0_READ   : out   std_logic_vector(7 downto 0);     --data lu
    PORT_FREE     : out   std_logic;                 --1 : on peut faire une lecture/ecriture
                                                    --0 : il faut attendre que celle en cours finisse
                                                    --voir commentaires dans process wishbone_driver pour subtilit�s
    RX          : in std_logic;          --entr�e cot� bus CAN
    TX          : out std_logic;         --sortie cot� bus CAN
    BUS_OFF_ON  : out std_logic;     --signal defini can_top et non SJA1000, faut voir a quoi ils servent
    IRQ_ON      : out std_logic;         --idem
    CLK_OUT     : out std_logic         --sortie de la CLK apres passage dans le divider               --1 : on peut faire une lecture/ecriture
  );
  end component;

  type can_open_state is --les different etats du driver
  (
    WAIT_ENABLE
    ,IDLE
    ,START_READ_ID_1
    ,END_READ_ID_1
    ,START_READ_ID_2
    ,END_READ_ID_2
    ,DECODE_ID
    ,SEND_TM_ORDER
    ,START_READ_DATA
    ,END_READ_DATA
    ,END_READ_DATA
    ,MANAGER_CONFIRM_ORDER
    ,CONTROLER_CAN_CONFIRM_ORDER
  );
  signal etat, etat_futur : can_open_state;

  signal start_machine : std_logic := "0";
  signal sig_CAN_OPEN_RAM_READ_ADRESS : std_logic_vector(12 downto 0);
  signal sig_CAN_OPEN_RAM_READ_ADRESS_POINTER : std_logic_vector(12 downto 0);

  signal CANOPEN_COB_ID         : std_logic_vector(10 downto 0);
  signal CANOPEN_FUNCTION_CODE  : std_logic_vector(3 downto 0);
  signal CANOPEN_NODE_ID        : std_logic_vector(6 downto 0);

  constant ONERAD_NODE_ID : std_logic_vector(6 downto 0) := x"00";

  -- signaux pour piloter la ram de reception
  signal sig_RAM_RX_CLK	        :   std_logic;
  signal sig_RAM_RX_DO	        :   std_logic_vector(7 downto 0);
  signal sig_RAM_RX_AD	        :   std_logic_vector(12 downto 0);
  signal sig_RAM_RX_WE	        :   std_logic;
  signal indice_ram_rx_address  :   integer := "8";

  signal trame_CAN_64               : std_logic_vector(63 downto 0);
  signal trame_CAN_CODE_SERVICE     : std_logic_vector(7 downto 0);
  signal trame_CAN_CODE_ARG1        : std_logic_vector(7 downto 0);
  signal trame_CAN_CODE_ARG2        : std_logic_vector(7 downto 0);
  signal trame_CAN_CODE_ARG3        : std_logic_vector(7 downto 0);
  signal trame_CAN_CODE_ARG4        : std_logic_vector(7 downto 0);
  signal trame_CAN_CODE_ARG5        : std_logic_vector(7 downto 0);
  signal trame_CAN_CODE_ARG6        : std_logic_vector(7 downto 0);
  signal trame_CAN_CODE_ARG7        : std_logic_vector(7 downto 0);

begin

  CANOPEN_FUNCTION_CODE <= CANOPEN_COB_ID(10 downto 7);
  CANOPEN_NODE_ID <= CANOPEN_COB_ID(6 downto 0);

  trame_CAN_CODE_SERVICE <= trame_CAN_64(63 downto 56);
  trame_CAN_CODE_ARG1 <= trame_CAN_64(55 downto 48);
  trame_CAN_CODE_ARG2 <= trame_CAN_64(47 downto 40);
  trame_CAN_CODE_ARG3 <= trame_CAN_64(39 downto 32);
  trame_CAN_CODE_ARG4 <= trame_CAN_64(31 downto 24);
  trame_CAN_CODE_ARG5 <= trame_CAN_64(23 downto 16);
  trame_CAN_CODE_ARG6 <= trame_CAN_64(15 downto 8);
  trame_CAN_CODE_ARG7 <= trame_CAN_64(7 downto 0);

  DATA_OUTPUT_CMD_ARG <= trame_CAN_64(55 downto 0);

  process (CLK)
  procedure read_ram_rx
  (
      constant read_ram_rx_addr : in std_logic_vector(7 downto 0) := x"00";
  )
  begin
      sig_RAM_RX_AD <= write_ram_rx_addr;
      sig_RAM_RX_WE <= '1';
  end read_ram_rx;
  begin
    if rising_edge(CLK) then
      if RST = '1' then
        BUSY <= '0';
        etat <= IDLE;
      else
        case etat is

          when IDLE =>
            if START = '1' then
              BUSY <= '1'; -- On indique a la fois que l'on a bien pirs en charge le decodage + que le module est dorenavent.
              sig_CAN_OPEN_RAM_READ_ADRESS_POINTER <= CAN_OPEN_RAM_READ_ADRESS;
              etat <=  START_READ_ID_1;
            end if;

          when START_READ_ID_1 => -- On va interroger la ram pour traiter les deux premiers mots CAN
            read_ram_rx(sig_CAN_OPEN_RAM_READ_ADRESS_POINTER);
            etat <= WAIT_TIME;
            etat_futur <= END_READ_ID_1;

          when END_READ_ID_1 => -- On va interroger la ram pour traiter les deux premiers mots CAN
            sig_CAN_OPEN_RAM_READ_ADRESS_POINTER <= std_logic_vector(unsigned(sig_CAN_OPEN_RAM_READ_ADRESS_POINTER) + 1); -- On incremente le vecteur.
            CANOPEN_COB_ID(10 downto 3) <= sig_RAM_RX_DO;
            etat <= START_READ_ID_2;

          when START_READ_ID_2 =>
            read_ram_rx(sig_CAN_OPEN_RAM_READ_ADRESS_POINTER);
            etat <= WAIT_TIME;
            etat_futur <= DECODE_ID;

          when END_READ_ID_2 => -- On va interroger la ram pour traiter les deux premiers mots CAN
            sig_CAN_OPEN_RAM_READ_ADRESS_POINTER <= std_logic_vector(unsigned(sig_CAN_OPEN_RAM_READ_ADRESS_POINTER) + 1); -- On incremente le vecteur.
            CANOPEN_COB_ID(2 downto 0) <= sig_RAM_RX_DO;
            etat <= DECODE_ID;

          when DECODE_ID =>
            if CANOPEN_NODE_ID = ONERAD_NODE_ID then  -- On verifie que le paquet est bien pour la charge utile

              case CANOPEN_FUNCTION_CODE is

              when x"4" => -- TPD01 Affectes aux demandes TM (On peut envoyer direct une demande transmission pour prendre le moins de tems possible).
              etat <= START_READ_DATA;

              when x"6" => -- TPD02 Affectes aux TC parametrage
              etat <= START_READ_DATA;

              when others => -- On ignore le paquet
              BUSY <= '0';
              etat <= IDLE;

              end case;

            else -- sinon on ignore le paquet
              BUSY <= '0';
              etat <= IDLE;
            end if;

          when SEND_TM_ORDER =>
          if FLAG_ReqTM_CONFIRM = '1' then
            etat <= IDLE;
            FLAG_ReqTM <= '0';
            BUSY <= '0';
          end if;

          when START_READ_DATA =>
          if indice_ram_rx_address > "0" then
          read_ram_rx(sig_CAN_OPEN_RAM_READ_ADRESS_POINTER);
          indice_ram_rx_address = indice_ram_rx_address - 1;
          etat <= WAIT_TIME;
          etat_futur <= END_READ_DATA;
          else
            etat <= DECODE_DATA;
          end if;

          when END_READ_DATA =>
          sig_CAN_OPEN_RAM_READ_ADRESS_POINTER <= std_logic_vector(unsigned(sig_CAN_OPEN_RAM_READ_ADRESS_POINTER) + 1); -- On incremente le vecteur.
          trame_CAN_64((7+(indice_ram_rx_address*8)) downto (0+(indice_ram_rx_address*8))) <= sig_RAM_RX_DO;
          etat <= START_READ_DATA;


          when DECODE_DATA =>
            case trame_CAN_CODE_SERVICE is

              when x"01" => -- SetTIME demande.
                if FLAG_MANAGER_BUSY = '0' then -- Le Manager est disponible pour une nouvelle requete
                  FLAG_SetTIME <= '1';
                  trame_CAN_CODE_SERVICE <= trame_CAN_64(63 downto 56);
                  trame_CAN_CODE_ARG1 <= trame_CAN_64(55 downto 48);
                  trame_CAN_CODE_ARG2 <= trame_CAN_64(47 downto 40);
                  trame_CAN_CODE_ARG3 <= trame_CAN_64(39 downto 32);
                  trame_CAN_CODE_ARG4 <= trame_CAN_64(31 downto 24);
                  trame_CAN_CODE_ARG5 <= trame_CAN_64(23 downto 16);
                  trame_CAN_CODE_ARG6 <= trame_CAN_64(15 downto 8);
                  trame_CAN_CODE_ARG7 <= trame_CAN_64(7 downto 0);
                  etat <= MANAGER_CONFIRM_ORDER;
                end if;

              when x"02" => -- SetCONFIG demande.
              if FLAG_MANAGER_BUSY = '0' then -- Le Manager est disponible pour une nouvelle requete
                FLAG_SetCONFIG <= '1';
                etat <= MANAGER_CONFIRM_ORDER;
              end if;

              when x"10" => -- ReqTM demande.
              if FLAG_ReqTM_CONFIRM = '0' then -- Le Manager est disponible pour une nouvelle requete
                FLAG_ReqTM <= '1';
                etat <= CONTROLER_CAN_CONFIRM_ORDER;
              end if;

              when x"20" => -- ReadCONFIG.
              if FLAG_MANAGER_BUSY = '0' then -- Le Manager est disponible pour une nouvelle requete
                FLAG_ReadCONFIG <= '1';
                etat <= MANAGER_CONFIRM_ORDER;
              end if;

              when x"40" => -- DumpMEM.
              if FLAG_MANAGER_BUSY = '0' then -- Le Manager est disponible pour une nouvelle requete
                FLAG_DumpMEM <= '1';
                etat <= MANAGER_CONFIRM_ORDER;
              end if;

              when x"80" => -- RESET demande.
              if FLAG_MANAGER_BUSY = '0' then -- Le Manager est disponible pour une nouvelle requete
                FLAG_SetTIME <= '1';
                etat <= MANAGER_CONFIRM_ORDER;
              end if;

              when others => -- On ignore le paquet
              BUSY <= '0';
              etat <= IDLE;

            end case;

          when MANAGER_CONFIRM_ORDER =>
            if FLAG_MANAGER_BUSY  =  '1' then
              FLAG_HeartBeat      <= '0';
              FLAG_DumpMEM        <= '0';
              FLAG_ReadCONFIG     <= '0';
              FLAG_SetCONFIG      <= '0';
              FLAG_SetTIME        <= '0';
              trame_CAN_64        <= (others => '0');
              BUSY <= '0';
              etat <= IDLE;
            end if;

          when CONTROLER_CAN_CONFIRM_ORDER =>
            if FLAG_ReqTM_CONFIRM = '1' then
              FLAG_ReqTM <= '0';
              BUSY <= '0';
              etat <= IDLE;
            end if;

         -- Attente
          when WAIT_TIME =>
            etat <= etat_futur;


        end case;
      end if;
    end if;
  end process;



end Behavioral;
