--
-- ex_mem.vhd
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
--! \brief EX/MEM register.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.39
--! 
--! \date 2020/11/28
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity EX_MEM is
    generic(
        DATA_WIDTH          : natural := 32;                                        --! Data width in bits.
        ADR_WIDTH           : natural := 64;                                        --! Address width in bits.
        REGFILE_ADR_WIDTH   : natural := 5                                          --! Register file address width in bits
        );
    port(
        clk                 : in std_logic;                                         --! Clock input.
        rst                 : in std_logic;                                         --! Reset signal.
        en                  : in std_logic;                                         --! Enable signal.

        reg_do_write_in     : in std_logic;                                         --! .
        reg_wr_src_ctrl_in  : in std_logic_vector(1 downto 0);                      --! .
        mem_do_write_in     : in std_logic;                                         --! .
        mem_op_in           : in std_logic_vector(3 downto 0);                      --! .
        pc4_in              : in std_logic_vector(ADR_WIDTH-1 downto 0);            --! .
        alures_in           : in std_logic_vector(DATA_WIDTH-1 downto 0);           --! .
        r2_in               : in std_logic_vector(DATA_WIDTH-1 downto 0);           --! .
        wr_reg_idx_in       : in std_logic_vector(REGFILE_ADR_WIDTH-1 downto 0);    --! .

        reg_do_write_out    : out std_logic;                                        --! .
        reg_wr_src_ctrl_out : out std_logic_vector(1 downto 0);                     --! .
        mem_do_write_out    : out std_logic;                                        --! .
        mem_op_out          : out std_logic_vector(3 downto 0);                     --! .
        pc4_out             : out std_logic_vector(ADR_WIDTH-1 downto 0);           --! .
        alures_out          : out std_logic_vector(DATA_WIDTH-1 downto 0);          --! .
        r2_out              : out std_logic_vector(DATA_WIDTH-1 downto 0);          --! .
        wr_reg_idx_out      : out std_logic_vector(REGFILE_ADR_WIDTH-1 downto 0)    --! .
        );
end EX_MEM;

architecture behavior of EX_MEM is

    component Reg
        generic(
            DATA_WIDTH  : natural := 32                                 --! Data width in bits.
            );
        port(
            clk         : in std_logic;                                 --! Clock input.
            rst         : in std_logic;                                 --! Reset signal.
            en          : in std_logic;                                 --! Enable signal.
            input       : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Data input.
            output      : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Data output.
            );
    end component;

    component Reg1b
        port(
            clk         : in std_logic;     --! Clock input.
            rst         : in std_logic;     --! Reset signal.
            en          : in std_logic;     --! Enable signal.
            input       : in std_logic;     --! Data input.
            output      : out std_logic     --! Data output.
            );
    end component;

begin

    reg_0 : Reg1b               port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => reg_do_write_in,
                                    output      => reg_do_write_out
                                    );

    reg_1 : Reg                 generic map(
                                    DATA_WIDTH  => 2
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => reg_wr_src_ctrl_in,
                                    output      => reg_wr_src_ctrl_out
                                    );

    reg_2 : Reg1b       port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => mem_do_write_in,
                                    output      => mem_do_write_out
                                    );


    reg_3 : Reg                 generic map(
                                    DATA_WIDTH  => 4
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => mem_op_in,
                                    output      => mem_op_out
                                    );

    reg_4 : Reg                 generic map(
                                    DATA_WIDTH  => ADR_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => pc4_in,
                                    output      => pc4_out
                                    );

    reg_5 : Reg                 generic map(
                                    DATA_WIDTH  => DATA_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => alures_in,
                                    output      => alures_out
                                    );

    reg_6 : Reg                 generic map(
                                    DATA_WIDTH  => DATA_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => r2_in,
                                    output      => r2_out
                                    );

    reg_7 : Reg                 generic map(
                                    DATA_WIDTH  => REGFILE_ADR_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => wr_reg_idx_in,
                                    output      => wr_reg_idx_out
                                    );

end behavior;
