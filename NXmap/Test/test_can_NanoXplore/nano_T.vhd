----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 18.06.2021 15:59:44
-- Design Name:
-- Module Name: test_can_bouton - Behavioral
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

entity nano_T is
    port(
    CLK : in std_logic;
    RST_CAN : in std_logic;

    BOUTON : in std_logic;

    TX_i : in std_logic; --le TX_i n'est pas vraiment un RX, c'est juste le TX de l'autre controlleur
    TX_o : out std_logic --le TX_o est bien le TX  (le tranceiver est emulé grace à TX_i et TX_o)
    );
end entity;

architecture Behavioral of nano_T is

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

signal TRAME : std_logic_vector(79 downto 0) := x"7A2801025468E3CDA2F1"; --la trame a envoier
signal byte_trame : std_logic_vector(7 downto 0) := x"7A"; --on ecrit la trame dans les registres par morceaux de 8 bits


signal sig_TX : std_logic; --signaux "après tranceiver"
signal sig_RX : std_logic;

signal rst : std_logic; --signal reset sur low skew (voir explication dans rapport)
signal sig_START  : std_logic := '0';
signal sig_RD_WR  :  std_logic := '0';
signal sig_REG_ADDR     :  std_logic_vector(7 downto 0);
signal sig_REG_DATA     : std_logic_vector(7 downto 0);
signal sig_PORT_0_READ : std_logic_vector(7 downto 0);
signal sig_PORT_FREE    : std_logic;
signal sig_BUS_OFF_ON : std_logic;     --signal defini can_top et non SJA1000, faut voir a quoi ils servent
signal sig_IRQ_ON : std_logic;         --idem
signal sig_CLK_OUT : std_logic;         --sortie de la CLK apres passage dans le divider

signal wait_N : unsigned(7 downto 0) := x"00"; --variable stockant le nombre de periode d'horloge d'attente
signal transmitting : std_logic := '0'; --pour eviter de faire 600 transmissions sur un seul appui de bouton
signal buff_ADDR : std_logic_vector(7 downto 0); --variables tampons pour addresse et données à ecrire dans registres
signal buff_DATA : std_logic_vector(7 downto 0); --c'est pour simplifier la machine à état
signal cnt_trame : integer range 0 to 10 := 0; --compteur jusqua 10 (les 10 registres de transmission)
signal cnt_addr_trame: unsigned(7 downto 0) := x"0A"; -- un compteur shifté de xOA pour l'adresse


type behavior_state is
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
    TX_BUFFER_WRITE,
    START_TRANSMISSION,
    WRITE_STATE,
    WAIT_N_CLOCK
  );
  signal etat : behavior_state;
  signal etat_futur : behavior_state;


  component can_controller
port(
        CLK : in std_logic;
        CLK_DRIVER : in std_logic;  --clk pour echanges wishbone
        RESET_BAR : in std_logic;   --reset sur 0

        START  : in    std_logic;                     --! Start pin for activate transmission
        RD_WR  : in    std_logic;                     --0 pour lire 1 pour ecrire
        REG_ADDR     : in    std_logic_vector(7 downto 0);  --adresse du registre ï¿½ lire/ecrire
        REG_DATA     : in    std_logic_vector(7 downto 0);  --data ï¿½ acrire
        PORT_0_READ : out std_logic_vector(7 downto 0);     --data lu
        PORT_FREE    : out   std_logic;                 --1 : on peut faire une lecture/ecriture
                                                        --0 : il faut attendre que celle en cours finisse
                                                        --voir commentaires dans process wishbone_driver pour subtilitï¿½s

        RX : in std_logic;          --entrï¿½e cotï¿½ bus CAN
        TX : out std_logic;         --sortie cotï¿½ bus CAN
        BUS_OFF_ON : out std_logic;     --signal defini can_top et non SJA1000, faut voir a quoi ils servent
        IRQ_ON : out std_logic;         --idem
        CLK_OUT : out std_logic       --sortie de la CLK apres passage dans le divider


);
end component;


begin

CKB_0 : NX_BD --instanciation du buffer driver (le commenter pour test sur zynq)
port map (
 I => RST_CAN --bouton de reset (pas low skew)
,
 O => rst --signal reset (low skew)
);

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



--rst <= RST_CAN; --(decommenter sa pour test sur zynq, car NX_BD ne fait plus la liason entr les 2)
TX_o <= sig_TX;
sig_RX <= TX_i and sig_TX; --(emulation du tranceiver, logique ET sur le bus CAN)


PROCESS_WRITE : process (CLK)

--procedure pour eviter d'ecrire plein de fois les memes 3 lignes
procedure set_write_buffer(constant proc_reg_addr : in std_logic_vector(7 downto 0) := x"00"; proc_reg_data : in std_logic_vector(7 downto 0) := x"00") is
begin
        buff_ADDR <= proc_reg_addr; 
        buff_DATA <= proc_reg_data;
        etat <= WRITE_STATE;
end set_write_buffer;

--sur zynq j'avais juste recuperer la partie de 8bits de TRAME qu'il faut grace a cnt_trame
--cependant sur NanoXplore on ne peut pas utiliser des indices non constant dans les vector
--donc ici c'est fait par decalage vers la gauche de TRAME
procedure next_byte_trame is
begin
    TRAME <= TRAME(71 downto 0) & x"00";
    byte_trame <= TRAME(71 downto 64);

end next_byte_trame;


begin
if(rising_edge(CLK)) then
    if(rst='0') then   -- si on met RST_CAN ici nxmap ne veut pas faire le placement/routage, pas vraiment de sens :/
          etat <= START_RESET; --juste apres la fin du reset on ecrit ce qu'il faut dans les registre de controle
    else
            case etat is

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

            -------------------------------------------------------------------------------------------------------

             when IDLE =>
                sig_START <= '0';
                if(BOUTON = '0' and transmitting = '0') then
                    transmitting <= '1';
                    TRAME <= x"7A2801025468E3CDA2F1"; --la trame commence par 7A28 (7 pour 4 premiers bits d'id et 8 pour la taille, RTR = 0)
                    byte_trame <= x"7A";
                    cnt_trame <= 0;
                    cnt_addr_trame <= x"0A";
                    etat <= TX_BUFFER_WRITE;
                end if;
                if(BOUTON = '1') then
                    transmitting <= '0';
                end if;

             when TX_BUFFER_WRITE =>
             if(cnt_trame = 10) then
                etat <= START_TRANSMISSION; --lorque que l'on a ecrit toute la trame
             else
                set_write_buffer(std_logic_vector(cnt_addr_trame),byte_trame); --TRAME(79-cnt_trame*8 downto 79 - cnt_trame*8 - 7) pas syntethisable sur NanoXplore
                next_byte_trame;
                etat_futur <= TX_BUFFER_WRITE; --tant qu'on a pas fait les 10 registre on revient sur l'etat apres le WRITE_STATE avec des cnt et byte_trame different 
                cnt_trame <= cnt_trame + 1;
                cnt_addr_trame <= cnt_addr_trame + 1;
             end if;

            when START_TRANSMISSION =>
            set_write_buffer(SJA1000_CommandReg,TR_Bit); --lance la transmission
            etat_futur <= IDLE; --(en soit il faudrait attendre que la transmission finisse avant de retourner dans IDLE)
                                --mais a moins d'appuier sur le bouton 2 fois en moins de 1ms sa marche
           ------------------------------------------------------------------------------------------------------------
            when WRITE_STATE => --on alterne entre TX_BUFFER_WRITE et WRITE_STATE quand on ecrit dans les registre
                if(sig_PORT_FREE = '1') then
                    sig_REG_ADDR <= buff_ADDR;
                    sig_REG_DATA <= buff_DATA;
                    sig_START <= '1';
                    sig_RD_WR <= '1';
                    wait_N <= x"02";
                    etat <= WAIT_N_CLOCK;
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
