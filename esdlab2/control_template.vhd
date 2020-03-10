-------------------------------------------------------------------------------
--                             VHDL ARCHITECTURE
-------------------------------------------------------------------------------
--
--  File      : control.vhd
--
--  Author    : Mark J. Milgrew
--
--  Address   : Microsystem Technology Research Group
--              University of Glasgow
--              Department of Electronics and Electrical Engineering
--              Oakfield Avenue
--              Glasgow
--              G12 8LT
--              Scotland
--
--  Telephone : +44 (0) 141 330 5226
--
--  Fax       : +44 (0) 141 330 6010
--
--  E-mail    : mark@elec.gla.ac.uk
--
--  Web       : http://www.elec.gla.ac.uk/~mark
--
--  Copyright (C) Mark J. Milgrew 2003.  All rights reserved.
--
-------------------------------------------------------------------------------
--                                DESCRIPTION
-------------------------------------------------------------------------------
--
--  Title     : Routing control for a crossbar switch.
--
--  Details   : Controller for routing a packet to one of two outputs
--              depending on the zero'th bit of the packet header word.  The
--              whole packet is then sent out, stopping when the 'FF' word is
--              sensed.  The controller sends request signals to the
--              appropriate output and sends the message on when it gets a
--              grant signal in return.
--
-------------------------------------------------------------------------------
--                               CHANGE HISTORY
-------------------------------------------------------------------------------
--
--  DATE           AUTHOR             DESCRIPTION
--  -----------    ---------------    ---------------------------------------
--  08-Feb-2003    Mark J. Milgrew    Created.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control is
        PORT(
            enable : OUT std_logic;
            reqx : OUT std_logic;
            reqy : OUT std_logic;
            write : OUT std_logic;
            available : IN std_logic;
            clk : IN std_logic;
            data_in : IN std_logic_vector(7 DOWNTO 0);
            gntx : IN std_logic;
            gnty : IN std_logic;
            reset : IN std_logic
        );
end control;

architecture behavior of control is

    -- Possible states.

    type states is (poll_fifo, setupA, setupB, setup_x, setup_y, data_xfer, data_yfer);

    -- Present state.

    signal present_state : states;

begin

    -- Main process.

    process (clk, reset)

    begin

        -- Activities triggered by asynchronous reset (active low).

        if (reset = '0') then

            -- Set the default state and outputs.

            present_state <= poll_fifo;
            enable <= '0';
            reqx <= '0';
            reqy <= '0';
            write <= '0';

        elsif (clk'event and clk = '1') then

            -- Set the default state and outputs.

            present_state <= poll_fifo;
            enable <= '0';
            reqx <= '0';
            reqy <= '0';
            write <= '0';

            case present_state is

                when poll_fifo =>
			if (available = '0') then 
				present_state <= poll_fifo;
			else  
				present_state <= setupA;
			end if
			 
		
                when setupA =>
			enable <= '1';
			present_state <= setupB;
			
				
                when setupB =>
			
			if (data_in(0) = '1') then
				reqx <= '1';
				present_state = data_xfer;
			if (data_in(0) = '0') then
				reqy <= '1';
				present_state = data_yfer;

                when setup_x =>
			

                when setup_y =>


                when data_xfer =>
			write <= '1';		


                when data_yfer =>
			write <= '1';

                when others =>

            end case;

        end if;

    end process;

end behavior;
