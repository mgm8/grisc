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
--! \version 0.0.49
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
        reg2        : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Operand 2.

        reg_x0      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x0.
        reg_x1      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x1.
        reg_x2      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x2.
        reg_x3      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x3.
        reg_x4      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x4.
        reg_x5      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x5.
        reg_x6      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x6.
        reg_x7      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x7.
        reg_x8      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x8.
        reg_x9      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x9.
        reg_x10     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x10.
        reg_x11     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x11.
        reg_x12     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x12.
        reg_x13     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x13.
        reg_x14     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x14.
        reg_x15     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x15.
        reg_x16     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x16.
        reg_x17     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x17.
        reg_x18     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x18.
        reg_x19     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x19.
        reg_x20     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x20.
        reg_x21     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x21.
        reg_x22     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x22.
        reg_x23     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x23.
        reg_x24     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x24.
        reg_x25     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x25.
        reg_x26     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x26.
        reg_x27     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x27.
        reg_x28     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x28.
        reg_x29     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x29.
        reg_x30     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x30.
        reg_x31     : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Register x31.
    );
end RegFile;

architecture behavior of RegFile is

    type bank is array(0 to REG_NUMBER) of std_logic_vector(DATA_WIDTH-1 downto 0);

    signal reg_bank : bank := (others => (others => '0'));

begin

    process(wr_en, wr_idx, wr_data) is
    begin
            if wr_en = '1' then
                if to_integer(unsigned(wr_idx)) /= 0 then   -- 0 = x0 = The constant zero register
                    reg_bank(to_integer(unsigned(wr_idx))) <= wr_data;
                end if;
            end if;
    end process;

    reg1 <= reg_bank(to_integer(unsigned(r1_idx)));
    reg2 <= reg_bank(to_integer(unsigned(r2_idx)));

    reg_x0 <= reg_bank(0);
    reg_x1 <= reg_bank(1);
    reg_x2 <= reg_bank(2);
    reg_x3 <= reg_bank(3);
    reg_x4 <= reg_bank(4);
    reg_x5 <= reg_bank(5);
    reg_x6 <= reg_bank(6);
    reg_x7 <= reg_bank(7);
    reg_x8 <= reg_bank(8);
    reg_x9 <= reg_bank(9);
    reg_x10 <= reg_bank(10);
    reg_x11 <= reg_bank(11);
    reg_x12 <= reg_bank(12);
    reg_x13 <= reg_bank(13);
    reg_x14 <= reg_bank(14);
    reg_x15 <= reg_bank(15);
    reg_x16 <= reg_bank(16);
    reg_x17 <= reg_bank(17);
    reg_x18 <= reg_bank(18);
    reg_x19 <= reg_bank(19);
    reg_x20 <= reg_bank(20);
    reg_x21 <= reg_bank(21);
    reg_x22 <= reg_bank(22);
    reg_x23 <= reg_bank(23);
    reg_x24 <= reg_bank(24);
    reg_x25 <= reg_bank(25);
    reg_x26 <= reg_bank(26);
    reg_x27 <= reg_bank(27);
    reg_x28 <= reg_bank(28);
    reg_x29 <= reg_bank(29);
    reg_x30 <= reg_bank(30);
    reg_x31 <= reg_bank(31);

end behavior;
