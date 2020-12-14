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
--! \brief CPU controller.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.34
--! 
--! \date 2020/11/23
--!

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity Controller is
    generic(
        DATA_WIDTH  : natural := 32;                                --! Data width in bits.
        DEBUG_MODE  : boolean := false                              --! Debug mode flag.
        );
    port(
        opcode      : in std_logic_vector(6 downto 0);              --! Opcode.
        func3       : in std_logic_vector(2 downto 0);              --! func3.
        func7       : in std_logic_vector(6 downto 0);              --! func7.
        reg_write   : out std_logic;                                --! Register write enable.
        alu_src     : out std_logic;                                --! ALU source selector.
        alu_op      : out std_logic_vector(1 downto 0);             --! ALU operation code.
        dmem_wr_en  : out std_logic;                                --! Data memory write enable.
        dmem_rd_en  : out std_logic;                                --! Data memory read enable.
        mem_to_reg  : out std_logic;                                --! Data memory to register source selector.
        branch      : out std_logic                                 --! Branch selector.
        );
end Controller;

architecture behavior of Controller is

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
    constant RISCV_FUNC7_SRLI   : std_logic_vector(5 downto 0) := "000000";     --! srli.
    constant RISCV_FUNC3_SRAI   : std_logic_vector(2 downto 0) := "101";        --! srai.
    constant RISCV_FUNC7_SRAI   : std_logic_vector(5 downto 0) := "100000";     --! srai.
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

begin

    process(opcode)
    begin
        case opcode is
            when RISCV_OPCODE_BRCH =>
                case func3 is
                    when RISCV_FUNC3_BEQ =>
                        reg_write   <= '0';
                        alu_src     <= '0';
                        alu_op      <= "01";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '0';
--                        mem_to_reg  <= '';
                        branch      <= '1';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: beq" severity note;
                        end if;
                    when RISCV_FUNC3_BNE =>
                        reg_write   <= '0';
                        alu_src     <= '0';
                        alu_op      <= "01";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '0';
--                        mem_to_reg  <= '';
                        branch      <= '1';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: bne" severity note;
                        end if;
                    when RISCV_FUNC3_BLT =>
                        reg_write   <= '0';
                        alu_src     <= '0';
                        alu_op      <= "01";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '0';
--                        mem_to_reg  <= '';
                        branch      <= '1';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: blt" severity note;
                        end if;
                    when RISCV_FUNC3_BGE =>
                        reg_write   <= '0';
                        alu_src     <= '0';
                        alu_op      <= "01";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '0';
--                        mem_to_reg  <= '';
                        branch      <= '1';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: bge" severity note;
                        end if;
--                    when RISCV_FUNC3_BLTU =>
--                        reg_write   <= '';
--                        alu_src     <= '';
--                        alu_op      <= "";
--                        dmem_wr_en  <= '';
--                        dmem_rd_en  <= '';
--                        mem_to_reg  <= '';
--                        branch      <= '';
--                        if DEBUG_MODE = true then
--                            assert false report "Read instruction: bltu" severity note;
--                        end if;
--                    when RISCV_FUNC3_BGEU =>
--                        reg_write   <= '';
--                        alu_src     <= '';
--                        alu_op      <= "";
--                        dmem_wr_en  <= '';
--                        dmem_rd_en  <= '';
--                        mem_to_reg  <= '';
--                        branch      <= '';
--                        if DEBUG_MODE = true then
--                            assert false report "Read instruction: bgeu" severity note;
--                        end if;
                    when others =>
                        reg_write   <= '0';
                        alu_src     <= '0';
                        alu_op      <= "00";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '0';
                        mem_to_reg  <= '0';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: beq" severity note;
                        end if;
                end case;
            when RISCV_OPCODE_LUI =>
                reg_write   <= '1';
                alu_src     <= '1';
                alu_op      <= "00";
                dmem_wr_en  <= '0';
                dmem_rd_en  <= '1';
                mem_to_reg  <= '0';
                branch      <= '0';
                if DEBUG_MODE = true then
                    assert false report "Read instruction: lui" severity note;
                end if;
--            when RISCV_OPCODE_AUIPC =>
--                reg_write   <= '';
--                alu_src     <= '';
--                alu_op      <= "";
--                dmem_wr_en  <= '';
--                dmem_rd_en  <= '';
--                mem_to_reg  <= '';
--                branch      <= '';
--            when RISCV_OPCODE_JAL =>
--                reg_write   <= '1';
--                alu_src     <= '';
--                alu_op      <= "";
--                dmem_wr_en  <= '0';
--                dmem_rd_en  <= '1';
--                mem_to_reg  <= '';
--                branch      <= '';
--            when RISCV_OPCODE_JALR =>
--                reg_write   <= '1';
--                alu_src     <= '';
--                alu_op      <= "";
--                dmem_wr_en  <= '0';
--                dmem_rd_en  <= '1';
--                mem_to_reg  <= '';
--                branch      <= '';
            when RISCV_OPCODE_IMM =>
                case func3 is
                    when RISCV_FUNC3_ADDI =>
                        reg_write   <= '1';
                        alu_src     <= '1';
                        alu_op      <= "10";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '1';
                        mem_to_reg  <= '0';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: addi" severity note;
                        end if;
                    when RISCV_FUNC3_SLLI =>
                        reg_write   <= '1';
                        alu_src     <= '1';
                        alu_op      <= "10";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '1';
                        mem_to_reg  <= '0';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: slli" severity note;
                        end if;
                    when RISCV_FUNC3_SLTI =>
                        reg_write   <= '1';
                        alu_src     <= '1';
                        alu_op      <= "10";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '1';
                        mem_to_reg  <= '0';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: slti" severity note;
                        end if;
                    when RISCV_FUNC3_SLTIU =>
                        reg_write   <= '1';
                        alu_src     <= '1';
                        alu_op      <= "10";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '1';
                        mem_to_reg  <= '0';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: sltiu" severity note;
                        end if;
                    when RISCV_FUNC3_XORI =>
                        reg_write   <= '1';
                        alu_src     <= '1';
                        alu_op      <= "10";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '1';
                        mem_to_reg  <= '0';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: xori" severity note;
                        end if;
                    when RISCV_FUNC3_SRLI =>    -- "srli" or "srai"
                        case func7(6 downto 1) is
                            when RISCV_FUNC7_SRLI =>
                                reg_write   <= '1';
                                alu_src     <= '1';
                                alu_op      <= "10";
                                dmem_wr_en  <= '0';
                                dmem_rd_en  <= '1';
                                mem_to_reg  <= '0';
                                branch      <= '0';
                                if DEBUG_MODE = true then
                                    assert false report "Read instruction: srli" severity note;
                                end if;
                            when RISCV_FUNC7_SRAI =>
                                reg_write   <= '1';
                                alu_src     <= '1';
                                alu_op      <= "10";
                                dmem_wr_en  <= '0';
                                dmem_rd_en  <= '1';
                                mem_to_reg  <= '0';
                                branch      <= '0';
                                if DEBUG_MODE = true then
                                    assert false report "Read instruction: srai" severity note;
                                end if;
                            when others =>
                                reg_write   <= '0';
                                alu_src     <= '0';
                                alu_op      <= "00";
                                dmem_wr_en  <= '0';
                                dmem_rd_en  <= '0';
                                mem_to_reg  <= '0';
                                branch      <= '0';
                        end case;
                    when RISCV_FUNC3_ORI =>
                        reg_write   <= '1';
                        alu_src     <= '1';
                        alu_op      <= "10";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '1';
                        mem_to_reg  <= '0';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: ori" severity note;
                        end if;
                    when RISCV_FUNC3_ANDI =>
                        reg_write   <= '1';
                        alu_src     <= '1';
                        alu_op      <= "10";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '1';
                        mem_to_reg  <= '0';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: andi" severity note;
                        end if;
                    when others =>
                        reg_write   <= '0';
                        alu_src     <= '0';
                        alu_op      <= "00";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '0';
                        mem_to_reg  <= '0';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: INVALID imm instruction!" severity note;
                        end if;
                end case;
            when RISCV_OPCODE_COMP =>
                case func3 is
                    when RISCV_FUNC3_ADD =>     -- "add" or "sub"
                        case func7 is
                            when RISCV_FUNC7_ADD =>
                                reg_write   <= '1';
                                alu_src     <= '0';
                                alu_op      <= "10";
                                dmem_wr_en  <= '0';
                                dmem_rd_en  <= '0';
                                mem_to_reg  <= '0';
                                branch      <= '0';
                                if DEBUG_MODE = true then
                                    assert false report "Read instruction: add" severity note;
                                end if;
                            when RISCV_FUNC7_SUB =>
                                reg_write   <= '1';
                                alu_src     <= '0';
                                alu_op      <= "10";
                                dmem_wr_en  <= '0';
                                dmem_rd_en  <= '0';
                                mem_to_reg  <= '0';
                                branch      <= '0';
                                if DEBUG_MODE = true then
                                    assert false report "Read instruction: sub" severity note;
                                end if;
                            when others =>
                                reg_write   <= '0';
                                alu_src     <= '0';
                                alu_op      <= "00";
                                dmem_wr_en  <= '0';
                                dmem_rd_en  <= '0';
                                mem_to_reg  <= '0';
                                branch      <= '0';
                        end case;
                    when RISCV_FUNC3_SLL =>
                        reg_write   <= '1';
                        alu_src     <= '0';
                        alu_op      <= "10";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '0';
                        mem_to_reg  <= '0';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: sll" severity note;
                        end if;
                    when RISCV_FUNC3_SLT =>
                        reg_write   <= '1';
                        alu_src     <= '0';
                        alu_op      <= "10";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '0';
                        mem_to_reg  <= '0';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: slt" severity note;
                        end if;
                    when RISCV_FUNC3_SLTU =>
                        reg_write   <= '1';
                        alu_src     <= '0';
                        alu_op      <= "10";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '0';
                        mem_to_reg  <= '0';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: sltu" severity note;
                        end if;
                    when RISCV_FUNC3_XOR =>
                        reg_write   <= '1';
                        alu_src     <= '0';
                        alu_op      <= "10";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '0';
                        mem_to_reg  <= '0';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: xor" severity note;
                        end if;
                    when RISCV_FUNC3_SRL =>     -- "srl" or "sra"
                        case func7 is
                            when RISCV_FUNC7_SRL =>
                                reg_write   <= '1';
                                alu_src     <= '0';
                                alu_op      <= "10";
                                dmem_wr_en  <= '0';
                                dmem_rd_en  <= '0';
                                mem_to_reg  <= '0';
                                branch      <= '0';
                            when RISCV_FUNC7_SRA =>
                                reg_write   <= '1';
                                alu_src     <= '0';
                                alu_op      <= "10";
                                dmem_wr_en  <= '0';
                                dmem_rd_en  <= '0';
                                mem_to_reg  <= '0';
                                branch      <= '0';
                            when others =>
                                reg_write   <= '0';
                                alu_src     <= '0';
                                alu_op      <= "00";
                                dmem_wr_en  <= '0';
                                dmem_rd_en  <= '0';
                                mem_to_reg  <= '0';
                                branch      <= '0';
                        end case;
                    when RISCV_FUNC3_OR =>
                        reg_write   <= '1';
                        alu_src     <= '0';
                        alu_op      <= "10";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '0';
                        mem_to_reg  <= '0';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: or" severity note;
                        end if;
                    when RISCV_FUNC3_AND =>
                        reg_write   <= '1';
                        alu_src     <= '0';
                        alu_op      <= "10";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '0';
                        mem_to_reg  <= '0';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: and" severity note;
                        end if;
                    when others =>
                        reg_write   <= '0';
                        alu_src     <= '0';
                        alu_op      <= "00";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '0';
                        mem_to_reg  <= '0';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: INVALID comp instruction!" severity note;
                        end if;
                end case;
            when RISCV_OPCODE_LOAD =>
                case func3 is
                    when RISCV_FUNC3_LB =>
                        reg_write   <= '1';
                        alu_src     <= '1';
                        alu_op      <= "00";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '1';
                        mem_to_reg  <= '1';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: lb" severity note;
                        end if;
                    when RISCV_FUNC3_LH =>
                        reg_write   <= '1';
                        alu_src     <= '1';
                        alu_op      <= "00";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '1';
                        mem_to_reg  <= '1';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: lh" severity note;
                        end if;
                    when RISCV_FUNC3_LW =>
                        reg_write   <= '1';
                        alu_src     <= '1';
                        alu_op      <= "00";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '1';
                        mem_to_reg  <= '1';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: lw" severity note;
                        end if;
                    when RISCV_FUNC3_LBU =>
                        reg_write   <= '1';
                        alu_src     <= '1';
                        alu_op      <= "00";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '1';
                        mem_to_reg  <= '1';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: lbu" severity note;
                        end if;
                    when RISCV_FUNC3_LHU =>
                        reg_write   <= '1';
                        alu_src     <= '1';
                        alu_op      <= "00";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '1';
                        mem_to_reg  <= '1';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: lhu" severity note;
                        end if;
                    when others =>
                        reg_write   <= '0';
                        alu_src     <= '1';
                        alu_op      <= "00";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '0';
                        mem_to_reg  <= '0';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: INVALID load instruction!" severity note;
                        end if;
                end case;
            when RISCV_OPCODE_STORE =>
                case func3 is
                    when RISCV_FUNC3_SB =>
                        reg_write   <= '0';
                        alu_src     <= '1';
                        alu_op      <= "00";
                        dmem_wr_en  <= '1';
                        dmem_rd_en  <= '0';
--                        mem_to_reg  <= 'X';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: sb" severity note;
                        end if;
                        branch      <= '0';
                    when RISCV_FUNC3_SH =>
                        reg_write   <= '0';
                        alu_src     <= '1';
                        alu_op      <= "00";
                        dmem_wr_en  <= '1';
                        dmem_rd_en  <= '0';
--                        mem_to_reg  <= 'X';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: sh" severity note;
                        end if;
                    when RISCV_FUNC3_SW =>
                        reg_write   <= '0';
                        alu_src     <= '1';
                        alu_op      <= "00";
                        dmem_wr_en  <= '1';
                        dmem_rd_en  <= '0';
--                        mem_to_reg  <= 'X';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: sw" severity note;
                        end if;
                    when others =>
                        reg_write   <= '0';
                        alu_src     <= '0';
                        alu_op      <= "00";
                        dmem_wr_en  <= '0';
                        dmem_rd_en  <= '0';
--                        mem_to_reg  <= 'X';
                        branch      <= '0';
                        if DEBUG_MODE = true then
                            assert false report "Read instruction: INVALID store instruction!" severity note;
                        end if;
                end case;
            when others =>
                reg_write   <= '0';
                alu_src     <= '0';
                alu_op      <= "00";
                dmem_wr_en  <= '0';
                dmem_rd_en  <= '0';
                mem_to_reg  <= '0';
                branch      <= '0';
                if DEBUG_MODE = true then
                    assert false report "Read instruction: INVALID instruction!" severity note;
                end if;
        end case;
    end process;

end behavior;
