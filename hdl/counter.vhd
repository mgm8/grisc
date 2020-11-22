--! 
--! \brief Up counter.
--! 
--! \details Reference: https://startingelectronics.org/software/VHDL-CPLD-course/tut19-up-down-counter/
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.2
--! 
--! \date 2018/01/24
--!

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity Counter is
    generic(
        DATA_WIDTH      : natural := 2;                             --! Data width in bits.
        INIT_VALUE      : natural := 0;                             --! Initial value.
        MAX_VALUE       : natural := 1024;                          --! Maximum value.
        INCREMENT_VALUE : natural := 1                              --! Counter increment.
        );
    port(
        clk         : in std_logic;                                 --! Reference clock.
        rst         : in std_logic;                                 --! Resets counting (go back to 0).
        output      : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Counter output.
        );
end Counter;

architecture behavior of Counter is

    signal count : natural := INIT_VALUE;

begin

    process(clk)
    begin
        if rst = '0' then
            count <= 0;
        else
            if rising_edge(clk) then
                if count /= MAX_VALUE then
                    count <= count + INCREMENT_VALUE;   -- Count up
                end if;
            end if;
        end if;
    end process;

    output <= std_logic_vector(to_unsigned(count, output'length));

end behavior;
