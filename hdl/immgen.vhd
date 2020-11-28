--
-- immgen.vhd
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
--! \brief Immediate Generator.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.15
--! 
--! \date 2020/11/23
--!

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

entity ImmGen is
    generic(
        DATA_WIDTH : natural := 32                                  --! Data width in bits.
        );
    port(
        inst    : in std_logic_vector(DATA_WIDTH-1 downto 0);       --! Instruction.
        imm     : out std_logic_vector((2*DATA_WIDTH)-1 downto 0)   --! Generated immediate.
        );
end ImmGen;

architecture behavior of ImmGen is

begin

    process(inst)
    begin
        if (inst(6) = '0' and inst(5) = '0') then       -- Load instructions
            imm(11 downto 0) <= inst(31 downto 20);
        elsif (inst(6) = '0' and inst(5) = '1') then    -- Store instructions
            imm(11 downto 0) <= inst(31 downto 25) & inst(11 downto 7);
        elsif (inst(6) = '1' and inst(5) = '0') then    -- Conditional branches
            imm(11 downto 0) <= inst(31) & inst(7) & inst(30 downto 25) & inst(11 downto 8);
        else
            imm(11 downto 0) <= inst(31) & inst(7) & inst(30 downto 25) & inst(11 downto 8);
        end if;
    end process;

    -- Sign-extension
    gen : for i in 12 to 63 generate
        imm(i) <= inst(31);
    end generate;

end behavior;
