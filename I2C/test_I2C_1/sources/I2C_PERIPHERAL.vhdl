----------------------------------------------------------------------------------
-- Company:   ONERA
-- Engineer:  guillaume.gourves@onera.fr
--
-- Create Date: 28.07.2021 08:42:22
-- Design Name:
-- Module Name: I2C_PERIPHERAL - Behavioral
-- Project Name: CREME
-- Target Devices: NG-MEDIUM
-- Tool Versions: Nxmap3
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: Thanks to the author of I2C-Master Core
-- Specification -> Richard Herveille (rherveille@opencores.org)
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

entity I2C_PERIPHERAL is
  Port (
        CLK       : in std_logic
        ;RESET_BAR : in std_logic

        ;START            : in  std_logic                       --! Start pin for activate transmission
        ;RD_WR            : in  std_logic                       --! Start pin for activate transmission
        ;PORT_READ        : out std_logic_vector(31 downto 0)   --! Port de lecteure du module
        ;PORT_WRITE_ADDR  : in  std_logic_vector(6 downto 0)    --! Port decriture du module
        ;PORT_WRITE_DATA  : in  std_logic_vector(31 downto 0)   --! Port decriture du module
        ;PORT_FREE        : out std_logic                       --! Indicateur de disponibilite du module (0 : occupe et 1 : libre)
        ;DATA_SIZE        : in  std_logic_vector(1 downto 0)    --! Taille de la donnee a envoyer 00 -> 8 bits, 01 -> 16 bits, 10 -> 24bits, 11 -> 32 bits.

        ;SCL              :inout  std_logic -- Serial Clock line
        ;SDA              :inout  std_logic -- Serial Data line input
  );

end I2C_PERIPHERAL;

architecture Behavioral of I2C_PERIPHERAL is

--------Adresse registre ---------------------
constant PRERlo : std_logic_vector(2 downto 0)  :=  "000"; -- Clock Prescale register lo-byte
constant PRERhi : std_logic_vector(2 downto 0)  :=  "001"; -- Clock Prescale register hi-byte
constant CTR    : std_logic_vector(2 downto 0)  :=  "010"; -- Control register
constant TXR    : std_logic_vector(2 downto 0)  :=  "011"; -- Transmit register
constant RXR    : std_logic_vector(2 downto 0)  :=  "011"; -- Receive register
constant CR     : std_logic_vector(2 downto 0)  :=  "100"; -- Command register
constant SR     : std_logic_vector(2 downto 0)  :=  "100"; -- Status register
-----Valeur des registre---------------------
constant prescalerbin : std_logic_vector(15 downto 0) := "0000000110010000";
constant ctrInit : std_logic_vector(7 downto 0) := "11000000";

----------Signaux interne----------------------
signal sig_port_read_peripheral         : std_logic_vector(31 downto 0) := (others => '0'); --! Tampon entre le traitment interne et les sorties
signal sig_port_write_data_peripheral   : std_logic_vector(31 downto 0) := (others => '0'); --! Tampon entre le traitment interne et les sorties
signal sig_port_write_addr_peripheral   : std_logic_vector(6 downto 0) := (others => '0'); --! Tampon entre le traitment interne et les sorties
signal sig_data_size_peripheral         : std_logic_vector(1 downto 0);                    --! Tampon entre le traitment interne et les sorties
signal sig_port_free_peripheral         : std_logic:='0';
signal sig_rd_wr_peripheral             : std_logic:='0';
------------signaax wishbone----------------------------
signal sig_arst       : std_logic;
signal sig_inta       : std_logic;

----------Signal Wishbone----------------------
signal sig_clk      : std_logic:='0';
signal sig_rst      : std_logic;
signal sig_adr      : std_logic_vector(2 downto 0);
signal sig_sel      : std_logic_vector(3 downto 0);
signal sig_we       : std_logic;
signal sig_stb      : std_logic;
signal sig_cyc      : std_logic;
signal sig_ack      : std_logic;
signal sig_err      : std_logic;
signal sig_int      : std_logic;
signal sig_data_i   : std_logic_vector(7 downto 0);
signal sig_data_o   : std_logic_vector(7 downto 0);

---------Sigaux whishbone_driver----------------------------------
signal sig_start      : std_logic:='0';
signal sig_rd_wr      : std_logic:='0';
signal sig_addr       : std_logic_vector(2 downto 0);
signal sig_data       : std_logic_vector(7 downto 0);
signal sig_port_read  : std_logic_vector(7 downto 0);
signal sig_port_free  : std_logic;

-------signaux I2C--------------------
signal sig_scl_pad_i      : std_logic;
signal sig_scl_pad_o      : std_logic;
signal sig_scl_padoen_o   : std_logic;
signal sig_sda_pad_i      : std_logic;
signal sig_sda_pad_o      : std_logic;
signal sig_sda_padoen_o   : std_logic;

type behavior_state is
(
  IDLE
  ,BUS_WRITE_PRERlo_init
  ,BUS_WRITE_PRERhi_init
  ,BUS_WRITE_CTR_init
  ,BUS_WRITE_ADDR
  ,BUS_WRITE_ADDR_END
  ,BUS_WRITE_DATA_8
  ,BUS_WRITE_DATA_16
  ,BUS_WRITE_DATA_24
  ,BUS_WRITE_DATA_32
  ,BUS_WRITE_DATA_8_END
  ,BUS_WRITE_DATA_16_END
  ,BUS_WRITE_DATA_24_END
  ,BUS_WRITE_DATA_32_END
  ,BUS_READ_DATA_8
  ,BUS_READ_DATA_16
  ,BUS_READ_DATA_24
  ,BUS_READ_DATA_32
  ,BUS_READ_DATA_8_READ
  ,BUS_READ_DATA_16_READ
  ,BUS_READ_DATA_24_READ
  ,BUS_READ_DATA_32_READ
  ,BUS_READ_DATA_8_END
  ,BUS_READ_DATA_16_END
  ,BUS_READ_DATA_24_END
  ,BUS_READ_DATA_32_END
  ,WAIT_WISHBONE_BUSY
  ,WAIT_WISHBONE_FINISH
  ,WAIT_I2C_IRQ
  ,BUS_READ_STATUS
  ,BUS_READ_STATUS_CHECK
  ,BUS_RESULT
);
signal etat, etat_futur, etat_futur2 : behavior_state;

component i2c_master_top
  port
  (
    ------------wishbone signal-----------------------
    wb_clk_i     : in   std_logic;                      -- master clock input
    wb_rst_i     : in   std_logic;                      -- synchronous active high reset
    arst_i       : in   std_logic;                      -- asynchronous reset
    wb_adr_i     : in   std_logic_vector(2 downto 0);   -- lower address bits
    wb_dat_i     : in   std_logic_vector(7 downto 0);   -- databus input
    wb_dat_o     : out  std_logic_vector(7 downto 0);   -- databus output
    wb_we_i      : in   std_logic;                      -- write enable input
    wb_stb_i     : in   std_logic;                      -- stobe/core select signal
    wb_cyc_i     : in   std_logic;                      -- valid bus cycle input
    wb_ack_o     : out  std_logic;                      -- bus cycle acknowledge output
    wb_inta_o    : out  std_logic;                      -- interrupt request signal output
    -------------------i2c signal---------------------
    scl_pad_i    : in std_logic;  -- SCL-line input
    scl_pad_o    : out std_logic; -- SCL-line output (always 1'b0)
    scl_padoen_o : out std_logic; -- SCL-line output enable (active low)
    sda_pad_i    : in std_logic;  -- SDA-line input
    sda_pad_o    : out std_logic; -- SDA-line output (always 1'b0)
    sda_padoen_o : out std_logic  -- SDA-line output enable (active low)
  );
end component;

component WISHBONE_MASTER
  port(
    CLK         : in  std_logic                      --! Clock pin
    ;RESET_BAR   : in  std_logic                     --! Reset pin for initialisation
    ;START       : in  std_logic                     --! Start pin for activate transmission
    ;RD_WR       : in  std_logic                     --! Start pin for activate transmission
    ;REG_ADDR    : in  std_logic_vector(2 downto 0)  --! Vecteur permettant de temporiser le registre d'adresse
    ;REG_DATA    : in  std_logic_vector(7 downto 0)  --! Vecteur permettant de temporiser le registre d'adresse
    ;PORT_0_READ : out std_logic_vector(7 downto 0)
    ;PORT_FREE   : out std_logic                     --! Output which indicate that the time has elapsed
    ;WB_DAT_I    : in  std_logic_vector(7 downto 0)
    ;WB_DAT_O    : out std_logic_vector(7 downto 0)
    ;WB_CYC_O    : out std_logic
    ;WB_STB_O    : out std_logic
    ;WB_ADR_O    : out std_logic_vector(2 downto 0)
    ;WB_WE_O     : out std_logic
    ;WB_ACK_I    : in  std_logic
  );
end component;

begin

    i2c_top_1 : i2c_master_top port map
    (
      wb_clk_i=>CLK,
      wb_rst_i=>RESET_BAR,
      arst_i=>'0',
      wb_adr_i=>sig_adr,
      wb_dat_i=>sig_data_o,
      wb_dat_o=>sig_data_i,
      wb_we_i=>sig_we,
      wb_stb_i=>sig_stb,
      wb_cyc_i=>sig_cyc,
      wb_ack_o=>sig_ack,
      wb_inta_o=>sig_inta,
      scl_pad_i=>sig_scl_pad_i,
      scl_pad_o=>sig_scl_pad_o,
      scl_padoen_o=>sig_scl_padoen_o,
      sda_pad_i=>sig_sda_pad_i,
      sda_pad_o=>sig_sda_pad_o,
      sda_padoen_o=>sig_sda_padoen_o
    );

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

    SCL <= sig_scl_pad_o when (sig_scl_padoen_o = '0') else 'Z';
    SDA <= sig_sda_pad_o when (sig_sda_padoen_o = '0') else 'Z';
    sig_scl_pad_i <= SCL;
    sig_scl_pad_i <= SDA;

    PORT_FREE <= sig_port_free_peripheral;

    PROCESS_I2C : process(CLK)
      procedure write_wishbone
      (
        constant proc_reg_addr : in std_logic_vector(2 downto 0) --:= "000"
        ;proc_reg_data : in std_logic_vector(7 downto 0) --:= x"00"
      ) is
      begin
              sig_addr <= proc_reg_addr;
              sig_data <= proc_reg_data;
              sig_start <= '1';
              sig_rd_wr <= '1';
      end write_wishbone;

      procedure read_wishbone
      (
        constant proc_reg_addr : in std_logic_vector(2 downto 0) --:= "000"
      ) is
      begin
              sig_addr <= proc_reg_addr;
              sig_data <= (others => '0');
              sig_start <= '1';
              sig_rd_wr <= '0';
      end read_wishbone;

    begin
      if rising_edge(CLK) then
        if RESET_BAR = '0' then   -- On réinitialisde le tout.
          sig_port_read_peripheral <= (others => '0');
          sig_port_write_data_peripheral <= (others => '0');
          sig_port_write_addr_peripheral <= (others => '0');
          sig_data_size_peripheral <= (others => '0');
          sig_port_free_peripheral <= '0';
          etat<=BUS_WRITE_PRERlo_init;
        else
          case etat is
            -------------- Initialisation du peripherique I2C ---------------
            when BUS_WRITE_PRERlo_init=>
              if(sig_port_free = '1') then
                write_wishbone(PRERlo,prescalerbin(7 downto 0));
                etat <= WAIT_WISHBONE_BUSY;
                etat_futur<=BUS_WRITE_PRERhi_init;
              end if;

            when BUS_WRITE_PRERhi_init=>
              if(sig_port_free = '1') then
                write_wishbone(PRERhi,prescalerbin(15 downto 8));
                etat <= WAIT_WISHBONE_BUSY;
                etat_futur<=BUS_WRITE_CTR_init;
              end if;

            when BUS_WRITE_CTR_init=>
              if(sig_port_free = '1') then
                write_wishbone(CTR,ctrInit);
                etat_futur<=IDLE;
                etat <= WAIT_WISHBONE_BUSY;
              end if;

            -------------- Routine -----------------------------------------
            when IDLE =>
              sig_port_free_peripheral <= '1';
              if (START = '1') then
                sig_port_write_addr_peripheral <= PORT_WRITE_ADDR;  -- On enregistre l'adresse du module a pointer.
                sig_port_write_data_peripheral <= PORT_WRITE_DATA;  -- On enregistre les donnees du module a pointer.
                sig_port_read_peripheral <= (others => '0');        -- Réinitialise le tampon de sortie.
                sig_data_size_peripheral <= DATA_SIZE;              -- On enregistre la taille des données à lire ou à écrire.
                sig_rd_wr_peripheral <= RD_WR;
                sig_port_free_peripheral <= '0';
                etat <= BUS_WRITE_ADDR;         -- On passe à l'ecriture du premmier octet.
              end if;

            -------------------Adresse--------------------------
            when BUS_WRITE_ADDR =>
              if(sig_port_free = '1') then
                if (sig_rd_wr_peripheral = '0') then-- lecture
                  write_wishbone(TXR,sig_port_write_addr_peripheral & '1');
                else
                  write_wishbone(TXR,sig_port_write_addr_peripheral & '0');
                end if;
                etat <= WAIT_WISHBONE_BUSY;
                etat_futur<=BUS_WRITE_ADDR_END;
              end if;

            when BUS_WRITE_ADDR_END =>
              if(sig_port_free = '1') then
                write_wishbone(CR,x"90");
                if (sig_rd_wr_peripheral = '0') then-- lecture
                  etat_futur2 <= BUS_READ_DATA_8;
                else
                  etat_futur2 <= BUS_WRITE_DATA_8;
                end if;
                etat_futur  <=  WAIT_I2C_IRQ;
                etat        <=  WAIT_WISHBONE_BUSY;
              end if;

            -------------------Ecriture------------------------
            when BUS_WRITE_DATA_8 =>
              if(sig_port_free = '1') then
                write_wishbone(TXR,sig_port_write_data_peripheral(7 downto 0));
                etat        <= WAIT_WISHBONE_BUSY;
                etat_futur  <= BUS_WRITE_DATA_8_END;
              end if;

            when BUS_WRITE_DATA_8_END =>
              if(sig_port_free = '1') then
                if (sig_data_size_peripheral = "00") then
                  write_wishbone(CR, x"50");
                  etat_futur2 <= IDLE;
                else
                  write_wishbone(CR,x"90");
                  etat_futur2 <= BUS_WRITE_DATA_16;
                end if;
                etat_futur  <=  WAIT_I2C_IRQ;
                etat        <=  WAIT_WISHBONE_BUSY;
              end if;

            when BUS_WRITE_DATA_16 =>
              if(sig_port_free = '1') then
                write_wishbone(TXR,sig_port_write_data_peripheral(15 downto 8));
                etat        <= WAIT_WISHBONE_BUSY;
                etat_futur  <= BUS_WRITE_DATA_16_END;
              end if;

            when BUS_WRITE_DATA_16_END =>
              if(sig_port_free = '1') then
                if (sig_data_size_peripheral = "01") then
                  write_wishbone(CR, x"50");
                  etat_futur2 <= IDLE;
                else
                  write_wishbone(CR,x"90");
                  etat_futur2 <= BUS_WRITE_DATA_24;
                end if;
                etat_futur  <=  WAIT_I2C_IRQ;
                etat        <=  WAIT_WISHBONE_BUSY;
              end if;

            when BUS_WRITE_DATA_24 =>
              if(sig_port_free = '1') then
                write_wishbone(TXR,sig_port_write_data_peripheral(23 downto 16));
                etat        <= WAIT_WISHBONE_BUSY;
                etat_futur  <= BUS_WRITE_DATA_24_END;
              end if;

            when BUS_WRITE_DATA_24_END =>
              if(sig_port_free = '1') then
                if (sig_data_size_peripheral = "10") then
                  write_wishbone(CR, x"50");
                  etat_futur2 <= IDLE;
                else
                  write_wishbone(CR,x"90");
                  etat_futur2 <= BUS_WRITE_DATA_32;
                end if;
                etat_futur  <=  WAIT_I2C_IRQ;
                etat        <=  WAIT_WISHBONE_BUSY;
              end if;

            when BUS_WRITE_DATA_32 =>
              if(sig_port_free = '1') then
                write_wishbone(TXR,sig_port_write_data_peripheral(31 downto 24));
                etat        <= WAIT_WISHBONE_BUSY;
                etat_futur  <= BUS_WRITE_DATA_32_END;
              end if;

            when BUS_WRITE_DATA_32_END =>
              if(sig_port_free = '1') then
                write_wishbone(CR, x"50");
                etat_futur2 <= IDLE;
                etat_futur  <=  WAIT_I2C_IRQ;
                etat        <=  WAIT_WISHBONE_BUSY;
              end if;

            -------------------Lecture-------------------------
            when BUS_READ_DATA_8 =>
              if(sig_port_free = '1') then
                if (sig_data_size_peripheral = "00") then
                  write_wishbone(CR, x"60");
                else
                  write_wishbone(CR,x"A0");
                end if;
                etat_futur2 <=  BUS_READ_DATA_8_READ;
                etat_futur  <=  WAIT_I2C_IRQ;
                etat        <=  WAIT_WISHBONE_BUSY;
              end if;

            when BUS_READ_DATA_8_READ =>
            if(sig_port_free = '1') then
              read_wishbone(RXR);
              etat_futur  <=  BUS_READ_DATA_8_END;
              etat        <=  WAIT_WISHBONE_BUSY;
            end if;

            when BUS_READ_DATA_8_END =>
              sig_port_read_peripheral(7 downto 0) <=  sig_port_read;
              if (sig_data_size_peripheral = "00") then
                etat <= BUS_RESULT;
              else
                etat <= BUS_READ_DATA_16;
              end if;

            when BUS_READ_DATA_16 =>
              if(sig_port_free = '1') then
                if (sig_data_size_peripheral = "01") then
                  write_wishbone(CR, x"60");
                else
                  write_wishbone(CR,x"A0");
                end if;
                etat_futur2 <=  BUS_READ_DATA_16_READ;
                etat_futur  <=  WAIT_I2C_IRQ;
                etat        <=  WAIT_WISHBONE_BUSY;
              end if;

            when BUS_READ_DATA_16_READ =>
              if(sig_port_free = '1') then
                read_wishbone(RXR);
                etat_futur  <=  BUS_READ_DATA_16_END;
                etat        <=  WAIT_WISHBONE_BUSY;
              end if;

            when BUS_READ_DATA_16_END =>
              sig_port_read_peripheral(15 downto 8) <=  sig_port_read;
              if (sig_data_size_peripheral = "01") then
                etat <= BUS_RESULT;
              else
                etat <= BUS_READ_DATA_24;
              end if;

            when BUS_READ_DATA_24 =>
              if(sig_port_free = '1') then
                if (sig_data_size_peripheral = "10") then
                  write_wishbone(CR, x"60");
                else
                  write_wishbone(CR,x"A0");
                end if;
                etat_futur2 <=  BUS_READ_DATA_24_READ;
                etat_futur  <=  WAIT_I2C_IRQ;
                etat        <=  WAIT_WISHBONE_BUSY;
              end if;

            when BUS_READ_DATA_24_READ =>
            if(sig_port_free = '1') then
              read_wishbone(RXR);
              etat_futur  <=  BUS_READ_DATA_24_END;
              etat        <=  WAIT_WISHBONE_BUSY;
            end if;

            when BUS_READ_DATA_24_END =>
              sig_port_read_peripheral(23 downto 16) <=  sig_port_read;
              if (sig_data_size_peripheral = "01") then
                etat <= BUS_RESULT;
              else
                etat <= BUS_READ_DATA_24;
              end if;

            when BUS_READ_DATA_32 =>
              if(sig_port_free = '1') then
                write_wishbone(CR, x"60");
                etat_futur2 <=  BUS_READ_DATA_32_READ;
                etat_futur  <=  WAIT_I2C_IRQ;
                etat        <=  WAIT_WISHBONE_BUSY;
              end if;

            when BUS_READ_DATA_32_READ =>
              if(sig_port_free = '1') then
                read_wishbone(RXR);
                etat_futur  <=  BUS_READ_DATA_32_END;
                etat        <=  WAIT_WISHBONE_BUSY;
              end if;

            when BUS_READ_DATA_32_END =>
              sig_port_read_peripheral(31 downto 24) <=  sig_port_read;
              etat <= BUS_RESULT;

            -------------- WISHBONE -----------------------------------------
            when WAIT_WISHBONE_BUSY =>
              if(sig_PORT_FREE = '0') then
                sig_start <= '0';
                etat <= WAIT_WISHBONE_FINISH;
              end if;

            when WAIT_WISHBONE_FINISH =>
              if(sig_PORT_FREE = '1') then
                etat <= etat_futur;
              end if;

            when WAIT_I2C_IRQ =>
              if(sig_int = '1') then
                sig_addr <= CR;
                sig_data <= "00000001";
                sig_start <= '1';
                sig_rd_wr <= '1';
                etat <= WAIT_WISHBONE_BUSY;
                etat_futur <= BUS_READ_STATUS;
              end if;

            when BUS_READ_STATUS =>
              if(sig_PORT_FREE = '1') then
                sig_addr <= SR;
                sig_start <= '1';
                sig_rd_wr <= '0';
                etat        <= WAIT_WISHBONE_BUSY;
                etat_futur  <= BUS_WRITE_DATA_8_END;
              end if;

            when BUS_READ_STATUS_CHECK =>
              if((sig_port_read and x"E3") = x"00") then -- Tout c'est bien passe
                etat        <= etat_futur2;
              else -- ERREUR I2C
                etat        <= IDLE;
                etat_futur  <= IDLE;
                etat_futur2 <= IDLE;
              end if;

            when BUS_RESULT =>
              PORT_READ <= sig_port_read_peripheral;
              etat <= IDLE;
              etat_futur <= IDLE;
              etat_futur2 <= IDLE;

            when others => -- Il y a baleine sous cailloux!
            etat <= IDLE;

          end case;
        end if;
      end if;
    end process;
end Behavioral;
