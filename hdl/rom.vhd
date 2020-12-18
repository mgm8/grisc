--
-- rom.vhd
--
-- Copyright (C) 2020, Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--
-- SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
--
-- Licensed under the Solderpad Hardware License v 2.1 (the "License");
-- you may not use this file except in compliance with the License,
-- or, at your option, the Apache License version 2.0.
--
-- You may obtain a copy of the License at
--
-- https://solderpad.org/licenses/SHL-2.1/
--
-- Unless required by applicable law or agreed to in writing, any
-- work distributed under the License is distributed on an "AS IS"
-- BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
-- express or implied. See the License for the specific language
-- governing permissions and limitations under the License.
--
--

--! 
--! \brief ROM memory.
--! 
--! \details This block loads a text file with hexadecimal numbers into a ROM.
--!
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.40
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
        ADR_WIDTH   : natural := 32;                                --! Address width in bits.
        SIZE        : natural := 1024;                              --! Memory size in bytes.
        MEM_FILE    : string := "rom.hex"                           --! File name of the memory file.
        );
    port(
        clk         : in std_logic;                                 --! Clock source.
        adr         : in std_logic_vector(ADR_WIDTH-1 downto 0);    --! Memory address.
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
                index := index + 4;
            end loop;
        end if;
		
        if rising_edge(clk) then
            data_out <= rom_mem(to_integer(unsigned(adr)));
        end if;
    end process;

end behavior;
