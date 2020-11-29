--
-- mem_wb.vhd
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
--! \brief MEM/WB register.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.19
--! 
--! \date 2020/11/28
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity MEM_WB is
    generic(
        DATA_WIDTH          : natural := 32;                                        --! Data width in bits.
        ADR_WIDTH           : natural := 64;                                        --! Address width in bits.
        WB_MUX_SEL_WIDTH    : natural := 1;                                         --! WB mux select width in bits.
        REGFILE_ADR_WIDTH   : natural := 5                                          --! Register file address width in bits
        );
    port(
        clk                 : in std_logic;                                         --! Clock input.
        rst                 : in std_logic;                                         --! Reset signal.
        wb_sel_in           : in std_logic_vector(WB_MUX_SEL_WIDTH-1 downto 0);     --! WB mux select input.
        wb_sel_out          : out std_logic_vector(WB_MUX_SEL_WIDTH-1 downto 0);    --! WB mux select output.
        regfile_wr_en_in    : in std_logic;                                         --! Register file write enable input.
        regfile_wr_en_out   : out std_logic;                                        --! Register file write enable output.
        regfile_wr_adr_in   : in std_logic_vector(REGFILE_ADR_WIDTH-1 downto 0);    --! Register file write address input.
        regfile_wr_adr_out  : out std_logic_vector(REGFILE_ADR_WIDTH-1 downto 0);   --! Register file write address output.
        alu_res_in          : in std_logic_vector(DATA_WIDTH-1 downto 0);           --! ALU result input.
        alu_res_out         : out std_logic_vector(DATA_WIDTH-1 downto 0);          --! ALU result output.
        data_mem_in         : in std_logic_vector(DATA_WIDTH-1 downto 0);           --! Data memory input.
        data_mem_out        : out std_logic_vector(DATA_WIDTH-1 downto 0)           --! Data memory output.
        );
end MEM_WB;

architecture behavior of MEM_WB is

    component Reg
        generic(
            DATA_WIDTH  : natural := 32                                 --! Data width in bits.
            );
        port(
            clk         : in std_logic;                                 --! Clock input.
            rst         : in std_logic;                                 --! Reset signal.
            input       : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Data input.
            output      : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Data output.
            );
    end component;

    signal regfile_wr_en_in_sig     : std_logic_vector(0 downto 0) := (others => '0');
    signal regfile_wr_en_out_sig    : std_logic_vector(0 downto 0) := (others => '0');

begin

    regfile_wr_en_in_sig(0) <= regfile_wr_en_in;
    regfile_wr_en_out       <= regfile_wr_en_out_sig(0);

    -- WB select register
    wb_sel_reg : Reg            generic map(
                                    DATA_WIDTH  => WB_MUX_SEL_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    input       => wb_sel_in,
                                    output      => wb_sel_out
                                    );

    -- Register file write enable register
    regfile_wr_en_reg : Reg     generic map(
                                    DATA_WIDTH  => 1
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    input       => regfile_wr_en_in_sig,
                                    output      => regfile_wr_en_out_sig
                                    );

    -- Register file write address register
    regfile_wr_adr_reg : Reg    generic map(
                                    DATA_WIDTH  => REGFILE_ADR_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    input       => regfile_wr_adr_in,
                                    output      => regfile_wr_adr_out
                                    );

    -- ALU result register
    alu_res_reg : Reg           generic map(
                                    DATA_WIDTH  => DATA_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    input       => alu_res_in,
                                    output      => alu_res_out
                                    );

    -- Data memory register
    data_mem_reg : Reg          generic map(
                                    DATA_WIDTH  => DATA_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    input       => data_mem_in,
                                    output      => data_mem_out
                                    );

end behavior;
