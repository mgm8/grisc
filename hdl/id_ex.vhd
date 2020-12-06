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
--! \version 0.0.31
--! 
--! \date 2020/11/28
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity ID_EX is
    generic(
        DATA_WIDTH          : natural := 32;                                        --! Data width in bits.
        ADR_WIDTH           : natural := 64;                                        --! Address width in bits.
        WB_MUX_SEL_WIDTH    : natural := 1;                                         --! WB mux select width in bits.
        REGFILE_ADR_WIDTH   : natural := 5;                                         --! Register file address width in bits
        ALU_OP_WIDTH        : natural := 2;                                         --! ALU operation width in bits.
        ALU_SRC_SEL_WIDTH   : natural := 1                                          --! ALU source mux select width in bits.
        );
    port(
        clk                 : in std_logic;                                         --! Clock input.
        rst                 : in std_logic;                                         --! Reset signal.

        -- WB
        wb_sel_in           : in std_logic_vector(WB_MUX_SEL_WIDTH-1 downto 0);     --! WB mux select input.
        wb_sel_out          : out std_logic_vector(WB_MUX_SEL_WIDTH-1 downto 0);    --! WB mux select output.
        regfile_wr_en_in    : in std_logic;                                         --! Register file write enable input.
        regfile_wr_en_out   : out std_logic;                                        --! Register file write enable output.
        regfile_adr_in      : in std_logic_vector(REGFILE_ADR_WIDTH-1 downto 0);    --! Register file address input.
        regfile_adr_out     : out std_logic_vector(REGFILE_ADR_WIDTH-1 downto 0);   --! Register file address output.

        -- MEM
        mem_wr_en_in        : in std_logic;                                         --! Data memory write enable input.
        mem_wr_en_out       : out std_logic;                                        --! Data memory write enable output.
        mem_rd_en_in        : in std_logic;                                         --! Data memory read enable input.
        mem_rd_en_out       : out std_logic;                                        --! Data memory read enable output.
        branch_in           : in std_logic;                                         --! Branch input.
        branch_out          : out std_logic;                                        --! Branch output.

        -- EX
        alu_op_in           : in std_logic_vector(ALU_OP_WIDTH-1 downto 0);         --! ALU operation input.
        alu_op_out          : out std_logic_vector(ALU_OP_WIDTH-1 downto 0);        --! ALU operation output.
        alu_src_sel_in      : in std_logic_vector(ALU_SRC_SEL_WIDTH-1 downto 0);    --! ALU source select input.
        alu_src_sel_out     : out std_logic_vector(ALU_SRC_SEL_WIDTH-1 downto 0);   --! ALU source select output.
        pc_adr_in           : in std_logic_vector(ADR_WIDTH-1 downto 0);            --! PC address input.
        pc_adr_out          : out std_logic_vector(ADR_WIDTH-1 downto 0);           --! PC address output.
        op1_in              : in std_logic_vector(DATA_WIDTH-1 downto 0);           --! Operand 1 input.
        op1_out             : out std_logic_vector(DATA_WIDTH-1 downto 0);          --! Operand 1 output.
        op2_in              : in std_logic_vector(DATA_WIDTH-1 downto 0);           --! Operand 2 input.
        op2_out             : out std_logic_vector(DATA_WIDTH-1 downto 0);          --! Operand 2 output.
        imm_gen_in          : in std_logic_vector(ADR_WIDTH-1 downto 0);            --! Immediate generator input.
        imm_gen_out         : out std_logic_vector(ADR_WIDTH-1 downto 0);           --! Immediate generator output.
        func3_in            : in std_logic_vector(2 downto 0);                      --! func3 input.
        func3_out           : out std_logic_vector(2 downto 0);                     --! func3 output.
        func7_in            : in std_logic_vector(6 downto 0);                      --! func7 input.
        func7_out           : out std_logic_vector(6 downto 0);                     --! func7 output.
        rs1_in              : in std_logic_vector(REGFILE_ADR_WIDTH-1 downto 0);    --! RS1 input.
        rs1_out             : out std_logic_vector(REGFILE_ADR_WIDTH-1 downto 0);   --! RS1 output.
        rs2_in              : in std_logic_vector(REGFILE_ADR_WIDTH-1 downto 0);    --! RS2 input.
        rs2_out             : out std_logic_vector(REGFILE_ADR_WIDTH-1 downto 0)    --! RS2 output.
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

    signal regfile_wr_en_in_sig     : std_logic_vector(0 downto 0) := (others => '0');
    signal regfile_wr_en_out_sig    : std_logic_vector(0 downto 0) := (others => '0');

    signal mem_wr_en_in_sig         : std_logic_vector(0 downto 0) := (others => '0');
    signal mem_wr_en_out_sig        : std_logic_vector(0 downto 0) := (others => '0');

    signal mem_rd_en_in_sig         : std_logic_vector(0 downto 0) := (others => '0');
    signal mem_rd_en_out_sig        : std_logic_vector(0 downto 0) := (others => '0');

    signal branch_in_sig            : std_logic_vector(0 downto 0) := (others => '0');
    signal branch_out_sig           : std_logic_vector(0 downto 0) := (others => '0');

begin

    regfile_wr_en_in_sig(0) <= regfile_wr_en_in;
    regfile_wr_en_out       <= regfile_wr_en_out_sig(0);

    mem_wr_en_in_sig(0)     <= mem_wr_en_in;
    mem_wr_en_out           <= mem_wr_en_out_sig(0);

    mem_rd_en_in_sig(0)     <= mem_rd_en_in;
    mem_rd_en_out           <= mem_rd_en_out_sig(0);

    branch_in_sig(0)        <= branch_in;
    branch_out              <= branch_out_sig(0);

    -- WB select register
    wb_sel_reg : Reg            generic map(
                                    DATA_WIDTH  => WB_MUX_SEL_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => '1',
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
                                    en          => '1',
                                    input       => regfile_wr_en_in_sig,
                                    output      => regfile_wr_en_out_sig
                                    );

    -- Register file address register
    regfile_adr_reg : Reg       generic map(
                                    DATA_WIDTH  => REGFILE_ADR_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => '1',
                                    input       => regfile_adr_in,
                                    output      => regfile_adr_out
                                    );


    -- Data memory write enable register
    mem_wr_en_reg : Reg         generic map(
                                    DATA_WIDTH  => 1
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => '1',
                                    input       => mem_wr_en_in_sig,
                                    output      => mem_wr_en_out_sig
                                    );

    -- Data memory read enable register
    mem_rd_en_reg : Reg         generic map(
                                    DATA_WIDTH  => 1
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => '1',
                                    input       => mem_rd_en_in_sig,
                                    output      => mem_rd_en_out_sig
                                    );

    -- Branch register
    branch_reg : Reg            generic map(
                                    DATA_WIDTH  => 1
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => '1',
                                    input       => branch_in_sig,
                                    output      => branch_out_sig
                                    );


    -- ALU operation register
    alu_op_reg : Reg            generic map(
                                    DATA_WIDTH  => ALU_OP_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => '1',
                                    input       => alu_op_in,
                                    output      => alu_op_out
                                    );

    -- ALU source select register
    alu_src_sel_reg : Reg       generic map(
                                    DATA_WIDTH  => ALU_SRC_SEL_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => '1',
                                    input       => alu_src_sel_in,
                                    output      => alu_src_sel_out
                                    );

    -- PC address register
    pc_adr_reg : Reg            generic map(
                                    DATA_WIDTH  => ADR_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => '1',
                                    input       => pc_adr_in,
                                    output      => pc_adr_out
                                    );

    -- Operand 1 register
    op1_reg : Reg               generic map(
                                    DATA_WIDTH  => DATA_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => '1',
                                    input       => op1_in,
                                    output      => op1_out
                                    );

    -- Operand 2 register
    op2_reg : Reg               generic map(
                                    DATA_WIDTH  => DATA_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => '1',
                                    input       => op2_in,
                                    output      => op2_out
                                    );

    -- Immediate generator register
    imm_gen_reg : Reg           generic map(
                                    DATA_WIDTH  => ADR_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => '1',
                                    input       => imm_gen_in,
                                    output      => imm_gen_out
                                    );

    -- func3 register
    func3_reg : Reg             generic map(
                                    DATA_WIDTH  => 3
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => '1',
                                    input       => func3_in,
                                    output      => func3_out
                                    );

    -- func7 register
    func7_reg : Reg             generic map(
                                    DATA_WIDTH  => 7
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => '1',
                                    input       => func7_in,
                                    output      => func7_out
                                    );

    -- RS1 register
    rs1_reg : Reg               generic map(
                                    DATA_WIDTH  => REGFILE_ADR_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => '1',
                                    input       => rs1_in,
                                    output      => rs1_out
                                    );

    -- RS2 register
    rs2_reg : Reg               generic map(
                                    DATA_WIDTH  => REGFILE_ADR_WIDTH
                                    )
                                port map(
                                    clk         => clk,
                                    rst         => rst,
                                    en          => '1',
                                    input       => rs2_in,
                                    output      => rs2_out
                                    );

end behavior;
