Library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library NX;
use NX.nxPackage.all;

entity pll is
port (
  ck25MHz   : in    std_logic;
  ck12_5MHz : out   std_logic;
  ck50MHz   : out   std_logic;
  nready    : out   std_logic;
  ready	    : out   std_logic
);
end entity;

architecture rtl of pll is

begin

-- targetFrequency = (referenceFrequency * (2 * fbk_intdiv)) / (2^clk_outdiv1))
-- 12.5 MHz        = (25 MHz             * (2 * 4) / (2^4))
-- 50 MHz          = (25 MHz             * (2 * 4) / (2^2))
--
-- Please note that (referenceFrequency * (2 * fbk_intdiv)) must be above 200 MHz and below 1200 MHz
  PLL_0 : NX_PLL
    generic map (
						-- Vco Range
						--    0: 200 -> 425 MHz
						--    1: 400 -> 850 MHz
      vco_range    => 0,			--    2: 800 -> 1200 MHz

						-- No added %2 division
      ref_div_on   => '0',			-- bypass :: %2
      fbk_div_on   => '0',			-- bypass :: %2
      ext_fbk_on   => '0',

						-- if fbk_div_on = 0
						--   2 to 31 => %4 to %62
						-- else
      fbk_intdiv   => 4,			--   1 to 15 => %4 to %60

						-- No Fbk Delay
      fbk_delay_on => '0',			-- fbk delay not used ...
      fbk_delay    => 0,			-- 0 to 63

      clk_outdiv1  => 4,			-- 0 to 7   (%1 to %2^7)
      clk_outdiv2  => 2,			-- 0 to 7   (%1 to %2^7)
      clk_outdiv3  => 0				-- 0 to 7   (%1 to %2^7)
    )
    port map (
        REF  => ck25MHz
      , FBK  => OPEN

      , VCO  => OPEN

      , D1   => ck12_5MHz
      , D2   => ck50MHz
      , D3   => OPEN
      , OSC  => OPEN

      , RDY  => ready
    );
    nready <= not(ready);

end architecture;
