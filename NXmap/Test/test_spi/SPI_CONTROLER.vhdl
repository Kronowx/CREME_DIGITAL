----------------------------------------------------------------------------------
-- Company: ONERA
-- Engineer: guillaume.gourves@onera.fr
--
-- Create Date: 18.06.2021 16:15:52
-- Design Name:
-- Module Name: SPI_CONTROLER - Behavioral
-- Project Name:CREME
-- Target Devices: NG-MEDIUM (NanoXplore)
-- Tool Versions: NxMap3
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
use ieee.numeric_std.all;

-- Librairies specifique au NG-Medium
--library NX;
--use NX.nxPackage.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPI_CONTROLER is
    Port
    (
        CLK                 : in std_logic  --! Signal d'horloge permettant a ce module de fonctionner.
        ;RESET_BAR          : in std_logic  --! Signal de reinitialisation de ce module
        ;PULSE_SHAPER_FAST  : in std_logic  --! Signal déclencheur d'un transfert SPI.
        ;HISTO_ACQ          : in std_logic  --! Signal déclencheur d'un transfert SPI.
        ;HISTO_SIGNAL       : out std_logic  --! Signal déclencheur d'un transfert SPI.
        ;SAMPLE             : out std_logic_vector (31 downto 0)
        ;SCK                : out std_logic --! Clock en sortie du module SPI
        ;MOSI               : out std_logic --! MOSI en sortie du module SPI
        ;MISO               : in std_logic  --! MISO en sortie du module SPI
    );
end SPI_CONTROLER;

architecture Behavioral of SPI_CONTROLER is

type SPI_CONTROLER_state is
  (
    IDLE
    ,START_RELEASE
    ,ACQUISITION
    ,HISTOGRAM_ACQ
  );
  signal etat, etat_futur : SPI_CONTROLER_state;

  signal sig_CLK            :  std_logic :='0';
  signal sig_RESET_BAR      :  std_logic :='0';
  signal sig_START          :  std_logic :='0';                     --! Start pin for activate transmission
  signal sig_PORT_READ      :  std_logic_vector(31 downto 0) :=  (others => '0');
  signal sig_PORT_WRITE     :  std_logic_vector(31 downto 0) :=  (others => '0');
  signal sig_PORT_FREE      :  std_logic :='0'; -- correspond � l'ack
  signal sig_DATA_SIZE      :  std_logic_vector(1 downto 0) :=  (others => '0');
  signal sig_SCK            :  std_logic :='0';
  signal sig_MOSI           :  std_logic :='0';
  signal sig_MISO           :  std_logic :='0';

component SPI_PERIPHERAL
  port
  (
    CLK         : in std_logic                                  --! Signaux de clock permettant le fonctionnement du module
    ;RESET_BAR  : in std_logic                           --! Pin de RESET (actif à l'état bas).
    ;START      : in    std_logic                     --! Start pin for activate transmission
    ;PORT_READ  : out   std_logic_vector(31 downto 0)   --! Port de lecteure du module
    ;PORT_WRITE : in   std_logic_vector(31 downto 0)    --! Port decriture du module
    ;PORT_FREE  : out   std_logic                     --! Indicateur de disponibilite du module (0 : occupe et 1 : libre)
    ;DATA_SIZE  : in std_logic_vector(1 downto 0)       --! Taille de la donnee a envoyer 00 -> 8 bits, 01 -> 16 bits, 10 -> 24bits, 11 -> 32 bits.
    ;SCK        : out std_logic                               --! Clock en sortie du module SPI
    ;MOSI       : out std_logic                               --! MOSI en sortie du module SPI
    ;MISO       : in std_logic                                --! MISO en sortie du module SPI
  );
  end component;

begin

  SPI_PERIPHERAL_CREME : SPI_PERIPHERAL port map
  (
    CLK           => sig_CLK,
    RESET_BAR     => sig_RESET_BAR,
    START         => sig_START,
    PORT_READ     => sig_PORT_READ,
    PORT_WRITE    => sig_PORT_WRITE,
    DATA_SIZE     => sig_DATA_SIZE,
    PORT_FREE     => sig_PORT_FREE,
    SCK           => sig_SCK,
    MOSI          => sig_MOSI,
    MISO          => sig_MISO
  );

  sig_CLK <= CLK;
  sig_RESET_BAR<=RESET_BAR;
  MOSI<=sig_mosi;
  sig_miso<=MISO;
  SCK <= sig_SCK;
  SAMPLE <= sig_PORT_READ;

  process(CLK)
  begin
    if rising_edge(CLK) then
      if sig_RESET_BAR='0' then   -- On réinitialisde le tout.
        sig_PORT_WRITE <= (others => '0');
        HISTO_SIGNAL <= '0';
        etat<=IDLE;
      else
        case etat is
        when IDLE =>
          if PULSE_SHAPER_FAST = '1' then
            if sig_PORT_FREE ='1' then
              sig_PORT_WRITE <= x"A5A5A5A5";
              sig_DATA_SIZE <= "10";
              sig_START <= '1';
              etat<=START_RELEASE;
            end if;
          end if;

        when START_RELEASE =>
          if sig_PORT_FREE = '0' then
            sig_START <= '0';
            etat<=ACQUISITION;
          end if;

        when ACQUISITION =>
          if sig_PORT_FREE = '1' then
            HISTO_SIGNAL <= '1';
            etat<=HISTOGRAM_ACQ;
          end if;

        when HISTOGRAM_ACQ =>
        if HISTO_ACQ = '1' then
          HISTO_SIGNAL <= '0';
          etat<=IDLE;
        end if;

        when others => -- Si on est l�  : c'est qu'il y a baleine sous cailloux!
          etat <= IDLE;

        end case;
      end if;
    end if;
  end process;


end Behavioral;
