--
-- tb_regfile.vhd
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
--! \brief Register file testbench.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.15
--! 
--! \date 2020/11/22
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity TB_RegFile is
end TB_RegFile;

architecture behavior of TB_RegFile is

    component Clock
        port(
            clk : out std_logic
            );
    end component;

    component RegFile
        generic(
            DATA_WIDTH  : natural := 32;                                --! Data width in bits.
            REG_NUMBER  : natural := 32                                 --! Total number of registers.
        );
        port(
            clk         : in std_logic;                                 --! Clock input.
            rs1         : in std_logic_vector(4 downto 0);              --! First source register number.
            rs2         : in std_logic_vector(4 downto 0);              --! Second source register number.
            rd          : in std_logic_vector(4 downto 0);              --! Destination register number.
            wr_en       : in std_logic;                                 --! Write register enable.
            data_write  : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Data to write into register.
            op1         : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Operand 1.
            op2         : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Operand 2.
        );
    end component;

    constant DATA_WIDTH     : natural := 32;

    signal clk_sig          : std_logic := '0';
    signal rs1_sig          : std_logic_vector(4 downto 0) := (others => '0');
    signal rs2_sig          : std_logic_vector(4 downto 0) := (others => '0');
    signal rd_sig           : std_logic_vector(4 downto 0) := (others => '0');
    signal wr_en_sig        : std_logic := '0';
    signal reg_write_sig    : std_logic_vector(4 downto 0) := (others => '0');
    signal data_write_sig   : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal op1_sig          : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal op2_sig          : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

begin

    clk_src : Clock port map(
                        clk             => clk_sig
                        );

    dut : RegFile   generic map(
                        DATA_WIDTH      => 32,
                        REG_NUMBER      => 32
                        )
                    port map(
                        clk             => clk_sig,
                        rs1             => rs1_sig,
                        rs2             => rs2_sig,
                        rd              => rd_sig,
                        wr_en           => wr_en_sig,
                        data_write      => data_write_sig,
                        op1             => op1_sig,
                        op2             => op2_sig
                        );

    process is
    begin
        wr_en_sig <= '1';

        rd_sig <= "00101";
        data_write_sig <= x"00000001";  -- Writes 0x01 to register 5
        wait for 30 ns;

        rd_sig <= "00111";
        data_write_sig <= x"00000002";  -- Writes 0x02 to register 7
        wait for 30 ns;

        wr_en_sig <= '0';
        wait for 30 ns;

        rs1_sig <= "00101";
        rs2_sig <= "00111";
        wait for 30 ns;

        if op1_sig /= x"00000001" then
            assert false report "Error: op1 is different from the expected value!" severity failure;
        end if;

        if op2_sig /= x"00000002" then
            assert false report "Error: op2 is different from the expected value!" severity failure;
        end if;

        assert false report "Test completed!" severity note;
        wait;
    end process;

end behavior;
