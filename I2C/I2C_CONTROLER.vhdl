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
library NX;
use NX.nxPackage.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity I2C_CONTROLER is
  Port (
        CLK        : in std_logic;
        BOUTTON_1    : in std_logic;
        --BOUTTON_2    : in std_logic;
        RESET  : in std_logic;


        SCL : inout std_logic;
        SDA : inout std_logic
  );
end I2C_CONTROLER;

architecture Behavioral of I2C_CONTROLER is

    constant PRERlo :std_logic_vector(2 downto 0):="000";
    constant PRERhi :std_logic_vector(2 downto 0):= "001";
    constant CTR :std_logic_vector(2 downto 0):= "010";
    constant TXR :std_logic_vector(2 downto 0):= "011";
    constant RXR :std_logic_vector(2 downto 0):="011";
    constant CR :std_logic_vector(2 downto 0):= "100";
    constant SR :std_logic_vector(2 downto 0):= "100";


    type behavior_state is
  (
    IDLE,
    WAIT_N_CLOCK,
    BUS_WRITE_PRERlo,
    BUS_WRITE_PRERhi,
    BUS_WRITE_CTR,
    BUS_WRITE_TXR,
    BUS_WRITE_CR,
    BUS_WRITE_TXR_1,
    BUS_WRITE_CR_1,
    BUS_WRITE_TXR_2,
    BUS_WRITE_CR_2,
    BUS_WRITE_TXR_3,
    BUS_WRITE_CR_3,
    BUS_WRITE_TXR_4,
    BUS_WRITE_CR_4,
    BUS_WRITE_TXR_5,
    BUS_WRITE_CR_5,
    BUS_WRITE_TXR_6,
    BUS_WRITE_CR_6,
    BUS_READ_TXR,
    BUS_READ_CR,
    BUS_READ_TXR_1,
    BUS_READ_CR_1,
    BUS_READ_RXR,
    BUS_READ,
    BUS_READ_CR_2,
    BUS_READ_RXR_1,
    BUS_READ_1,
    BUS_READ_CR_3,
    BUS_READ_RXR_2,
    BUS_READ_2,
    BUS_READ_CR_4,
    BUS_READ_RXR_3,
    BUS_READ_3,
    BUS_READ_CR_5,
    BUS_READ_CR_6,
    BUS_WRITE_TXR_7,
    BUS_WRITE_CR_7,
    BUS_WRITE_TXR_8,
    BUS_WRITE_CR_8,
    BUS_WRITE_CR_9,
    BUS_WRITE_CR_10,
    BUS_WRITE_CR_11,
    BUS_WRITE_CR_12,
    BUS_WRITE_CR_13,
    BUS_WRITE_TXR_9,
    BUS_WRITE_TXR_10,
    BUS_WRITE_TXR_11,
    BUS_WRITE_TXR_12,
    WRITE_RAM_1,
    WRITE_RAM_2,
    WRITE_RAM_3,
    WRITE_RAM_4,
    READ_RAM_1,
    READ_RAM_2,
    READ_RAM_3,
    READ_RAM_4,
    WAIT_TRANSMISSION,
    CATCH_STATUS,
    attente
  );

  signal etat, etat_futur : behavior_state;

    signal sig_clk       : std_logic:='0';
    --signal sig_boutton   : std_logic;
    signal sig_rst  : std_logic;
    signal sig_start     : std_logic:='0';
    signal sig_rd_wr     : std_logic:='0';
    signal sig_addr  : std_logic_vector(2 downto 0);
    signal sig_data  : std_logic_vector(7 downto 0);
    signal sig_port_read : std_logic_vector(7 downto 0);
    signal sig_port_free : std_logic;



    --signal sig_scl  : std_logic;
    --signal sig_sda  : std_logic;

    signal sig_scl_pad_i  : std_logic;
    signal sig_scl_pad_o  : std_logic;
    signal sig_scl_pad_en : std_logic;

    signal sig_sda_pad_i  : std_logic;
    signal sig_sda_pad_o  : std_logic;
    signal sig_sda_pad_en : std_logic;


    signal transmiting_1   : std_logic:='0';
    signal wait_N : unsigned(23 downto 0) := x"000000";
    signal cnt_etat : integer:=0;
    signal q : std_logic_vector(31 downto 0);

    signal cnt_adr  : unsigned(12 downto 0):= '0' & x"654";
    signal sig_din  : std_logic_vector(7 downto 0);
    signal sig_we   : std_logic;
    signal sig_adr  : std_logic_vector(12 downto 0);
    signal sig_dout : std_logic_vector(7 downto 0);


component I2C_PERIPHERAL
    port(
     CLK : in std_logic;
     --CLK_DRIVER : in std_logic;

     RESET_BAR : in std_logic;

     START  : in    std_logic;                     --! Start pin for activate transmission
     RD_WR  : in    std_logic;                     --! Start pin for activate transmission
     REG_ADDR     : in    std_logic_vector(2 downto 0);  --! Vecteur permettant de temporiser le registre d'adresse
     REG_DATA     : in    std_logic_vector(7 downto 0);  --! Vecteur permettant de temporiser le registre d'adresse                    --! Receive pin for CAN
     PORT_0_READ  : out   std_logic_vector(7 downto 0);
     PORT_FREE    : out   std_logic; -- correspond à l'ack

     scl_pad_i  : in std_logic;
     scl_pad_o  : out std_logic;
     scl_pad_en : out std_logic;
     sda_pad_i  : in std_logic;
     sda_pad_o  : out std_logic;
     sda_pad_en : out std_logic;
     DI  : in std_logic_vector(7 downto 0);
     WE   : in std_logic;
     AD  : in std_logic_vector(12 downto 0);
     DO : out std_logic_vector(7 downto 0)
    );
end component;

--component i2c_slave_model
    --port(
    --scl : inout std_logic;
    --sda : inout std_logic
    --);
--end component;

begin

    i2c_peripheral_1 : I2C_PERIPHERAL port map
    (
    CLK=>CLK,
    RESET_BAR=>sig_rst,
    START=>sig_start,
    RD_WR=>sig_rd_wr,
    REG_ADDR=>sig_addr,
    REG_DATA=>sig_data,
    PORT_0_READ=>sig_port_read,
    PORT_FREE=>sig_port_free,
    scl_pad_i=>scl,
    scl_pad_o=>sig_scl_pad_o,
    scl_pad_en=>sig_scl_pad_en,
    sda_pad_i=>sda,
    sda_pad_o=>sig_sda_pad_o,
    sda_pad_en=>sig_sda_pad_en,
    DI=>sig_din,
    WE=>sig_we,
    AD=>sig_adr,
    DO=>sig_dout
    );

    --i2c_slave_1 : i2c_slave_model port map
    --(
    --scl=>SCL,
    --sda=>SDA
    --);

    BD_0 : NX_BD port map
    (
    I=>RESET,
    O=>sig_rst
    );




scl <= sig_scl_pad_o when (sig_scl_pad_en = '0') else '1'; --dans le else mettre H pour simu et 1 pour carte réel
sda <= sig_sda_pad_o when (sig_sda_pad_en = '0') else '1'; --dans le else mettre H pour simu et 1 pour carte réel
--scl<='H';
--sda<='H';
--sig_rst<=not(RESET); --Ligne à utiliser que en simu

 process(CLK)
    begin
        if rising_edge(CLK) then
            if sig_rst='0' then   -- On réinitialise le tout.
                sig_start<='0';
                sig_addr<="000";
                sig_rd_wr<='0';
                wait_N <= x"000001"; --32 d'attente
                etat <= WAIT_N_CLOCK;
                etat_futur<=IDLE;
            else
                case etat is
                    when IDLE=>
                        cnt_etat<=0;
                        if (BOUTTON_1='0' and transmiting_1='0') then--bouton à changer pour la carte
                            transmiting_1<='1';
                            etat<=BUS_WRITE_PRERlo;
                        end if;
                        if boutton_1='1' then--boouton à changer pour la carte
                            transmiting_1<='0';
                            etat<=IDLE;
                        end if;

------------------------------Machine à etat-----------------------------------------------------------

----------------------Initialisation prescaler---------------------------------------------------------

                   when BUS_WRITE_PRERlo=>
                   if(sig_port_free = '1') then
                            sig_addr <=PRERlo ;
                            sig_data <= x"02";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_WRITE_PRERhi;
                   end if;


                   when BUS_WRITE_PRERhi=>
                   if(sig_port_free = '1') then
                            sig_addr <=PRERhi ;
                            sig_data <= x"00";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_WRITE_CTR;
                   end if;

 ------------------------------Début écriture----------------------------------------------------------

                   when BUS_WRITE_CTR=>
                   if(sig_port_free = '1') then
                            sig_addr <=CTR ;
                            sig_data <= x"80";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_WRITE_TXR;
                   end if;


                   when BUS_WRITE_TXR=>
                   if(sig_port_free = '1') then
                            sig_addr <=TXR ;
                            sig_data <= "01111000";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_WRITE_CR;
                   end if;


                   when BUS_WRITE_CR=>
                   if(sig_port_free = '1') then
                            sig_addr <= CR ;
                            sig_data <= x"90";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            cnt_etat<=cnt_etat+1;--cnt_etat=1
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=WAIT_TRANSMISSION;
                   end if;


                   when BUS_WRITE_TXR_1=>
                   if(sig_port_free = '1') then
                            sig_addr <=TXR ;
                            sig_data <= x"40";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_WRITE_CR_1;
                   end if;


                   when BUS_WRITE_CR_1=>
                   if(sig_port_free = '1') then
                            sig_addr <= CR ;
                            sig_data <= x"10";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            cnt_etat<=cnt_etat+1;--cnt_etat=2
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=WAIT_TRANSMISSION;
                   end if;


                   when BUS_WRITE_TXR_2=>
                   if(sig_port_free = '1') then
                            sig_addr <=TXR ;
                            sig_data <= x"a5";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_WRITE_CR_2;
                   end if;


                   when BUS_WRITE_CR_2=>
                   if(sig_port_free = '1') then
                            sig_addr <= CR ;
                            sig_data <= x"10";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            cnt_etat<=cnt_etat+1;--cnt_etat=3
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=WAIT_TRANSMISSION;
                   end if;


                   when BUS_WRITE_TXR_3=>
                   if(sig_port_free = '1') then
                            sig_addr <=TXR ;
                            sig_data <= x"5a";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_WRITE_CR_3;
                   end if;


                   when BUS_WRITE_CR_3=>
                   if(sig_port_free = '1') then
                            sig_addr <= CR ;
                            sig_data <= x"10";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            cnt_etat<=cnt_etat+1;--cnt_etat=4
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=WAIT_TRANSMISSION;
                   end if;


                   when BUS_WRITE_TXR_4=>
                   if(sig_port_free = '1') then
                            sig_addr <=TXR ;
                            sig_data <= x"b6";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_WRITE_CR_4;
                   end if;


                   when BUS_WRITE_CR_4=>
                   if(sig_port_free = '1') then
                            sig_addr <= CR ;
                            sig_data <= x"10";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            cnt_etat<=cnt_etat+1;--cnt_etat=5
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=WAIT_TRANSMISSION;
                   end if;


                   when BUS_WRITE_TXR_5=>
                   if(sig_port_free = '1') then
                            sig_addr <=TXR ;
                            sig_data <= x"6b";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_WRITE_CR_5;
                   end if;


                   when BUS_WRITE_CR_5=>
                   if(sig_port_free = '1') then
                            sig_addr <= CR ;
                            sig_data <= x"50";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            cnt_etat<=cnt_etat+1;--cnt_etat=6
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=WAIT_TRANSMISSION;
                   end if;

--------------------Début de la lecture-------------------------------------------

                   when BUS_READ_TXR=>
                   if(sig_port_free = '1') then
                            sig_addr <=TXR ;
                            sig_data <= "01111000";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_READ_CR;
                   end if;


                   when BUS_READ_CR=>
                   if(sig_port_free = '1') then
                            sig_addr <= CR ;
                            sig_data <= x"90";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            cnt_etat<=cnt_etat+1;--cnt_etat=7
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=WAIT_TRANSMISSION;
                   end if;


                   when BUS_WRITE_TXR_6=>
                   if(sig_port_free = '1') then
                            sig_addr <=TXR ;
                            sig_data <= x"2F";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_WRITE_CR_6;
                   end if;


                   when BUS_WRITE_CR_6=>
                   if(sig_port_free = '1') then
                            sig_addr <= CR ;
                            sig_data <= x"10";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            cnt_etat<=cnt_etat+1;--cnt_etat=8
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=WAIT_TRANSMISSION;
                   end if;


                   when BUS_READ_TXR_1=>
                   if(sig_port_free = '1') then
                            sig_addr <=TXR ;
                            sig_data <= "01111001";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_READ_CR_1;
                   end if;


                   when BUS_READ_CR_1=>
                   if(sig_port_free = '1') then
                            sig_addr <= CR ;
                            sig_data <= x"90";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            cnt_etat<=cnt_etat+1;--cnt_etat=9
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=WAIT_TRANSMISSION;
                   end if;


                   when BUS_READ_CR_2=>
                   if(sig_port_free = '1') then
                            sig_addr <= CR ;
                            sig_data <= x"20";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            cnt_etat<=cnt_etat+1;--cnt_etat=10
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=WAIT_TRANSMISSION;
                   end if;


                   when BUS_READ_RXR=>
                   if(sig_port_free = '1') then
                            sig_addr <=RXR ;
                            sig_start <= '1';
                            sig_rd_wr <= '0';
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_READ;
                   end if;


                   when BUS_READ =>
                   if(sig_PORT_FREE='1') then
                        q(31 downto 24)<=sig_port_read;
                        wait_N <= x"000001"; --mettre le wait_N au moins à 1 car sinon la transmition se fait mal
                        etat <= WAIT_N_CLOCK;
                        etat_futur<=BUS_READ_CR_3;
                    end if;


                   when BUS_READ_CR_3=>
                   if(sig_port_free = '1') then
                            sig_addr <= CR ;
                            sig_data <= x"20";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            cnt_etat<=cnt_etat+1;--cnt_etat=11
                            wait_N <= x"000000"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=WAIT_TRANSMISSION;
                   end if;


                   when BUS_READ_RXR_1=>
                   if(sig_port_free = '1') then
                            sig_addr <=RXR ;
                            sig_start <= '1';
                            sig_rd_wr <= '0';
                            wait_N <= x"000000"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_READ_1;
                   end if;


                   when BUS_READ_1 =>
                   if(sig_PORT_FREE='1') then
                        q(23 downto 16)<=sig_port_read;
                        wait_N <= x"000000"; --mettre le wait_N au moins à 1 car sinon la transmition se fait mal
                        etat <= WAIT_N_CLOCK;
                        etat_futur<=BUS_READ_CR_4;
                    end if;


                   when BUS_READ_CR_4=>
                   if(sig_port_free = '1') then
                            sig_addr <= CR ;
                            sig_data <= x"20";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            cnt_etat<=cnt_etat+1;--cnt_etat=12
                            wait_N <= x"000000"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=WAIT_TRANSMISSION;
                   end if;


                   when BUS_READ_RXR_2=>
                   if(sig_port_free = '1') then
                            sig_addr <=RXR ;
                            sig_start <= '1';
                            sig_rd_wr <= '0';
                            wait_N <= x"000000"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_READ_2;
                   end if;


                   when BUS_READ_2 =>
                   if(sig_PORT_FREE='1') then
                        q(15 downto 8)<=sig_port_read;
                        wait_N <= x"000000"; --mettre le wait_N au moins à 1 car sinon la transmition se fait mal
                        etat <= WAIT_N_CLOCK;
                        etat_futur<=BUS_READ_CR_5;
                    end if;


                   when BUS_READ_CR_5=>
                   if(sig_port_free = '1') then
                            sig_addr <= CR ;
                            sig_data <= x"28";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            cnt_etat<=cnt_etat+1;--cnt_etat=13
                            wait_N <= x"000000"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=WAIT_TRANSMISSION;
                   end if;


                   when BUS_READ_RXR_3=>
                   if(sig_port_free = '1') then
                            sig_addr <=RXR ;
                            sig_start <= '1';
                            sig_rd_wr <= '0';
                            wait_N <= x"000000"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_READ_3;
                   end if;


                   when BUS_READ_3 =>
                   if(sig_PORT_FREE='1') then
                        q(7 downto 0)<=sig_port_read;
                        wait_N <= x"000020"; --mettre le wait_N au moins à 1 car sinon la transmition se fait mal
                        etat <= WAIT_N_CLOCK;
                        etat_futur<=WRITE_RAM_1;
                    end if;




                   --when BUS_WRITE_TXR_7=>
                   --if(sig_port_free = '1') then
                            --sig_addr <=TXR ;
                            --sig_data <= "01111000";
                            --sig_start <= '1';
                            --sig_rd_wr <= '1';
                            --wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            --etat <= WAIT_N_CLOCK;
                            --etat_futur<=BUS_WRITE_CR_7;
                   --end if;

                   --when BUS_WRITE_CR_7=>
                   --if(sig_port_free = '1') then
                            --sig_addr <= CR ;
                            --sig_data <= x"90";
                            --sig_start <= '1';
                            --sig_rd_wr <= '1';
                            --cnt_etat<=cnt_etat+1;--cnt_etat=14
                            --wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            --etat <= WAIT_N_CLOCK;
                            --etat_futur<=WAIT_TRANSMISSION;
                   --end if;


                   --when BUS_WRITE_TXR_8=>
                   --if(sig_port_free = '1') then
                            --sig_addr <=TXR ;
                            --sig_data <= x"11";
                            --sig_start <= '1';
                            --sig_rd_wr <= '1';
                            --wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            --etat <= WAIT_N_CLOCK;
                            --etat_futur<=BUS_WRITE_CR_8;
                   --end if;


                   --when BUS_WRITE_CR_8=>
                   --if(sig_port_free = '1') then
                            --sig_addr <= CR ;
                            --sig_data <= x"10";
                            --sig_start <= '1';
                            --sig_rd_wr <= '1';
                            --cnt_etat<=cnt_etat+1;--cnt_etat=15
                            --wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            --etat <= WAIT_N_CLOCK;
                            --etat_futur<=WAIT_TRANSMISSION;
                   --end if;

--------------------------Ecriture dans la RAM--------------------------------
                when WRITE_RAM_1 =>
                sig_DIN<=q(31 downto 24);
                sig_adr<=std_logic_vector(cnt_adr);
                sig_we<='1';
                cnt_adr<=cnt_adr+1;
                wait_n<=x"000002";
                etat<=WAIT_N_CLOCK;
                etat_futur<=WRITE_RAM_2;

                when WRITE_RAM_2 =>
                sig_DIN<=q(23 downto 16);
                sig_adr<=std_logic_vector(cnt_adr);
                sig_we<='1';
                cnt_adr<=cnt_adr+1;
                wait_n<=x"000002";
                etat<=WAIT_N_CLOCK;
                etat_futur<=WRITE_RAM_3;

                when WRITE_RAM_3 =>
                sig_DIN<=q(15 downto 8);
                sig_adr<=std_logic_vector(cnt_adr);
                sig_we<='1';
                cnt_adr<=cnt_adr+1;
                wait_n<=x"000002";
                etat<=WAIT_N_CLOCK;
                etat_futur<=WRITE_RAM_4;

                when WRITE_RAM_4 =>
                sig_DIN<=q(7 downto 0);
                sig_adr<=std_logic_vector(cnt_adr);
                sig_we<='1';
                wait_n<=x"000002";
                etat<=WAIT_N_CLOCK;
                etat_futur<=BUS_WRITE_TXR_7;

---------------------------Lecture dans la RAM-------------------------------------------

                   when BUS_WRITE_TXR_7=>
                   if(sig_port_free = '1') then
                            sig_addr <=TXR ;
                            sig_data <= "00100000";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_WRITE_CR_7;
                   end if;


                   when BUS_WRITE_CR_7=>
                   if(sig_port_free = '1') then
                            sig_addr <= CR ;
                            sig_data <= x"90";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            cnt_etat<=cnt_etat+1;--cnt_etat=14
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=WAIT_TRANSMISSION;
                   end if;


                   when BUS_WRITE_TXR_8=>
                   if(sig_port_free = '1') then
                            sig_addr <=TXR ;
                            sig_data <= x"00";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_WRITE_CR_8;
                   end if;


                   when BUS_WRITE_CR_8=>
                   if(sig_port_free = '1') then
                            sig_addr <= CR ;
                            sig_data <= x"10";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            cnt_etat<=cnt_etat+1;--cnt_etat=15
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=WAIT_TRANSMISSION;
                   end if;


                    when READ_RAM_1 =>
                        sig_adr<='0' & x"654";
                        wait_n<=x"000002";
                        etat<=WAIT_N_CLOCK;
                        etat_futur<=BUS_WRITE_TXR_9;


                   when BUS_WRITE_TXR_9=>
                   if(sig_port_free = '1') then
                            sig_addr <=TXR ;
                            sig_data <= sig_dout;
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_WRITE_CR_9;
                   end if;


                   when BUS_WRITE_CR_9=>
                   if(sig_port_free = '1') then
                            sig_addr <= CR ;
                            sig_data <= x"10";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            cnt_etat<=cnt_etat+1;--cnt_etat=16
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=WAIT_TRANSMISSION;
                   end if;


                    when READ_RAM_2 =>
                        sig_adr<='0' & x"655";
                        wait_n<=x"000002";
                        etat<=WAIT_N_CLOCK;
                        etat_futur<=BUS_WRITE_TXR_10;


                   when BUS_WRITE_TXR_10=>
                   if(sig_port_free = '1') then
                            sig_addr <=TXR ;
                            sig_data <= sig_dout;
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_WRITE_CR_10;
                   end if;


                   when BUS_WRITE_CR_10=>
                   if(sig_port_free = '1') then
                            sig_addr <= CR ;
                            sig_data <= x"10";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            cnt_etat<=cnt_etat+1;--cnt_etat=17
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=WAIT_TRANSMISSION;
                   end if;


                    when READ_RAM_3 =>
                        sig_adr<='0' & x"656";
                        wait_n<=x"000002";
                        etat<=WAIT_N_CLOCK;
                        etat_futur<=BUS_WRITE_TXR_11;


                   when BUS_WRITE_TXR_11=>
                   if(sig_port_free = '1') then
                            sig_addr <=TXR ;
                            sig_data <= sig_dout;
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_WRITE_CR_11;
                   end if;


                   when BUS_WRITE_CR_11=>
                   if(sig_port_free = '1') then
                            sig_addr <= CR ;
                            sig_data <= x"10";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            cnt_etat<=cnt_etat+1;--cnt_etat=18
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=WAIT_TRANSMISSION;
                   end if;


                    when READ_RAM_4 =>
                        sig_adr<='0' & x"657";
                        wait_n<=x"000002";
                        etat<=WAIT_N_CLOCK;
                        etat_futur<=BUS_WRITE_TXR_12;


                   when BUS_WRITE_TXR_12=>
                   if(sig_port_free = '1') then
                            sig_addr <=TXR ;
                            sig_data <= sig_dout;
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_WRITE_CR_12;
                   end if;


                   when BUS_WRITE_CR_12=>
                   if(sig_port_free = '1') then
                            sig_addr <= CR ;
                            sig_data <= x"50";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            cnt_etat<=cnt_etat+1;--cnt_etat=19
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=BUS_WRITE_CR_13;
                   end if;


                   when BUS_WRITE_CR_13=>
                   if(sig_port_free = '1') then
                            sig_addr <= CR ;
                            sig_data <= x"40";
                            sig_start <= '1';
                            sig_rd_wr <= '1';
                            cnt_etat<=cnt_etat+1;--cnt_etat=16
                            wait_N <= x"000001"; --on attend pendant 1 clock d'horloge
                            etat <= WAIT_N_CLOCK;
                            etat_futur<=IDLE;
                   end if;


               --when attente=>
                    --wait_n<=x"000020";
                    --etat<=WAIT_N_CLOCK;
                    --etat_futur<=WAIT_TRANSMISSION;


                when WAIT_TRANSMISSION =>       --on alterne entre WAIT_TRANSMISSION et CATCH_STATUS jusqu'a ce que la transmission soit finie
                if(sig_PORT_FREE = '1') then
                    sig_addr <= SR;
                    sig_start <= '1';
                    sig_rd_wr <= '0';
                    wait_N <= x"000001";
                    etat <= WAIT_N_CLOCK;
                    etat_futur <= CATCH_STATUS;
                end if;


                when CATCH_STATUS =>
                if(sig_PORT_FREE = '1') then
                    if (sig_port_read(1) ='0') then --si la transmission est finie
                        if(cnt_etat=1) then
                            etat <= BUS_WRITE_TXR_1;
                        end if;
                        if(cnt_etat=2) then
                            etat<=BUS_WRITE_TXR_2;
                        end if;
                        if(cnt_etat=3) then
                            etat<=BUS_WRITE_TXR_3;
                        end if;
                        if(cnt_etat=4) then
                            etat<=BUS_WRITE_TXR_4;
                        end if;
                        if(cnt_etat=5) then
                            etat<=BUS_WRITE_TXR_5;
                        end if;
                        if(cnt_etat=6) then
                            wait_N<=x"000100";
                            etat<=WAIT_N_CLOCK;
                            etat_futur<=BUS_READ_TXR;
                        end if;
                        if(cnt_etat=7) then
                            etat<=BUS_WRITE_TXR_6;
                        end if;
                        if(cnt_etat=8) then
                            etat<=BUS_READ_TXR_1;
                        end if;
                        if(cnt_etat=9) then
                            etat<=BUS_READ_CR_2;
                        end if;
                        if(cnt_etat=10) then
                            etat<=BUS_READ_RXR;
                        end if;
                        if(cnt_etat=11) then
                            etat<=BUS_READ_RXR_1;
                        end if;
                        if(cnt_etat=12) then
                            etat<=BUS_READ_RXR_2;
                        end if;
                        if(cnt_etat=13) then
                            etat<=BUS_READ_RXR_3;
                        end if;
                        if(cnt_etat=14) then
                            etat<=BUS_WRITE_TXR_8;
                        end if;
                        if(cnt_etat=15) then
                            etat<=READ_RAM_1;
                        end if;
                        if(cnt_etat=16) then
                            etat<=READ_RAM_2;
                        end if;
                        if(cnt_etat=17) then
                            etat<=READ_RAM_3;
                        end if;
                        if(cnt_etat=18) then
                            etat<=READ_RAM_4;
                        end if;

                     else
                        --wait_N <= x"000020"; --200 coups d'horloge pour transmettre un bit
                        --etat <= WAIT_N_CLOCK;   --(ca sert a rien de regarder le status register 2000 fois par trame)
                        etat <= WAIT_TRANSMISSION;
                    end if;
                end if;



                    when WAIT_N_CLOCK =>
                    if(wait_N = x"000000") then
                        etat <= etat_futur;
                        sig_start <= '0';
                        sig_we<='0';
                    else
                        wait_N <= wait_N - 1;
                    end if;

                  when others => -- Si on est lÃ  : c'est qu'il y a baleine sous cailloux!
                --          etat <= INIT;


    end case;
    end if;
    end if;
end process;
end Behavioral;
