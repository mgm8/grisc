--
-- tb_alu.vhd
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
--! \brief Aritmetic Logic Unit testbench.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.24
--! 
--! \date 2020/11/22
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity TB_ALU is
end TB_ALU;

architecture behavior of TB_ALU is

    component Clock
        port(
            clk : out std_logic
            );
    end component;

    component ALU is
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
    end component;

    constant DATA_WIDTH     : natural := 32;

    constant ALU_OP_ID_AND : std_logic_vector(3 downto 0) := "0000";    --! AND operation.
    constant ALU_OP_ID_OR  : std_logic_vector(3 downto 0) := "0001";    --! OR operation.
    constant ALU_OP_ID_ADD : std_logic_vector(3 downto 0) := "0010";    --! ADD operation.
    constant ALU_OP_ID_XOR : std_logic_vector(3 downto 0) := "0011";    --! XOR operation.
    constant ALU_OP_ID_SUB : std_logic_vector(3 downto 0) := "0110";    --! SUB operation.

    signal clk_sig          : std_logic := '0';
    signal op1_sig          : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal op2_sig          : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal operation_sig    : std_logic_vector(3 downto 0) := (others => '0');
    signal result_sig       : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal zero_sig         : std_logic := '0';

begin

    clk_src : Clock port map(
                        clk             => clk_sig
                        );

    dut : ALU   generic map(
                    DATA_WIDTH  => DATA_WIDTH
                    )
                port map(
                    op1         => op1_sig,
                    op2         => op2_sig,
                    operation   => operation_sig,
                    result      => result_sig,
                    zero        => zero_sig
                    );

    process is
    begin
        -- ADD test
        op1_sig <= x"00000002";
        op2_sig <= x"00000001";
        operation_sig <= ALU_OP_ID_ADD;
        wait for 50 ns;

        if result_sig /= x"00000003" then
            assert false report "Error: Wrong result on the ADD operator!" severity failure;
        end if;

        -- AND test
        op1_sig <= x"00000001";
        op2_sig <= x"00000001";
        operation_sig <= ALU_OP_ID_AND;
        wait for 50 ns;

        if result_sig /= x"00000001" then
            assert false report "Error: Wrong result on the AND operator!" severity failure;
        end if;

        -- OR test
        op1_sig <= x"00000001";
        op2_sig <= x"00000004";
        operation_sig <= ALU_OP_ID_OR;
        wait for 50 ns;

        if result_sig /= x"00000005" then
            assert false report "Error: Wrong result on the OR operator!" severity failure;
        end if;

        -- XOR test
        op1_sig <= x"00000021";
        op2_sig <= x"00000006";
        operation_sig <= ALU_OP_ID_XOR;
        wait for 50 ns;

        if result_sig /= x"00000027" then
            assert false report "Error: Wrong result on the XOR operator!" severity failure;
        end if;

        assert false report "Test completed!" severity note;
        wait;
    end process;

end behavior;
