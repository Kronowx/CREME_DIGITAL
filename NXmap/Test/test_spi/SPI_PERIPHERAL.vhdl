----------------------------------------------------------------------------------
-- Company: ONERA
-- Engineer: guillaume.gourves@onera.for
--
-- Create Date: 16.06.2021 14:13:34
-- Design Name:
-- Module Name: SPI_PERIPHERAL - Behavioral
-- Project Name: CREME
-- Target Devices: NG-MEDIUM
-- Tool Versions: nxmap3
-- Description:
--
-- Dependencies: OpenCores
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_textio.all;
use STD.textio.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPI_PERIPHERAL is
port
  (
    CLK : in std_logic                                  --! Signaux de clock permettant le fonctionnement du module
    ;RESET_BAR : in std_logic                           --! Pin de RESET (actif à l'état bas).
    ;START        : in    std_logic                     --! Start pin for activate transmission
    ;PORT_READ  : out   std_logic_vector(31 downto 0)   --! Port de lecteure du module
    ;PORT_WRITE : in   std_logic_vector(31 downto 0)    --! Port decriture du module
    ;PORT_FREE    : out   std_logic                     --! Indicateur de disponibilite du module (0 : occupe et 1 : libre)
    ;DATA_SIZE  : in std_logic_vector(1 downto 0)       --! Taille de la donnee a envoyer 00 -> 8 bits, 01 -> 16 bits, 10 -> 24bits, 11 -> 32 bits.
    ;SCK  : out std_logic                               --! Clock en sortie du module SPI
    ;MOSI : out std_logic                               --! MOSI en sortie du module SPI
    ;MISO : in std_logic                                --! MISO en sortie du module SPI
  );
end SPI_PERIPHERAL;

architecture Behavioral of SPI_PERIPHERAL is

  constant SPCR :std_logic_vector(1 downto 0):= "00"; --! Control Register
  constant SPSR :std_logic_vector(1 downto 0):= "01"; --! Status Register
  constant SPDR :std_logic_vector(1 downto 0):= "10"; --! Data Register
  constant SPER :std_logic_vector(1 downto 0):= "11"; --! Extensions Register

  ----------Signaux interne----------------------
  signal sig_port_read_peripheral    :std_logic_vector(31 downto 0) := (others => '0'); --! Tampon entre le traitment interne et les sorties
  signal sig_port_write_peripheral   :std_logic_vector(31 downto 0) := (others => '0'); --! Tampon entre le traitment interne et les sorties
  signal sig_data_size_peripheral    : std_logic_vector(1 downto 0);                    --! Tampon entre le traitment interne et les sorties
  signal sig_port_free_peripheral    : std_logic:='0';

  ----------Signal Wishbone----------------------
  signal sig_clk      : std_logic:='0';
  signal sig_rst      : std_logic;
  signal sig_adr      : std_logic_vector(1 downto 0);
  signal sig_sel      : std_logic_vector(3 downto 0);
  signal sig_we       : std_logic;
  signal sig_stb      : std_logic;
  signal sig_cyc      : std_logic;
  signal sig_ack      : std_logic;
  signal sig_err      : std_logic;
  signal sig_int      : std_logic;
  signal sig_data_i   :std_logic_vector(7 downto 0);
  signal sig_data_o   :std_logic_vector(7 downto 0);

  ---------Sigaux whishbone_driver----------------------------------
  signal sig_start      : std_logic:='0';
  signal sig_rd_wr      : std_logic:='0';
  signal sig_addr       : std_logic_vector(1 downto 0);
  signal sig_data       : std_logic_vector(7 downto 0);
  signal sig_port_read  : std_logic_vector(7 downto 0);
  signal sig_port_free  : std_logic;

  --------Signaux SPI------------------------------------------------
  signal sig_sclk     :std_logic;
  signal sig_mosi     : std_logic;
  signal sig_miso     :std_logic;

  --------Signaux SPI-----------------------------------------------
  signal sig_n_addr : integer;
  signal sig_n_data : integer;

  type behavior_state is
  (
    fini
    ,BUS_WRITE_SPCR_init
    ,BUS_WRITE_SPER_init
    ,BUS_WRITE_SPSR_init
    ,BUS_WRITE_SPDR_8
    ,BUS_WRITE_SPDR_16
    ,BUS_WRITE_SPDR_24
    ,BUS_WRITE_SPDR_32
    ,BUS_WRITE_SPDR_8_READ
    ,BUS_WRITE_SPDR_16_READ
    ,BUS_WRITE_SPDR_24_READ
    ,BUS_WRITE_SPDR_32_READ
    ,BUS_WRITE_SPDR_8_END
    ,BUS_WRITE_SPDR_16_END
    ,BUS_WRITE_SPDR_24_END
    ,BUS_WRITE_SPDR_32_END
    ,BUS_RESULT
    ,WAIT_WISHBONE_BUSY
    ,WAIT_WISHBONE_FINISH
    ,WAIT_SPI_IRQ
    ,IDLE
  );
  signal etat, etat_futur, etat_futur2 : behavior_state;

  component simple_spi_top
    port
    (
      -- Interfacce Wishbone
      clk_i    : in std_logic                         -- clock pin
      ;rst_i    : in std_logic                        -- reset
      ;we_i     : in std_logic                        -- write enable
      ;stb_i    : in std_logic                        -- strobe
      ;cyc_i    : in std_logic                        -- cycle
      ;ack_o    : out std_logic                       -- normal bus terminaison
      ;inta_o    : out std_logic                      -- interupt output
      ;adr_i    : in std_logic_vector(1 downto 0)     -- address
      ;dat_i    : in std_logic_vector(7 downto 0)     -- data input
      ;dat_o    : out std_logic_vector(7 downto 0)    -- data output
      -- Sortie SPI
      ;sck_o  : out std_logic   -- Serial clock output
      ;mosi_o  : out std_logic  -- MasterOut SlaveIn
      ;miso_i  : in std_logic   -- MasterIn SlaveOut
    );
  end component;

  component WISHBONE_MASTER
    port(
      CLK         : in  std_logic                      --! Clock pin                   --! Reset pin for initialisation
      ;RESET_BAR   : in  std_logic                     --! Reset pin for initialisation
      ;START       : in  std_logic                     --! Start pin for activate transmission
      ;RD_WR       : in  std_logic                     --! Start pin for activate transmission
      ;REG_ADDR    : in  std_logic_vector(1 downto 0)  --! Vecteur permettant de temporiser le registre d'adresse
      ;REG_DATA    : in  std_logic_vector(7 downto 0)  --! Vecteur permettant de temporiser le registre d'adresse                    --! Receive pin for CAN
      ;PORT_0_READ : out std_logic_vector(7 downto 0)
      ;PORT_FREE   : out std_logic                     --! Output which indicate that the time has elapsed
      ;WB_DAT_I    : in  std_logic_vector(7 downto 0)
      ;WB_DAT_O    : out std_logic_vector(7 downto 0)
      ;WB_CYC_O    : out std_logic
      ;WB_STB_O    : out std_logic
      ;WB_ADR_O    : out std_logic_vector(1 downto 0)
      ;WB_WE_O     : out std_logic
      ;WB_ACK_I    : in  std_logic
    );
  end component;

begin

--On instancie les signaux qui sont dans le SPI_top
    spi_top_1 : simple_spi_top port map
    (
      clk_i =>CLK,
      rst_i=>RESET_BAR,
      adr_i=>sig_adr(1 downto 0),
      dat_i=>sig_data_o,
      dat_o=>sig_data_i,
      we_i=>sig_we,
      stb_i=>sig_stb,
      cyc_i=>sig_cyc,
      ack_o=>sig_ack,
      inta_o=>sig_int,
      sck_o=>sig_sclk,
      mosi_o=>sig_mosi,
      miso_i=>sig_miso
  );

  --On instancie les signaux wishbone
  driver_1 : WISHBONE_MASTER port map
  (
    CLK           => CLK,                    --! Clock pin                   --! Reset pin for initialisation
    RESET_BAR     => RESET_BAR,                    --! Reset pin for initialisation
    START         => sig_start,                    --! Start pin for activate transmission
    RD_WR         => sig_rd_wr,                   --! Start pin for activate transmission
    REG_ADDR      => sig_addr,
    REG_DATA      => sig_data,  --! Vecteur permettant de temporiser le registre d'adresse                    --! Receive pin for CAN
    PORT_0_READ   => sig_port_read,
    PORT_FREE     => sig_port_free,                     --! Output which indicate that the time has elapsed
    WB_DAT_I      => sig_data_i,
    WB_DAT_O      => sig_data_o,
    WB_CYC_O      => sig_cyc,
    WB_STB_O      => sig_stb,
    WB_ADR_O      => sig_adr,
    WB_WE_O       => sig_we,
    WB_ACK_I      => sig_ack
  );

  SCK<=sig_sclk;
  MOSI<=sig_mosi;
  sig_miso<=MISO;
  PORT_FREE<=sig_port_free_peripheral ;

---------------------------TRAME POUBELLE-------------------------------------------------------
  process(CLK)
  begin
    if rising_edge(CLK) then
      if RESET_BAR='0' then   -- On réinitialisde le tout.
        sig_port_free_peripheral <= '0';
        etat<=BUS_WRITE_SPCR_init;
        etat_futur <= IDLE;
        etat_futur2 <= IDLE;
        ----------------------------Initialisation des registres pour commencer l'ecriture-----------------------
      else
        case etat is

          when BUS_WRITE_SPCR_init=>
            if(sig_port_free = '1') then
              sig_addr <= SPCR;
              sig_data <= "11010001";
              sig_start <= '1';
              sig_rd_wr <= '1';
              etat <= WAIT_WISHBONE_BUSY;
              etat_futur<=BUS_WRITE_SPER_init;
            end if;

          when BUS_WRITE_SPER_init=>
            if(sig_PORT_FREE = '1') then
              sig_addr <= SPER;
              sig_data <= "00000001";
              sig_start <= '1';
              sig_rd_wr <= '1';
              etat <= WAIT_WISHBONE_BUSY;
              etat_futur<=BUS_WRITE_SPSR_init;
            end if;

          when BUS_WRITE_SPSR_init=>
            if(sig_PORT_FREE = '1') then
              sig_addr <= SPSR;
              sig_data <= "00000000";
              sig_start <= '1';
              sig_rd_wr <= '1';
              etat <= WAIT_WISHBONE_BUSY;
              etat_futur<=IDLE;
            end if;
          -------------------------------debut transmition----------------------------------------
          when IDLE =>
            sig_port_free_peripheral <= '1';
            if(START = '1') then                -- On attend que l'utilisateur manifeste une demande de réception ou d'envoie.
              sig_port_write_peripheral <= PORT_WRITE;     -- On enregistre l'écriture demandée.
              sig_port_read_peripheral <= (others => '0'); -- Réinitialise le tampon de sortie.
              sig_data_size_peripheral <= DATA_SIZE;       -- On enregistre la taille des données à lire ou à écrire.
              sig_port_free_peripheral <= '0';
              etat <= BUS_WRITE_SPDR_8;         -- On passe à l'ecriture du premmier octet.
            end if;

          when BUS_WRITE_SPDR_8 =>
            if(sig_PORT_FREE = '1') then
              sig_addr <= SPDR;
              sig_data <= sig_port_write_peripheral(7 downto 0);
              sig_start <= '1';
              sig_rd_wr <= '1';
              etat <= WAIT_WISHBONE_BUSY;
              etat_futur<=WAIT_SPI_IRQ;
              etat_futur2<=BUS_WRITE_SPDR_8_READ;
            end if;

          when BUS_WRITE_SPDR_8_READ =>
            if(sig_PORT_FREE = '1') then
              sig_addr <= SPDR;
              sig_start <= '1';
              sig_rd_wr <= '0';
              etat <= WAIT_WISHBONE_BUSY;
              etat_futur<=BUS_WRITE_SPDR_8_END;
            end if;

          when BUS_WRITE_SPDR_8_END =>
            sig_port_read_peripheral(7 downto 0) <= sig_port_read;
            if(sig_data_size_peripheral = "00") then
              etat <= BUS_RESULT;
            else
              etat <= BUS_WRITE_SPDR_16;
            end if;

          when BUS_WRITE_SPDR_16 =>
            if(sig_PORT_FREE = '1') then
              sig_addr <= SPDR;
              sig_data <= sig_port_write_peripheral(15 downto 8);
              sig_start <= '1';
              sig_rd_wr <= '1';
              etat <= WAIT_WISHBONE_BUSY;
              etat_futur<=WAIT_SPI_IRQ;
              etat_futur2<=BUS_WRITE_SPDR_16_READ;
            end if;

          when BUS_WRITE_SPDR_16_READ =>
            if(sig_PORT_FREE = '1') then
              sig_addr <= SPDR;
              sig_start <= '1';
              sig_rd_wr <= '0';
              etat <= WAIT_WISHBONE_BUSY;
              etat_futur<=BUS_WRITE_SPDR_16_END;
            end if;

          when BUS_WRITE_SPDR_16_END =>
            sig_port_read_peripheral(15 downto 8) <= sig_port_read;
            if(sig_data_size_peripheral = "01") then
              etat <= BUS_RESULT;
            else
              etat <= BUS_WRITE_SPDR_24;
            end if;

          when BUS_WRITE_SPDR_24=>
            if(sig_PORT_FREE = '1') then
              sig_addr <= SPDR;
              sig_data <= sig_port_write_peripheral(23 downto 16);
              sig_start <= '1';
              sig_rd_wr <= '1';
              etat <= WAIT_WISHBONE_BUSY;
              etat_futur<=WAIT_SPI_IRQ;
              etat_futur2<=BUS_WRITE_SPDR_24_READ;
            end if;

          when BUS_WRITE_SPDR_24_READ =>
            if(sig_PORT_FREE = '1') then
              sig_addr <= SPDR;
              sig_start <= '1';
              sig_rd_wr <= '0';
              etat <= WAIT_WISHBONE_BUSY;
              etat_futur<=BUS_WRITE_SPDR_24_END;
            end if;

          when BUS_WRITE_SPDR_24_END =>
            sig_port_read_peripheral(23 downto 16) <= sig_port_read;
            if(sig_data_size_peripheral = "10") then
              etat <= BUS_RESULT;
            else
              etat <= BUS_WRITE_SPDR_32;
            end if;

          when BUS_WRITE_SPDR_32=>
            if(sig_PORT_FREE = '1') then
              sig_addr <= SPDR;
              sig_data <= sig_port_write_peripheral(31 downto 24);
              sig_start <= '1';
              sig_rd_wr <= '1';
              etat <= WAIT_WISHBONE_BUSY;
              etat_futur<=WAIT_SPI_IRQ;
              etat_futur2<=BUS_WRITE_SPDR_32_READ;
            end if;

          when BUS_WRITE_SPDR_32_READ =>
            if(sig_PORT_FREE = '1') then
              sig_addr <= SPDR;
              sig_start <= '1';
              sig_rd_wr <= '0';
              etat <= WAIT_WISHBONE_BUSY;
              etat_futur<=BUS_WRITE_SPDR_32_END;
            end if;

          when BUS_WRITE_SPDR_32_END =>
            sig_port_read_peripheral(31 downto 24) <= sig_port_read;
            etat <= BUS_RESULT;

          when BUS_RESULT =>
            PORT_READ <= sig_port_read_peripheral;
            etat <= IDLE;
            etat_futur <= IDLE;
            etat_futur2 <= IDLE;

          when WAIT_WISHBONE_BUSY =>
            if(sig_PORT_FREE = '0') then
              sig_start <= '0';
              etat <= WAIT_WISHBONE_FINISH;
            end if;

          when WAIT_WISHBONE_FINISH =>
            if(sig_PORT_FREE = '1') then
              sig_start <= '0';
              etat <= etat_futur;
            end if;

          when WAIT_SPI_IRQ =>
            if(sig_int = '1') then
              sig_addr <= SPSR;
              sig_data <= "10000000";
              sig_start <= '1';
              sig_rd_wr <= '1';
              etat <= WAIT_WISHBONE_BUSY;
              etat_futur <= etat_futur2;
            end if;

          when others =>
            etat <= IDLE;
            etat_futur <= IDLE;
            etat_futur2 <= IDLE;

        end case;
      end if;
    end if;
  end process;

end Behavioral;
