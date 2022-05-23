----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 28.07.2021 10:46:31
-- Design Name:
-- Module Name: I2C_CONTROLER - Behavioral
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
use ieee.numeric_std.all;
--library NX;
--use NX.nxPackage.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity I2C_CONTROLER is
  Port (
        CLK                     : in std_logic;
        RESET_BAR               : in std_logic;
        START_HOUSEKEEPING      : in std_logic;
        ACQ_HOUSEKEEPING        : out std_logic;
        PORT_FREE               : out std_logic;
        SCL                     : inout std_logic;
        SDA                     : inout std_logic
  );
end I2C_CONTROLER;

architecture Behavioral of I2C_CONTROLER is

    constant ADDR_TEMP_NG_MEDIUM        : std_logic_vector(6 downto 0) := "1001000"; --! Adresse de temperature du NG-Medium
    constant ADDR_TEMP_RADFET_1         : std_logic_vector(6 downto 0) := "1001001"; --! Adresse de temperature de la tete detection 1
    constant ADDR_TEMP_RADFET_2         : std_logic_vector(6 downto 0) := "1001010"; --! Adresse de temperature de la tete detection 2
    constant ADDR_TEMP_PCB_CONDTIONNEUR : std_logic_vector(6 downto 0) := "1001011"; --! Adresse de temperature du JFET A de la tete detection 1
    constant ADDR_TEMP_PCB_ACQUISITION  : std_logic_vector(6 downto 0) := "1001100"; --! Adresse de temperature du JFET A de la tete detection 1
    constant ADDR_TEMP_PCB_NUMERIQUE    : std_logic_vector(6 downto 0) := "1001101"; --! Adresse de temperature du JFET B de la tete detection 2
    constant ADDR_TEMP_PCB_PUISSANCE    : std_logic_vector(6 downto 0) := "1001110"; --! Adresse de temperature du JFET B de la tete detection 2

    type behavior_state is
  (
    IDLE
    ,ACQ_TEMP_NG_MEDIUM
    ,ACQ_TEMP_RADFET_1
    ,ACQ_TEMP_RADFET_2
    ,ACQ_TEMP_PCB_CONDTIONNEUR
    ,ACQ_TEMP_PCB_ACQUISITION
    ,ACQ_TEMP_PCB_NUMERIQUE
    ,ACQ_TEMP_PCB_PUISSANCE
    ,WAIT_PERIPHERAL_START_WORKING
    ,WAIT_PERIPHERAL_FINISH_WORKING
  );

    signal etat, etat_futur : behavior_state;

    signal sig_CLK              : std_logic:='0';
    signal sig_RESET_BAR        : std_logic:='0';
    signal sig_START            : std_logic:='0';
    signal sig_ACQ_HOUSEKEEPING : std_logic:='0';
    signal sig_RD_WR            : std_logic:='0';
    signal sig_PORT_READ        : std_logic_vector(31 downto 0);
    signal sig_PORT_WRITE_ADDR  : std_logic_vector(6 downto 0);    --! signal decriture du module
    signal sig_PORT_WRITE_DATA  : std_logic_vector(31 downto 0);    --! Port decriture du module
    signal sig_PORT_FREE        : std_logic;
    signal sig_DATA_SIZE        : std_logic_vector(1 downto 0);
--    signal sig_SCL              : std_logic;                        -- Serial Clock line
--    signal sig_SDA              : std_logic;                        -- Serial Data line input


component I2C_PERIPHERAL
    port(
      CLK               : in      std_logic
      ;RESET_BAR        : in      std_logic
      ;START            : in      std_logic                       --! Start pin for activate transmission
      ;RD_WR            : in      std_logic                       --! Start pin for activate transmission
      ;PORT_READ        : out     std_logic_vector(31 downto 0)   --! Port de lecteure du module
      ;PORT_WRITE_ADDR  : in      std_logic_vector(6 downto 0)    --! Port decriture du module
      ;PORT_WRITE_DATA  : in      std_logic_vector(31 downto 0)   --! Port decriture du module
      ;PORT_FREE        : out     std_logic                       --! Indicateur de disponibilite du module (0 : occupe et 1 : libre)
      ;DATA_SIZE        : in      std_logic_vector(1 downto 0)    --! Taille de la donnee a envoyer 00 -> 8 bits, 01 -> 16 bits, 10 -> 24bits, 11 -> 32 bits.
      ;SCL              : inout   std_logic -- Serial Clock line
      ;SDA              : inout   std_logic -- Serial Data line input
    );
end component;

begin

    my_i2c_peripheral : I2C_PERIPHERAL port map
    (
      CLK             =>  sig_CLK,
      RESET_BAR       =>  sig_RESET_BAR,
      START           =>  sig_START,
      RD_WR           =>  sig_RD_WR,
      PORT_READ       =>  sig_PORT_READ,
      PORT_WRITE_ADDR =>  sig_PORT_WRITE_ADDR,
      PORT_WRITE_DATA =>  sig_PORT_WRITE_DATA,
      PORT_FREE       =>  sig_PORT_FREE,
      DATA_SIZE       =>  sig_DATA_SIZE,
      SCL             =>  SCL,
      SDA             =>  SDA
    );

    sig_CLK           <= CLK;
    sig_RESET_BAR     <= RESET_BAR;
    ACQ_HOUSEKEEPING  <= sig_ACQ_HOUSEKEEPING;
  process(CLK)

    -- Procedure permettant de demande une reception de donnees a un peripherique I2C
    procedure read_i2c_driver
    (
      ADDR  : in std_logic_vector(6 downto 0) := "0000000"  -- Adresse du peripherique a adresser
      ;SIZE : in std_logic_vector(1 downto 0) := "00"       -- Taille des donnée attendues
    ) is
    begin
      sig_PORT_WRITE_ADDR <= ADDR;          -- Adresse I2C visee
      sig_DATA_SIZE <= SIZE;                -- On specifie la taille
      sig_RD_WR <= '0';                     -- On demande une lecture a cette adresse
      sig_START <= '1';                     -- On lance le module
    etat <= WAIT_PERIPHERAL_START_WORKING;
    end read_i2c_driver;

  begin
    if rising_edge(CLK) then
      if RESET_BAR = '0' then   -- On réinitialise le tout.
        sig_START<='0';
        sig_PORT_WRITE_ADDR <=  (others=>'0');
        sig_PORT_WRITE_DATA <=  (others=>'0');
        sig_ACQ_HOUSEKEEPING <= '0';
        sig_RD_WR<='0';
        PORT_FREE <= '0';
        etat <= IDLE;
      else
        case etat is
          when IDLE=>
            PORT_FREE <= '1';
            etat_futur <= IDLE;
            if START_HOUSEKEEPING = '1' then    -- Le temps est écoulé on fait un tours des capteurs
                PORT_FREE <= '0';
                etat <= ACQ_TEMP_NG_MEDIUM;
            end if;

        when ACQ_TEMP_NG_MEDIUM =>
            read_i2c_driver(ADDR_TEMP_NG_MEDIUM,"01");
            etat_futur <= ACQ_TEMP_RADFET_1;

        when ACQ_TEMP_RADFET_1 =>
            read_i2c_driver(ADDR_TEMP_RADFET_1,"01");
            etat_futur <= ACQ_TEMP_RADFET_2;

        when ACQ_TEMP_RADFET_2 =>
            read_i2c_driver(ADDR_TEMP_RADFET_2,"01");
            etat_futur <= ACQ_TEMP_PCB_CONDTIONNEUR;

        when ACQ_TEMP_PCB_CONDTIONNEUR =>
            read_i2c_driver(ADDR_TEMP_PCB_CONDTIONNEUR,"01");
            etat_futur <= ACQ_TEMP_PCB_ACQUISITION;

        when ACQ_TEMP_PCB_ACQUISITION =>
            read_i2c_driver(ADDR_TEMP_PCB_ACQUISITION,"01");
            etat_futur <= ACQ_TEMP_PCB_NUMERIQUE;

        when ACQ_TEMP_PCB_NUMERIQUE =>
            read_i2c_driver(ADDR_TEMP_PCB_NUMERIQUE,"01");
            etat_futur <= ACQ_TEMP_PCB_PUISSANCE;

        when ACQ_TEMP_PCB_PUISSANCE =>
            read_i2c_driver(ADDR_TEMP_PCB_PUISSANCE,"01");
            etat_futur <= IDLE;

        when WAIT_PERIPHERAL_START_WORKING =>
            if sig_PORT_FREE = '0' then -- La prise en compte est faite
                sig_START <= '0';  -- On relache le start
                etat <= WAIT_PERIPHERAL_FINISH_WORKING;
            end if;

        when WAIT_PERIPHERAL_FINISH_WORKING =>
            if sig_PORT_FREE = '1' then -- La prise en compte est faite
                etat <= etat_futur;
            end if;

        when others =>

        end case;
      end if;
    end if;
  end process;
end Behavioral;
