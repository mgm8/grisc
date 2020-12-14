--
-- tb_core.vhd
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
--! \brief Core testbench.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.41
--! 
--! \date 2020/11/23
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity TB_Core is
end TB_Core;

architecture behavior of TB_Core is

    component Clock
        port(
            clk : out std_logic
            );
    end component;

    component Core
        generic(
            DATA_WIDTH      : natural := 32;                        --! Data width in bits.
            MEM_ADR_WIDTH   : natural := 32;                        --! Memory address width in bits.
            IMEM_SIZE_BYTES : natural := 1024;                      --! Instruction memory size in bytes.
            DMEM_SIZE_BYTES : natural := 8*1024;                    --! Data memory in bytes.
            PROGRAM_FILE    : string := "program.hex"               --! Instruction file.
            );
        port(
            clk : in std_logic;                                     --! Clock source.
            rst : in std_logic                                      --! Reset signal.
            );
    end component;

    constant DATA_WIDTH : natural := 32;

    signal clk_sig      : std_logic := '0';

begin

    clk_src : Clock port map(
                        clk             => clk_sig
                        );

    dut : Core     generic map(
                        DATA_WIDTH      => DATA_WIDTH,
                        MEM_ADR_WIDTH   => 32,
                        IMEM_SIZE_BYTES => 1024,
                        DMEM_SIZE_BYTES => 75*1024,
                        PROGRAM_FILE    => "program.hex"
                        )
                    port map(
                        clk             => clk_sig,
                        rst             => '1'
                        );

    process is
    begin
        wait for 750 ns;
        assert false report "Test completed with SUCCESS!" severity note;
        wait;
    end process;

end behavior;
