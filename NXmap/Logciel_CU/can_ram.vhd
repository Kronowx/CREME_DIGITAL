----------------------------------------------------------------------------------
-- Company: ONERA Toulouse/DTIS
-- Engineer: guillaume.gourves@onera.fr
--
-- Create Date: 08.07.2021 15:43:33
-- Design Name:
-- Module Name: can_ram - Behavioral
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

library NX;
use NX.nxPackage.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity can_ram is
generic(N_ADDR : integer);
port (
    CLK : in std_logic;
    RESET_BAR : in std_logic;

    FREE : out std_logic;
    ADDR_START : in std_logic_vector(N_ADDR-1 downto 0);
    NBR_TRAME : in std_logic_vector(N_ADDR-1 downto 0);
    SEND : in std_logic;

    ADDR_RAM : out std_logic_vector(N_ADDR-1 downto 0);
    WE_RAM : out std_logic := '0';
    DO_RAM : out std_logic_vector(7 downto 0) := x"00";
    DI_RAM : in std_logic_vector(7 downto 0);

    RX : in std_logic;
    TX : out std_logic
    --la flemme de trainer bus_off_on, irq_on et clk_out de partout, les rajouter si besoin
);
end can_ram;

architecture Behavioral of can_ram is

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
    constant CAN_TIMING1_TSEG1			    : std_logic_vector(3 downto 0):= "1111";
    constant CAN_TIMING1_TSEG2			    : std_logic_vector(2 downto 0):= "010";
    constant CAN_TIMING1_SAM				: std_logic := '0';
    constant EXTENDED_MODE					: std_logic := '1';
    constant CAN_MODE_RESET					: std_logic := '1';


signal sig_ADDR_START : std_logic_vector(N_ADDR-1 downto 0);
signal sig_NBR_TRAME : std_logic_vector(N_ADDR-1 downto 0);

signal sig_START : std_logic := '0';
signal sig_RD_WR : std_logic := '0';
signal sig_REG_ADDR : std_logic_vector(7 downto 0) := x"00";
signal sig_REG_DATA : std_logic_vector(7 downto 0) := x"00";
signal sig_PORT_0_READ : std_logic_vector(7 downto 0);
signal sig_PORT_FREE : std_logic;


signal wait_N : unsigned(7 downto 0) := x"00";
signal transmitting : std_logic := '0';
signal buff_ADDR : std_logic_vector(7 downto 0);
signal buff_DATA : std_logic_vector(7 downto 0);

signal cnt_block : unsigned(N_ADDR-1 downto 0) := (others => '0');
signal cnt_trame : unsigned(3 downto 0) := x"0";
signal size_trame : unsigned(3 downto 0) := x"0";
signal cnt_addr_block : unsigned(N_ADDR-1 downto 0) := (others => '0');
signal cnt_addr_trame: unsigned(7 downto 0) := x"0A";

signal rst : std_logic;

component can_controller port(
     CLK : in std_logic;
        CLK_DRIVER : in std_logic;  --clk pour echanges wishbone
        RESET_BAR : in std_logic;   --reset sur 0

        START  : in    std_logic;                     --! Start pin for activate transmission
        RD_WR  : in    std_logic;                     --0 pour lire 1 pour ecrire
        REG_ADDR     : in    std_logic_vector(7 downto 0);  --adresse du registre � lire/ecrire
        REG_DATA     : in    std_logic_vector(7 downto 0);  --data � acrire
        PORT_0_READ : out std_logic_vector(7 downto 0);     --data lu
        PORT_FREE    : out   std_logic;                 --1 : on peut faire une lecture/ecriture
                                                        --0 : il faut attendre que celle en cours finisse
                                                        --voir commentaires dans process wishbone_driver pour subtilit�s

        RX : in std_logic;          --entr�e cot� bus CAN
        TX : out std_logic;         --sortie cot� bus CAN
        BUS_OFF_ON : out std_logic;     --signal defini can_top et non SJA1000, faut voir a quoi ils servent
        IRQ_ON : out std_logic;         --idem
        CLK_OUT : out std_logic         --sortie de la CLK apres passage dans le divider

);
end component;


type behavior_state is --les different etats du driver
  (
    IDLE,
    START_RESET,
    BUS_TIMING0,
    BUS_TIMING1,
    ACCEPT_CODE,
    ACCEPT_MASK,
    CLOCK_DIVIDE,
    NORMAL_MODE,
    END_RESET,
    END_RESET2,
    SETUP_TRANSMISSION,

    GET_ID1,
    GET_ID2_SIZE,

    TX_BUFFER_WRITE,
    START_TRANSMISSION,
    WAIT_TRANSMISSION,
    CATCH_STATUS,

    WRITE_STATE,

    ASK_RAM,
    CATCH_RAM,

    WAIT_N_CLOCK

  );
  signal etat, etat_futur : behavior_state;
begin

controller_1 : can_controller port map(
    CLK => CLK,
    CLK_DRIVER => CLK, --peut etre mettre une autre clock pour les driver wishbone
    RESET_BAR => rst,

    START => sig_START,
    RD_WR => sig_RD_WR,
    REG_ADDR => sig_REG_ADDR,
    REG_DATA => sig_REG_DATA,
    PORT_0_READ => sig_PORT_0_READ,
    PORT_FREE => sig_PORT_FREE,

    RX => RX,
    TX => TX,
    BUS_OFF_ON => OPEN,
    IRQ_ON => OPEN,
    CLK_OUT => OPEN
);


rst <= RESET_BAR;

process(CLK)

procedure set_write_buffer(constant proc_reg_addr : in std_logic_vector(7 downto 0) := x"00";constant proc_reg_data : in std_logic_vector(7 downto 0) := x"00") is
begin
        buff_ADDR <= proc_reg_addr;
        buff_DATA <= proc_reg_data;
        etat <= WRITE_STATE;
end set_write_buffer;


begin
 if(rising_edge(CLK)) then
    if (rst='0') then   --surtout pas RESET_BAR !!!!!
          FREE <= '0';
          sig_START <= '0';
          wait_N <= x"FF"; --des fois les etats START_RESET, BUS_TIMING etc... se deroulait pas
          etat <= WAIT_N_CLOCK; --je pense que c'est parce que on commencais l'ecriture instantanemant apres la fin du rest
          etat_futur <= START_RESET;  --en mettant en peu de delai entre sa marche (on peut peut etre le reduire)
    else
            case etat is

            when START_RESET =>
            set_write_buffer(SJA1000_ControlReg,RM_RR_Bit);
            etat_futur <=  BUS_TIMING0;

            when BUS_TIMING0 =>
            set_write_buffer(SJA1000_BusTiming0Reg,x"09"); --20 en prescaler
            etat_futur <= BUS_TIMING1;

            when BUS_TIMING1 =>
            set_write_buffer(SJA1000_BusTiming1Reg,x"34"); --10 can_clock pour 1 bit donc 1 bit tout les 200 coup de clock
            etat_futur <= ACCEPT_CODE;                     --clock a 25MHz => 125Kbit/s

            when ACCEPT_CODE =>
            set_write_buffer(SJA1000_AcceptCodeReg,x"E8");
            etat_futur <=  ACCEPT_MASK;

            when ACCEPT_MASK =>
            set_write_buffer(SJA1000_AcceptMaskReg,x"0F"); --seul les 4 premier bit de l'ID sont regard�
            etat_futur <= CLOCK_DIVIDE;

            when CLOCK_DIVIDE =>
            set_write_buffer(SJA1000_ClockDivideReg,ClkOff_Bit);
            etat_futur <= NORMAL_MODE;

            when NORMAL_MODE =>
            set_write_buffer(SJA1000_OutControlReg,NormalMode);
            etat_futur <= END_RESET;

            when END_RESET =>
            wait_N <= x"20"; --32 d'attente
            etat <= WAIT_N_CLOCK;
            etat_futur <= END_RESET2;

             when END_RESET2 =>
             set_write_buffer(SJA1000_ControlReg,(RM_RR_Bit xor RM_RR_Bit)); --on enleve le mode reset
             etat_futur <= SETUP_TRANSMISSION;

             when SETUP_TRANSMISSION =>
             set_write_buffer(SJA1000_ControlReg, RIE_Bit or TIE_Bit or EIE_Bit or DOIE_Bit); --on active toute les IRQ
             etat_futur <= IDLE;
             ----------------------------------------------------------------------
             when IDLE =>
                sig_START <= '0';
                FREE <= '1';
                if(SEND = '1') then
                    FREE <= '0';
                    cnt_block <= (others => '0');
                    cnt_trame <= x"0";
                    cnt_addr_trame <= x"0A";
                    cnt_addr_block <= unsigned(ADDR_START);
                    sig_ADDR_START <= ADDR_START;
                    sig_NBR_TRAME <= NBR_TRAME;
                    etat <= TX_BUFFER_WRITE;
                end if;

             when TX_BUFFER_WRITE => --TX_BUFFER_WRITE decide si c'est le moment de transmettre ou de lire le prochain octet
             --sa aurait �t� plus clair de faire une boucle dans une autre mais c'est pas grave, sa marche
             if(cnt_trame > 1 and cnt_trame-2 = size_trame) then --si on a deja eu les 2 octets d'ID/RTR/LEN et qu'on a atteint la fin de la trame actuelle
                etat <= START_TRANSMISSION; --on transmet la trame actuelle
             else
                etat <= ASK_RAM;    --sinon on recupere le prochain octet de cette trame
             end if;

            when START_TRANSMISSION =>
            cnt_trame <= x"0";  --on remet � 0 les compteurs de trame
            cnt_addr_trame <= x"0A";
            set_write_buffer(SJA1000_CommandReg,TR_Bit); --lance la transmission
            etat_futur <= WAIT_TRANSMISSION;
           ------------------------------------------------------------------------------------------------------------
            when WRITE_STATE => --on alterne entre TX_BUFFER_WRITE et WRITE_STATE quand on ecrit dans les registre
                if(sig_PORT_FREE = '1') then
                    sig_REG_ADDR <= buff_ADDR;
                    sig_REG_DATA <= buff_DATA;
                    sig_START <= '1';
                    sig_RD_WR <= '1';
                    wait_N <= x"02"; --les delais peuvent peut etre etre raccourcis à 1
                    etat <= WAIT_N_CLOCK;
                end if;


            when ASK_RAM =>
                WE_RAM <= '0';
                ADDR_RAM <= std_logic_vector(cnt_addr_block);
                wait_N <= x"00"; --on attend 2 coups d'horloge avant de lire la sortie de la ram
                etat <= WAIT_N_CLOCK;
                etat_futur <= CATCH_RAM;

            when CATCH_RAM =>
                if(cnt_trame = x"1") then --si c'est l'octet contenant la taille de la trame (le deuxieme)
                    size_trame <= unsigned(DI_RAM(3 downto 0)); --on recupere la taille de la trame
                end if;
                set_write_buffer(std_logic_vector(cnt_addr_trame),DI_RAM); --on ecrit la sortie de la ram dans les registre de T
                cnt_addr_block <= cnt_addr_block + 1;
                cnt_trame <= cnt_trame + 1;
                cnt_addr_trame <= cnt_addr_trame + 1;
                etat_futur <= TX_BUFFER_WRITE;


            when WAIT_TRANSMISSION =>       --on alterne entre WAIT_TRANSMISSION et CATCH_STATUS jusqu'a ce que la transmission soit finie
                if(sig_PORT_FREE = '1') then
                    sig_REG_ADDR <= SJA1000_StatusReg;
                    sig_START <= '1';
                    sig_RD_WR <= '0';
                    wait_N <= x"02";
                    etat <= WAIT_N_CLOCK;
                    etat_futur <= CATCH_STATUS;
                end if;

            when CATCH_STATUS =>
                if(sig_PORT_FREE = '1') then
                    if ((sig_PORT_0_READ and TCS_Bit) = TCS_Bit) then --si la transmission est finie
                        if(std_logic_vector(cnt_block+1) = sig_NBR_TRAME) then  --si c'etait la derniere trame
                            etat <= IDLE;   --on retourne en attente
                        else
                            etat <= TX_BUFFER_WRITE; --on passe a la prochaine trame
                        end if;
                        cnt_block <= cnt_block + 1;
                     else
                        wait_N <= x"C8"; --200 coups d'horloge pour transmettre un bit
                        etat <= WAIT_N_CLOCK;   --(sa sert a rien de regarder le status register 2000 fois par trame)
                        etat_futur <= WAIT_TRANSMISSION;
                    end if;
                end if;


            when WAIT_N_CLOCK =>
            if(wait_N = x"00") then
                etat <= etat_futur;
                sig_START <= '0'; --je me sert du WAIT_N_CLOCK pour remettre a 0 le sig_START
            else
                wait_N <= wait_N - 1;
            end if;

            when others =>

           end case;
         end if;
       end if;

end process;


end Behavioral;
