--! 
--! \brief Clock generation block for simulation.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.13
--! 
--! \date 2017/12/13
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity Clock is
    port(
        clk : out std_logic
        );
end Clock;

architecture behavior of Clock is

    signal clock_signal : std_logic := '0';

begin

    clock_signal <= not (clock_signal) after 10 ns;     -- Clock with 20 ns time period

    clk <= clock_signal;

end behavior;
