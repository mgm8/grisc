--
-- aluctrl.vhd
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
--! \brief ALU Control.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.34
--! 
--! \date 2020/11/23
--!

library ieee;
    use ieee.std_logic_1164.all;

entity ALUCtrl is
    generic(
        DATA_WIDTH : natural := 32                              --! Data width in bits.
        );
    port(
        clk         : in std_logic;                             --! Clock signal.
        func3       : in std_logic_vector(2 downto 0);          --! 3-bit function code.
        func7       : in std_logic_vector(6 downto 0);          --! 7-bit function code.
        alu_op      : in std_logic_vector(1 downto 0);          --! ALU operation.
        alu_ctrl    : out std_logic_vector(3 downto 0)          --! ALU operation code.
        );
end ALUCtrl;

architecture behavior of ALUCtrl is

    constant ALU_OP_ID_AND : std_logic_vector(alu_ctrl'range) := "0000";    --! AND operation.
    constant ALU_OP_ID_OR  : std_logic_vector(alu_ctrl'range) := "0001";    --! OR operation.
    constant ALU_OP_ID_ADD : std_logic_vector(alu_ctrl'range) := "0010";    --! ADD operation.
    constant ALU_OP_ID_XOR : std_logic_vector(alu_ctrl'range) := "0011";    --! XOR operation.
    constant ALU_OP_ID_SLL : std_logic_vector(alu_ctrl'range) := "0100";    --! SLL operation.
    constant ALU_OP_ID_SRL : std_logic_vector(alu_ctrl'range) := "0101";    --! SRL operation.
    constant ALU_OP_ID_SUB : std_logic_vector(alu_ctrl'range) := "0110";    --! SUB operation.
    constant ALU_OP_ID_SLT : std_logic_vector(alu_ctrl'range) := "0111";    --! SLT operation.
    constant ALU_OP_ID_BEQ : std_logic_vector(alu_ctrl'range) := "1000";    --! BEQ operation.
    constant ALU_OP_ID_BNE : std_logic_vector(alu_ctrl'range) := "1001";    --! BNE operation.
    constant ALU_OP_ID_BLT : std_logic_vector(alu_ctrl'range) := "1010";    --! BLT operation.
    constant ALU_OP_ID_BGE : std_logic_vector(alu_ctrl'range) := "1011";    --! BGE operation.
    constant ALU_OP_ID_NOR : std_logic_vector(alu_ctrl'range) := "1100";    --! NOR operation.

begin

    process(func3, func7, alu_op)
    begin
        if alu_op = "00" then                                               -- load or store
            alu_ctrl <= ALU_OP_ID_ADD;
        elsif (alu_op = "01" and func3 = "000") then                        -- B-type: beq
            alu_ctrl <= ALU_OP_ID_SUB;
        elsif (alu_op = "01" and func3 = "001") then                        -- B-type: bne
            alu_ctrl <= ALU_OP_ID_BNE;
        elsif (alu_op = "01" and func3 = "100") then                        -- B-type: blt
            alu_ctrl <= ALU_OP_ID_BLT;
        elsif (alu_op = "01" and func3 = "101") then                        -- B-type: bge
            alu_ctrl <= ALU_OP_ID_BGE;
        elsif (alu_op = "10" and func7(5) = '0' and func3 = "000") then     -- R-type: add
            alu_ctrl <= ALU_OP_ID_ADD;
        elsif (alu_op = "10" and func7(5) = '1' and func3 = "000") then     -- R-type: sub
            alu_ctrl <= ALU_OP_ID_SUB;
        elsif (alu_op = "10" and func7(5) = '0' and func3 = "111") then     -- R-type: and
            alu_ctrl <= ALU_OP_ID_AND;
        elsif (alu_op = "10" and func7(5) = '0' and func3 = "110") then     -- R-type: or
            alu_ctrl <= ALU_OP_ID_OR;
        elsif (alu_op = "10" and func7(5) = '0' and func3 = "100") then     -- R-type: xor
            alu_ctrl <= ALU_OP_ID_XOR;
        elsif (alu_op = "10" and func7(5) = '0' and func3 = "001") then     -- R-type: sll
            alu_ctrl <= ALU_OP_ID_SLL;
        elsif (alu_op = "10" and func7(5) = '0' and func3 = "101") then     -- R-type: srl
            alu_ctrl <= ALU_OP_ID_SRL;
        elsif (alu_op = "10" and func7(5) = '0' and func3 = "010") then     -- R-type: srl
            alu_ctrl <= ALU_OP_ID_SLT;
        else
            alu_ctrl <= "1111";
        end if;
    end process;

end behavior;
