--! 
--! \brief ROM memory.
--! 
--! \details This block loads a text file with hexadecimal numbers into a ROM.
--!
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.1
--! 
--! \date 2020/11/22
--! 

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_textio.all;
    use ieee.numeric_std.all;
    use std.textio.all;

entity ROM is
    generic(
        DATA_WIDTH  : natural := 32;                                --! Data width in bits.
        SIZE        : natural := 1024;                              --! Memory size in bytes.
        MEM_FILE    : string := "rom.hex"                           --! File name of the memory file.
        );
    port(
        clk         : in std_logic;                                 --! Clock source.
        adr         : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Memory address.
        data_out    : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Data output.
        );
end ROM;

architecture behavior of ROM is
 
    type rom_type is array(SIZE-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);

    signal rom_mem : rom_type := (others => (others => '0'));

begin

    process(clk)
        variable data : std_logic_vector(DATA_WIDTH-1 downto 0); 
        variable index : natural := 0;
        file load_file : text open read_mode is MEM_FILE;
        variable hex_file_line : line;
    begin
        if index = 0 then
            while not endfile(load_file) loop
                readline(load_file, hex_file_line);
                hread(hex_file_line, data);
                rom_mem(index) <= data;
                index := index + 1;
            end loop;
        end if;
		
        if rising_edge(clk) then
            data_out <= rom_mem(to_integer(unsigned(adr)));
        end if;
    end process;

end behavior;
