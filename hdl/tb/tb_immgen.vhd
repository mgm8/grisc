--
-- tb_immgen.vhd
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
--! \brief Immediate Generator testbench.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.15
--! 
--! \date 2020/11/23
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity TB_ImmGen is
end TB_ImmGen;

architecture behavior of TB_ImmGen is

    component Clock
        port(
            clk : out std_logic
            );
    end component;

    component ImmGen
        generic(
            DATA_WIDTH : natural := 32                                  --! Data width in bits.
        );
        port(
            inst    : in std_logic_vector(DATA_WIDTH-1 downto 0);       --! Instruction.
            imm     : out std_logic_vector((2*DATA_WIDTH)-1 downto 0)   --! Generated address.
        );
    end component;

    constant DATA_WIDTH : natural := 32;

    signal clk_sig      : std_logic := '0';
    signal inst_sig     : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal imm_sig      : std_logic_vector((2*DATA_WIDTH)-1 downto 0) := (others => '0');

begin

    clk_src : Clock port map(
                        clk         => clk_sig
                        );

    dut : ImmGen    generic map(
                        DATA_WIDTH  => DATA_WIDTH
                        )
                    port map(
                        inst        => inst_sig,
                        imm         => imm_sig
                        );

    process is
    begin
        inst_sig <= x"01700000";
        wait for 30 ns;

        if imm_sig /= x"0000000000000017" then
            assert false report "Error: Invalid result!" severity failure;
        end if;

        inst_sig <= x"0E0008A0";
        wait for 30 ns;

        if imm_sig /= x"00000000000000F1" then
            assert false report "Error: Invalid result!" severity failure;
        end if;

        inst_sig <= x"C20009C0";
        wait for 30 ns;

        if imm_sig /= x"FFFFFFFFFFFFFE19" then
            assert false report "Error: Invalid result!" severity failure;
        end if;

        assert false report "Test completed with SUCCESS!" severity note;
        wait;
    end process;

end behavior;
