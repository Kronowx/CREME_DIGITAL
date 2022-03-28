----------------------------------------------------------------------------------
-- Company: ONERA
-- Engineer: guillaume.gourves@onera.fr
--
-- Create Date: 20.07.2018 10:55:35
-- Design Name:
-- Module Name: tb_TOP_basic - Behavioral
-- Project Name: CREME
-- Target Devices: NG-MEDIUM (NanoXplore)
-- Tool Versions: NxMap3
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
use ieee.std_logic_textio.all;
use STD.textio.all;
use ieee.numeric_std.all;

entity tb_I2C_PERIPHERAL is
end tb_I2C_PERIPHERAL;

architecture Behavioral of tb_I2C_PERIPHERAL is
  constant device_addr      : std_logic_vector(6 downto 0)    :=  "0010000";
  constant device_word_send : std_logic_vector(31 downto 0)   :=  x"A5A5A5A5";

  signal sig_CLK              :  std_logic :='0';
  signal sig_RESET_BAR        :  std_logic :='0';
  signal sig_START            :  std_logic :='0';                     --! Start pin for activate transmission
  signal sig_RD_WR            :  std_logic :='0';                     --! Start pin for activate transmission
  signal sig_PORT_READ        :  std_logic_vector(31 downto 0)  :=  (others => '0');
  signal sig_PORT_WRITE_ADDR  :  std_logic_vector(6 downto 0)   :=  (others => '0');
  signal sig_PORT_WRITE_DATA  :  std_logic_vector(31 downto 0)  :=  (others => '0');
  signal sig_PORT_FREE        :  std_logic :='0'; -- correspond � l'ack
  signal sig_DATA_SIZE        :  std_logic_vector(1 downto 0) :=  (others => '0');
  signal sig_SCL              :  std_logic;
  signal sig_SDA              :  std_logic;

component I2C_PERIPHERAL is
  port
    (
      CLK       : in std_logic
      ;RESET_BAR : in std_logic

      ;START            : in  std_logic                       --! Start pin for activate transmission
      ;RD_WR            : in  std_logic                       --! Start pin for activate transmission
      ;PORT_READ        : out std_logic_vector(31 downto 0)   --! Port de lecteure du module
      ;PORT_WRITE_ADDR  : in  std_logic_vector(6 downto 0)    --! Port decriture du module
      ;PORT_WRITE_DATA  : in  std_logic_vector(31 downto 0)   --! Port decriture du module
      ;PORT_FREE        : out std_logic                       --! Indicateur de disponibilite du module (0 : occupe et 1 : libre)
      ;DATA_SIZE        : in  std_logic_vector(1 downto 0)    --! Taille de la donnee a envoyer 00 -> 8 bits, 01 -> 16 bits, 10 -> 24bits, 11 -> 32 bits.

      ;SCL              : inout  std_logic -- Serial Clock line
      ;SDA              : inout  std_logic -- Serial Data line input
    );
end component;

component i2c_slave_model is
  Port
    (
      scl : in    std_logic
      ;sda : inout std_logic
    );
end component;

begin

  evaluate_I2C_PERIPHERAL : I2C_PERIPHERAL
  Port map
  (
    CLK               => sig_CLK
    ,RESET_BAR         => sig_RESET_BAR
    ,START             => sig_START
    ,RD_WR             => sig_RD_WR
    ,PORT_READ         => sig_PORT_READ
    ,PORT_WRITE_ADDR   => sig_PORT_WRITE_ADDR
    ,PORT_WRITE_DATA   => sig_PORT_WRITE_DATA
    ,PORT_FREE         => sig_PORT_FREE
    ,DATA_SIZE         => sig_DATA_SIZE
    ,SCL               => sig_SCL
    ,SDA               => sig_SDA
  );

  simulateur_slave : i2c_slave_model
  Port map
  (
    scl   => sig_SCL
    ,sda  => sig_SDA
  );

  PROCESS_CLOCK : process
  begin
    sig_CLK <= not(sig_CLK);
    wait for 5 ns;
  end process;

  PROCESS_TB : process

    -- Procedure permettant de demande un envoie de donnees a un peripherique I2C
    procedure write_i2c_driver
    (
      ADDR  : in std_logic_vector(6 downto 0) := "0000000"
      ;DATA : in std_logic_vector(31 downto 0) := (others => '0')
      ;SIZE : in std_logic_vector(1 downto 0) := "00"
    ) is
    begin
      sig_PORT_WRITE_ADDR <= ADDR;          -- Adresse I2C visee 0x53
      sig_PORT_WRITE_DATA <= DATA;          -- On indique le message a transmettre
      sig_DATA_SIZE <= SIZE;                -- On specifie la taille
      sig_RD_WR <= '1';                     -- On demande une ecriture a cette adresse
      sig_START <= '1';                     -- On lance le module
      wait until sig_PORT_FREE = '0';       -- On attend que le module se mette en mode occupe
      sig_START <= '0';                     -- On passe a zero le bit de demarrage (evite les demarrages multiple)
      wait until sig_PORT_FREE = '1';       -- On attend que le module soit de nouveau disponible (indique quye la tache a ete realise).
    end write_i2c_driver;

    -- Procedure permettant de demande une reception de donnees a un peripherique I2C
    procedure read_i2c_driver
    (
      ADDR  : in std_logic_vector(6 downto 0) := "0000000"
      ;SIZE : in std_logic_vector(1 downto 0) := "00"
    ) is
    begin
      sig_PORT_WRITE_ADDR <= ADDR;          -- Adresse I2C visee 0x53
      sig_DATA_SIZE <= SIZE;                -- On specifie la taille
      sig_RD_WR <= '0';                     -- On demande une lecture a cette adresse
      sig_START <= '1';                     -- On lance le module
      wait until sig_PORT_FREE = '0';       -- On attend que le module se mette en mode occupe
      sig_START <= '0';                     -- On passe a zero le bit de demarrage (evite les demarrages multiple)
      wait until sig_PORT_FREE = '1';       -- On attend que le module soit de nouveau disponible (indique quye la tache a ete realise).
    end read_i2c_driver;

  begin
  
  -- ATTENTION IL FAUT PENSER A RECHANGER RST 
  
  
    sig_RESET_BAR <= '1';             -- On lance la procédure de RESET 
    wait for 100 us;                  -- Pendant un temps
    sig_RESET_BAR <= '0';             -- On relache le Reset
    wait until sig_PORT_FREE = '1';   -- On attend que le module SPI_PERIPHERAL soit disponible
    write_i2c_driver(device_addr,device_word_send,"00"); -- Ecriture d'un paquet de 8 bits
    write_i2c_driver(device_addr,device_word_send,"01"); -- Ecriture d'un paquet de 16 bits
    write_i2c_driver(device_addr,device_word_send,"10"); -- Ecriture d'un paquet de 24 bits
    write_i2c_driver(device_addr,device_word_send,"11"); -- Ecriture d'un paquet de 32 bits
    wait;

  end process;
end Behavioral;
