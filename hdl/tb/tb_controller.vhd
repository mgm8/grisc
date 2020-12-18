--
-- tb_controller.vhd
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
--! \brief Controller testbench.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.27
--! 
--! \date 2020/11/30
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity TB_Controller is
end TB_Controller;

architecture behavior of TB_Controller is

    component Clock
        port(
            clk : out std_logic
            );
    end component;

    component Controller
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
    end component;

    constant DATA_WIDTH     : natural := 32;

    signal clk_sig          : std_logic := '0';
    signal instruct_sig     : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal reg_write_sig    : std_logic := '0';
    signal alu_src_sig      : std_logic := '0';
    signal alu_op_sig       : std_logic_vector(1 downto 0) := (others => '0');
    signal dmem_wr_en_sig   : std_logic := '0';
    signal dmem_rd_en_sig   : std_logic := '0';
    signal mem_to_reg_sig   : std_logic := '0';
    signal branch_sig       : std_logic := '0';

begin

    clk_src : Clock     port map(
                            clk         => clk_sig
                            );

    dut : Controller    generic map(
                            DATA_WIDTH  => DATA_WIDTH,
                            DEBUG_MODE  => true
                            )
                        port map(
                            opcode      => instruct_sig(6 downto 0),
                            func3       => instruct_sig(14 downto 12),
                            func7       => instruct_sig(31 downto 25),
                            reg_write   => reg_write_sig,
                            alu_src     => alu_src_sig,
                            alu_op      => alu_op_sig,
                            dmem_wr_en  => dmem_wr_en_sig,
                            dmem_rd_en  => dmem_rd_en_sig,
                            mem_to_reg  => mem_to_reg_sig,
                            branch      => branch_sig
                            );

    process is
    begin
        instruct_sig <= x"00A00513";    -- addi x10, x0, 10
        wait for 20 ns;

        if (reg_write_sig & alu_src_sig & alu_op_sig & dmem_wr_en_sig & dmem_rd_en_sig & mem_to_reg_sig & branch_sig) /= "11100100" then
            assert false report "ERROR: Invalid result in an addi instruction!" severity failure;
        end if;

        instruct_sig <= x"00500593";    -- addi x11 , x0, 5
        wait for 20 ns;

        if (reg_write_sig & alu_src_sig & alu_op_sig & dmem_wr_en_sig & dmem_rd_en_sig & mem_to_reg_sig & branch_sig) /= "11100100" then
            assert false report "ERROR: Invalid result in an addi instruction!" severity failure;
        end if;

        instruct_sig <= x"00A58633";    -- add x12, x11, x10
        wait for 20 ns;

        if (reg_write_sig & alu_src_sig & alu_op_sig & dmem_wr_en_sig & dmem_rd_en_sig & mem_to_reg_sig & branch_sig) /= "10100000" then
            assert false report "ERROR: Invalid result in an add instruction!" severity failure;
        end if;

        instruct_sig <= x"00C576B3";    -- and x13, x10, x12
        wait for 20 ns;

        if (reg_write_sig & alu_src_sig & alu_op_sig & dmem_wr_en_sig & dmem_rd_en_sig & mem_to_reg_sig & branch_sig) /= "10100000" then
            assert false report "ERROR: Invalid result in an or instruction!" severity failure;
        end if;

        assert false report "Test completed with SUCCESS!" severity note;
        wait;
    end process;

end behavior;
