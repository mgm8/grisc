--
-- regfile.vhd
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
--! \brief Register file.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.40
--! 
--! \date 2020/11/22
--! 

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity RegFile is
    generic(
        DATA_WIDTH  : natural := 32;                                --! Data width in bits.
        REG_NUMBER  : natural := 32                                 --! Total number of registers.
    );
    port(
        clk         : in std_logic;                                 --! Clock input.
        r1_idx      : in std_logic_vector(4 downto 0);              --! First source register number.
        r2_idx      : in std_logic_vector(4 downto 0);              --! Second source register number.
        wr_idx      : in std_logic_vector(4 downto 0);              --! Destination register number.
        wr_en       : in std_logic;                                 --! Write register enable.
        wr_data     : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Data to write into register.
        reg1        : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Operand 1.
        reg2        : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Operand 2.
    );
end RegFile;

architecture behavior of RegFile is

    type bank is array(0 to REG_NUMBER) of std_logic_vector(DATA_WIDTH-1 downto 0);

    signal reg_bank : bank := (others => (others => '0'));

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if wr_en = '1' then
                if to_integer(unsigned(wr_idx)) /= 0 then   -- 0 = x0 = The constant zero register
                    reg_bank(to_integer(unsigned(wr_idx))) <= wr_data;
                end if;
            end if;
        end if;
    end process;

    reg1 <= reg_bank(to_integer(unsigned(r1_idx)));
    reg2 <= reg_bank(to_integer(unsigned(r2_idx)));

end behavior;
