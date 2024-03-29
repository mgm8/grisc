--
-- tb_ram.vhd
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
--! \brief RAM testbench.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.41
--! 
--! \date 2020/11/21
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity TB_RAM is
end TB_RAM;

architecture behavior of TB_RAM is

    component Clock
        port(
            clk : out std_logic
            );
    end component;

    component RAM
        generic(
            DATA_WIDTH  : natural := 32;                                --! Data width in bits.
            ADR_WIDTH   : natural := 32;                                --! Address width in bits.
            SIZE        : natural := 1024                               --! Memory size in bytes.
        );
        port(
            clk         : in std_logic;                                 --! Clock input.
            wr_en       : in std_logic;                                 --! Write enable.
            op          : in std_logic_vector(3 downto 0);              --! Memory operation.
            adr         : in std_logic_vector(ADR_WIDTH-1 downto 0);    --! Memory address to access.
            data_in     : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Data input.
            data_out    : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Data output.
        );
    end component;

    signal clk_sig      : std_logic := '0';
    signal wr_en_sig    : std_logic := '0';
    signal adr_sig      : std_logic_vector(31 downto 0) := (others => '0');
    signal data_in_sig  : std_logic_vector(31 downto 0) := (others => '0');
    signal data_out_sig : std_logic_vector(31 downto 0) := (others => '0');

begin

    clk_src : Clock port map(
                        clk         => clk_sig
                        );

    dut : RAM       generic map(
                        DATA_WIDTH  => 32,
                        ADR_WIDTH   => 32,
                        SIZE        => 16
                        )
                    port map(
                        clk         => clk_sig,
                        wr_en       => wr_en_sig,
                        op          => "0000",
                        adr         => adr_sig,
                        data_in     => data_in_sig,
                        data_out    => data_out_sig
                        );

    process is
    begin
        wr_en_sig <= '0';
        adr_sig <= x"00000000";
        data_in_sig <= x"10101010";
        wait for 30 ns;

        if data_out_sig /= x"00000000" then
            assert false report "Error: Invalid value on address 0x00000000!" severity failure;
        end if;

        wr_en_sig <= '1';
        wait for 30 ns;

        if data_out_sig /= x"10101010" then
            assert false report "Error: Invalid value on address 0x00000000!" severity failure;
        end if;

        wr_en_sig <= '0';
        adr_sig <= x"00000001";
        data_in_sig <= x"0000AAAA";
        wait for 30 ns;

        wr_en_sig <= '1';
        wait for 30 ns;

        if data_out_sig /= x"0000AAAA" then
            assert false report "Error: Invalid value on address 0x00000001!" severity failure;
        end if;

        wr_en_sig <= '0';
        wait for 30 ns;

        assert false report "Test completed with SUCCESS!" severity note;
        wait;
    end process;

end behavior;
