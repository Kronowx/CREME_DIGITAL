
-- Company:
-- Engineer:
--
-- Create Date: 12.07.2021 13:53:37
-- Design Name:
-- Module Name: test_can_ram - Behavioral
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

entity test_can_ram is port (
    CLK : in std_logic;
    RESET_BAR : in std_logic;

    BOUTON : in std_logic;

    TX_o : out std_logic;
    TX_i : in std_logic;
    RX_oscillo : out std_logic

);
end test_can_ram;

architecture Behavioral of test_can_ram is

signal sig_FREE : std_logic;
signal sig_ADDR_START : std_logic_vector(12 downto 0);
signal    sig_NBR_TRAME : std_logic_vector(12 downto 0);
   signal  sig_SEND :  std_logic := '0';


    signal sig_ADDR_RAM : std_logic_vector(12 downto 0);
    signal sig_WE_RAM :  std_logic;
    signal sig_DO_RAM : std_logic_vector(7 downto 0);
    signal sig_DI_RAM : std_logic_vector(7 downto 0);

    signal sig_RX :  std_logic;
    signal sig_TX :  std_logic;


    signal sig_TX_2 :  std_logic;
        signal sig_RX_2 :  std_logic;


    signal sig_DIN : std_logic_vector(7 downto 0);
    signal sig_WE : std_logic := '0';
    signal sig_ADR : std_logic_vector(12 downto 0);
    signal sig_DOUT : std_logic_vector(7 downto 0);

     signal sig_DIN_2 : std_logic_vector(7 downto 0);
    signal sig_WE_2 : std_logic := '0';
    signal sig_ADR_2 : std_logic_vector(12 downto 0);
    signal sig_DOUT_2 : std_logic_vector(7 downto 0);

signal switch : std_logic := '0';

    signal cnt : unsigned(7 downto 0) := x"00";
    signal slice_trame_1 : unsigned(7 downto 0) := x"C7"; --199
    signal slice_trame_2 : unsigned(7 downto 0) := x"C0"; --192
    signal cnt_adr : unsigned(12 downto 0) := '0' & x"654";

    signal data_block : std_logic_vector(199 downto 0) := x"ea235634B2ea2811335577ABCDEF00ea20ea26895731A74EB5";

    signal wait_N : unsigned(7 downto 0) := x"00";
    signal transmitting : std_logic := '0';
    signal rst : std_logic;

--component memory
--generic(
--     N_ADDR : integer;
--    N_DATA : integer
--);
--port(
--    CLK : in std_logic;
--    DIN : in std_logic_vector(N_DATA-1 downto 0);
--    WE : in std_logic;
--    ADR : in std_logic_vector(N_ADDR-1 downto 0);
--    DOUT : out std_logic_vector(N_DATA-1 downto 0)
--);
--end component;

component ram
port(
    CLK	:   in std_logic;
	DI	:   in std_logic_vector(7 downto 0);
	DO	:   out std_logic_vector(7 downto 0);
	AD	:   in std_logic_vector(12 downto 0);
	WE	:   in std_logic
);
end component;

component can_ram
generic(
 N_ADDR : integer
);
port(
CLK : in std_logic;
    RESET_BAR : in std_logic;

    FREE : out std_logic;
    ADDR_START : in std_logic_vector(N_ADDR-1 downto 0);
    NBR_TRAME : in std_logic_vector(N_ADDR-1 downto 0);
    SEND : in std_logic;

    ADDR_RAM : out std_logic_vector(N_ADDR-1 downto 0);
    WE_RAM : out std_logic := '0';
    DO_RAM : out std_logic_vector(7 downto 0);
    DI_RAM : in std_logic_vector(7 downto 0);

    RX : in std_logic;
    TX : out std_logic
);
end component;


type behavior_state is --les different etats du driver
  (
    IDLE,
    WRITE_RAM,
    SEND,

    WAIT_N_CLOCK

  );
  signal etat, etat_futur : behavior_state;

begin

CKB_0 : NX_BD
port map (
 I => RESET_BAR,
 O => rst
);


--memory_1 : memory
--generic map(
--N_ADDR => 13,
--N_DATA => 8
--)
--port map(
-- CLK => CLK,
--    DIN => sig_DIN,
--    WE  => sig_WE,
--    ADR => sig_ADR,
--    DOUT => sig_DOUT
--);



ram_1 : ram
port map(
    CLK	=>  CLK,
	DI	=> sig_DIN,
	DO	=> sig_DOUT,
	AD	=> sig_ADR,
	WE	=> sig_WE
);

can_ram_1 : can_ram
generic map(
    N_ADDR => 13
)
port map(
    CLK => CLK,
    RESET_BAR => rst,

    FREE => sig_FREE,
    ADDR_START => sig_ADDR_START,
    NBR_TRAME => sig_NBR_TRAME,
    SEND => sig_SEND,

    ADDR_RAM  => sig_ADDR_RAM,
    WE_RAM => sig_WE_RAM,
    DO_RAM => sig_DO_RAM,
    DI_RAM => sig_DI_RAM,

    RX => sig_RX,
    TX => sig_TX
);



--rst <= RESET_BAR;

--des fois c'est le process en bas qui communique avec la ram et apres c'est le can_ram
--il faut donc faire l'aguillage (il est possible dans les NX_RAM d'avoir 2 banque de signaux entrant et sortant (A et B)
--donc il vaudrait mieux se servir de sa en changeant le module ram)
sig_DIN <= sig_DO_RAM when switch = '1' else sig_DIN_2;
sig_WE <= sig_WE_RAM when switch = '1' else sig_WE_2;
sig_ADR <= sig_ADDR_RAM when switch = '1' else sig_ADR_2;
sig_DI_RAM <= sig_DOUT;

RX_oscillo <= sig_TX and TX_i; --emulation du transceiveur
sig_RX <= sig_TX and TX_i;
TX_o <= sig_TX;

--le process rempli la ram et demande la transmission au can_ram

process(CLK)
begin
if(rising_edge(CLK)) then
    if(rst = '0') then
        etat <= IDLE;
        sig_SEND <= '0';

    else
        case etat is

        when IDLE =>
            sig_SEND <= '0';
            if(BOUTON = '0' and sig_FREE = '1' and transmitting = '0') then
                switch <= '0';
                cnt <= x"00";
                cnt_adr <= '0' & x"654"; --arbitraire
                slice_trame_1 <= x"C7"; --199
                slice_trame_2 <= x"C0"; --192
                transmitting <= '1';
                etat <= WRITE_RAM;
            end if;
            if(BOUTON = '1') then
                transmitting <= '0';
            end if;

        when WRITE_RAM =>
            if(cnt = 25) then --25 octet a stocker
                etat <= SEND;
                switch <= '1';
            else
                sig_DIN_2 <= data_block(to_integer(slice_trame_1) downto to_integer(slice_trame_2));
                sig_ADR_2 <= std_logic_vector(cnt_adr);
                sig_WE_2 <= '1';
                cnt <= cnt + 1;
                cnt_adr <= cnt_adr + 1;
                slice_trame_1 <= slice_trame_1 - 8;
                slice_trame_2 <= slice_trame_2 - 8;
                wait_N <= x"02";
                etat <= WAIT_N_CLOCK;
                etat_futur <= WRITE_RAM;
            end if;

        when SEND =>
            sig_ADDR_START <= '0' & x"654";
            sig_NBR_TRAME <= '0' & x"004"; --il ya 4 trames a cette adresse
            sig_SEND <= '1';
            wait_N <= x"01";
            etat <= WAIT_N_CLOCK;
            etat_futur <= IDLE;


        when WAIT_N_CLOCK =>
            if(wait_N = x"00") then
                etat <= etat_futur;
                sig_WE_2 <= '0';
            else
                wait_N <= wait_N - 1;
            end if;


        end case;
    end if;
end if;
end process;

end Behavioral;
