--
-- id_ex.vhd
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
--! \brief ID/EX register.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.39
--! 
--! \date 2020/11/28
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity ID_EX is
    generic(
        DATA_WIDTH          : natural := 32;                                        --! Data width in bits.
        ADR_WIDTH           : natural := 32;                                        --! Address width in bits.
        REGFILE_ADR_WIDTH   : natural := 5                                          --! Register file address width in bits
        );
    port(
        clk                 : in std_logic;                                         --! Clock input.
        rst                 : in std_logic;                                         --! Reset signal.
        en                  : in std_logic;                                         --! Enable signal.

        reg_do_write_in     : in std_logic;                                         --! .
        reg_wr_src_ctrl_in  : in std_logic_vector(1 downto 0);                      --! .
        mem_do_write_in     : in std_logic;                                         --! .
        mem_do_read_in      : in std_logic;                                         --! .
        mem_op_in           : in std_logic_vector(3 downto 0);                      --! .
        do_jmp_in           : in std_logic;                                         --! .
        do_br_in            : in std_logic;                                         --! .
        alu_op1_ctrl_in     : in std_logic;                                         --! .
        alu_op2_ctrl_in     : in std_logic;                                         --! .
        alu_ctrl_in         : in std_logic_vector(4 downto 0);                      --! .
        br_op_in            : in std_logic_vector(2 downto 0);                      --! .
        pc4_in              : in std_logic_vector(ADR_WIDTH-1 downto 0);            --! .
        pc_in               : in std_logic_vector(ADR_WIDTH-1 downto 0);            --! .
        r1_in               : in std_logic_vector(DATA_WIDTH-1 downto 0);           --! .
        r2_in               : in std_logic_vector(DATA_WIDTH-1 downto 0);           --! .
        imm_in              : in std_logic_vector(DATA_WIDTH-1 downto 0);           --! .
        rd_reg1_idx_in      : in std_logic_vector(REGFILE_ADR_WIDTH-1 downto 0);    --! .
        rd_reg2_idx_in      : in std_logic_vector(REGFILE_ADR_WIDTH-1 downto 0);    --! .
        wr_reg_idx_in       : in std_logic_vector(REGFILE_ADR_WIDTH-1 downto 0);    --! .
        instr_id_in         : in std_logic_vector(5 downto 0);                      --! .

        reg_do_write_out    : out std_logic;                                        --! .
        reg_wr_src_ctrl_out : out std_logic_vector(1 downto 0);                     --! .
        mem_do_write_out    : out std_logic;                                        --! .
        mem_do_read_out     : out std_logic;                                        --! .
        mem_op_out          : out std_logic_vector(3 downto 0);                     --! .
        do_jmp_out          : out std_logic;                                        --! .
        do_br_out           : out std_logic;                                        --! .
        alu_op1_ctrl_out    : out std_logic;                                        --! .
        alu_op2_ctrl_out    : out std_logic;                                        --! .
        alu_ctrl_out        : out std_logic_vector(4 downto 0);                     --! .
        br_op_out           : out std_logic_vector(2 downto 0);                     --! .
        pc4_out             : out std_logic_vector(ADR_WIDTH-1 downto 0);           --! .
        pc_out              : out std_logic_vector(ADR_WIDTH-1 downto 0);           --! .
        r1_out              : out std_logic_vector(DATA_WIDTH-1 downto 0);          --! .
        r2_out              : out std_logic_vector(DATA_WIDTH-1 downto 0);          --! .
        imm_out             : out std_logic_vector(DATA_WIDTH-1 downto 0);          --! .
        rd_reg1_idx_out     : out std_logic_vector(REGFILE_ADR_WIDTH-1 downto 0);   --! .
        rd_reg2_idx_out     : out std_logic_vector(REGFILE_ADR_WIDTH-1 downto 0);   --! .
        wr_reg_idx_out      : out std_logic_vector(REGFILE_ADR_WIDTH-1 downto 0);   --! .
        instr_id_out        : out std_logic_vector(5 downto 0)                      --! .
        );
end ID_EX;

architecture behavior of ID_EX is

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

    reg_0: Reg1b                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => reg_do_write_in,
                                    output      => reg_do_write_out
                                    );

    reg_1 : Reg                  generic map(
                                    DATA_WIDTH  => 2
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => reg_wr_src_ctrl_in,
                                    output      => reg_wr_src_ctrl_out
                                    );

    reg_2 : Reg1b               port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => mem_do_write_in,
                                    output      => mem_do_write_out
                                    );


    reg_3 : Reg1b               port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => mem_do_read_in,
                                    output      => mem_do_read_out
                                    );

    reg_4 : Reg                 generic map(
                                    DATA_WIDTH  => 4
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => mem_op_in,
                                    output      => mem_op_out
                                    );

    reg_5 : Reg1b               port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => do_jmp_in,
                                    output      => do_jmp_out
                                    );


    reg_6 : Reg1b               port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => do_br_in,
                                    output      => do_br_out
                                    );

    reg_7 : Reg1b               port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => alu_op1_ctrl_in,
                                    output      => alu_op1_ctrl_out
                                    );

    reg_8 : Reg1b               port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => alu_op2_ctrl_in,
                                    output      => alu_op2_ctrl_out
                                    );

    reg_9 : Reg                 generic map(
                                    DATA_WIDTH  => 5
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => alu_ctrl_in,
                                    output      => alu_ctrl_out
                                    );

    reg_10 : Reg                generic map(
                                    DATA_WIDTH  => 3
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => br_op_in,
                                    output      => br_op_out
                                    );

    reg_11 : Reg                generic map(
                                    DATA_WIDTH  => ADR_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => pc4_in,
                                    output      => pc4_out
                                    );

    reg_12 : Reg                generic map(
                                    DATA_WIDTH  => ADR_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => pc_in,
                                    output      => pc_out
                                    );

    reg_13 : Reg                generic map(
                                    DATA_WIDTH  => DATA_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => r1_in,
                                    output      => r1_out
                                    );

    reg_14 : Reg                generic map(
                                    DATA_WIDTH  => DATA_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => r2_in,
                                    output      => r2_out
                                    );

    reg_15 : Reg                generic map(
                                    DATA_WIDTH  => DATA_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => imm_in,
                                    output      => imm_out
                                    );

    reg_16 : Reg                generic map(
                                    DATA_WIDTH  => REGFILE_ADR_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => rd_reg1_idx_in,
                                    output      => rd_reg1_idx_out
                                    );

    reg_17 : Reg                generic map(
                                    DATA_WIDTH  => REGFILE_ADR_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => rd_reg2_idx_in,
                                    output      => rd_reg2_idx_out
                                    );

    reg_18 : Reg                generic map(
                                    DATA_WIDTH  => REGFILE_ADR_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => wr_reg_idx_in,
                                    output      => wr_reg_idx_out
                                    );

    reg_19 : Reg                generic map(
                                    DATA_WIDTH  => 6
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => en,
                                    input       => instr_id_in,
                                    output      => instr_id_out
                                    );

end behavior;
