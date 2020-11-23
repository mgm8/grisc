--! 
--! \brief Simple RAM memory.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.9
--! 
--! \date 2020/11/21
--! 

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity RAM is
    generic(
        DATA_WIDTH  : natural := 32;                                --! Data width in bits.
        ADR_WIDTH   : natural := 32;                                --! Address width in bits.
        SIZE        : natural := 1024                               --! Memory size in bytes.
    );
    port(
        clk         : in std_logic;                                 --! Clock input.
        wr_en       : in std_logic;                                 --! Write enable.
        adr         : in std_logic_vector(ADR_WIDTH-1 downto 0);    --! Memory address to access.
        data_in     : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Data input.
        data_out    : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Data output.
    );
end RAM;

architecture behavior of RAM is

    type ram_type is array (0 to SIZE-1) of std_logic_vector(data_in'range);

    signal ram_mem : ram_type := (others => (others => '1'));

begin

    process(clk) is
    begin
        if rising_edge(clk) then
            if wr_en = '1' then
                ram_mem(to_integer(unsigned(adr))) <= data_in;
            end if;

            data_out <= ram_mem(to_integer(unsigned(adr)));
        end if;
    end process;

end behavior;
