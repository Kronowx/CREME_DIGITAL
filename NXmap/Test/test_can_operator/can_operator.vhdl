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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity can_operator is port
    (
      CLK              : in  std_logic;
      RST              : in  std_logic;
      DI_RAM_TX	       : in  std_logic_vector(7 downto 0);
      DO_RAM_TX	       : out std_logic_vector(7 downto 0);
    	AD_RAM_TX	       : in  std_logic_vector(12 downto 0);
    	WE_RAM_TX	       : in  std_logic;
      DI_RAM_RX	       : in  std_logic_vector(7 downto 0);
      DO_RAM_RX	       : out std_logic_vector(7 downto 0);
    	AD_RAM_RX	       : in  std_logic_vector(12 downto 0);
    	WE_RAM_RX        : in  std_logic;
      CAN_OPEN_WAKEUP  : out std_logic
    );

end can_operator;

architecture Behavioral of can_operator is

  constant SJA1000_ClearReg         : std_logic_vector(7 downto 0):= x"00";

  --- Address and bit definitions for the Mode & Control Register
  constant SJA1000_ControlReg         : std_logic_vector(7 downto 0):= x"00";
    constant RM_RR_Bit  : std_logic_vector(7 downto 0):= x"01"; --reset mode (request) bit.
    constant RIE_Bit    : std_logic_vector(7 downto 0):= x"02"; --Receive Interrupt enable bit.
    constant TIE_Bit    : std_logic_vector(7 downto 0):= x"04"; --Transmit Interrupt enable bit.
    constant EIE_Bit    : std_logic_vector(7 downto 0):= x"08"; --Error Interrupt enable bit.
    constant DOIE_Bit   : std_logic_vector(7 downto 0):= x"10"; --Overrun Interrupt enable bit.

  -- Address and bit definitions for the Command Register
  constant SJA1000_CommandReg             : std_logic_vector(7 downto 0):= x"01";
    constant TR_Bit   : std_logic_vector(7 downto 0):= x"01"; --transmission request bit.
    constant AT_Bit   : std_logic_vector(7 downto 0):= x"02"; --abort transmission bit.
    constant RRB_Bit  : std_logic_vector(7 downto 0):= x"04"; --release receive buffer bit.
    constant CDO_Bit  : std_logic_vector(7 downto 0):= x"08"; --clear data overrun bit.
    constant GTS_Bit  : std_logic_vector(7 downto 0):= x"10"; --goto sleep bit (BasicCAN mode).

  -- Address and bit definitions for the Status Register
  constant SJA1000_StatusReg            : std_logic_vector(7 downto 0):= x"02";
    constant RBS_Bit  : std_logic_vector(7 downto 0):= x"01"; --receive buffer status bit.
    constant DOS_Bit  : std_logic_vector(7 downto 0):= x"02"; --data overrun status bit.
    constant TBS_Bit  : std_logic_vector(7 downto 0):= x"04"; --transmit buffer status bit.
    constant TCS_Bit  : std_logic_vector(7 downto 0):= x"08"; --transmission complete status bit.
    constant RS_Bit   : std_logic_vector(7 downto 0):= x"10"; --receive status bit.
    constant TS_Bit   : std_logic_vector(7 downto 0):= x"20"; --transmit status bit.
    constant ES_Bit   : std_logic_vector(7 downto 0):= x"40"; --error status bit.
    constant BS_Bit   : std_logic_vector(7 downto 0):= x"80"; --bus status bit.

  --- Address and bit definitions for the Interrupt Register
  constant SJA1000_InterruptReg         : std_logic_vector(7 downto 0):= x"03";
    constant RI_Bit     : std_logic_vector(7 downto 0):= x"01"; --receive interrupt bit.
    constant TI_Bit     : std_logic_vector(7 downto 0):= x"02"; --transmit interrupt bit.
    constant EI_Bit     : std_logic_vector(7 downto 0):= x"04"; --error warning interrupt bit.
    constant DOI_Bit    : std_logic_vector(7 downto 0):= x"08"; --data overrun interrupt bit.
    constant WUI_Bit    : std_logic_vector(7 downto 0):= x"10"; --wake-up interrupt bit.

  --- Address definitions of Acceptance Code & Mask Registers
  constant SJA1000_AcceptCodeReg 	        : std_logic_vector(7 downto 0):= x"04";
  constant SJA1000_AcceptMaskReg 	        : std_logic_vector(7 downto 0):= x"05";

  --- Address and bit definitions for the Bus Timing Registers
  constant SJA1000_BusTiming0Reg 	: std_logic_vector(7 downto 0):= x"06";
  constant SJA1000_BusTiming1Reg  : std_logic_vector(7 downto 0):= x"07";
    constant SAM_Bit                : std_logic_vector(7 downto 0):= x"80"; --sample mode bit 1 == the bus is sampled 3 times or 0 == the bus is sampled once.

  --- Address and bit definitions for the Output Control Register
  constant SJA1000_OutControlReg			    : std_logic_vector(7 downto 0):= x"08";
    --OCMODE1, OCMODE0.
    constant BiPhaseMode  : std_logic_vector(7 downto 0):= x"00"; --bi-phase output mode.
    constant NormalMode   : std_logic_vector(7 downto 0):= x"02"; --normal output mode.
    constant ClkOutMode   : std_logic_vector(7 downto 0):= x"03"; --clock output mode.
    -- output pin configuration for TX1.
    constant OCPOL1_Bit   : std_logic_vector(7 downto 0):= x"20"; --output polarity control bit.
    constant Tx1Float     : std_logic_vector(7 downto 0):= x"00"; --configured as float.
    constant Tx1PullDn    : std_logic_vector(7 downto 0):= x"40"; --configured as pull-down.
    constant Tx1PullUp    : std_logic_vector(7 downto 0):= x"80"; --configured as pull-up.
    constant Tx1PshPull   : std_logic_vector(7 downto 0):= x"C0"; --configured as push/pull.
    -- output pin configuration for TX0.
    constant OCPOL0_Bit   : std_logic_vector(7 downto 0):= x"04"; --output polarity control bit.
    constant Tx0Float     : std_logic_vector(7 downto 0):= x"00"; --configured as float.
    constant Tx0PullDn    : std_logic_vector(7 downto 0):= x"08"; --configured as pull-down.
    constant Tx0PullUp    : std_logic_vector(7 downto 0):= x"10"; --configured as pull-up.
    constant Tx0PshPull   : std_logic_vector(7 downto 0):= x"18"; --configured as push/pull.

  -- Test
  constant SJA1000_TestReg    : std_logic_vector(7 downto 0):= x"09";

  --- Address definitions of the Tx-Buffer
  constant SJA1000_TxBuffer1   : std_logic_vector(7 downto 0):= x"0A";
  constant SJA1000_TxBuffer2   : std_logic_vector(7 downto 0):= x"0B";
  constant SJA1000_TxBuffer3   : std_logic_vector(7 downto 0):= x"0C";
  constant SJA1000_TxBuffer4   : std_logic_vector(7 downto 0):= x"0D";
  constant SJA1000_TxBuffer5   : std_logic_vector(7 downto 0):= x"0E";
  constant SJA1000_TxBuffer6   : std_logic_vector(7 downto 0):= x"0F";
  constant SJA1000_TxBuffer7   : std_logic_vector(7 downto 0):= x"10";
  constant SJA1000_TxBuffer8 	 : std_logic_vector(7 downto 0):= x"11";
  constant SJA1000_TxBuffer9 	 : std_logic_vector(7 downto 0):= x"12";
  constant SJA1000_TxBuffer10  : std_logic_vector(7 downto 0):= x"13";

  --- Address definitions of the Rx-Buffer
  constant SJA1000_RxBuffer1   : std_logic_vector(7 downto 0):= x"14";
  constant SJA1000_RxBuffer2   : std_logic_vector(7 downto 0):= x"15";
  constant SJA1000_RxBuffer3   : std_logic_vector(7 downto 0):= x"16";
  constant SJA1000_RxBuffer4   : std_logic_vector(7 downto 0):= x"17";
  constant SJA1000_RxBuffer5   : std_logic_vector(7 downto 0):= x"18";
  constant SJA1000_RxBuffer6   : std_logic_vector(7 downto 0):= x"19";
  constant SJA1000_RxBuffer7   : std_logic_vector(7 downto 0):= x"1A";
  constant SJA1000_RxBuffer8   : std_logic_vector(7 downto 0):= x"1B";
  constant SJA1000_RxBuffer9   : std_logic_vector(7 downto 0):= x"1C";
  constant SJA1000_RxBuffer10  : std_logic_vector(7 downto 0):= x"1D";

  -- Address and bit definitions for the Clock Divider Register
  constant SJA1000_ClockDivideReg					: std_logic_vector(7 downto 0):= x"1F";
    constant DivBy1       : std_logic_vector(7 downto 0):= x"07"; --CLKOUT = oscillator frequency.
    constant DivBy2       : std_logic_vector(7 downto 0):= x"00"; --CLKOUT = 1/2 oscillator frequency.
    constant ClkOff_Bit   : std_logic_vector(7 downto 0):= x"08"; --clock off bit,  control of the CLK OUT pin.
    constant RXINTEN_Bit  : std_logic_vector(7 downto 0):= x"20"; --pin TX1 used for receive interrupt.
    constant CBP_Bit      : std_logic_vector(7 downto 0):= x"40"; --CAN comparator bypass control bit.
    constant CANMode_Bit  : std_logic_vector(7 downto 0):= x"80"; --CAN mode definition bit (BasicCAN or PeliCAN).

  -- Initialisation parameters
  constant CAN_TIMING0_BRP				: std_logic_vector(5 downto 0):= "000011";
  constant CAN_TIMING0_SJW				: std_logic_vector(1 downto 0):= "01";
  constant CAN_TIMING1_TSEG1	    : std_logic_vector(3 downto 0):= "1111";
  constant CAN_TIMING1_TSEG2	    : std_logic_vector(2 downto 0):= "010";
  constant CAN_TIMING1_SAM				: std_logic := '0';
  constant EXTENDED_MODE					: std_logic := '1';
  constant CAN_MODE_RESET					: std_logic := '1';

  signal sig_TX_o_T       : std_logic;
  signal sig_TX_o_R       : std_logic;
  signal sig_START        : std_logic;                     --! Start pin for activate transmission
  signal sig_RD_WR        : std_logic;                     --! 0 for read 1 for write
  signal sig_REG_ADDR     : std_logic_vector(N_ADDR-1 downto 0);  --! vecteur pour l'adresse
  signal sig_REG_DATA     : std_logic_vector(N_DATA-1 downto 0);  --! vecteur pour les donn�e a ecrire
  signal sig_PORT_0_READ  : std_logic_vector(N_DATA-1 downto 0);     --vecteur pour les donn�e � lire
  signal sig_PORT_FREE    : std_logic;                     --! indique si la dernier acc�s est termin�
  signal sig_WB_DAT_I     : std_logic_vector(N_DATA-1 downto 0); --signaux wishbone
  signal sig_WB_DAT_O     : std_logic_vector(N_DATA-1 downto 0);
  signal sig_WB_CYC_O     : std_logic;
  signal sig_WB_STB_O     : std_logic;
  signal sig_WB_ADR_O     : std_logic_vector(N_ADDR-1 downto 0);
  signal sig_WB_WE_O      : std_logic;
  signal sig_WB_ACK_I     : std_logic;
  signal sig_IRQ_ON       : std_logic;
  signal cnt_trame        : integer range 0 to 10 := 0;

  -- signaux pour piloter la ram de transmission
  signal sig_RAM_TX_CLK	   :   std_logic;
  signal sig_RAM_TX_DI	   :   std_logic_vector(7 downto 0);
  signal sig_RAM_TX_AD	   :   std_logic_vector(12 downto 0);
  signal sig_RAM_TX_WE	   :   integer range 0 to 10 := 0;

  -- signaux pour piloter la ram de reception
  signal sig_RAM_RX_CLK	        :   std_logic;
  signal sig_RAM_RX_DO	        :   std_logic_vector(7 downto 0);
  signal sig_RAM_RX_AD	        :   std_logic_vector(12 downto 0);
  signal sig_RAM_RX_WE	        :   std_logic;
  signal indice_ram_rx_address  :   integer;

  -- signaux pour le signalement CANOPEN :
  signal indice_trame_can_open  : integer;

  -- signaux permettant de controler le nombre de tm envoyé par rapport à ceux à envoyer
  signal indice_trame_can_open_to_send  : integer;
  signal indice_trame_can_open_send     : integer;
  signal count_trame_canopen_send       : integer := "0";
  signal count_trame_byte_send          : integer := "0";
  signal ram_tx_addr_pointer            : std_logic_vector(7 downto 0) := x"00";


  component can_controller port(
    CLK           : in std_logic;
    CLK_DRIVER    : in std_logic;  --clk pour echanges wishbone
    RESET_BAR     : in std_logic;   --reset sur 0

    PUSH_CAN_OPEN_TO_SEND : in std_logic;

    START         : in    std_logic;                     --! Start pin for activate transmission
    RD_WR         : in    std_logic;                     --0 pour lire 1 pour ecrire
    REG_ADDR      : in    std_logic_vector(7 downto 0);  --adresse du registre � lire/ecrire
    REG_DATA      : in    std_logic_vector(7 downto 0);  --data � acrire
    PORT_0_READ   : out std_logic_vector(7 downto 0);     --data lu
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

  component ram
  port(
    CLK	:   in std_logic;
  	DI	:   in std_logic_vector(7 downto 0);
  	DO	:   out std_logic_vector(7 downto 0);
  	AD	:   in std_logic_vector(12 downto 0);
  	WE	:   in std_logic
  );
  end component;

  type behavior_state is --les different etats du driver
  (
    WAIT_ENABLE,
    IDLE,
    WAIT_TIME,
    READ_IRQ_REGISTER,
    READ_RECEIVE_REGISTER,
    READ_RECEIVE_REGISTER_RESULT_AND_WRITE_RAM,
    READ_RECEIVE_REGISTER_RESULT_AND_WRITE_RAM_END,
    READ_RAM,
    WAIT_IRQ,
    BUS_REQUEST_READ,
    WAIT_FOR_ACK
  );
  signal etat, etat_futur : behavior_state;

begin

  can_controller_1 : can_controller port map(
    CLK => CLK,
    CLK_DRIVER => CLK,
    RESET_BAR => rst,
    START => sig_START,
    RD_WR => sig_RD_WR,
    REG_ADDR => sig_REG_ADDR,
    REG_DATA => sig_REG_DATA,
    PORT_0_READ => sig_PORT_0_READ,
    PORT_FREE => sig_PORT_FREE,
    RX => sig_RX,
    TX => sig_TX,
    BUS_OFF_ON => sig_BUS_OFF_ON,
    IRQ_ON => sig_IRQ_ON,
    CLK_OUT => sig_CLK_OUT
  );

  raw_tx : ram port map(
    CLK	=>   sig_RAM_TX_CLK,
    DI	=>   sig_RAM_TX_DI,
    DO	=>   sig_RAM_TX_DO,
    AD	=>   sig_RAM_TX_AD,
    WE	=>   sig_RAM_TX_WE
  );

  raw_rx : ram port map(
    CLK	=>   sig_RAM_RX_CLK,
    DI	=>   sig_RAM_RX_DI,
    DO	=>   sig_RAM_RX_DO,
    AD	=>   sig_RAM_RX_AD,
    WE	=>   sig_RAM_RX_WE
  );

PROCESS_SURVEY : process (CLK)

  procedure set_read_buffer
  (
    constant proc_reg_addr : in std_logic_vector(7 downto 0) := x"00"
  ) is
  begin
    if(sig_PORT_FREE = '1') then
        sig_REG_ADDR <= proc_reg_addr;
        sig_START <= '1';
        sig_RD_WR <= '0';
        etat <= etat_futur;
    end if;
  end set_read_buffer;

  --procedure pour eviter d'ecrire plein de fois les memes 3 lignes
  procedure set_write_buffer
  (
    constant proc_reg_addr : in std_logic_vector(7 downto 0) := x"00";
    proc_reg_data : in std_logic_vector(7 downto 0) := x"00"
  ) is
  begin
          buff_ADDR <= proc_reg_addr;
          buff_DATA <= proc_reg_data;
          etat <= WRITE_STATE;
  end set_write_buffer;

  procedure write_ram_rx
  (
      constant write_ram_rx_addr : in std_logic_vector(7 downto 0) := x"00";
      constant write_ram_rx_data : in std_logic_vector(7 downto 0) := x"00"
  )
  begin
      sig_RAM_RX_AD <= write_ram_rx_addr;
      sig_RAM_RX_DI <= write_ram_rx_data;
      sig_RAM_RX_WE <= '1';
  end write_ram_rx;

  procedure write_ram_rx_end()
  begin
      sig_RAM_RX_WE <= '0';
  end write_ram_rx_end;

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
    if RST = '0' then
      WB_DAT_O <= (others => 'Z');
      WB_CYC_O <='0';
      WB_STB_O <= '0';
      WB_ADR_O <= (others => 'Z');
      WB_WE_O <= '0';
      PORT_FREE <= '0';
      etat <= WAIT_ENABLE;
    else
      case etat is

        -- Initialisation
        when WAIT_ENABLE => -- On attend un évènement autorisant le démarrage du process

        when START_RESET =>
          set_write_buffer(SJA1000_ControlReg,RM_RR_Bit); --activation du mode reset
          etat_futur <=  BUS_TIMING0;

        when BUS_TIMING0 =>
          set_write_buffer(SJA1000_BusTiming0Reg,x"09"); --20 en prescaler
          etat_futur <= BUS_TIMING1;

        when BUS_TIMING1 =>
          set_write_buffer(SJA1000_BusTiming1Reg,x"34"); --10 can_clock pour 1 bit donc 1 bit tout les 200 coup de clock
          etat_futur <= ACCEPT_CODE;                     --clock a 100MHz => 125Kbit/s

        when ACCEPT_CODE =>
          set_write_buffer(SJA1000_AcceptCodeReg,x"78");
          etat_futur <=  ACCEPT_MASK;

        when ACCEPT_MASK =>
          set_write_buffer(SJA1000_AcceptMaskReg,x"0F"); --seul les 4premiers bits de acceptCodeReg compte
          etat_futur <= CLOCK_DIVIDE;                     --donc la trame doit commencer par "7"

        when CLOCK_DIVIDE =>
          set_write_buffer(SJA1000_ClockDivideReg,ClkOff_Bit);
          etat_futur <= NORMAL_MODE;

        when NORMAL_MODE =>
          set_write_buffer(SJA1000_OutControlReg,NormalMode);
          etat_futur <= END_RESET;

        when END_RESET =>
          wait_N <= x"20"; --32 d'attente apres le reset
          etat <= WAIT_N_CLOCK;
          etat_futur <= END_RESET2;

         when END_RESET2 =>
          set_write_buffer(SJA1000_ControlReg,(RM_RR_Bit xor RM_RR_Bit)); --on enleve mode reset
          etat_futur <= SETUP_TRANSMISSION;

         when SETUP_TRANSMISSION =>
           set_write_buffer(SJA1000_ControlReg, RIE_Bit or TIE_Bit or EIE_Bit or DOIE_Bit); --je sais pas vraiment
           etat_futur <= IDLE;

        when IDLE => -- Etat repos

        -- Détection de l'IRQ puis traitement
        when WAIT_IRQ =>
          if IRQ_ON = '1' then
             etat_futur <= READ_IRQ_REGISTER;
             set_read_buffer(SJA1000_InterruptReg);
          end if;

        when READ_IRQ_REGISTER => -- Il y a une donnée à lire
          if sig_PORT_0_READ AND RI_Bit then      -- Une lecture est à faire (prioritaire)
            etat <= READ_RECEIVE_REGISTER;
          elsif sig_PORT_0_READ AND TI_Bit then     -- Une écriture est à faire (secondaire)
            etat <= ASK_TRANSMIT_REGISTER;
          else                             -- Il y a un pépin
            -- Il faut clearer les autres flags
            etat <= WAIT_IRQ;
          end if

        -- RECEPTION TC
        when READ_RECEIVE_REGISTER => -- On parcours les registre de réceptions
          if(cnt_trame = 10) then --si on a fini de lire
            cnt_trame <= 0;
            cnt_addr_trame <= x"0A"; --dans les registre de transmission
            etat <= SIGNAL_CANOPEN; -- on le signal au module de décodage CANOPEN
          else
            set_read_buffer(std_logic_vector(cnt_addr_trame));
            etat_futur <= READ_RECEIVE_REGISTER_RESULT_AND_WRITE_RAM;
          end if;

        when READ_RECEIVE_REGISTER_RESULT_AND_WRITE_RAM =>
          write_ram_rx(indice_ram_rx_address,sig_PORT_0_READ);
          etat <= WAIT_TIME;
          etat_future <= READ_RECEIVE_REGISTER_RESULT_AND_WRITE_RAM_END;

        when READ_RECEIVE_REGISTER_RESULT_AND_WRITE_RAM_END =>
          write_ram_rx_end();
          indice_ram_rx_address <= indice_ram_rx_address + 1;
          etat <= READ_RECEIVE_REGISTER;

        when SIGNAL_CANOPEN =>
          indice_trame_can_open <= indice_trame_can_open + 1;
          etat <= WAIT_IRQ

        -- EMISSION TM
        when ASK_TRANSMIT_REGISTER =>
          if (indice_trame_can_open_to_send > indice_trame_can_open_to_send) then
            etat <= SEND_CCSDS_TRAME;
          else
            etat <= WAIT_IRQ
          end if;

        when SEND_CCSDS_TRAME =>
          if(count_trame_canopen_send = 8) then --si on a fini de lire
            etat <= SIGNAL_CANOPEN; -- on le signal au module de décodage CANOPEN
            count_trame_canopen_send = 0;
          else
            etat <= SEND_CAN_OPEN_TRAME;
          end if;

        when SEND_CCSDS_TRAME =>
          if(count_trame_byte_send = 10) then --si on a fini de lire
            etat        <=  WAIT_IRQ_TRANSMIT;
            count_trame_canopen_send = count_trame_canopen_send + 1;
          else
            read_ram_rx(ram_tx_addr_pointer + count_trame_canopen_send + count_trame_byte_send);
            etat        <=  WAIT_TIME
            etat_futur  <=  TX_BUFFER_WRITE; -- on le signal au module de décodage CANOPEN
          end if;

        when TX_BUFFER_WRITE =>
        if(cnt_trame = 10) then
           etat <= START_TRANSMISSION; --lorque que l'on a ecrit toute la trame
        else
           set_write_buffer(std_logic_vector(cnt_addr_trame),sig_RAM_RX_DO); --TRAME(79-cnt_trame*8 downto 79 - cnt_trame*8 - 7) pas syntethisable sur NanoXplore
           next_byte_trame;
           etat_futur <= TX_BUFFER_WRITE; --tant qu'on a pas fait les 10 registre on revient sur l'etat apres le WRITE_STATE avec des cnt et byte_trame different
           cnt_trame <= cnt_trame + 1;
           cnt_addr_trame <= cnt_addr_trame + 1;
        end if;

       when START_TRANSMISSION =>
         set_write_buffer(SJA1000_CommandReg,TR_Bit); --lance la transmission
         etat_futur <= WAIT_IRQ_TRANSMIT; --(en soit il faudrait attendre que la transmission finisse avant de retourner dans IDLE)

        -- Attente
        when WAIT_TIME =>
          etat <= etat_futur;

        when WAIT_IRQ_TRANSMIT =>


        when others =>

      end case;
    end if;
  end if;
end process;


end Behavioral;
