--
-- branch.vhd
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
--! \brief Branch control.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.38
--! 
--! \date 2020/12/14
--! 

library ieee;
    use ieee.std_logic_1164.all;

library work;
    use work.grisc.all;

entity Branch is
    generic(
        DATA_WIDTH  : natural := 32                                 --! Data width in bits.
        );
    port(
        comp_ctrl   : in std_logic_vector(2 downto 0);              --! Comp control.
        op1         : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Operator 1.
        op2         : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Operator 2.
        res         : out std_logic                                 --! Result.
        );
end Branch;

architecture behavior of Branch is

begin

    process(comp_ctrl, op1, op2)
    begin
        case comp_ctrl is
            when GRISC_COMP_OP_NOP =>
                res <= '0';
            when GRISC_COMP_OP_EQ =>
                if op1 = op2 then
                    res <= '1';
                else
                    res <= '0';
                end if;
            when GRISC_COMP_OP_NE =>
                if op1 /= op2 then
                    res <= '1';
                else
                    res <= '0';
                end if;
            when GRISC_COMP_OP_LT =>
                if op1 < op2 then
                    res <= '1';
                else
                    res <= '0';
                end if;
            when GRISC_COMP_OP_LTU =>
                if op1 < op2 then
                    res <= '1';
                else
                    res <= '0';
                end if;
            when GRISC_COMP_OP_GE =>
                if op1 >= op2 then
                    res <= '1';
                else
                    res <= '0';
                end if;
            when GRISC_COMP_OP_GEU =>
                if op1 >= op2 then
                    res <= '1';
                else
                    res <= '0';
                end if;
            when others =>
                res <= '0';
        end case;
    end process;

end behavior;
