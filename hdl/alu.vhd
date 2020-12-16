--
-- alu.vhd
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
--! \brief Aritmetic Logic Unit (ALU).
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.42
--! 
--! \date 2020/11/22
--! 

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.numeric_std.all;

library work;
    use work.grisc.all;

entity ALU is
    generic(
        DATA_WIDTH : natural := 32                              --! Data width in bits.
    );
    port(
        ctrl    : in  std_logic_vector(4 downto 0);             --! Operation control.
        op1     : in  std_logic_vector(DATA_WIDTH-1 downto 0);  --! Operand 1.
        op2     : in  std_logic_vector(DATA_WIDTH-1 downto 0);  --! Operand 2.
        res     : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Operation output.
    );
end ALU;

architecture behavior of ALU is

    constant ZERO_CONST : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    constant ONE_CONST  : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '1');

begin

    process(ctrl, op1, op2)
    begin
        case ctrl is
            when GRISC_ALU_OP_NOP =>
                res <= ZERO_CONST;
            when GRISC_ALU_OP_ADD =>
                res <= op1 + op2;
            when GRISC_ALU_OP_SUB =>
                res <= op1 - op2;
            when GRISC_ALU_OP_MUL =>
                res <= op1 * op2;
--            when GRISC_ALU_OP_DIV =>
--                res <= op1 / op2;
            when GRISC_ALU_OP_AND =>
                res <= op1 and op2;
            when GRISC_ALU_OP_OR =>
                res <= op1 or op2;
            when GRISC_ALU_OP_XOR =>
                res <= op1 xor op2;
            when GRISC_ALU_OP_SL =>
                res <= std_logic_vector(shift_left(unsigned(op1), to_integer(unsigned(op2))));
            when GRISC_ALU_OP_SRA =>
                res <= std_logic_vector(shift_right(unsigned(op1), to_integer(unsigned(op2))));
            when GRISC_ALU_OP_SRL =>
                res <= std_logic_vector(shift_right(unsigned(op1), to_integer(unsigned(op2))));
            when GRISC_ALU_OP_LUI =>
                res <= op2;
            when GRISC_ALU_OP_LT =>
                if op1 < op2 then
                    res <= x"00000001";
                else
                    res <= ZERO_CONST;
                end if;
            when GRISC_ALU_OP_LTU =>
                if op1 < op2 then
                    res <= x"00000001";
                else
                    res <= ZERO_CONST;
                end if;
            when GRISC_ALU_OP_MULH =>
                res <= op1 * op2;
            when GRISC_ALU_OP_MULHU =>
                res <= op1 * op2;
            when GRISC_ALU_OP_MULHSU=>
                res <= op1 * op2;
--            when GRISC_ALU_OP_DIVU =>
--                if op2 = ZERO_CONST then
--                    res <= ONE_CONST;
--                else
--                    res <= op1 / op2;
--                end if;
--            when GRISC_ALU_OP_REM =>
--                if op2 = ZERO_CONST then
--                    res <= op1;
--                else
--                    res <= op1 rem op2;
--                end if;
--            when GRISC_ALU_OP_REMU =>
--                if op2 = ZERO_CONST then
--                    res <= op1;
--                else
--                    res <= op1 rem op2;
--                end if;
            when others =>
                res <= ZERO_CONST;
        end case;
    end process;

end behavior;
