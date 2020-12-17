--
-- ram.vhd
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
--! \brief Simple RAM memory.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.49
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
        op          : in std_logic_vector(3 downto 0);              --! Memory operation.
        adr         : in std_logic_vector(ADR_WIDTH-1 downto 0);    --! Memory address to access.
        data_in     : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Data input.
        data_out    : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Data output.
    );
end RAM;

architecture behavior of RAM is

    type ram_type is array (0 to SIZE-1) of std_logic_vector(data_in'range);

    signal ram_mem : ram_type := (others => (others => '0'));

begin

    process(wr_en, adr) is
    begin
            if wr_en = '1' then
                if adr < std_logic_vector(to_unsigned(SIZE, adr'length)) then
                    ram_mem(to_integer(unsigned(adr))) <= data_in;
                end if;
            end if;
    end process;

    process(adr)
    begin
        if adr > std_logic_vector(to_unsigned(SIZE, adr'length)) then
            data_out <= (others => '0');
        else
            data_out <= ram_mem(to_integer(unsigned(adr)));
        end if;
    end process;

end behavior;
