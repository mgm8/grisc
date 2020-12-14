--
-- controller.vhd
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
--! \brief Datapath controller.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.41
--! 
--! \date 2020/11/23
--!

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.grisc.all;

entity Controller is
    generic(
        DATA_WIDTH          : natural := 32                         --! Data width in bits.
        );
    port(
        instr_id            : in std_logic_vector(5 downto 0);      --! Instruction ID.
        reg_do_write_ctrl   : out std_logic;                        --! Register write enable.
        reg_wr_src_ctrl     : out std_logic_vector(1 downto 0);     --! Register write source.
        mem_do_write_ctrl   : out std_logic;                        --! Data memory write enable.
        mem_do_read_ctrl    : out std_logic;                        --! Data memory read enable.
        mem_ctrl            : out std_logic_vector(3 downto 0);     --! Data memory control.
        do_jump             : out std_logic;                        --! Jump enable.

        do_branch           : out std_logic;                        --! Branch enable.
        alu_op1_ctrl        : out std_logic;                        --! ALU op1 control.
        alu_op2_ctrl        : out std_Logic;                        --! ALU op2 control.
        alu_ctrl            : out std_logic_vector(4 downto 0);     --! ALU control.
        comp_ctrl           : out std_logic_vector(2 downto 0)      --! Comp control.
        );
end Controller;

architecture behavior of Controller is

begin

    process(instr_id)
    begin
        case instr_id is
            when RISCV_INSTR_NOP =>
                reg_do_write_ctrl   <= '0';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_REG2;
                alu_ctrl            <= GRISC_ALU_OP_NOP;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_LUI =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_LUI;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_AUIPC =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_PC;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_ADD;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_JAL =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_PC4;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '1';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_PC;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_ADD;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_JALR =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_PC4;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '1';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_ADD;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_BEQ =>
                reg_do_write_ctrl   <= '0';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '1';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_PC;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_ADD;
                comp_ctrl           <= GRISC_COMP_OP_EQ;
            when RISCV_INSTR_BNE =>
                reg_do_write_ctrl   <= '0';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '1';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_PC;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_ADD;
                comp_ctrl           <= GRISC_COMP_OP_NE;
            when RISCV_INSTR_BLT =>
                reg_do_write_ctrl   <= '0';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '1';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_PC;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_ADD;
                comp_ctrl           <= GRISC_COMP_OP_LT;
            when RISCV_INSTR_BGE =>
                reg_do_write_ctrl   <= '0';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '1';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_PC;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_ADD;
                comp_ctrl           <= GRISC_COMP_OP_GE;
            when RISCV_INSTR_BLTU =>
                reg_do_write_ctrl   <= '0';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '1';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_PC;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_ADD;
                comp_ctrl           <= GRISC_COMP_OP_LTU;
            when RISCV_INSTR_BGEU =>
                reg_do_write_ctrl   <= '0';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '1';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_PC;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_ADD;
                comp_ctrl           <= GRISC_COMP_OP_GEU;
            when RISCV_INSTR_LB =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_MEMREAD;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '1';
                mem_ctrl            <= GRISC_MEM_OP_LB;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_ADD;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_LH =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_MEMREAD;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '1';
                mem_ctrl            <= GRISC_MEM_OP_LH;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_ADD;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_LW =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_MEMREAD;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '1';
                mem_ctrl            <= GRISC_MEM_OP_LW;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_ADD;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_LBU =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_MEMREAD;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '1';
                mem_ctrl            <= GRISC_MEM_OP_LBU;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_ADD;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_SB =>
                reg_do_write_ctrl   <= '0';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '1';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_SB;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_ADD;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_SH =>
                reg_do_write_ctrl   <= '0';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '1';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_SH;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_ADD;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_SW =>
                reg_do_write_ctrl   <= '0';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '1';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_SW;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_ADD;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_ADDI =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_ADD;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_SLTI =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_LT;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_SLTIU =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_LTU;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_XORI =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_XOR;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_ORI =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_OR;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_ANDI =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_AND;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_SLLI =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_SL;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_SRLI =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_SRL;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_SRAI =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_IMM;
                alu_ctrl            <= GRISC_ALU_OP_SRA;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_ADD =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_REG2;
                alu_ctrl            <= GRISC_ALU_OP_ADD;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_SUB =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_REG2;
                alu_ctrl            <= GRISC_ALU_OP_SUB;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_SLL =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_REG2;
                alu_ctrl            <= GRISC_ALU_OP_SL;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_SLT =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_REG2;
                alu_ctrl            <= GRISC_ALU_OP_LT;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_SLTU =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_REG2;
                alu_ctrl            <= GRISC_ALU_OP_LTU;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_XOR =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_REG2;
                alu_ctrl            <= GRISC_ALU_OP_XOR;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_SRL =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_REG2;
                alu_ctrl            <= GRISC_ALU_OP_SRL;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_SRA =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_REG2;
                alu_ctrl            <= GRISC_ALU_OP_SRA;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_OR =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_REG2;
                alu_ctrl            <= GRISC_ALU_OP_OR;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when RISCV_INSTR_AND =>
                reg_do_write_ctrl   <= '1';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_REG2;
                alu_ctrl            <= GRISC_ALU_OP_AND;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
            when others =>
                reg_do_write_ctrl   <= '0';
                reg_wr_src_ctrl     <= GRISC_REG_WR_SRC_ALURES;
                mem_do_write_ctrl   <= '0';
                mem_do_read_ctrl    <= '0';
                mem_ctrl            <= GRISC_MEM_OP_NOP;
                do_jump             <= '0';
                do_branch           <= '0';
                alu_op1_ctrl        <= GRISC_ALU_SRC_1_REG1;
                alu_op2_ctrl        <= GRISC_ALU_SRC_2_REG2;
                alu_ctrl            <= GRISC_ALU_OP_NOP;
                comp_ctrl           <= GRISC_COMP_OP_NOP;
        end case;
    end process;

end behavior;
