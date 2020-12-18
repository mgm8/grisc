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
--! \version 0.0.36
--! 
--! \date 2020/11/22
--! 

library ieee;
    use ieee.std_logic_1164.all;

library work;
    use work.grisc.all;

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
            DATA_WIDTH : natural := 32                              --! Data width in bits.
        );
        port(
            ctrl    : in  std_logic_vector(4 downto 0);             --! Operation control.
            op1     : in  std_logic_vector(DATA_WIDTH-1 downto 0);  --! Operand 1.
            op2     : in  std_logic_vector(DATA_WIDTH-1 downto 0);  --! Operand 2.
            res     : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Operation output.
        );
    end component;

    constant DATA_WIDTH     : natural := 32;

    signal clk_sig          : std_logic := '0';
    signal ctrl_sig         : std_logic_vector(4 downto 0) := (others => '0');
    signal op1_sig          : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal op2_sig          : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal res_sig          : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

begin

    clk_src : Clock port map(
                        clk             => clk_sig
                        );

    dut : ALU   generic map(
                    DATA_WIDTH  => DATA_WIDTH
                    )
                port map(
                    ctrl        => ctrl_sig,
                    op1         => op1_sig,
                    op2         => op2_sig,
                    res         => res_sig
                    );

    process is
    begin
        -- NOP test
        op1_sig <= x"0000000A";
        op2_sig <= x"00000008";
        ctrl_sig <= GRISC_ALU_OP_NOP;
        wait for 50 ns;

        if res_sig /= x"00000000" then
            assert false report "Error: Wrong result on the NOP operator!" severity failure;
        end if;

        -- ADD test
        ctrl_sig <= GRISC_ALU_OP_ADD;
        wait for 50 ns;

        if res_sig /= x"00000012" then
            assert false report "Error: Wrong result on the ADD operator!" severity failure;
        end if;

        -- SUB test
        ctrl_sig <= GRISC_ALU_OP_SUB;
        wait for 50 ns;

        if res_sig /= x"00000002" then
            assert false report "Error: Wrong result on the SUB operator!" severity failure;
        end if;

        -- MUL test
        ctrl_sig <= GRISC_ALU_OP_MUL;
        wait for 50 ns;

        if res_sig /= x"00000050" then
            assert false report "Error: Wrong result on the MUL operator!" severity failure;
        end if;

        -- DIV test
--        ctrl_sig <= GRISC_ALU_OP_DIV;
--        wait for 50 ns;
--
--        if res_sig /= x"00000001" then
--            assert false report "Error: Wrong result on the DIV operator!" severity failure;
--        end if;

        -- AND test
        ctrl_sig <= GRISC_ALU_OP_AND;
        wait for 50 ns;

        if res_sig /= x"00000008" then
            assert false report "Error: Wrong result on the AND operator!" severity failure;
        end if;

        -- OR test
        ctrl_sig <= GRISC_ALU_OP_OR;
        wait for 50 ns;

        if res_sig /= x"0000000A" then
            assert false report "Error: Wrong result on the OR operator!" severity failure;
        end if;

        -- XOR test
        ctrl_sig <= GRISC_ALU_OP_XOR;
        wait for 50 ns;

        if res_sig /= x"00000002" then
            assert false report "Error: Wrong result on the XOR operator!" severity failure;
        end if;

        -- SL tes
        ctrl_sig <= GRISC_ALU_OP_SL;
        wait for 50 ns;

        if res_sig /= x"00000A00" then
            assert false report "Error: Wrong result on the SL operator!" severity failure;
        end if;

        -- SRA test
        ctrl_sig <= GRISC_ALU_OP_SRA;
        wait for 50 ns;

        if res_sig /= x"00000000" then
            assert false report "Error: Wrong result on the SRA operator!" severity failure;
        end if;

        -- SRL test
        ctrl_sig <= GRISC_ALU_OP_SRL;
        wait for 50 ns;

        if res_sig /= x"00000A00" then
            assert false report "Error: Wrong result on the SRL operator!" severity failure;
        end if;

        -- LUI test
        ctrl_sig <= GRISC_ALU_OP_LUI;
        wait for 50 ns;

        if res_sig /= op2_sig then
            assert false report "Error: Wrong result on the LUI operator!" severity failure;
        end if;

        -- LT test
        ctrl_sig <= GRISC_ALU_OP_LT;
        wait for 50 ns;

        if res_sig /= x"00000000" then
            assert false report "Error: Wrong result on the LT operator!" severity failure;
        end if;

        -- LTU test
        ctrl_sig <= GRISC_ALU_OP_LTU;
        wait for 50 ns;

        if res_sig /= x"00000000" then
            assert false report "Error: Wrong result on the LTU operator!" severity failure;
        end if;

        assert false report "Test completed!" severity note;
        wait;
    end process;

end behavior;
