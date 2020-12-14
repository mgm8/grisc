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
--! \version 0.0.34
--! 
--! \date 2020/11/22
--! 

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.numeric_std.all;

entity ALU is
    generic(
        DATA_WIDTH  : natural := 32                                 --! Data width in bits.
    );
    port(
        op1         : in  std_logic_vector(DATA_WIDTH-1 downto 0);  --! Operand 1.
        op2         : in  std_logic_vector(DATA_WIDTH-1 downto 0);  --! Operand 2.
        operation   : in  std_logic_vector(3 downto 0);             --! Operation code.
        result      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Opeartion output.
        zero        : out std_logic                                 --! Zero result flag.
    );
end ALU;

architecture behavior of ALU is

    constant ALU_OP_ID_AND : std_logic_vector(operation'range) := "0000";   --! AND operation.
    constant ALU_OP_ID_OR  : std_logic_vector(operation'range) := "0001";   --! OR operation.
    constant ALU_OP_ID_ADD : std_logic_vector(operation'range) := "0010";   --! ADD operation.
    constant ALU_OP_ID_XOR : std_logic_vector(operation'range) := "0011";   --! XOR operation.
    constant ALU_OP_ID_SLL : std_logic_vector(operation'range) := "0100";   --! SLL operation.
    constant ALU_OP_ID_SRL : std_logic_vector(operation'range) := "0101";   --! SRL operation.
    constant ALU_OP_ID_SUB : std_logic_vector(operation'range) := "0110";   --! SUB operation.
    constant ALU_OP_ID_SLT : std_logic_vector(operation'range) := "0111";   --! SLT operation.
    constant ALU_OP_ID_BEQ : std_logic_vector(operation'range) := "1000";   --! BEQ operation.
    constant ALU_OP_ID_BNE : std_logic_vector(operation'range) := "1001";   --! BNE operation.
    constant ALU_OP_ID_BLT : std_logic_vector(operation'range) := "1010";   --! BLT operation.
    constant ALU_OP_ID_BGE : std_logic_vector(operation'range) := "1011";   --! BGE operation.
    constant ALU_OP_ID_NOR : std_logic_vector(operation'range) := "1100";   --! NOR operation.

    signal result_sig   : std_logic_vector(result'range) := (others => '0');
    signal res_buf_sig  : std_logic_vector(DATA_WIDTH downto 0) := (others => '0');

begin

    result <= result_sig;

    zero <= not (result_sig(31) or result_sig(30) or result_sig(29) or result_sig(28) or result_sig(27) or
                 result_sig(26) or result_sig(25) or result_sig(24) or result_sig(23) or result_sig(22) or
                 result_sig(21) or result_sig(20) or result_sig(19) or result_sig(18) or result_sig(17) or
                 result_sig(16) or result_sig(15) or result_sig(14) or result_sig(13) or result_sig(12) or
                 result_sig(11) or result_sig(10) or result_sig(9)  or result_sig(8)  or result_sig(7) or
                 result_sig(6)  or result_sig(5)  or result_sig(4)  or result_sig(3)  or result_sig(2) or
                 result_sig(1)  or result_sig(0));

    process(operation, op1, op2)
    begin
        case operation is
            when ALU_OP_ID_AND => result_sig <= op1 and op2;
            when ALU_OP_ID_OR  => result_sig <= op1 or op2;
            when ALU_OP_ID_ADD => result_sig <= op1 + op2;
            when ALU_OP_ID_XOR => result_sig <= op1 xor op2;
            when ALU_OP_ID_SUB => result_sig <= op1 - op2;
            when ALU_OP_ID_SLT =>
                if op1 < op2 then
                    result_sig <= x"00000001";
                else
                    result_sig <= x"00000000";
                end if;
            when ALU_OP_ID_NOR => result_sig <= op1 nor op2;
            when ALU_OP_ID_SLL => result_sig <= std_logic_vector(shift_left(unsigned(op1), to_integer(unsigned(op2))));
            when ALU_OP_ID_SRL => result_sig <= std_logic_vector(shift_right(unsigned(op1), to_integer(unsigned(op2))));
            when ALU_OP_ID_BEQ =>
                if op1 = op2 then
                    result_sig <= (others => '0');
                else
                    result_sig <= (others => '1');
                end if;
            when ALU_OP_ID_BNE =>
                if op1 /= op2 then
                    result_sig <= (others => '0');
                else
                    result_sig <= (others => '1');
                end if;
            when ALU_OP_ID_BLT =>
                if op1 < op2 then
                    result_sig <= (others => '0');
                else
                    result_sig <= (others => '1');
                end if;
            when ALU_OP_ID_BGE =>
                if op1 >= op2 then
                    result_sig <= (others => '0');
                else
                    result_sig <= (others => '1');
                end if;
            when others => result_sig <= (others => '0');
        end case;
    end process;

end behavior;
