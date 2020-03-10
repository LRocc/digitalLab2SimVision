-------------------------------------------------------------------------------
-- Title      : Test stimulus for Crossbar Design
-- Project    : 
-------------------------------------------------------------------------------
-- File       : testbench_xbar.vhd
-- Author     : S.Roy based on automated output from IC442 Cadence tools
-- Company    : 
-- Last update: 
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Links together a testbench (stim_xbar.vhd), two output
--              (output.vhd) and two control blocks (control.vhd), to form 
--              the overall test system for a crossbar switch.
--              See lab notes for a schematic description of the switch.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 26 Jan 06   1.1      S.Roy   Initial file 
--
-------------------------------------------------------------------------------

LIBRARY ieee;
LIBRARY worklib;
USE ieee.std_logic_1164.all;

ENTITY testbench_xbar IS END;

ARCHITECTURE schematic OF testbench_xbar IS
    COMPONENT stim_xbar
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
    END COMPONENT;
    
    COMPONENT control
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
    END COMPONENT;
    
    COMPONENT output
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
    END COMPONENT;
    
    SIGNAL x_gntx : std_logic;
    SIGNAL reset : std_logic;
    SIGNAL y_reqx : std_logic;
    SIGNAL y_reqy : std_logic;
    SIGNAL clock : std_logic;
    SIGNAL ywrite : std_logic;
    SIGNAL y_gnty : std_logic;
    SIGNAL y_gntx : std_logic;
    SIGNAL yavail : std_logic;
    SIGNAL xenable : std_logic;
    SIGNAL xdata : std_logic_vector(7 DOWNTO 0);
    SIGNAL x_reqx : std_logic;
    SIGNAL x_reqy : std_logic;
    SIGNAL xwrite : std_logic;
    SIGNAL ydata : std_logic_vector(7 DOWNTO 0);
    SIGNAL xavail : std_logic;
    SIGNAL yenable : std_logic;
    SIGNAL x_gnty : std_logic;
    
    SIGNAL data_outx : std_logic_vector(7 DOWNTO 0);
    SIGNAL data_outy : std_logic_vector(7 DOWNTO 0);
    
    FOR ALL: stim_xbar USE ENTITY worklib.stim_xbar(behavior);
    FOR ALL: control USE ENTITY worklib.control(behavior);
    FOR ALL: output USE ENTITY worklib.output(behavior);
    
    
BEGIN
    
    
    U1 : stim_xbar 
        PORT MAP(
            clk => clock,
            r_n => reset,
            stim_xavail => xavail,
            stim_xdata(7 DOWNTO 0) => xdata(7 DOWNTO 0),
            stim_yavail => yavail,
            stim_ydata(7 DOWNTO 0) => ydata(7 DOWNTO 0),
            stim_xenable => xenable,
            stim_yenable => yenable
        );
    
    U2 : control 
        PORT MAP(
            enable => yenable,
            reqx => y_reqx,
            reqy => y_reqy,
            write => ywrite,
            available => yavail,
            clk => clock,
            data_in(7 DOWNTO 0) => ydata(7 DOWNTO 0),
            gntx => y_gntx,
            gnty => y_gnty,
            reset => reset
        );
    
    U3 : control 
        PORT MAP(
            enable => xenable,
            reqx => x_reqx,
            reqy => x_reqy,
            write => xwrite,
            available => xavail,
            clk => clock,
            data_in(7 DOWNTO 0) => xdata(7 DOWNTO 0),
            gntx => x_gntx,
            gnty => x_gnty,
            reset => reset
        );
    
    U4 : output 
        PORT MAP(
            data_out(7 DOWNTO 0) => data_outy(7 DOWNTO 0),
            gntx => x_gnty,
            gnty => y_gnty,
            clk => clock,
            data_inx(7 DOWNTO 0) => xdata(7 DOWNTO 0),
            data_iny(7 DOWNTO 0) => ydata(7 DOWNTO 0),
            reqx => x_reqy,
            reqy => y_reqy,
            reset => reset,
            writex => xwrite,
            writey => ywrite
        );
    
    U5 : output 
        PORT MAP(
            data_out(7 DOWNTO 0) => data_outx(7 DOWNTO 0),
            gntx => x_gntx,
            gnty => y_gntx,
            clk => clock,
            data_inx(7 DOWNTO 0) => xdata(7 DOWNTO 0),
            data_iny(7 DOWNTO 0) => ydata(7 DOWNTO 0),
            reqx => x_reqx,
            reqy => y_reqx,
            reset => reset,
            writex => xwrite,
            writey => ywrite
        );
    
END schematic;
