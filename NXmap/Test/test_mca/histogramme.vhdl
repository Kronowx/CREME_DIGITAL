----------------------------------------------------------------------------------
-- Company: ONERA Toulouse
-- Engineer: guillaume.gourves@onera.for
--
-- Create Date: 10/11/2021
-- Design Name: Dateur
-- Module Name:
-- Project Name: CREME
-- Target Devices: NG-MEDIUM (NanoXplore)
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
use IEEE.NUMERIC_STD.ALL;

--library NX;
--use NX.nxPackage.all;

entity histogramer is
    port(
        CLK_100MHz       : in  std_logic                    -- Système de clock (100MHz)
        ;RESET           : in  std_logic                    -- Réinitialisation de l'histogramme.
        ;ENABLE          : in  std_logic                    -- Démarrage de l'histogramme.
        ;CONFIG          : in  std_logic                    -- Demande de configuration
        ;DATE            : in  std_logic_vector(16 downto 0) -- Heure locale CU.
        ;SPT_ACQ_PERIOD  : in  std_logic_vector(7 downto 0) -- Temps de cycle entre acquisitions
        ;SPT_INT_TIME    : in  std_logic_vector(7 downto 0) -- Temps d’intégration d’une acquisition.
        ;SPT_CH_COUNT    : in  std_logic_vector(7 downto 0) -- Nombre de canaux
        ;SPT_MODE        : in  std_logic_vector(1 downto 0) -- Mode d'acquisition
        ;CHA             : in  std_logic_vector(6 downto 0) -- Valeur de la voie A (ADC)
        ;PEAK_A          : in  std_logic                    -- Signal d'acquisition de la voie A
        ;CHB             : in  std_logic_vector(6 downto 0) -- Valeur de la voie B (ADC)
        ;PEAK_B          : in  std_logic                    -- Signal d'acquisition de la voie B.
        ;ACQ             : out  std_logic                    -- ACQ d'utilisation
    );
end histogramer;

architecture Behavioral of histogramer is
    type histogramer_state is
    (
      STATE_WAIT_ENABLE
      ,STATE_INIT
      ,STATE_IDLE
      ,STATE_CONFIG
      ,STATE_ALLOC
      ,STATE_START_ACQ
      ,STATE_WAIT_ACQ
    );
    signal etatp            : histogramer_state;
    type Header_TM is
    (
        Header_DATE_0
        ,Header_DATE_1
        ,Header_DATE_2
        ,Header_DATE_3
        ,Header_ACQ_PERIOD
        ,Header_INT_TIME
        ,Header_CH_COUNT
        ,Header_MODE
        ,Header_WRITE_RAM
        ,Header_WAIT_RAM
    );
    signal etat_header_present  : Header_TM;
    signal etat_header_futur    : Header_TM;
    signal go, go_p             : std_logic;
    signal a, b                 : unsigned(6 downto 0);
    signal s                    : unsigned(7 downto 0);
    signal s_tronc              : std_logic_vector(6 downto 0);
    signal sig_SPT_ACQ_PERIOD   : std_logic_vector(7 downto 0) := x"04";
    signal sig_SPT_INT_TIME     : std_logic_vector(7 downto 0);
    signal sig_SPT_CH_COUNT     : std_logic_vector(7 downto 0);
    signal sig_DATE             : std_logic_vector(31 downto 0);
    signal sig_SPT_MODE         : std_logic_vector(1 downto 0);
    signal sig_start_acq        : std_logic := '0'; -- Signal de démarrage de l'histogramme
    signal sig_ram_CLK	        : std_logic;                      -- Horloge de fonctionnement du module
    signal sig_ram_RESET        : std_logic;                      --  Reinitialisation du module
    signal sig_ram_DI	          : std_logic_vector(7 downto 0);   -- Donnee a ecrire
    signal sig_ram_DO	          : std_logic_vector(7 downto 0);   -- Donner a lire
    signal sig_ram_AD	          : std_logic_vector(12 downto 0);  -- Adresse a lire ou ecrire
    signal sig_ram_READ_WRITE   : std_logic;                      -- Commande de lecture ou d'ecriture
    signal sig_ram_WE	          : std_logic;                      -- Commande d'activation du module
    signal sig_ram_BUSY         : std_logic;                      -- Indicateur d'occupation du module
    signal sig_ram_READY        : std_logic;                      -- Indicateur de plein focntionnement du module
    signal sig_ram_START        : std_logic;                      -- Pin de lancement d'un traitement du module
    signal sig_ram_AD_BASE_TRAME: std_logic_vector(12 downto 0) := (others => '0');  -- Adresse a lire ou ecrire
    signal sig_ram_AD_BASE_DATE : std_logic_vector(12 downto 0) := (others => '0');  -- Adresse a lire ou ecrire
    component ram_controller
    port
    (
      CLK	        :   in   std_logic                      -- Horloge de fonctionnement du module
      ;RESET      :   in   std_logic                      --  Reinitialisation du module
    	;DI	        :   in   std_logic_vector(7 downto 0)   -- Donnee a ecrire
    	;DO	        :   out  std_logic_vector(7 downto 0)   -- Donner a lire
    	;AD	        :   in   std_logic_vector(12 downto 0)  -- Adresse a lire ou ecrire
      ;READ_WRITE :   in   std_logic                      -- Commande de lecture ou d'ecriture
      ;WE	        :   in   std_logic                      -- Commande d'activation du module
      ;BUSY       :   out  std_logic                      -- Indicateur d'occupation du module
      ;READY      :   out  std_logic                      -- Indicateur de plein focntionnement du module
      ;START      :   in   std_logic                      -- Pin de lancement d'un traitement du module
    );
    end component;

begin

  ram_controller_1 : ram_controller
  port map
  (
     CLK         =>  sig_ram_CLK
    ,RESET       =>  sig_ram_RESET
    ,DI          =>  sig_ram_DI
    ,DO          =>  sig_ram_DO
    ,AD          =>  sig_ram_AD
    ,READ_WRITE  =>  sig_ram_READ_WRITE
    ,WE          =>  sig_ram_WE
    ,BUSY        =>  sig_ram_BUSY
    ,READY       =>  sig_ram_READY
    ,START       =>  sig_ram_START
  );

    PROCESS_HISTOGRAMME : process(CLK_100MHz)
    begin
        if RESET = '1' then
          etatp <= STATE_INIT;
        else
          if rising_edge(CLK_100MHz) then
            case etatp is
              when STATE_INIT         =>
                sig_ram_DI          <= (others => '0');
                sig_ram_DO          <= (others => '0');
                sig_ram_AD          <= (others => '0');
                sig_ram_READ_WRITE  <= '0';
                sig_ram_START       <= '0';
                if sig_ram_READY = '1' then
                  etatp <= STATE_WAIT_ENABLE;
                end if;

              when STATE_WAIT_ENABLE  =>
                if ENABLE = '1' then
                  etatp <= STATE_IDLE;
                end if;

              when STATE_IDLE         =>
                if CONFIG = '1' then -- Reconfiguration de l'histogramme demandé.-
                  etatp <= STATE_CONFIG;
                  ACQ <= '0';
                else
                  if sig_start_acq = '1' then
                    sig_DATE <= DATE;
                  end if;
                  etatp <= STATE_ALLOC;
                end if;

              when STATE_CONFIG   =>
                sig_SPT_ACQ_PERIOD  <= SPT_ACQ_PERIOD;
                sig_SPT_INT_TIME    <= SPT_INT_TIME;
                sig_SPT_CH_COUNT    <= SPT_CH_COUNT;
                sig_SPT_MODE        <= SPT_MODE;
                etatp               <= STATE_IDLE;
                ACQ <= '1';

              when STATE_ALLOC => -- On écrit d'abord en entête.
                case etat_header is

                  when Header_DATE_0 => -- En registrement de la date de démarrage
                    sig_ram_DI          <= sig_DATE(7 downto 0);
                    sig_ram_READ_WRITE  <= '1';
                    if sig_ram_BUSY = '0' then
                      etat_header_present <= Header_WRITE_RAM;
                      etat_header_futur   <= Header_DATE_1;
                    end if;

                  when Header_DATE_1 => -- En registrement de la date de démarrage
                    sig_ram_DI <= sig_DATE(15 downto 8);
                    sig_ram_AD <= std_logic_vector(unsigned(sig_ram_AD) + 1);
                    sig_ram_READ_WRITE <= '1';
                    if sig_ram_BUSY = '0' then
                      etat_header_present <= Header_WRITE_RAM;
                      etat_header_futur   <= Header_DATE_2;
                    end if;

                  when Header_DATE_2 => -- En registrement de la date de démarrage
                    sig_ram_DI <= sig_DATE(23 downto 16);
                    sig_ram_AD <= std_logic_vector(unsigned(sig_ram_AD) + 1);
                    sig_ram_READ_WRITE <= '1';
                    if sig_ram_BUSY = '0' then
                      etat_header_present <= Header_WRITE_RAM;
                      etat_header_futur   <= Header_DATE_3;
                    end if;

                  when Header_DATE_3 => -- En registrement de la date de démarrage
                    sig_ram_DI <= sig_DATE(31 downto 24);
                    sig_ram_AD <= std_logic_vector(unsigned(sig_ram_AD) + 1);
                    sig_ram_READ_WRITE <= '1';
                    if sig_ram_BUSY = '0' then
                      etat_header_present <= Header_WRITE_RAM;
                      etat_header_futur   <= Header_ACQ_PERIOD;
                    end if;

                  when Header_ACQ_PERIOD =>
                    sig_ram_DI <= sig_PERIOD;
                    sig_ram_AD <= std_logic_vector(unsigned(sig_ram_AD) + 1);
                    sig_ram_READ_WRITE <= '1';
                    if sig_ram_BUSY = '0' then
                      etat_header_present <= Header_WRITE_RAM;
                      etat_header_futur   <= Header_INT_TIME;
                    end if;

                  when Header_INT_TIME =>
                    sig_ram_DI <= sig_INT_TIME;
                    sig_ram_AD <= std_logic_vector(unsigned(sig_ram_AD) + 1);
                    sig_ram_READ_WRITE <= '1';
                    if sig_ram_BUSY = '0' then
                      etat_header_present <= Header_WRITE_RAM;
                      etat_header_futur   <= Header_CH_COUNT;
                    end if;

                  when Header_CH_COUNT =>
                    sig_ram_DI <= sig_CH_COUNT;
                    sig_ram_AD <= std_logic_vector(unsigned(sig_ram_AD) + 1);
                    sig_ram_READ_WRITE <= '1';
                    if sig_ram_BUSY = '0' then
                      etat_header_present <= Header_WRITE_RAM;
                      etat_header_futur   <= Header_MODE;
                    end if;

                  when Header_MODE =>
                    sig_ram_DI(1 downto 0) <= sig_MODE;
                    sig_ram_AD <= std_logic_vector(unsigned(sig_ram_AD) + 1);
                    sig_ram_READ_WRITE <= '1';
                    if sig_ram_BUSY = '0' then
                      etat_header_present <= Header_WRITE_RAM;
                      etat_header_futur   <= Header_MODE;
                    end if;

                  when Header_END =>
                    etat_header_present <= Header_DATE_0;
                    etatp <= STATE_START_ACQ;

                  when Header_WRITE_RAM =>
                    sig_ram_START <= '1';
                    if sig_sig_ram_BUSY = '1'
                      etat_header_present <= Header_WAIT_RAM;
                    end if;

                  when Header_WAIT_RAM =>
                    sig_ram_START <= '0';
                    if sig_ram_BUSY = '0' then
                      etat_header_present <= etat_header_futur;
                    end if;

                  when others => -- Gros pepin
                    etatp <= STATE_INIT;
                end case;


              when STATE_START_ACQ => -- On configure la mémoire en fonction des parametre de configuration.

              when STATE_WAIT_ACQ  => -- On attend un évènement pour incrémenter le

              when others =>
                etatp <= STATE_INIT;

            end case;
          end if;
        end if;
    end process;

end Behavioral;
