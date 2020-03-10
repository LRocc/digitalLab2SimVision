-------------------------------------------------------------------------------
-- Title      : Test stimulus for Crossbar Internals
-- Project    : 
-------------------------------------------------------------------------------
-- File       : stim_xbar.vhd
-- Author     : S.Roy - based on an original file by C.Slorach
-- Company    : 
-- Last update: 2001/02/06
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Provides a test stimulus for the Crossbar switch.
--              Two entirely separate data streams in xdata and ydata
--              contained in the same file to make use of same internal clock
--              See comments within the code.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2001/02/06  1.0      sroy    Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;           -- for internal counter etc.

ENTITY stim_xbar IS
    PORT(
        clk : OUT std_logic;
        r_n : OUT std_logic;
        stim_xavail : OUT std_logic;
        stim_xdata : OUT std_logic_vector(7 DOWNTO 0);
        stim_yavail : OUT std_logic;
        stim_ydata : OUT std_logic_vector(7 DOWNTO 0);
        stim_xenable : IN std_logic;
        stim_yenable : IN std_logic
    );
END stim_xbar;

architecture behavior of stim_xbar is

  -- Internal signals. As the clock source is used in the internal
  -- architecture of the stimulus generator, the clock output
  -- cannot be driven directly.                               

  signal internalclock : std_logic;     -- internal clock
  signal dummy         : std_logic;     -- dummy signal

begin  -- behavior


  
  -- purpose: Generates the reset signal, the output is set to logic '0'
  --          for the first 2450ns, then set to logic '1' for the rest
  --          of the time. Use is made of a 'dummy' event at the end
  --          of the process- this is a neat way of making the generation
  --          of the reset 'simulator friendly' to avoid unnecessary
  --          computation.
  --          To add in more stimuli for the reset, simply add in more
  --          entries after the 'wait for 2450ns' line.
  --          NB: This source is independent of any clock sources.
  --
  -- outputs: r_n
  
  resetgen : process

  begin  -- process resetgen

    r_n <= '0';
    wait for 2450 ns;

    r_n <= '1';

    -- Add more entries if required at this point !
    
    wait until dummy'event;

  end process resetgen;

  
  
  -- purpose: Generates the internal clock source. This is a 50% duty
  --          cycle clock source, period 1000ns, with the first half of
  --          the cycle being logic '0'.
  --
  -- outputs: internalclock

  clockgen : process
  begin  -- process clockgen

    internalclock <= '0';
    wait for 500 ns;
    internalclock <= '1';
    wait for 500 ns;

  end process clockgen;



  -- purpose: Generates the stimuli for the data, using a counter based
  --          approach which is much cleaner than explicit timings  
  --
  -- outputs: stim_inst
  --          stim_a
  --          stim_b  
  
  datagen : process

    -- Since we're going to output a number of different test
    -- data we need an internal counter to keep track of things.
    
    variable count : unsigned (5 downto 0) := "000000";

  begin  -- process datagen

    wait until internalclock'event and internalclock = '1';

    count := count + 1;

    if count = 4 then                   -- simple data transfer x -> x

      stim_xavail <= '1';               -- data flag raised
      
      wait until internalclock'event and internalclock = '1' 
                                     and stim_xenable = '1';
      
      stim_xdata  <= "00000010";	-- header word pushed when system
      stim_xavail <= '0';		-- requests transfer, and flag back down
      
      wait until internalclock'event and internalclock = '1' 
                                     and stim_xenable = '1';
      
      stim_xdata  <= "10101010";	-- data word pushed
      
      wait until internalclock'event and internalclock = '1' 
                                     and stim_xenable = '1';
      
      stim_xdata  <= "11111111";	-- end word pushed
      
    elsif count = 5 then		-- NO OPERATION

      stim_xavail <= '0';
      stim_xdata  <= "00000000";		

    else				-- NO OPERATION

      stim_xavail <= '0';
      stim_xdata  <= "00000000";		
      
    end if;

  end process datagen;

  -- now drive the output clock, this is simply the internal clock
  -- nb: could also invert the clock if desired to allow for signals
  -- to be generated pseudo-asynchronously
  
  clk <= internalclock;

end behavior;
