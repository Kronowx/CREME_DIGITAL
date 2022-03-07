-------------------------------------------------------
--! @file timer32.vhdl
--! @author guillaume.gourves@onera.fr
--! @brief Timer for CREME Project
-------------------------------------------------------
 --! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library NX; no need
--use NX.nxpackage.all; no need

--! Mux entity brief description

--! Detailed description of this
--! mux design element.
entity timer_x_bit is
    generic
    (
      nb_bit : integer := 32                              --! Timer resolution
    );
    port
    (
         CLK       : in    std_logic                            --! Clock for module 100MHz
        ;RESET_BAR : in    std_logic                            --! Reset pin for initialisation
        ;ARM       : in    std_logic                            --! Input that goes armed our timer
        ;VALUE     : in    std_logic_vector(nb_bit-1 downto 0)  --! Input that specified xhen the timer set an interrupt flag
        ;IRQ_FLAG  : out   std_logic                            --! Output which indicate that the time has elapsed
    );
end entity;

--! @brief Architecture definition of the test_controleur_can
--! @details More details about this mux element.
architecture behavior of timer_x_bit is
  signal sig_value      : std_logic_vector (nb_bit-1 downto 0);
  signal sig_cnt        : std_logic_vector (nb_bit-1 downto 0);
  signal sig_arm        : std_logic;
  signal sig_irq_flag   : std_logic;
  type behavior_state is
  (
    INIT
    ,IDLE
    ,LOAD_VALUE
    ,COUNT
    ,IRQ
  );
  signal etat : behavior_state;

begin
  IRQ_FLAG <= sig_irq_flag;
  sig_arm <= ARM;
  process(CLK) is

  begin
    if rising_edge(CLK) then
      if RESET_BAR = '0' then         -- Initialisation
        sig_cnt <= (others => '0');
        sig_value <= (others => '0');
        sig_irq_flag <= '1';
      else
        case etat is
          when INIT   => -- Initialisation
            sig_cnt <= (others => '0');
            sig_value <= (others => '0');
            sig_irq_flag <= '1';
            etat <= IDLE;
          when IDLE   =>  -- Attente du demande d'armement
            sig_cnt <= (others => '0');
            sig_value <= (others => '0');
            sig_irq_flag <= '1';
            if (sig_arm='1') then
                etat <= LOAD_VALUE;
            end if;
          when LOAD_VALUE   => -- On attend de relacher la pin d'armement pour démarer
            if (sig_arm='0') then
              sig_irq_flag  <= '0';
              sig_cnt   <= std_logic_vector(unsigned(sig_cnt)+10);
              sig_value <= VALUE;
              if(sig_value = "0") then
                etat <= IRQ;
              else
                etat <= COUNT;
              end if;
            end if;
          when COUNT  =>  -- On Compte jusqu'à la fin dut timer
            sig_cnt   <= std_logic_vector(unsigned(sig_cnt)+10);
            if (unsigned(sig_cnt)>=unsigned(sig_value)) then
              etat <= IRQ;
            end if;
          when IRQ    =>  -- On génère la fin du comptage
            sig_irq_flag <= '1';
            etat <= IDLE;
          when others      =>
            etat <= INIT;
        end case;
      end if;
    end if;
  end process;

end architecture;
