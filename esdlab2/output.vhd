-------------------------------------------------------------------------------
--                             VHDL ARCHITECTURE
-------------------------------------------------------------------------------
--
--  File      : output.vhd
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
--  Title     : Output control logic for crossbar switch.
--
--  Details   : Implements the output multiplexing and grant/request signals
--              needed for one ouput section of a crossbar switch.
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

LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY output IS
    PORT(
        data_out : OUT std_logic_vector(7 DOWNTO 0);
        gntx : OUT std_logic;
        gnty : OUT std_logic;
        clk : IN std_logic;
        data_inx : IN std_logic_vector(7 DOWNTO 0);
        data_iny : IN std_logic_vector(7 DOWNTO 0);
        reqx : IN std_logic;
        reqy : IN std_logic;
        reset : IN std_logic;
        writex : IN std_logic;
        writey : IN std_logic
    );
END output;

architecture behavior of output is

    -- Possible states.

    type states is (poll_x, poll_y, grant_x, grant_y);

    -- Present state.

    signal present_state : states;

begin

    -- Main process.

    process (clk, reset)

    begin

        -- Activities triggered by asynchronous reset (active low).

        if (reset = '0') then

            -- Set the default state and outputs.

            present_state <= poll_x;
            gntx <= '0';
            gnty <= '0';
            data_out <= "00000000";

        elsif (clk'event and clk = '1') then

            -- Set the default state and outputs.

            present_state <= poll_x;
            gntx <= '0';
            gnty <= '0';
            data_out <= "00000000";

            case present_state is

                when poll_x =>

                    if (reqx = '1') then
                        present_state <= grant_x;
                    else
                        present_state <= poll_y;
                    end if;

                when poll_y =>

                    if (reqy = '1') then
                        present_state <= grant_y;
                    else
                        present_state <= poll_x;
                    end if;

                when grant_x =>

                    if (writex = '1') then
                        data_out <= data_inx;
                    end if;

                    if (reqx = '1') then
                        present_state <= grant_x;
                    else
                        present_state <= poll_y;   
                    end if;

                    gntx <= '1';

                when grant_y =>

                    if (writey = '1') then
                        data_out <= data_iny;
                    end if;

                    if (reqy = '1') then
                        present_state <= grant_y;
                    else
                        present_state <= poll_x;
                    end if;

                    gnty <= '1';

                when others =>

                    -- Set the default state and outputs.

                    present_state <= poll_x;
                    gntx <= '0';
                    gnty <= '0';
                    data_out <= "00000000";

            end case;

        end if;

    end process;

end behavior;
