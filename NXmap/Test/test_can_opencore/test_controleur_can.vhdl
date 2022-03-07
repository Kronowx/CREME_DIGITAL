-------------------------------------------------------
--! @file test_controleur_can.vhdl
--! @brief Runtime test of can wich provide opencore.org
-------------------------------------------------------
 --! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

--library NX;
--use NX.nxpackage.all;

--! Mux entity brief description

--! Detailed description of this
--! mux design element.
entity test_controleur_can is
    generic
    (
      nb_bit_timer_x_bit : integer := 32
    );
    port (
        CLK           : in    std_logic                     --! Clock pin
        ;CLK_TIMER    : in    std_logic                     --! Reset pin for initialisation
        ;RESET_BAR    : in    std_logic                     --! Reset pin for initialisation
        ;START        : in    std_logic                     --! Start pin for activate transmission
        ;CAN_TX       : out   std_logic                     --! Transmission pin for CAN
        ;REG_ADDR     : in    std_logic_vector(7 downto 0)  --! Vecteur permettant de temporiser le registre d'adresse
        ;REG_DATA     : in    std_logic_vector(7 downto 0)  --! Vecteur permettant de temporiser le registre d'adresse
        ;CAN_RX       : in    std_logic                     --! Receive pin for CAN
        ;PORT_FREE    : out   std_logic                     --! Output which indicate that the time has elapsed
        ;ALE_I        : out   std_logic                     --! MAP
        ;RD_I         : out   std_logic                     --! MAP
        ;WR_I         : out   std_logic                     --! MAP
        ;PORT_0_IO    : out   std_logic_vector(7 downto 0)  --! MAP
        ;CS_CAN_I     : out   std_logic                     --! MAP
        ;BUS_OFF_ON   : out   std_logic                     --! MAP
        ;IRQ_ON       : out   std_logic                     --! MAP
        ;RESET_INV    : out   std_logic
        ;CLK_OUT      : out   std_logic
       );
end entity;

--! @brief Architecture definition of the test_controleur_can
--! @details More details about this mux element.
architecture behavior of test_controleur_can is

  signal word                     : std_logic_vector(7 downto 0);
  signal sig_ale_i                : std_logic;                     -- input        ale_i;
  signal sig_rd_i                 : std_logic;                     -- input        rd_i;
  signal sig_wr_i                 : std_logic;                     -- input        wr_i;
  signal sig_port_0_io            : std_logic_vector(7 downto 0);  -- inout  [7:0] port_0_io;
  signal read_data_register       : std_logic_vector(7 downto 0);  -- inout  [7:0] port_0_io;
  signal sig_cs_can_i             : std_logic;                     -- input        cs_can_i;
  signal sig_clk_i                : std_logic;                     -- input        clk_i;
  signal sig_bus_off_on           : std_logic;                     -- output       bus_off_on;
  signal sig_irq_on               : std_logic;                     -- output       irq_on;
  signal sig_clkout_o             : std_logic;                      -- output       clkout_o;
  signal sig_port_free                : std_logic;                     -- output
  signal sig_reg_addr             : std_logic_vector(7 downto 0) := (others => '0');  -- inout  [7:0] port_0_io;
  signal sig_reg_data             : std_logic_vector(7 downto 0) := (others => '0');  -- inout  [7:0] port_0_io;
  signal sig_timer_xbit_arm       : std_logic;                             --! Input that goes armed our timer
  signal sig_timer_xbit_value     : std_logic_vector(nb_bit_timer_x_bit-1 downto 0);   --! Input that specified xhen the timer set an interrupt flag
  signal sig_timer_xbit_irq_flag  : std_logic;                             --! Output which indicate that the time has elapsed
  signal sig_reset_inv                : std_logic;                             --! Output which indicate that the time has elapsed

  type behavior_state is
  (
    INIT
  , CS_CAN_ON
  , SET_ADDRESS_START
  , SET_ADDRESS_END
  , WRITE_DATA_START
  , WRITE_DATA_END
  , WRITE_DATA
  , READ_DATA
  , CS_CAN_OFF
  , WAIT_TIME
  , IDLE
  );
  signal etat, etat_futur : behavior_state;

  component timer_x_bit
  generic
  (
    nb_bit : integer := nb_bit_timer_x_bit                              --! Timer resolution
  );
  port
  (
      CLK       : in    std_logic                             --! Clock for module
     ;RESET_BAR : in    std_logic                             --! Reset pin for initialisation
     ;ARM       : in    std_logic                             --! Input that goes armed our timer
     ;VALUE     : in    std_logic_vector(nb_bit-1 downto 0)   --! Input that specified xhen the timer set an interrupt flag
     ;IRQ_FLAG  : out   std_logic                             --! Output which indicate that the time has elapsed
  );
  end component;

  component can_top
  port
  (
      rst_i       : in    std_logic;                     -- input        rst_i;
      ale_i       : in    std_logic;                     -- input        ale_i;
      rd_i        : in    std_logic;                     -- input        rd_i;
      wr_i        : in    std_logic;                     -- input        wr_i;
      port_0_io   : inout std_logic_vector(7 downto 0);  -- inout  [7:0] port_0_io;
      cs_can_i    : in    std_logic;                     -- input        cs_can_i;
      clk_i       : in    std_logic;                     -- input        clk_i;
      rx_i        : in    std_logic;                     -- input        rx_i;
      tx_o        : out   std_logic;                     -- output       tx_o;
      bus_off_on  : out   std_logic;                     -- output       bus_off_on;
      irq_on      : out   std_logic;                     -- output       irq_on;
      clkout_o    : out   std_logic                      -- output       clkout_o;
  );
  end component;

  -- Procedur permettant d'écrie dans les registre du can
--  procedure write_register (
--  signal in_reg_addr : std_logic_vector(7 downto 0); -- Registre d'adresse
--  signal in_reg_data : std_logic_vector(7 downto 0)  -- Donnée a envoyer
--  )
--  is
--    variable REG_ADDR : std_logic_vector(7 downto 0);
--    variable REG_DATA : std_logic_vector(7 downto 0);
--  begin
--    REG_ADDR :=  in_reg_addr;
--    REG_DATA :=  in_reg_data;
--  end write_register;

begin

  can_top_1 : can_top port map
  (
    rst_i       => sig_reset_inv,           -- input        rst_i;
    ale_i       => sig_ale_i,       -- input        ale_i;
    rd_i        => sig_rd_i,        -- input        rd_i;
    wr_i        => sig_wr_i,          -- input        wr_i;
    port_0_io(7 downto 0)   => sig_port_0_io(7 downto 0),   -- inout  [7:0] port_0_io;
    cs_can_i    => sig_cs_can_i,    -- input        cs_can_i;
    clk_i       => sig_clk_i,       -- input        clk_i;
    rx_i        => CAN_RX,          -- input        rx_i;
    tx_o        => CAN_TX,          -- output       tx_o;
    bus_off_on  => sig_bus_off_on,  -- output       bus_off_on;
    irq_on      => sig_irq_on,      -- output       irq_on;
    clkout_o    => sig_clkout_o     -- output       clkout_o;
  );

    timer_x_bit_1 : timer_x_bit port MAP
    (
      CLK         => CLK_TIMER                      --! Clock for module
      ,RESET_BAR  => RESET_BAR                   --! Reset pin for initialisation
      ,ARM        => sig_timer_xbit_arm      --! Input that goes armed our timer
      ,VALUE      => sig_timer_xbit_value    --! Input that specified xhen the timer set an interrupt flag
      ,IRQ_FLAG   => sig_timer_xbit_irq_flag --! Output which indicate that the time has elapsed
    );

  sig_reset_inv <= not(RESET_BAR);
  RESET_INV <= sig_reset_inv;

  ALE_I        <= sig_ale_i;        -- MAP
  RD_I         <= sig_rd_i;         -- MAP
  WR_I         <= sig_wr_i;         -- MAP
  PORT_0_IO    <= sig_port_0_io;    -- MAP
  CS_CAN_I     <= sig_cs_can_i;     -- MAP
  BUS_OFF_ON   <= sig_bus_off_on;   -- MAP
  IRQ_ON       <= sig_irq_on;       -- MAP
  PORT_FREE    <= sig_port_free;

  PROCESS_WRITE : process (CLK)
    variable tmp : integer;
	begin
		if CLK'event then
      if RESET_BAR='0' then   -- On réinitialisde le tout.
        sig_cs_can_i <='0';
        sig_ale_i <='0';
        sig_rd_i <= '0';
        sig_wr_i <= '0';
        sig_timer_xbit_arm <= '0';
        sig_timer_xbit_value <= (others => '0');
        sig_port_0_io <= (others => 'Z');
        sig_port_free <= '0';
        etat <= INIT;
      else
        case etat is
          when INIT => -- Initialisation
            sig_cs_can_i <='0';
            sig_ale_i <='0';
            sig_rd_i <= '0';
            sig_wr_i <= '0';
            sig_port_0_io <= (others => 'Z');
            sig_timer_xbit_arm <= '0';
            sig_timer_xbit_value <= conv_std_logic_vector(200,nb_bit_timer_x_bit); -- MAP a revoir en fonction de la fonction timer
            sig_port_free <= '0';
            etat <= WAIT_TIME;
	          etat_futur <= IDLE;
          when IDLE => -- Attente d'une instruction
            sig_cs_can_i <='0';
            sig_ale_i <='0';
            sig_rd_i <= '0';
            sig_wr_i <= '0';
            sig_port_0_io <= (others => 'Z');
            sig_port_free <= '1';
            if START = '1' then
               etat <= CS_CAN_ON;
            end if;
          when CS_CAN_ON =>
            sig_reg_addr <= REG_ADDR; -- Adress register acquisition
            sig_reg_data <= REG_DATA; -- Data register acquisition
            if(clk <= '1') then
              sig_cs_can_i <='1';
              sig_port_free <= '0';
              etat <= SET_ADDRESS_START;
            end if;
          when SET_ADDRESS_START =>
          if(clk <= '0') then
            sig_ale_i <='1';
  	        sig_port_0_io <= sig_reg_addr;
	          etat <= SET_ADDRESS_END;
          end if;
          when SET_ADDRESS_END =>
            if(clk <= '0') then
              sig_ale_i <='0';
              sig_timer_xbit_arm <= '1';
              sig_timer_xbit_value <= conv_std_logic_vector(90,nb_bit_timer_x_bit); -- MAP a revoir en fonction de la fonction timer
  	          etat <= WAIT_TIME;
  	          etat_futur <= WRITE_DATA_START;
            end if;
          when WRITE_DATA_START =>
            sig_wr_i <= '1';
	          sig_port_0_io <= sig_reg_data;
            --tmp := 158; -- MAP
            sig_timer_xbit_arm <= '1';
            sig_timer_xbit_value <= conv_std_logic_vector(160,nb_bit_timer_x_bit); -- MAP a revoir en fonction de la fonction timer
            etat <= WAIT_TIME;
	          etat_futur <= WRITE_DATA_END;
          when WRITE_DATA_END =>
            sig_wr_i <= '0';
            sig_cs_can_i <='0';
            sig_port_free <= '1';
	          sig_port_0_io <= (others => 'Z');
            etat <= IDLE;
          when READ_DATA =>
            sig_cs_can_i <='1';
            sig_ale_i <='1';
            sig_rd_i <= '0';
            sig_wr_i <= '1';
	          read_data_register <= sig_port_0_io;
          when CS_CAN_OFF =>
            etat <= IDLE;
          when WAIT_TIME =>
          sig_timer_xbit_arm <= '0';
          --tmp :=  tmp - 1;
          --if tmp < 0 then
          if (sig_timer_xbit_irq_flag = '1') then
            etat <= etat_futur;
          end if;
          when others => -- Si on est là : c'est qu'il y a baleine sous cailloux!
            sig_cs_can_i <='0';
            sig_ale_i <='0';
            sig_rd_i <= '0';
            sig_wr_i <= '0';
            sig_port_0_io <= (others => 'Z');
            sig_port_free <= '1';
            etat <= INIT;
        end case;
      end if;
		end if;
	end process;
end architecture;
