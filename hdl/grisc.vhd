--
-- grisc.vhd
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
--! \brief GRISC definitions.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.36
--! 
--! \date 2020/12/14
--! 

library ieee;
    use ieee.std_logic_1164.all;

package grisc is

    -- Reference: https://github.com/riscv/riscv-opcodes/blob/master/opcodes-rv32i
    constant RISCV_OPCODE_BRCH  : std_logic_vector(6 downto 0) := "1100011";    --! Branches instructions.
    constant RISCV_FUNC3_BEQ    : std_logic_vector(2 downto 0) := "000";        --! beq.
    constant RISCV_FUNC3_BNE    : std_logic_vector(2 downto 0) := "001";        --! bne.
    constant RISCV_FUNC3_BLT    : std_logic_vector(2 downto 0) := "100";        --! blt.
    constant RISCV_FUNC3_BGE    : std_logic_vector(2 downto 0) := "101";        --! bge.
    constant RISCV_FUNC3_BLTU   : std_logic_vector(2 downto 0) := "110";        --! bltu.
    constant RISCV_FUNC3_BGEU   : std_logic_vector(2 downto 0) := "111";        --! bgeu.

    constant RISCV_OPCODE_LUI   : std_logic_vector(6 downto 0) := "0110111";    --! lui.
    constant RISCV_OPCODE_AUIPC : std_logic_vector(6 downto 0) := "0010111";    --! auipc.
    constant RISCV_OPCODE_JAL   : std_logic_vector(6 downto 0) := "1101111";    --! jal.
    constant RISCV_OPCODE_JALR  : std_logic_vector(6 downto 0) := "1100111";    --! jalr.

    constant RISCV_OPCODE_IMM   : std_logic_vector(6 downto 0) := "0010011";    --! Immediate instructions.
    constant RISCV_FUNC3_ADDI   : std_logic_vector(2 downto 0) := "000";        --! addi.
    constant RISCV_FUNC3_SLLI   : std_logic_vector(2 downto 0) := "001";        --! slli.
    constant RISCV_FUNC3_SLTI   : std_logic_vector(2 downto 0) := "010";        --! slti.
    constant RISCV_FUNC3_SLTIU  : std_logic_vector(2 downto 0) := "011";        --! sltiu.
    constant RISCV_FUNC3_XORI   : std_logic_vector(2 downto 0) := "100";        --! xori.
    constant RISCV_FUNC3_SRLI   : std_logic_vector(2 downto 0) := "101";        --! srli.
    constant RISCV_FUNC7_SRLI   : std_logic_vector(6 downto 0) := "0000000";    --! srli.
    constant RISCV_FUNC3_SRAI   : std_logic_vector(2 downto 0) := "101";        --! srai.
    constant RISCV_FUNC7_SRAI   : std_logic_vector(6 downto 0) := "0100000";    --! srai.
    constant RISCV_FUNC3_ORI    : std_logic_vector(2 downto 0) := "110";        --! ori.
    constant RISCV_FUNC3_ANDI   : std_logic_vector(2 downto 0) := "111";        --! andi.

    constant RISCV_OPCODE_COMP  : std_logic_vector(6 downto 0) := "0110011";    --! Computation instructions.
    constant RISCV_FUNC3_ADD    : std_logic_vector(2 downto 0) := "000";        --! add.
    constant RISCV_FUNC7_ADD    : std_logic_vector(6 downto 0) := "0000000";    --! add.
    constant RISCV_FUNC3_SUB    : std_logic_vector(2 downto 0) := "000";        --! sub.
    constant RISCV_FUNC7_SUB    : std_logic_vector(6 downto 0) := "0100000";    --! sub.
    constant RISCV_FUNC3_SLL    : std_logic_vector(2 downto 0) := "001";        --! sll.
    constant RISCV_FUNC7_SLL    : std_logic_vector(6 downto 0) := "0000000";    --! sll.
    constant RISCV_FUNC3_SLT    : std_logic_vector(2 downto 0) := "010";        --! slt.
    constant RISCV_FUNC7_SLT    : std_logic_vector(6 downto 0) := "0000000";    --! slt.
    constant RISCV_FUNC3_SLTU   : std_logic_vector(2 downto 0) := "011";        --! sltu.
    constant RISCV_FUNC7_SLTU   : std_logic_vector(6 downto 0) := "0000000";    --! sltu.
    constant RISCV_FUNC3_XOR    : std_logic_vector(2 downto 0) := "100";        --! xor.
    constant RISCV_FUNC7_XOR    : std_logic_vector(6 downto 0) := "0000000";    --! xor.
    constant RISCV_FUNC3_SRL    : std_logic_vector(2 downto 0) := "101";        --! srl.
    constant RISCV_FUNC7_SRL    : std_logic_vector(6 downto 0) := "0000000";    --! srl.
    constant RISCV_FUNC3_SRA    : std_logic_vector(2 downto 0) := "101";        --! sra.
    constant RISCV_FUNC7_SRA    : std_logic_vector(6 downto 0) := "0100000";    --! sra.
    constant RISCV_FUNC3_OR     : std_logic_vector(2 downto 0) := "110";        --! or.
    constant RISCV_FUNC7_OR     : std_logic_vector(6 downto 0) := "0000000";    --! or.
    constant RISCV_FUNC3_AND    : std_logic_vector(2 downto 0) := "111";        --! and.
    constant RISCV_FUNC7_AND    : std_logic_vector(6 downto 0) := "0000000";    --! and.

    constant RISCV_OPCODE_LOAD  : std_logic_vector(6 downto 0) := "0000011";    --! Loads instructions.
    constant RISCV_FUNC3_LB     : std_logic_vector(2 downto 0) := "000";        --! lb (load byte).
    constant RISCV_FUNC3_LH     : std_logic_vector(2 downto 0) := "001";        --! lh (load half-word).
    constant RISCV_FUNC3_LW     : std_logic_vector(2 downto 0) := "010";        --! lw (load word).
    constant RISCV_FUNC3_LBU    : std_logic_vector(2 downto 0) := "100";        --! lbu (load byte-unsigned).
    constant RISCV_FUNC3_LHU    : std_logic_vector(2 downto 0) := "101";        --! lhu (load half-word unsigned).

    constant RISCV_OPCODE_STORE : std_logic_vector(6 downto 0) := "0100011";    --! Stores instructions.
    constant RISCV_FUNC3_SB     : std_logic_vector(2 downto 0) := "000";        --! sb (store byte).
    constant RISCV_FUNC3_SH     : std_logic_vector(2 downto 0) := "001";        --! sh (store half-word).
    constant RISCV_FUNC3_SW     : std_logic_vector(2 downto 0) := "010";        --! sw (store-word).

    -- Instructions IDs
    constant RISCV_INSTR_NOP    : std_logic_vector(5 downto 0) := "000000";
    constant RISCV_INSTR_LUI    : std_logic_vector(5 downto 0) := "000001";
    constant RISCV_INSTR_AUIPC  : std_logic_vector(5 downto 0) := "000010";
    constant RISCV_INSTR_JAL    : std_logic_vector(5 downto 0) := "000011";
    constant RISCV_INSTR_JALR   : std_logic_vector(5 downto 0) := "000100";
    constant RISCV_INSTR_BEQ    : std_logic_vector(5 downto 0) := "000101";
    constant RISCV_INSTR_BNE    : std_logic_vector(5 downto 0) := "000110";
    constant RISCV_INSTR_BLT    : std_logic_vector(5 downto 0) := "000111";
    constant RISCV_INSTR_BGE    : std_logic_vector(5 downto 0) := "001000";
    constant RISCV_INSTR_BLTU   : std_logic_vector(5 downto 0) := "001001";
    constant RISCV_INSTR_BGEU   : std_logic_vector(5 downto 0) := "001010";
    constant RISCV_INSTR_LB     : std_logic_vector(5 downto 0) := "001011";
    constant RISCV_INSTR_LH     : std_logic_vector(5 downto 0) := "001100";
    constant RISCV_INSTR_LW     : std_logic_vector(5 downto 0) := "001101";
    constant RISCV_INSTR_LBU    : std_logic_vector(5 downto 0) := "001110";
    constant RISCV_INSTR_SB     : std_logic_vector(5 downto 0) := "001111";
    constant RISCV_INSTR_SH     : std_logic_vector(5 downto 0) := "010000";
    constant RISCV_INSTR_SW     : std_logic_vector(5 downto 0) := "010001";
    constant RISCV_INSTR_ADDI   : std_logic_vector(5 downto 0) := "010010";
    constant RISCV_INSTR_SLTI   : std_logic_vector(5 downto 0) := "010011";
    constant RISCV_INSTR_SLTIU  : std_logic_vector(5 downto 0) := "010100";
    constant RISCV_INSTR_XORI   : std_logic_vector(5 downto 0) := "010101";
    constant RISCV_INSTR_ORI    : std_logic_vector(5 downto 0) := "010110";
    constant RISCV_INSTR_ANDI   : std_logic_vector(5 downto 0) := "010111";
    constant RISCV_INSTR_SLLI   : std_logic_vector(5 downto 0) := "011000";
    constant RISCV_INSTR_SRLI   : std_logic_vector(5 downto 0) := "011001";
    constant RISCV_INSTR_SRAI   : std_logic_vector(5 downto 0) := "011010";
    constant RISCV_INSTR_ADD    : std_logic_vector(5 downto 0) := "011011";
    constant RISCV_INSTR_SUB    : std_logic_vector(5 downto 0) := "011100";
    constant RISCV_INSTR_SLL    : std_logic_vector(5 downto 0) := "011101";
    constant RISCV_INSTR_SLT    : std_logic_vector(5 downto 0) := "011110";
    constant RISCV_INSTR_SLTU   : std_logic_vector(5 downto 0) := "011111";
    constant RISCV_INSTR_XOR    : std_logic_vector(5 downto 0) := "100000";
    constant RISCV_INSTR_SRL    : std_logic_vector(5 downto 0) := "100001";
    constant RISCV_INSTR_SRA    : std_logic_vector(5 downto 0) := "100010";
    constant RISCV_INSTR_OR     : std_logic_vector(5 downto 0) := "100011";
    constant RISCV_INSTR_AND    : std_logic_vector(5 downto 0) := "100100";
    constant RISCV_INSTR_ECALL  : std_logic_vector(5 downto 0) := "100101";

    constant GRISC_ALU_OP_NOP       : std_logic_vector(4 downto 0) := "00000";
    constant GRISC_ALU_OP_ADD       : std_logic_vector(4 downto 0) := "00001";
    constant GRISC_ALU_OP_SUB       : std_logic_vector(4 downto 0) := "00010";
    constant GRISC_ALU_OP_MUL       : std_logic_vector(4 downto 0) := "00011";
    constant GRISC_ALU_OP_DIV       : std_logic_vector(4 downto 0) := "00100";
    constant GRISC_ALU_OP_AND       : std_logic_vector(4 downto 0) := "00101";
    constant GRISC_ALU_OP_OR        : std_logic_vector(4 downto 0) := "00110";
    constant GRISC_ALU_OP_XOR       : std_logic_vector(4 downto 0) := "00111";
    constant GRISC_ALU_OP_SL        : std_logic_vector(4 downto 0) := "01000";
    constant GRISC_ALU_OP_SRA       : std_logic_vector(4 downto 0) := "01001";
    constant GRISC_ALU_OP_SRL       : std_logic_vector(4 downto 0) := "01010";
    constant GRISC_ALU_OP_LUI       : std_logic_vector(4 downto 0) := "01011";
    constant GRISC_ALU_OP_LT        : std_logic_vector(4 downto 0) := "01100";
    constant GRISC_ALU_OP_LTU       : std_logic_vector(4 downto 0) := "01101";
    constant GRISC_ALU_OP_EQ        : std_logic_vector(4 downto 0) := "01110";
    constant GRISC_ALU_OP_MULH      : std_logic_vector(4 downto 0) := "01111";
    constant GRISC_ALU_OP_MULHU     : std_logic_vector(4 downto 0) := "10000";
    constant GRISC_ALU_OP_MULHSU    : std_logic_vector(4 downto 0) := "10001";
    constant GRISC_ALU_OP_DIVU      : std_logic_vector(4 downto 0) := "10010";
    constant GRISC_ALU_OP_REM       : std_logic_vector(4 downto 0) := "10011";
    constant GRISC_ALU_OP_REMU      : std_logic_vector(4 downto 0) := "10100";

    constant GRISC_REG_WR_SRC_MEMREAD   : std_logic_vector(1 downto 0) := "00";
    constant GRISC_REG_WR_SRC_ALURES    : std_logic_vector(1 downto 0) := "01";
    constant GRISC_REG_WR_SRC_PC4       : std_logic_vector(1 downto 0) := "10";

    constant GRISC_ALU_SRC_1_REG1   : std_logic := '0';
    constant GRISC_ALU_SRC_1_PC     : std_logic := '1';

    constant GRISC_ALU_SRC_2_REG2   : std_logic := '0';
    constant GRISC_ALU_SRC_2_IMM    : std_logic := '1';

    constant GRISC_COMP_OP_NOP  : std_logic_vector(2 downto 0) := "000";
    constant GRISC_COMP_OP_EQ   : std_logic_vector(2 downto 0) := "001";
    constant GRISC_COMP_OP_NE   : std_logic_vector(2 downto 0) := "010";
    constant GRISC_COMP_OP_LT   : std_logic_vector(2 downto 0) := "011";
    constant GRISC_COMP_OP_LTU  : std_logic_vector(2 downto 0) := "100";
    constant GRISC_COMP_OP_GE   : std_logic_vector(2 downto 0) := "101";
    constant GRISC_COMP_OP_GEU  : std_logic_vector(2 downto 0) := "110";

    constant GRISC_MEM_OP_NOP   : std_logic_vector(3 downto 0) := "0000";
    constant GRISC_MEM_OP_LB    : std_logic_vector(3 downto 0) := "0001";
    constant GRISC_MEM_OP_LH    : std_logic_vector(3 downto 0) := "0010";
    constant GRISC_MEM_OP_LW    : std_logic_vector(3 downto 0) := "0011";
    constant GRISC_MEM_OP_LBU   : std_logic_vector(3 downto 0) := "0100";
    constant GRISC_MEM_OP_LHU   : std_logic_vector(3 downto 0) := "0101";
    constant GRISC_MEM_OP_SB    : std_logic_vector(3 downto 0) := "0110";
    constant GRISC_MEM_OP_SH    : std_logic_vector(3 downto 0) := "0111";
    constant GRISC_MEM_OP_SW    : std_logic_vector(3 downto 0) := "1000";

    constant GRISC_PC_SRC_PC4   : std_logic := '0';
    constant GRISC_PC_SRC_ALU   : std_logic := '1';

    constant GRISC_FORWARDING_SRC_ID_STAGE  : std_logic_vector(1 downto 0) := "00";
    constant GRISC_FORWARDING_SRC_MEM_STAGE : std_logic_vector(1 downto 0) := "01";
    constant GRISC_FORWARDING_SRC_WB_STAGE  : std_logic_vector(1 downto 0) := "10";

end grisc;
