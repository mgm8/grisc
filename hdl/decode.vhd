--
-- decode.vhd
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
--! \brief Instruction decoder.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.38
--! 
--! \date 2020/12/14
--! 

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.grisc.all;

entity Decode is
    generic(
        DATA_WIDTH  : natural := 32                                 --! Data width in bits.
        );
    port(
        instr       : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Instruction.
        r1_idx      : out std_logic_vector(4 downto 0);             --! Register 1 index.
        r2_idx      : out std_logic_vector(4 downto 0);             --! Register 2 index.
        wr_idx      : out std_logic_vector(4 downto 0);             --! Write register index.
        instr_id    : out std_logic_vector(5 downto 0)              --! Instruction ID.
    );
end Decode;

architecture behavior of Decode is

    signal opcode   : std_logic_vector(6 downto 0) := (others => '0');
    signal func3    : std_logic_vector(2 downto 0) := (others => '0');
    signal func7    : std_logic_vector(6 downto 0) := (others => '0');

begin

    opcode <= instr(6 downto 0);
    func3 <= instr(14 downto 12);
    func7 <= instr(31 downto 25);

    process(opcode, func3, func7)
    begin
        case opcode is
            when RISCV_OPCODE_BRCH =>
                case func3 is
                    when RISCV_FUNC3_BEQ =>
                        instr_id <= RISCV_INSTR_BEQ;
                    when RISCV_FUNC3_BNE =>
                        instr_id <= RISCV_INSTR_BNE;
                    when RISCV_FUNC3_BLT =>
                        instr_id <= RISCV_INSTR_BLT;
                    when RISCV_FUNC3_BGE =>
                        instr_id <= RISCV_INSTR_BGE;
                    when RISCV_FUNC3_BLTU =>
                        instr_id <= RISCV_INSTR_BLTU;
                    when RISCV_FUNC3_BGEU =>
                        instr_id <= RISCV_INSTR_BGEU;
                    when others =>
                        instr_id <= RISCV_INSTR_NOP;
                end case;
            when RISCV_OPCODE_LUI =>
                instr_id <= RISCV_INSTR_LUI;
            when RISCV_OPCODE_AUIPC =>
                instr_id <= RISCV_INSTR_AUIPC;
            when RISCV_OPCODE_JAL =>
                instr_id <= RISCV_INSTR_JAL;
            when RISCV_OPCODE_JALR =>
                instr_id <= RISCV_INSTR_JALR;
            when RISCV_OPCODE_IMM =>
                case func3 is
                    when RISCV_FUNC3_ADDI =>
                        instr_id <= RISCV_INSTR_ADDI;
                    when RISCV_FUNC3_SLLI =>
                        instr_id <= RISCV_INSTR_SLLI;
                    when RISCV_FUNC3_SLTI =>
                        instr_id <= RISCV_INSTR_SLTI;
                    when RISCV_FUNC3_SLTIU =>
                        instr_id <= RISCV_INSTR_SLTIU;
                    when RISCV_FUNC3_XORI =>
                        instr_id <= RISCV_INSTR_XORI;
                    when RISCV_FUNC3_SRLI =>
                        case func7 is
                            when RISCV_FUNC7_SRLI =>
                                instr_id <= RISCV_INSTR_SRLI;
                            when RISCV_FUNC7_SRAI =>
                                instr_id <= RISCV_INSTR_SRAI;
                            when others =>
                                instr_id <= RISCV_INSTR_NOP;
                        end case;
                    when RISCV_FUNC3_ORI =>
                        instr_id <= RISCV_INSTR_ORI;
                    when RISCV_FUNC3_ANDI =>
                        instr_id <= RISCV_INSTR_ANDI;
                    when others =>
                        instr_id <= RISCV_INSTR_NOP;
                end case;
            when RISCV_OPCODE_COMP =>
                case func3 is
                    when RISCV_FUNC3_ADD =>
                        case func7 is
                            when RISCV_FUNC7_ADD =>
                                instr_id <= RISCV_INSTR_ADD;
                            when RISCV_FUNC7_SUB =>
                                instr_id <= RISCV_INSTR_SUB;
                            when others =>
                                instr_id <= RISCV_INSTR_NOP;
                        end case;
                    when RISCV_FUNC3_SLL =>
                        instr_id <= RISCV_INSTR_SLL;
                    when RISCV_FUNC3_SLT =>
                        instr_id <= RISCV_INSTR_SLT;
                    when RISCV_FUNC3_SLTU=>
                        instr_id <= RISCV_INSTR_SLTU;
                    when RISCV_FUNC3_XOR =>
                        instr_id <= RISCV_INSTR_XOR;
                    when RISCV_FUNC3_SRL =>
                        case func7 is
                            when RISCV_FUNC7_SRL =>
                                instr_id <= RISCV_INSTR_SRL;
                            when RISCV_FUNC7_SRA =>
                                instr_id <= RISCV_INSTR_SRA;
                            when others =>
                                instr_id <= RISCV_INSTR_NOP;
                        end case;
                    when RISCV_FUNC3_OR =>
                        instr_id <= RISCV_INSTR_OR;
                    when RISCV_FUNC3_AND =>
                        instr_id <= RISCV_INSTR_AND;
                    when others =>
                        instr_id <= RISCV_INSTR_NOP;
                end case;
            when RISCV_OPCODE_LOAD =>
                case func3 is
                    when RISCV_FUNC3_LB =>
                        instr_id <= RISCV_INSTR_LB;
                    when RISCV_FUNC3_LH =>
                        instr_id <= RISCV_INSTR_LH;
                    when RISCV_FUNC3_LW =>
                        instr_id <= RISCV_INSTR_LW;
                    when RISCV_FUNC3_LBU =>
                        instr_id <= RISCV_INSTR_LBU;
--                    when RISCV_FUNC3_LHU =>
--                        instr_id <= RISCV_INSTR_LHU;
                    when others =>
                        instr_id <= RISCV_INSTR_NOP;
                end case;
            when RISCV_OPCODE_STORE =>
                case func3 is
                    when RISCV_FUNC3_SB =>
                        instr_id <= RISCV_INSTR_SB;
                    when RISCV_FUNC3_SH =>
                        instr_id <= RISCV_INSTR_SH;
                    when RISCV_FUNC3_SW =>
                        instr_id <= RISCV_INSTR_SW;
                    when others =>
                        instr_id <= RISCV_INSTR_NOP;
                end case;
            when others =>
                instr_id <= RISCV_INSTR_NOP;
        end case;
    end process;

    r1_idx <= instr(19 downto 15);
    r2_idx <= instr(24 downto 20);
    wr_idx <= instr(11 downto 7);

end behavior;
