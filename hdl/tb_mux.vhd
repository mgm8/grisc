--
-- tb_mux.vhd
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
--! \brief Multiplexer testbench.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.15
--! 
--! \date 2020/11/22
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity TB_Mux is
end TB_Mux;

architecture behavior of TB_Mux is

    component Clock
        port(
            clk : out std_logic
            );
    end component;

    component Mux2x1
        generic(
            DATA_WIDTH  : natural := 32                             --! Width (in bits) of the inputs.
        );
        port(
            input1  : in  std_logic_vector(DATA_WIDTH-1 downto 0);  --! Input 1.
            input2  : in  std_logic_vector(DATA_WIDTH-1 downto 0);  --! Input 2.
            sel     : in  std_logic;                                --! Input selection.
            output  : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Output.
        );
    end component;

    constant DATA_WIDTH : natural := 32;

    signal clk_sig      : std_logic := '0';
    signal input1_sig   : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal input2_sig   : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal sel_sig      : std_logic := '0';
    signal output_sig   : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

begin

    clk_src : Clock port map(
                        clk         => clk_sig
                        );

    dut : Mux2x1    generic map(
                        DATA_WIDTH  => DATA_WIDTH
                        )
                    port map(
                        input1      => input1_sig,
                        input2      => input2_sig,
                        sel         => sel_sig,
                        output      => output_sig
                        );

    process is
    begin
        sel_sig <= '0';
        input1_sig <= x"00000001";
        input2_sig <= x"00000002";
        wait for 30 ns;

        if output_sig /= x"00000001" then
            assert false report "Error: Invalid value!" severity failure;
        end if;

        wait for 30 ns;

        sel_sig <= '1';
        wait for 30 ns;

        if output_sig /= x"00000002" then
            assert false report "Error: Invalid value!" severity failure;
        end if;

        assert false report "Test completed!" severity note;
        wait;
    end process;

end behavior;
