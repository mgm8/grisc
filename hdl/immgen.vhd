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
--! \version 0.0.42
--! 
--! \date 2020/11/23
--!

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

library work;
    use work.grisc.all;

entity ImmGen is
    generic(
        DATA_WIDTH : natural := 32                                  --! Data width in bits.
        );
    port(
        instr       : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Instruction.
        instr_id    : in std_logic_vector(5 downto 0);              --! Instruction ID.
        imm         : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Generated immediate.
        );
end ImmGen;

architecture behavior of ImmGen is

    constant ZERO_CONST : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

begin

    process(instr, instr_id)
    begin
        case instr_id is
            when RISCV_INSTR_NOP =>
                imm <= ZERO_CONST;
            when RISCV_INSTR_LUI =>
                imm <= instr and x"FFFFF000";
            when RISCV_INSTR_AUIPC =>
                imm <= instr and x"FFFFF000";
            when RISCV_INSTR_JAL =>
                imm(20 downto 0) <= instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0';
                -- Sign-extension
                for i in 21 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_JALR =>
                imm(11 downto 0) <= instr(31 downto 20);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_BEQ =>
                imm(11 downto 0) <= instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_BNE =>
                imm(11 downto 0) <= instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_BLT =>
                imm(11 downto 0) <= instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_BGE =>
                imm(11 downto 0) <= instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_BLTU =>
                imm(11 downto 0) <= instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_BGEU =>
                imm(11 downto 0) <= instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_LB =>
                imm(11 downto 0) <= instr(31 downto 20);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_LH =>
                imm(11 downto 0) <= instr(31 downto 20);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_LW =>
                imm(11 downto 0) <= instr(31 downto 20);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_LBU =>
                imm(11 downto 0) <= instr(31 downto 20);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_SB =>
                imm(11 downto 0) <= instr(31 downto 25) & instr(11 downto 7);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_SH =>
                imm(11 downto 0) <= instr(31 downto 25) & instr(11 downto 7);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_SW =>
                imm(11 downto 0) <= instr(31 downto 25) & instr(11 downto 7);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_ADDI =>
                imm(11 downto 0) <= instr(31 downto 20);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_SLTI =>
                imm(11 downto 0) <= instr(31 downto 20);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_SLTIU =>
                imm(11 downto 0) <= instr(31 downto 20);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_XORI =>
                imm(11 downto 0) <= instr(31 downto 20);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_ORI =>
                imm(11 downto 0) <= instr(31 downto 20);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_ANDI =>
                imm(11 downto 0) <= instr(31 downto 20);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_SLLI =>
                imm(11 downto 0) <= instr(31 downto 20);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_SRLI =>
                imm(11 downto 0) <= instr(31 downto 20);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when RISCV_INSTR_SRAI =>
                imm(11 downto 0) <= instr(31 downto 20);
                -- Sign-extension
                for i in 12 to DATA_WIDTH-1 loop
                    imm(i) <= instr(31);
                end loop;
            when others =>
                imm <= ZERO_CONST;
        end case;
    end process;

end behavior;
