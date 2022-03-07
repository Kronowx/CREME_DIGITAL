----------------------------------------------------------------------------------
-- Company: ONERA Toulouse
-- Engineer: guillaume.gourves@onera.fr
--
-- Create Date: 05.07.2021 11:07:56
-- Design Name:
-- Module Name: package_SJA1000 - Behavioral
-- Project Name: CREME
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

PACKAGE SJA1000 IS -- déclaration de l'entête du package
constant SJA1000_ClearReg         : std_logic_vector(7 downto 0):= x"00";

--- Address and bit definitions for the Mode & Control Register
constant SJA1000_ControlReg         : std_logic_vector(7 downto 0):= x"00";
  constant RM_RR_Bit  : std_logic_vector(7 downto 0):= x"01"; --reset mode (request) bit.
  constant RIE_Bit    : std_logic_vector(7 downto 0):= x"02"; --Receive Interrupt enable bit.
  constant TIE_Bit    : std_logic_vector(7 downto 0):= x"04"; --Transmit Interrupt enable bit.
  constant EIE_Bit    : std_logic_vector(7 downto 0):= x"08"; --Error Interrupt enable bit.
  constant DOIE_Bit   : std_logic_vector(7 downto 0):= x"10"; --Overrun Interrupt enable bit.

-- Address and bit definitions for the Command Register
constant SJA1000_CommandReg             : std_logic_vector(7 downto 0):= x"01";
  constant TR_Bit   : std_logic_vector(7 downto 0):= x"01"; --transmission request bit.
  constant AT_Bit   : std_logic_vector(7 downto 0):= x"02"; --abort transmission bit.
  constant RRB_Bit  : std_logic_vector(7 downto 0):= x"04"; --release receive buffer bit.
  constant CDO_Bit  : std_logic_vector(7 downto 0):= x"08"; --clear data overrun bit.
  constant GTS_Bit  : std_logic_vector(7 downto 0):= x"10"; --goto sleep bit (BasicCAN mode).

-- Address and bit definitions for the Status Register
constant SJA1000_StatusReg            : std_logic_vector(7 downto 0):= x"02";
  constant RBS_Bit  : std_logic_vector(7 downto 0):= x"01"; --receive buffer status bit.
  constant DOS_Bit  : std_logic_vector(7 downto 0):= x"02"; --data overrun status bit.
  constant TBS_Bit  : std_logic_vector(7 downto 0):= x"04"; --transmit buffer status bit.
  constant TCS_Bit  : std_logic_vector(7 downto 0):= x"08"; --transmission complete status bit.
  constant RS_Bit   : std_logic_vector(7 downto 0):= x"10"; --receive status bit.
  constant TS_Bit   : std_logic_vector(7 downto 0):= x"20"; --transmit status bit.
  constant ES_Bit   : std_logic_vector(7 downto 0):= x"40"; --error status bit.
  constant BS_Bit   : std_logic_vector(7 downto 0):= x"80"; --bus status bit.

--- Address and bit definitions for the Interrupt Register
constant SJA1000_InterruptReg         : std_logic_vector(7 downto 0):= x"03";
  constant RI_Bit     : std_logic_vector(7 downto 0):= x"01"; --receive interrupt bit.
  constant TI_Bit     : std_logic_vector(7 downto 0):= x"02"; --transmit interrupt bit.
  constant EI_Bit     : std_logic_vector(7 downto 0):= x"04"; --error warning interrupt bit.
  constant DOI_Bit    : std_logic_vector(7 downto 0):= x"08"; --data overrun interrupt bit.
  constant WUI_Bit    : std_logic_vector(7 downto 0):= x"10"; --wake-up interrupt bit.

--- Address definitions of Acceptance Code & Mask Registers
constant SJA1000_AcceptCodeReg 	        : std_logic_vector(7 downto 0):= x"04";
constant SJA1000_AcceptMaskReg 	        : std_logic_vector(7 downto 0):= x"05";

--- Address and bit definitions for the Bus Timing Registers
constant SJA1000_BusTiming0Reg 	: std_logic_vector(7 downto 0):= x"06";
constant SJA1000_BusTiming1Reg  : std_logic_vector(7 downto 0):= x"07";
  constant SAM_Bit                : std_logic_vector(7 downto 0):= x"80"; --sample mode bit 1 == the bus is sampled 3 times or 0 == the bus is sampled once.

--- Address and bit definitions for the Output Control Register
constant SJA1000_OutControlReg			    : std_logic_vector(7 downto 0):= x"08";
  --OCMODE1, OCMODE0.
  constant BiPhaseMode  : std_logic_vector(7 downto 0):= x"00"; --bi-phase output mode.
  constant NormalMode   : std_logic_vector(7 downto 0):= x"02"; --normal output mode.
  constant ClkOutMode   : std_logic_vector(7 downto 0):= x"03"; --clock output mode.
  -- output pin configuration for TX1.
  constant OCPOL1_Bit   : std_logic_vector(7 downto 0):= x"20"; --output polarity control bit.
  constant Tx1Float     : std_logic_vector(7 downto 0):= x"00"; --configured as float.
  constant Tx1PullDn    : std_logic_vector(7 downto 0):= x"40"; --configured as pull-down.
  constant Tx1PullUp    : std_logic_vector(7 downto 0):= x"80"; --configured as pull-up.
  constant Tx1PshPull   : std_logic_vector(7 downto 0):= x"C0"; --configured as push/pull.
  -- output pin configuration for TX0.
  constant OCPOL0_Bit   : std_logic_vector(7 downto 0):= x"04"; --output polarity control bit.
  constant Tx0Float     : std_logic_vector(7 downto 0):= x"00"; --configured as float.
  constant Tx0PullDn    : std_logic_vector(7 downto 0):= x"08"; --configured as pull-down.
  constant Tx0PullUp    : std_logic_vector(7 downto 0):= x"10"; --configured as pull-up.
  constant Tx0PshPull   : std_logic_vector(7 downto 0):= x"18"; --configured as push/pull.

-- Test
constant SJA1000_TestReg    : std_logic_vector(7 downto 0):= x"09";

--- Address definitions of the Tx-Buffer
constant SJA1000_TxBuffer1   : std_logic_vector(7 downto 0):= x"0A";
constant SJA1000_TxBuffer2   : std_logic_vector(7 downto 0):= x"0B";
constant SJA1000_TxBuffer3   : std_logic_vector(7 downto 0):= x"0C";
constant SJA1000_TxBuffer4   : std_logic_vector(7 downto 0):= x"0D";
constant SJA1000_TxBuffer5   : std_logic_vector(7 downto 0):= x"0E";
constant SJA1000_TxBuffer6   : std_logic_vector(7 downto 0):= x"0F";
constant SJA1000_TxBuffer7   : std_logic_vector(7 downto 0):= x"10";
constant SJA1000_TxBuffer8 	 : std_logic_vector(7 downto 0):= x"11";
constant SJA1000_TxBuffer9 	 : std_logic_vector(7 downto 0):= x"12";
constant SJA1000_TxBuffer10  : std_logic_vector(7 downto 0):= x"13";

--- Address definitions of the Rx-Buffer
constant SJA1000_RxBuffer1   : std_logic_vector(7 downto 0):= x"14";
constant SJA1000_RxBuffer2   : std_logic_vector(7 downto 0):= x"15";
constant SJA1000_RxBuffer3   : std_logic_vector(7 downto 0):= x"16";
constant SJA1000_RxBuffer4   : std_logic_vector(7 downto 0):= x"17";
constant SJA1000_RxBuffer5   : std_logic_vector(7 downto 0):= x"18";
constant SJA1000_RxBuffer6   : std_logic_vector(7 downto 0):= x"19";
constant SJA1000_RxBuffer7   : std_logic_vector(7 downto 0):= x"1A";
constant SJA1000_RxBuffer8   : std_logic_vector(7 downto 0):= x"1B";
constant SJA1000_RxBuffer9   : std_logic_vector(7 downto 0):= x"1C";
constant SJA1000_RxBuffer10  : std_logic_vector(7 downto 0):= x"1D";

-- Address and bit definitions for the Clock Divider Register
constant SJA1000_ClockDivideReg					: std_logic_vector(7 downto 0):= x"1F";
  constant DivBy1       : std_logic_vector(7 downto 0):= x"07"; --CLKOUT = oscillator frequency.
  constant DivBy2       : std_logic_vector(7 downto 0):= x"00"; --CLKOUT = 1/2 oscillator frequency.
  constant ClkOff_Bit   : std_logic_vector(7 downto 0):= x"08"; --clock off bit,  control of the CLK OUT pin.
  constant RXINTEN_Bit  : std_logic_vector(7 downto 0):= x"20"; --pin TX1 used for receive interrupt.
  constant CBP_Bit      : std_logic_vector(7 downto 0):= x"40"; --CAN comparator bypass control bit.
  constant CANMode_Bit  : std_logic_vector(7 downto 0):= x"80"; --CAN mode definition bit (BasicCAN or PeliCAN).

-- Initialisation parameters
constant CAN_TIMING0_BRP				: std_logic_vector(5 downto 0):= "000011";
constant CAN_TIMING0_SJW				: std_logic_vector(1 downto 0):= "01";
constant CAN_TIMING1_TSEG1	    : std_logic_vector(3 downto 0):= "1111";
constant CAN_TIMING1_TSEG2	    : std_logic_vector(2 downto 0):= "010";
constant CAN_TIMING1_SAM				: std_logic := '0';
constant EXTENDED_MODE					: std_logic := '1';
constant CAN_MODE_RESET					: std_logic := '1';
END SJA1000;

PACKAGE BODY SJA1000 IS -- déinition du corp du package
