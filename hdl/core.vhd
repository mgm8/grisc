--
-- core.vhd
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
--! \brief CPU core.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.43
--! 
--! \date 2020/11/22
--! 

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity Core is
    generic(
        DATA_WIDTH      : natural := 32;                                --! Data width in bits.
        MEM_ADR_WIDTH   : natural := 32;                                --! Memory address width in bits.
        RF_ADR_WIDTH    : natural := 5;                                 --! Register file address width in bits.
        IMEM_SIZE_BYTES : natural := 1024;                              --! Instruction memory size in bytes.
        DMEM_SIZE_BYTES : natural := 8*1024;                            --! Data memory in bytes.
        PROGRAM_FILE    : string := "program.hex"                       --! Instruction file.
        );
    port(
        clk : in std_logic;                                             --! Clock source.
        rst : in std_logic                                              --! Reset signal.
        );
end Core;

architecture behavior of Core is
 
    component HazardDetection
        generic(
            RF_ADR_WIDTH        : natural := 5                                  --! Regfile address width in bits.
            );
        port(
            ex_do_mem_read_en   : in std_logic;                                 --! .
            ex_reg_wr_idx       : in std_logic_vector(RF_ADR_WIDTH-1 downto 0); --! .
            instr_id            : in std_logic_vector(5 downto 0);              --! Instruction ID.
            id_reg1_idx         : in std_logic_vector(RF_ADR_WIDTH-1 downto 0); --! .
            id_reg2_idx         : in std_logic_vector(RF_ADR_WIDTH-1 downto 0); --! .
            mem_do_reg_write    : in std_logic;                                 --! .
            wb_do_reg_write     : in std_logic;                                 --! .
            hazard_id_ex_en     : out std_logic;                                --! ID/EX enable.
            hazard_fe_en        : out std_logic;                                --! PC enable.
            hazard_ex_mem_clear : out std_logic                                 --! EX/MEM clear.
            );
    end component;

    component Decode
        generic(
            DATA_WIDTH  : natural := 32                                 --! Data width in bits.
            );
        port(
            instr       : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Instruction.
            r1_idx      : out std_logic_vector(4 downto 0);             --! Register 1 index.
            r2_idx      : out std_logic_vector(4 downto 0);             --! Register 2 index.
            wr_idx      : out std_logic_vector(4 downto 0);             --! Write register index.
            instr_id    : out std_logic_vector(5 downto 0)              --! Instruction ID.
        );
    end component;

    component Controller
        generic(
            DATA_WIDTH          : natural := 32                         --! Data width in bits.
            );
        port(
            instr_id            : in std_logic_vector(5 downto 0);      --! Instruction ID.
            reg_do_write_ctrl   : out std_logic;                        --! Register write enable.
            reg_wr_src_ctrl     : out std_logic_vector(1 downto 0);     --! Register write source.
            mem_do_write_ctrl   : out std_logic;                        --! Data memory write enable.
            mem_do_read_ctrl    : out std_logic;                        --! Data memory read enable.
            mem_ctrl            : out std_logic_vector(3 downto 0);     --! Data memory control.
            do_jump             : out std_logic;                        --! Jump enable.

            do_branch           : out std_logic;                        --! Branch enable.
            alu_op1_ctrl        : out std_logic;                        --! ALU op1 control.
            alu_op2_ctrl        : out std_Logic;                        --! ALU op2 control.
            alu_ctrl            : out std_logic_vector(4 downto 0);     --! ALU control.
            comp_ctrl           : out std_logic_vector(2 downto 0)      --! Comp control.
            );
    end component;

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

    component Adder
        generic(
            DATA_WIDTH : natural := 32                                  --! Data width in bits.
            );
        port(
            a       : in std_logic_vector(DATA_WIDTH-1 downto 0);       --! Input A.
            b       : in std_logic_vector(DATA_WIDTH-1 downto 0);       --! Input B.
            result  : out std_logic_vector(DATA_WIDTH-1 downto 0)       --! Result (A + B).
            );
    end component;

    component ROM
        generic(
            DATA_WIDTH  : natural := 32;                                --! Data width in bits.
            ADR_WIDTH   : natural := 32;                                --! Address width in bits.
            SIZE        : natural := 1024;                              --! Memory size in bytes.
            MEM_FILE    : string := "rom.hex"                           --! File name of the memory file.
            );
        port(
            clk         : in std_logic;                                 --! Clock source.
            adr         : in std_logic_vector(ADR_WIDTH-1 downto 0);    --! Memory address.
            data_out    : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Data output.
            );
    end component;

    component RegFile
        generic(
            DATA_WIDTH  : natural := 32;                                --! Data width in bits.
            REG_NUMBER  : natural := 32                                 --! Total number of registers.
            );
        port(
            clk         : in std_logic;                                 --! Clock input.
            r1_idx      : in std_logic_vector(4 downto 0);              --! First source register number.
            r2_idx      : in std_logic_vector(4 downto 0);              --! Second source register number.
            wr_idx      : in std_logic_vector(4 downto 0);              --! Destination register number.
            wr_en       : in std_logic;                                 --! Write register enable.
            wr_data     : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Data to write into register.
            reg1        : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Operand 1.
            reg2        : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Operand 2.

            reg_x0      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x0.
            reg_x1      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x1.
            reg_x2      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x2.
            reg_x3      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x3.
            reg_x4      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x4.
            reg_x5      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x5.
            reg_x6      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x6.
            reg_x7      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x7.
            reg_x8      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x8.
            reg_x9      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x9.
            reg_x10     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x10.
            reg_x11     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x11.
            reg_x12     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x12.
            reg_x13     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x13.
            reg_x14     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x14.
            reg_x15     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x15.
            reg_x16     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x16.
            reg_x17     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x17.
            reg_x18     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x18.
            reg_x19     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x19.
            reg_x20     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x20.
            reg_x21     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x21.
            reg_x22     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x22.
            reg_x23     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x23.
            reg_x24     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x24.
            reg_x25     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x25.
            reg_x26     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x26.
            reg_x27     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x27.
            reg_x28     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x28.
            reg_x29     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x29.
            reg_x30     : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Register x30.
            reg_x31     : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Register x31.
            );
    end component;

    component ImmGen
        generic(
            DATA_WIDTH : natural := 32                                  --! Data width in bits.
            );
        port(
            instr       : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Instruction.
            instr_id    : in std_logic_vector(5 downto 0);              --! Instruction ID.
            imm         : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Generated immediate.
            );
    end component;

    component ALU
        generic(
            DATA_WIDTH  : natural := 32                                 --! Data width in bits.
            );
        port(
            ctrl    : in  std_logic_vector(4 downto 0);                 --! Operation control.
            op1     : in  std_logic_vector(DATA_WIDTH-1 downto 0);      --! Operand 1.
            op2     : in  std_logic_vector(DATA_WIDTH-1 downto 0);      --! Operand 2.
            res     : out std_logic_vector(DATA_WIDTH-1 downto 0)       --! Operation output.
            );
    end component;

    component Branch
        generic(
            DATA_WIDTH  : natural := 32                                 --! Data width in bits.
            );
        port(
            comp_ctrl   : in std_logic_vector(2 downto 0);              --! Comp control.
            op1         : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Operator 1.
            op2         : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Operator 2.
            res         : out std_logic                                 --! Result.
            );
    end component;

    component ForwardingUnit
        generic(
            RF_ADR_WIDTH : natural := 5                                                 --! Regfile address width in bits.
            );
        port(
            id_reg1_idx                 : in std_logic_vector(RF_ADR_WIDTH-1 downto 0); --! ID/EX register 1.
            id_reg2_idx                 : in std_logic_vector(RF_ADR_WIDTH-1 downto 0); --! ID/EX register 2.
            wb_reg_wr_en                : in std_logic;                                 --! Write register enable.
            wb_reg_wr_idx               : in std_logic_vector(RF_ADR_WIDTH-1 downto 0); --! WB write register index.
            mem_reg_wr_en               : in std_logic;                                 --! MEM write register enable.
            mem_reg_wr_idx              : in std_logic_vector(RF_ADR_WIDTH-1 downto 0); --! MEM write register index.
            alu_reg1_forwarding_ctrl    : out std_logic_vector(1 downto 0);             --! ALU op1 source control.
            alu_reg2_forwarding_ctrl    : out std_logic_vector(1 downto 0)              --! ALU op2 source control.
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

    component Mux2x1
        generic(
            DATA_WIDTH  : natural := 32                                 --! Width (in bits) of the inputs.
            );
        port(
            input1  : in  std_logic_vector(DATA_WIDTH-1 downto 0);      --! Input 1.
            input2  : in  std_logic_vector(DATA_WIDTH-1 downto 0);      --! Input 2.
            sel     : in  std_logic;                                    --! Input selection.
            output  : out std_logic_vector(DATA_WIDTH-1 downto 0)       --! Output.
            );
    end component;

    component Mux3x1
        generic(
            DATA_WIDTH  : natural := 32                                 --! Width (in bits) of the inputs.
            );
        port(
            input1      : in  std_logic_vector(DATA_WIDTH-1 downto 0);  --! Input 1.
            input2      : in  std_logic_vector(DATA_WIDTH-1 downto 0);  --! Input 2.
            input3      : in  std_logic_vector(DATA_WIDTH-1 downto 0);  --! Input 3.
            sel         : in  std_logic_vector(1 downto 0);             --! Input selection.
            output      : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Output.
            );
    end component;

    component IF_ID
        generic(
            DATA_WIDTH  : natural := 32;                                --! Data width in bits.
            ADR_WIDTH   : natural := 64                                 --! Address width in bits.
            );
        port(
            clk         : in std_logic;                                 --! Clock input.
            rst         : in std_logic;                                 --! Reset signal.
            en          : in std_logic;                                 --! Enable signal.

            pc4_in      : in std_logic_vector(ADR_WIDTH-1 downto 0);    --! Next PC address input.
            pc_in       : in std_logic_vector(ADR_WIDTH-1 downto 0);    --! PC address input.
            instr_in    : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Instruction input.
            pc4_out     : out std_logic_vector(ADR_WIDTH-1 downto 0);   --! Next PC address output.
            pc_out      : out std_logic_vector(ADR_WIDTH-1 downto 0);   --! PC address output.
            instr_out   : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Instruction output.
            );
    end component;

    component ID_EX
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
    end component;

    component EX_MEM
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
    end component;

    component MEM_WB
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
            pc4_in              : in std_logic_vector(ADR_WIDTH-1 downto 0);            --! .
            alures_in           : in std_logic_vector(DATA_WIDTH-1 downto 0);           --! .
            mem_read_in         : in std_logic_vector(DATA_WIDTH-1 downto 0);           --! .
            wr_reg_idx_in       : in std_logic_vector(REGFILE_ADR_WIDTH-1 downto 0);    --! .

            reg_do_write_out    : out std_logic;                                        --! .
            reg_wr_src_ctrl_out : out std_logic_vector(1 downto 0);                     --! .
            pc4_out             : out std_logic_vector(ADR_WIDTH-1 downto 0);           --! .
            alures_out          : out std_logic_vector(DATA_WIDTH-1 downto 0);          --! .
            mem_read_out        : out std_logic_vector(DATA_WIDTH-1 downto 0);          --! .
            wr_reg_idx_out      : out std_logic_vector(REGFILE_ADR_WIDTH-1 downto 0)    --! .
            );
    end component;

    -- General signals
    signal clk_sig                  : std_logic                                         := '0';
    signal rst_sig                  : std_logic                                         := '0';

    -- IF signals
    signal pc_adderres_sig          : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)        := (others => '0');
    signal pc_next_adr_sig          : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)        := (others => '0');
    signal pc_sig                   : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)        := (others => '0');
    signal instr_sig                : std_logic_vector(DATA_WIDTH-1 downto 0)           := (others => '0');

    -- ID signals
    signal pc4_id_sig               : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)        := (others => '0');
    signal pc_id_sig                : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)        := (others => '0');
    signal instr_id_sig             : std_logic_vector(DATA_WIDTH-1 downto 0)           := (others => '0');
    signal r1_reg_idx_sig           : std_logic_vector(RF_ADR_WIDTH-1 downto 0)         := (others => '0');
    signal r2_reg_idx_sig           : std_logic_vector(RF_ADR_WIDTH-1 downto 0)         := (others => '0');
    signal wd_reg_idx_sig           : std_logic_vector(RF_ADR_WIDTH-1 downto 0)         := (others => '0');
    signal instr_id_id_sig          : std_logic_vector(5 downto 0)                      := (others => '0');
    signal imm_sig                  : std_logic_vector(DATA_WIDTH-1 downto 0)           := (others => '0');
    signal r1_sig                   : std_logic_vector(DATA_WIDTH-1 downto 0)           := (others => '0');
    signal r2_sig                   : std_logic_vector(DATA_WIDTH-1 downto 0)           := (others => '0');
    signal reg_do_write_ctrl_sig    : std_logic                                         := '0';
    signal reg_wr_src_ctrl_sig      : std_logic_vector(1 downto 0)                      := (others => '0');
    signal mem_do_write_ctrl_sig    : std_logic                                         := '0';
    signal mem_do_read_ctrl_sig     : std_logic                                         := '0';
    signal mem_ctrl_sig             : std_logic_vector(3 downto 0)                      := (others => '0');
    signal do_jump_sig              : std_logic                                         := '0';
    signal do_branch_sig            : std_logic                                         := '0';
    signal alu_op1_ctrl_sig         : std_logic                                         := '0';
    signal alu_op2_ctrl_sig         : std_logic                                         := '0';
    signal alu_ctrl_sig             : std_logic_vector(4 downto 0)                      := (others => '0');
    signal comp_ctrl_sig            : std_logic_vector(2 downto 0)                      := (others => '0');

    -- EX signals
    signal pc_sel_sig               : std_logic                                         := '0';
    signal alures_sig               : std_logic_vector(DATA_WIDTH-1 downto 0)           := (others => '0');
    signal hazard_fe_en_sig         : std_logic                                         := '0';
    signal hazard_id_ex_en_sig      : std_logic                                         := '0';
    signal r1_ex_sig                : std_logic_vector(DATA_WIDTH-1 downto 0)           := (others => '0');
    signal reg_do_write_ex_sig      : std_logic                                         := '0';
    signal reg_wr_src_ctrl_ex_sig   : std_logic_vector(1 downto 0)                      := (others => '0');
    signal mem_do_write_ex_sig      : std_logic                                         := '0';
    signal mem_do_read_ex_sig       : std_logic                                         := '0';
    signal mem_op_ex_sig            : std_logic_vector(3 downto 0)                      := (others => '0');
    signal do_jump_ex_sig           : std_logic                                         := '0';
    signal do_br_ex_sig             : std_logic                                         := '0';
    signal alu_op1_ctrl_ex_sig      : std_logic                                         := '0';
    signal alu_op2_ctrl_ex_sig      : std_logic                                         := '0';
    signal alu_ctrl_ex_sig          : std_logic_vector(4 downto 0)                      := (others => '0');
    signal br_op_ex_sig             : std_logic_vector(2 downto 0)                      := (others => '0');
    signal pc4_ex_sig               : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)        := (others => '0');
    signal pc_ex_sig                : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)        := (others => '0');
    signal r2_ex_sig                : std_logic_vector(DATA_WIDTH-1 downto 0)           := (others => '0');
    signal imm_ex_sig               : std_logic_vector(DATA_WIDTH-1 downto 0)           := (others => '0');
    signal rd_reg1_idx_ex_sig       : std_logic_vector(4 downto 0)                      := (others => '0');
    signal wr_reg_idx_ex_sig        : std_logic_vector(4 downto 0)                      := (others => '0');
    signal rd_reg2_idx_ex_sig       : std_logic_vector(4 downto 0)                      := (others => '0');
    signal instr_id_ex_sig          : std_logic_vector(5 downto 0)                      := (others => '0');
    signal alu_op1_sig              : std_logic_vector(DATA_WIDTH-1 downto 0)           := (others => '0');
    signal alu_op2_sig              : std_logic_vector(DATA_WIDTH-1 downto 0)           := (others => '0');
    signal branch_taken_sig         : std_logic                                         := '0';
    signal r2_ex_op2_sig            : std_logic_vector(DATA_WIDTH-1 downto 0)           := (others => '0');
    signal r1_ex_op1_sig            : std_logic_vector(DATA_WIDTH-1 downto 0)           := (others => '0');
    signal alu_reg1_fwd_ctrl_sig    : std_logic_vector(1 downto 0)                      := (others => '0');
    signal alu_reg2_fwd_ctrl_sig    : std_logic_vector(1 downto 0)                      := (others => '0');
    signal wr_reg_idx_mem_sig       : std_logic_vector(RF_ADR_WIDTH-1 downto 0)         := (others => '0');
    signal reg_do_write_mem_sig     : std_logic                                         := '0';
    signal hazard_ex_mem_clear_sig  : std_logic                                         := '0';

    -- MEM signals
    signal alures_mem_sig           : std_logic_vector(DATA_WIDTH-1 downto 0)           := (others => '0');
    signal reg_wr_src_ctrl_mem_sig  : std_logic_vector(1 downto 0)                      := (others => '0');
    signal mem_do_write_mem_sig     : std_logic                                         := '0';
    signal mem_op_mem_sig           : std_logic_vector(3 downto 0)                      := (others => '0');
    signal pc4_mem_sig              : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)        := (others => '0');
    signal r2_mem_sig               : std_logic_vector(DATA_WIDTH-1 downto 0)           := (others => '0');
    signal mem_data_sig             : std_logic_vector(DATA_WIDTH-1 downto 0)           := (others => '0');

    -- WB signals
    signal reg_do_write_wb_sig      : std_logic                                         := '0';
    signal wb_res_sig               : std_logic_vector(DATA_WIDTH-1 downto 0)           := (others => '0');
    signal wr_reg_idx_wb_sig        : std_logic_vector(RF_ADR_WIDTH-1 downto 0)         := (others => '0');
    signal reg_wr_src_ctrl_wb_sig   : std_logic_vector(1 downto 0)                      := (others => '0');
    signal mem_read_wb_sig          : std_logic_vector(DATA_WIDTH-1 downto 0)           := (others => '0');
    signal alures_wb_sig            : std_logic_vector(DATA_WIDTH-1 downto 0)           := (others => '0');
    signal pc4_wb_sig               : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)        := (others => '0');

begin

    clk_sig <= clk;
    rst_sig <= rst;

    pc_sel_sig <= (do_br_ex_sig and branch_taken_sig) or do_jump_ex_sig;

    -- ##########################################################################
    -- ##########################################################################
    -- == IF Stage ==============================================================
    -- ##########################################################################
    -- ##########################################################################

    pc_mux : Mux2x1      generic map(
                             DATA_WIDTH         => MEM_ADR_WIDTH
                             )
                         port map(
                             input1             => pc_adderres_sig,
                             input2             => alures_sig,
                             sel                => pc_sel_sig,
                             output             => pc_next_adr_sig
                             );

    pc : Reg           generic map(
                            DATA_WIDTH          => MEM_ADR_WIDTH
                            )
                        port map(
                            clk                 => clk_sig,
                            rst                 => rst_sig,
                            en                  => hazard_fe_en_sig,
                            input               => pc_next_adr_sig,
                            output              => pc_sig
                            );

    pc_add : Adder      generic map(
                            DATA_WIDTH          => MEM_ADR_WIDTH
                            )
                        port map(
                            a                   => x"00000004",
                            b                   => pc_sig,
                            result              => pc_adderres_sig
                            );

    imem : ROM          generic map(
                            DATA_WIDTH          => DATA_WIDTH,
                            ADR_WIDTH           => MEM_ADR_WIDTH,
                            SIZE                => IMEM_SIZE_BYTES,
                            MEM_FILE            => PROGRAM_FILE
                            )
                        port map(
                            clk                 => clk_sig,
                            adr                 => pc_sig,
                            data_out            => instr_sig
                            );

    if_id_reg : IF_ID   generic map(
                            DATA_WIDTH          => DATA_WIDTH,
                            ADR_WIDTH           => MEM_ADR_WIDTH
                            )
                        port map(
                            clk                 => clk_sig,
                            rst                 => rst_sig,
                            en                  => '1',
                            pc4_in              => pc_adderres_sig,
                            pc_in               => pc_sig,
                            instr_in            => instr_sig,
                            pc4_out             => pc4_id_sig,
                            pc_out              => pc_id_sig,
                            instr_out           => instr_id_sig
                            );

    -- ##########################################################################
    -- ##########################################################################
    -- == ID Stage ==============================================================
    -- ##########################################################################
    -- ##########################################################################

    dec : Decode        generic map(
                            DATA_WIDTH          => DATA_WIDTH
                            )
                        port map(
                            instr               => instr_id_sig,
                            r1_idx              => r1_reg_idx_sig,
                            r2_idx              => r2_reg_idx_sig,
                            wr_idx              => wd_reg_idx_sig,
                            instr_id            => instr_id_id_sig
                            );

    ctrl : Controller   generic map(
                            DATA_WIDTH          => DATA_WIDTH
                            )
                        port map(
                            instr_id            => instr_id_id_sig,
                            reg_do_write_ctrl   => reg_do_write_ctrl_sig,
                            reg_wr_src_ctrl     => reg_wr_src_ctrl_sig,
                            mem_do_write_ctrl   => mem_do_write_ctrl_sig,
                            mem_do_read_ctrl    => mem_do_read_ctrl_sig,
                            mem_ctrl            => mem_ctrl_sig,
                            do_jump             => do_jump_sig,
                            do_branch           => do_branch_sig,
                            alu_op1_ctrl        => alu_op1_ctrl_sig,
                            alu_op2_ctrl        => alu_op2_ctrl_sig,
                            alu_ctrl            => alu_ctrl_sig,
                            comp_ctrl           => comp_ctrl_sig
                            );

    regs : RegFile       generic map(
                             DATA_WIDTH         => DATA_WIDTH,
                             REG_NUMBER         => 32
                             )
                         port map(
                             clk                => clk_sig,
                             r1_idx             => r1_reg_idx_sig,
                             r2_idx             => r2_reg_idx_sig,
                             wr_idx             => wr_reg_idx_wb_sig,
                             wr_en              => reg_do_write_wb_sig,
                             wr_data            => wb_res_sig,
                             reg1               => r1_sig,
                             reg2               => r2_sig
                             );

    imm_g : ImmGen       generic map(
                             DATA_WIDTH         => DATA_WIDTH
                             )
                         port map(
                             instr              => instr_id_sig,
                             instr_id           => instr_id_id_sig,
                             imm                => imm_sig
                             );

    id_ex_reg : ID_EX   generic map(
                            DATA_WIDTH          => DATA_WIDTH,
                            ADR_WIDTH           => MEM_ADR_WIDTH,
                            REGFILE_ADR_WIDTH   => RF_ADR_WIDTH
                            )
                        port map(
                            clk                 => clk_sig,
                            rst                 => rst_sig,
                            en                  => hazard_id_ex_en_sig,
                            reg_do_write_in     => reg_do_write_ctrl_sig,
                            reg_wr_src_ctrl_in  => reg_wr_src_ctrl_sig,
                            mem_do_write_in     => mem_do_write_ctrl_sig,
                            mem_do_read_in      => mem_do_read_ctrl_sig,
                            mem_op_in           => mem_ctrl_sig,
                            do_jmp_in           => do_jump_sig,
                            do_br_in            => do_branch_sig,
                            alu_op1_ctrl_in     => alu_op1_ctrl_sig,
                            alu_op2_ctrl_in     => alu_op2_ctrl_sig,
                            alu_ctrl_in         => alu_ctrl_sig,
                            br_op_in            => comp_ctrl_sig,
                            pc4_in              => pc4_id_sig,
                            pc_in               => pc_id_sig,
                            r1_in               => r1_sig,
                            r2_in               => r2_sig,
                            imm_in              => imm_sig,
                            rd_reg1_idx_in      => r1_reg_idx_sig,
                            rd_reg2_idx_in      => r2_reg_idx_sig,
                            wr_reg_idx_in       => wd_reg_idx_sig,
                            instr_id_in         => instr_id_id_sig,

                            reg_do_write_out    => reg_do_write_ex_sig,
                            reg_wr_src_ctrl_out => reg_wr_src_ctrl_ex_sig,
                            mem_do_write_out    => mem_do_write_ex_sig,
                            mem_do_read_out     => mem_do_read_ex_sig,
                            mem_op_out          => mem_op_ex_sig,
                            do_jmp_out          => do_jump_ex_sig,
                            do_br_out           => do_br_ex_sig,
                            alu_op1_ctrl_out    => alu_op1_ctrl_ex_sig,
                            alu_op2_ctrl_out    => alu_op2_ctrl_ex_sig,
                            alu_ctrl_out        => alu_ctrl_ex_sig,
                            br_op_out           => br_op_ex_sig,
                            pc4_out             => pc4_ex_sig,
                            pc_out              => pc_ex_sig,
                            r1_out              => r1_ex_sig,
                            r2_out              => r2_ex_sig,
                            imm_out             => imm_ex_sig,
                            rd_reg1_idx_out     => rd_reg1_idx_ex_sig,
                            rd_reg2_idx_out     => rd_reg2_idx_ex_sig,
                            wr_reg_idx_out      => wr_reg_idx_ex_sig,
                            instr_id_out        => instr_id_ex_sig
                            );

    -- ##########################################################################
    -- ##########################################################################
    -- == EX Stage ==============================================================
    -- ##########################################################################
    -- ##########################################################################

    op1_mux : Mux3x1     generic map(
                             DATA_WIDTH         => DATA_WIDTH
                             )
                         port map(
                             input1             => r1_ex_sig,
                             input2             => alures_mem_sig,
                             input3             => wb_res_sig,
                             sel                => alu_reg1_fwd_ctrl_sig,
                             output             => r1_ex_op1_sig
                             );

    op2_mux : Mux3x1     generic map(
                             DATA_WIDTH         => DATA_WIDTH
                             )
                         port map(
                             input1             => r2_ex_sig,
                             input2             => alures_mem_sig,
                             input3             => wb_res_sig,
                             sel                => alu_reg2_fwd_ctrl_sig,
                             output             => r2_ex_op2_sig
                             );

    alu_src_1 : Mux2x1   generic map(
                             DATA_WIDTH         => DATA_WIDTH
                             )
                         port map(
                             input1             => r1_ex_op1_sig,
                             input2             => pc_ex_sig,
                             sel                => alu_op1_ctrl_ex_sig,
                             output             => alu_op1_sig
                             );

    alu_src_2 : Mux2x1   generic map(
                             DATA_WIDTH         => DATA_WIDTH
                             )
                         port map(
                             input1             => r2_ex_op2_sig,
                             input2             => imm_ex_sig,
                             sel                => alu_op2_ctrl_ex_sig,
                             output             => alu_op2_sig
                             );

    alu_0 : ALU          generic map(
                             DATA_WIDTH         => DATA_WIDTH
                             )
                         port map(
                             ctrl               => alu_ctrl_ex_sig,
                             op1                => alu_op1_sig,
                             op2                => alu_op2_sig,
                             res                => alures_sig
                             );

    fd : ForwardingUnit generic map(
                            RF_ADR_WIDTH        => RF_ADR_WIDTH
                            )
                        port map(
                            id_reg1_idx                 => rd_reg1_idx_ex_sig,
                            id_reg2_idx                 => rd_reg2_idx_ex_sig,
                            wb_reg_wr_en                => reg_do_write_wb_sig,
                            wb_reg_wr_idx               => wr_reg_idx_wb_sig,
                            mem_reg_wr_en               => reg_do_write_mem_sig,
                            mem_reg_wr_idx              => wr_reg_idx_mem_sig,
                            alu_reg1_forwarding_ctrl    => alu_reg1_fwd_ctrl_sig,
                            alu_reg2_forwarding_ctrl    => alu_reg2_fwd_ctrl_sig
                            );

    h : HazardDetection generic map(
                            RF_ADR_WIDTH        => RF_ADR_WIDTH
                            )
                        port map(
                            ex_do_mem_read_en   => mem_do_read_ex_sig,
                            ex_reg_wr_idx       => wr_reg_idx_ex_sig,
                            instr_id            => instr_id_ex_sig,
                            id_reg1_idx         => r1_reg_idx_sig,
                            id_reg2_idx         => r2_reg_idx_sig,
                            mem_do_reg_write    => reg_do_write_mem_sig,
                            wb_do_reg_write     => reg_do_write_wb_sig,
                            hazard_id_ex_en     => hazard_id_ex_en_sig,
                            hazard_fe_en        => hazard_fe_en_sig,
                            hazard_ex_mem_clear => hazard_ex_mem_clear_sig
                            );

    brch : Branch       generic map(
                            DATA_WIDTH          => DATA_WIDTH
                            )
                        port map(
                            comp_ctrl           => br_op_ex_sig,
                            op1                 => r1_ex_op1_sig,
                            op2                 => r2_ex_op2_sig,
                            res                 => branch_taken_sig
                            );

    ex_mem_reg : EX_MEM generic map(
                            DATA_WIDTH          => DATA_WIDTH,
                            ADR_WIDTH           => MEM_ADR_WIDTH,
                            REGFILE_ADR_WIDTH   => 5
                            )
                        port map(
                            clk                 => clk_sig,
                            rst                 => hazard_ex_mem_clear_sig,
                            en                  => '1',
                            reg_do_write_in     => reg_do_write_ex_sig,
                            reg_wr_src_ctrl_in  => reg_wr_src_ctrl_ex_sig,
                            mem_do_write_in     => mem_do_write_ex_sig,
                            mem_op_in           => mem_op_ex_sig,
                            pc4_in              => pc4_ex_sig,
                            alures_in           => alures_sig,
                            r2_in               => r2_ex_op2_sig,
                            wr_reg_idx_in       => wr_reg_idx_ex_sig,
                            reg_do_write_out    => reg_do_write_mem_sig,
                            reg_wr_src_ctrl_out => reg_wr_src_ctrl_mem_sig,
                            mem_do_write_out    => mem_do_write_mem_sig,
                            mem_op_out          => mem_op_mem_sig,
                            pc4_out             => pc4_mem_sig,
                            alures_out          => alures_mem_sig,
                            r2_out              => r2_mem_sig,
                            wr_reg_idx_out      => wr_reg_idx_mem_sig
                            );

    -- ##########################################################################
    -- ##########################################################################
    -- == MEM Stage =============================================================
    -- ##########################################################################
    -- ##########################################################################

    data_mem : RAM       generic map(
                             DATA_WIDTH         => DATA_WIDTH,
                             ADR_WIDTH          => MEM_ADR_WIDTH,
                             SIZE               => DMEM_SIZE_BYTES
                             )
                         port map(
                             clk                => clk_sig,
                             wr_en              => mem_do_write_mem_sig,
                             op                 => mem_op_mem_sig,
                             adr                => alures_mem_sig,
                             data_in            => r2_mem_sig,
                             data_out           => mem_data_sig
                             );

    mem_wb_reg : MEM_WB generic map(
                            DATA_WIDTH          => DATA_WIDTH,
                            ADR_WIDTH           => MEM_ADR_WIDTH,
                            REGFILE_ADR_WIDTH   => 5
                            )
                        port map(
                            clk                 => clk_sig,
                            rst                 => rst_sig,
                            en                  => '1',
                            reg_do_write_in     => reg_do_write_mem_sig,
                            reg_wr_src_ctrl_in  => reg_wr_src_ctrl_mem_sig,
                            pc4_in              => pc4_mem_sig,
                            alures_in           => alures_mem_sig,
                            mem_read_in         => mem_data_sig,
                            wr_reg_idx_in       => wr_reg_idx_mem_sig,
                            reg_do_write_out    => reg_do_write_wb_sig,
                            reg_wr_src_ctrl_out => reg_wr_src_ctrl_wb_sig,
                            pc4_out             => pc4_wb_sig,
                            alures_out          => alures_wb_sig,
                            mem_read_out        => mem_read_wb_sig,
                            wr_reg_idx_out      => wr_reg_idx_wb_sig
                            );

    -- ##########################################################################
    -- ##########################################################################
    -- == WB Stage ==============================================================
    -- ##########################################################################
    -- ##########################################################################

    wb : Mux3x1         generic map(
                            DATA_WIDTH          => DATA_WIDTH
                            )
                        port map(
                            input1              => mem_read_wb_sig,
                            input2              => alures_wb_sig,
                            input3              => pc4_wb_sig,
                            sel                 => reg_wr_src_ctrl_wb_sig,
                            output              => wb_res_sig
                            );

end behavior;
