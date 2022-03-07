library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity  tb_controleur_can_bench is
-- Port ();
end tb_controleur_can_bench;

architecture behavorial of tb_controleur_can_bench is

	-- Lenght register
	constant lenght_register 				: integer := 8;
	-- Adress register
	constant interrupt_register_can : std_logic_vector(7 downto 0):= x"03";
	constant accpetance_code_0_can 	: std_logic_vector(7 downto 0):= x"04";
	constant accpetance_mask_0_can 	: std_logic_vector(7 downto 0):= x"05";
	constant bus_timing_0_can 			: std_logic_vector(7 downto 0):= x"06";
	constant bus_timing_1_can 			: std_logic_vector(7 downto 0):= x"07";
	constant TX_data_0_can 					: std_logic_vector(7 downto 0):= x"0A";
	constant TX_data_1_can 					: std_logic_vector(7 downto 0):= x"0B";
	constant TX_data_2_can 					: std_logic_vector(7 downto 0):= x"0C";
	constant TX_data_3_can 					: std_logic_vector(7 downto 0):= x"0D";
	constant TX_data_4_can 					: std_logic_vector(7 downto 0):= x"0E";
	constant TX_data_5_can 					: std_logic_vector(7 downto 0):= x"0F";
	constant TX_data_6_can 					: std_logic_vector(7 downto 0):= x"10";
	constant TX_data_7_can 					: std_logic_vector(7 downto 0):= x"11";
	constant TX_data_8_can 					: std_logic_vector(7 downto 0):= x"12";
	constant TX_data_9_can 					: std_logic_vector(7 downto 0):= x"13";
	constant RX_data_0_can 					: std_logic_vector(7 downto 0):= x"14";
	constant RX_data_1_can 					: std_logic_vector(7 downto 0):= x"15";
	constant RX_data_2_can 					: std_logic_vector(7 downto 0):= x"16";
	constant RX_data_3_can 					: std_logic_vector(7 downto 0):= x"17";
	constant RX_data_4_can 					: std_logic_vector(7 downto 0):= x"1A";
	constant RX_data_5_can 					: std_logic_vector(7 downto 0):= x"1B";
	constant RX_data_6_can 					: std_logic_vector(7 downto 0):= x"1C";
	constant RX_data_7_can 					: std_logic_vector(7 downto 0):= x"1D";
	constant RX_data_8_can 					: std_logic_vector(7 downto 0):= x"1E";
	constant RX_data_9_can 					: std_logic_vector(7 downto 0):= x"1F";
	constant clock_div_can 					: std_logic_vector(7 downto 0):= x"21";
	-- Initialisation parameters
	constant CAN_TIMING0_BRP				: std_logic_vector(5 downto 0):= conv_std_logic_vector(3,6);
	constant CAN_TIMING0_SJW				: std_logic_vector(1 downto 0):= conv_std_logic_vector(1,2);
	constant CAN_TIMING1_TSEG1			: std_logic_vector(3 downto 0):= conv_std_logic_vector(15,4);
	constant CAN_TIMING1_TSEG2			: std_logic_vector(2 downto 0):= conv_std_logic_vector(2,3);
	constant CAN_TIMING1_SAM				: std_logic := '0';
	constant EXTENDED_MODE					:	std_logic := '1';
	constant CAN_MODE_RESET					: std_logic := '1';



component test_controleur_can is
	port
	(
		CLK     			: in  std_logic  									--! Reset pin for initialisation
		;CLK_TIMER    : in    std_logic                     --! Reset pin for initialisation
		;RESET_BAR   	: in  std_logic  									--! Reset pin for initialisation
		;START   			: inout  std_logic  							--! Start pin for activate transmission
		;CAN_TX  			: out  std_logic 									--! Transmission pin for CAN
		;REG_ADDR 		: in std_logic_vector(7 downto 0) --! Vecteur permettant de temporiser le registre d'adresse
		;REG_DATA 		: in std_logic_vector(7 downto 0) --! Vecteur permettant de temporiser le registre d'adresse
		;CAN_RX  			: in std_logic    								--! Receive pin for CAN
		;FREE       	: out   std_logic                 --! Output which indicate that the time has elapsed
		;ALE_I        : out   std_logic                     --! MAP
		;RD_I         : out   std_logic                     --! MAP
		;WR_I         : out   std_logic                     --! MAP
		;PORT_0_IO    : out   std_logic_vector(7 downto 0)	 --! MAP
		;CS_CAN_I     : out   std_logic                     --! MAP
		;BUS_OFF_ON   : out   std_logic                     --! MAP
		;IRQ_ON       : out   std_logic                     --! MAP
		;RESET_INV    : out   std_logic
		;CLK_OUT    	: out   std_logic
	);
end component;

signal sig_CLK 	  			:	std_logic := '0'; 						-- Initialisation de la CLK à 0
signal sig_CLK_TIMER		:	std_logic := '0'; 						-- Initialisation de la CLK à 0
signal sig_RESET_BAR  	: std_logic := '0'; 						-- Initialisation de la CLK à 0
signal sig_START 				:	std_logic := '0'; 						-- Initialisation du bit DATA_IN à 0
signal sig_CAN_TX				:	std_logic; 										-- Initialisation du bit DATA_IN à 0
signal sig_CAN_RX				:	std_logic; 										-- Initialisation du bit DATA_IN à 0
signal sig_FREE					:	std_logic; 										-- Initialisation du bit DATA_IN à 0
signal sig_REG_ADDR			:	std_logic_vector(7 downto 0); -- Initialisation du bit DATA_IN à 0
signal sig_REG_DATA			:	std_logic_vector(7 downto 0); -- Initialisation du bit DATA_IN à 0
signal sig_ALE_I        : std_logic;                     --! MAP
signal sig_RD_I         : std_logic;                     --! MAP
signal sig_WR_I         : std_logic;                     --! MAP
signal sig_PORT_0_IO    : std_logic_vector(7 downto 0);  --! MAP
signal sig_CS_CAN_I     : std_logic;                     --! MAP
signal sig_BUS_OFF_ON   : std_logic;                     --! MAP
signal sig_IRQ_ON       : std_logic;                     --! MAP
signal sig_RESET_INV    : std_logic;                     --! MAP
signal sig_CLK_OUT    	: std_logic;                     --! MAP


begin

TESTCAN :  test_controleur_can port map
(
	CLK 				=>	sig_CLK
	,CLK_TIMER	=>  sig_CLK_TIMER                   --! Reset pin for initialisation
	,RESET_BAR 	=>	sig_RESET_BAR
	,START			=>	sig_START
	,CAN_TX 		=>	sig_CAN_TX
	,CAN_RX 		=>	sig_CAN_RX
	,REG_ADDR 	=>	sig_REG_ADDR
	,FREE 			=> 	sig_FREE
	,REG_DATA 	=>	sig_REG_DATA
	,RD_I 			=>	sig_RD_I
	,ALE_I 			=>	sig_ALE_I
	,WR_I 			=>	sig_WR_I
	,PORT_0_IO 	=>	sig_PORT_0_IO
	,CS_CAN_I 	=>	sig_CS_CAN_I
	,BUS_OFF_ON =>	sig_BUS_OFF_ON
	,IRQ_ON 		=>	sig_IRQ_ON
	,RESET_INV 	=> 	sig_RESET_INV
	,CLK_OUT 	=> 	sig_CLK_OUT
);

-- Generation de la clock à 16MHz
process
begin
	sig_CLK <= not(sig_CLK);
	wait for 31250 ps;
end process;

process
begin
	sig_CLK_TIMER <= not(sig_CLK_TIMER);
	wait for 10000 ps;
end process;


process
begin
	sig_RESET_BAR <= '0';
	wait for 30 ns;
	sig_RESET_BAR <= '1';
	wait for 20 ns;
	wait until sig_FREE = '1';
	-- Initialisation
	sig_REG_ADDR <= bus_timing_0_can;
	sig_REG_DATA <= CAN_TIMING0_SJW & CAN_TIMING0_BRP;
  sig_START <= '1';
	wait for 20 ns;
	sig_START <= '0';
	wait until sig_FREE = '1';
	sig_REG_ADDR <= bus_timing_1_can;
	sig_REG_DATA <= CAN_TIMING1_SAM & CAN_TIMING1_TSEG2 & CAN_TIMING1_TSEG1;
	sig_START <= '1';
	wait for 20 ns;
	sig_START <= '0';
	wait until sig_FREE = '1';

	-- réglage du diviseur de Clock
	--sig_REG_ADDR <= clock_div_can;
	--sig_REG_DATA <= EXTENDED_MODE & "0000000";
	--wait for 20 ns;
	--sig_START <= '0';
	--wait until sig_FREE = '1';

	-- Accetation des codes et des maesques
	sig_REG_ADDR <= accpetance_code_0_can;
	sig_REG_DATA <= x"e8";
	sig_START <= '1';
	wait for 20 ns;
	sig_START <= '0';
	wait until sig_FREE = '1';

	sig_REG_ADDR <= accpetance_mask_0_can;
	sig_REG_DATA <= x"0F";
	sig_START <= '1';
	wait for 20 ns;
	sig_START <= '0';
	wait until sig_FREE = '1';

	sig_REG_ADDR <= x"00"; -- Savoir c'est quoi comme registre.
	sig_REG_DATA <= "0000000" & not(CAN_MODE_RESET); --
	sig_START <= '1';
	wait for 20 ns;
	sig_START <= '0';
	wait until sig_FREE = '1';

	-- Ecriture de la trame
	--write_register(8'd10, 8'hea); // Writing ID[10:3] = 0xea
	sig_REG_ADDR <= TX_data_0_can;
	sig_REG_DATA <= x"EA";
	sig_START <= '1';
	wait for 20 ns;
	sig_START <= '0';
	wait until sig_FREE = '1';
	--write_register(8'd11, 8'h28); // Writing ID[2:0] = 0x1, rtr = 0, length = 8
	sig_REG_ADDR <= TX_data_1_can;
	sig_REG_DATA <= x"28";
	sig_START <= '1';
	wait for 20 ns;
	sig_START <= '0';
	wait until sig_FREE = '1';
	--write_register(8'd12, 8'h56); // data byte 1
	sig_REG_ADDR <= TX_data_2_can;
	sig_REG_DATA <= x"56";
	sig_START <= '1';
	wait for 20 ns;
	sig_START <= '0';
	wait until sig_FREE = '1';
	--write_register(8'd13, 8'h78); // data byte 2
	sig_REG_ADDR <= TX_data_3_can;
	sig_REG_DATA <= x"78";
	sig_START <= '1';
	wait for 20 ns;
	sig_START <= '0';
	wait until sig_FREE = '1';
	--write_register(8'd14, 8'h9a); // data byte 3
	sig_REG_ADDR <= TX_data_4_can;
	sig_REG_DATA <= x"9A";
	sig_START <= '1';
	wait for 20 ns;
	sig_START <= '0';
	wait until sig_FREE = '1';
	--write_register(8'd15, 8'hbc); // data byte 4
	sig_REG_ADDR <= TX_data_5_can;
	sig_REG_DATA <= x"BC";
	sig_START <= '1';
	wait for 20 ns;
	sig_START <= '0';
	wait until sig_FREE = '1';
	--write_register(8'd16, 8'hde); // data byte 5
	sig_REG_ADDR <= TX_data_6_can;
	sig_REG_DATA <= x"de";
	sig_START <= '1';
	wait for 20 ns;
	sig_START <= '0';
	wait until sig_FREE = '1';
	--write_register(8'd17, 8'hf0); // data byte 6
	sig_REG_ADDR <= TX_data_7_can;
	sig_REG_DATA <= x"F0";
	sig_START <= '1';
	wait for 20 ns;
	sig_START <= '0';
	wait until sig_FREE = '1';
	--write_register(8'd18, 8'h0f); // data byte 7
	sig_REG_ADDR <= TX_data_8_can;
	sig_REG_DATA <= x"0F";
	sig_START <= '1';
	wait for 20 ns;
	sig_START <= '0';
	wait until sig_FREE = '1';
	--write_register(8'd19, 8'hed); // data byte 8
	sig_REG_ADDR <= TX_data_9_can;
	sig_REG_DATA <= x"ED";
	sig_START <= '1';
	wait for 20 ns;
	sig_START <= '0';
	wait until sig_FREE = '1';

	-- Activation de l'irq
	sig_REG_ADDR <= interrupt_register_can;
	sig_REG_DATA <= x"1e";
	sig_START <= '1';
	wait for 20 ns;
	sig_START <= '0';
	wait until sig_FREE = '1';

	sig_REG_ADDR <= (others => 'Z');
	sig_REG_DATA <= (others => 'Z');
  wait;
end process;


end behavorial;
