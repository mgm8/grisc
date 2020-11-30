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
--! \version 0.0.23
--! 
--! \date 2020/11/22
--! 

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity Core is
    generic(
        DATA_WIDTH      : natural := 32;                                --! Data width in bits.
        MEM_ADR_WIDTH   : natural := 64;                                --! Memory address width in bits.
        IMEM_SIZE_BYTES : natural := 1024;                              --! Instruction memory size in bytes.
        DMEM_SIZE_BYTES : natural := 8*1024;                            --! Data memory in bytes.
        PROGRAM_FILE    : string := "program.hex";                      --! Instruction file.
        DEBUG_MODE      : boolean := false                              --! Debug mode flag.
        );
    port(
        clk : in std_logic;                                             --! Clock source.
        rst : in std_logic                                              --! Reset signal.
        );
end Core;

architecture behavior of Core is
 
    component Controller
        generic(
            DATA_WIDTH  : natural := 32;                                --! Data width in bits.
            DEBUG_MODE  : boolean := false                              --! Debug mode flag.
            );
        port(
            clk         : in std_logic;                                 --! Reference clock.
            rst         : in std_logic;                                 --! Resets the controller.
            opcode      : in std_logic_vector(6 downto 0);              --! Opcode.
            func3       : in std_logic_vector(2 downto 0);              --! func3.
            func7       : in std_logic_vector(6 downto 0);              --! func7.
            reg_write   : out std_logic;                                --! Register write enable.
            alu_src     : out std_logic;                                --! ALU source selector.
            alu_op      : out std_logic_vector(1 downto 0);             --! ALU operation code.
            dmem_wr_en  : out std_logic;                                --! Data memory write enable.
            dmem_rd_en  : out std_logic;                                --! Data memory read enable.
            mem_to_reg  : out std_logic;                                --! Data memory to register source selector.
            branch      : out std_logic                                 --! Branch selector.
            );
    end component;

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
            ADR_WIDTH   : natural := 64;                                --! Address width in bits.
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
            rs1         : in std_logic_vector(4 downto 0);              --! First source register number.
            rs2         : in std_logic_vector(4 downto 0);              --! Second source register number.
            rd          : in std_logic_vector(4 downto 0);              --! Destination register number.
            wr_en       : in std_logic;                                 --! Write register enable.
            data_write  : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Data to write into register.
            op1         : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Operand 1.
            op2         : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Operand 2.
        );
    end component;

    component ImmGen
        generic(
            DATA_WIDTH : natural := 32                                  --! Data width in bits.
            );
        port(
            inst    : in std_logic_vector(DATA_WIDTH-1 downto 0);       --! Instruction.
            imm     : out std_logic_vector((2*DATA_WIDTH)-1 downto 0)   --! Generated immediate.
            );
    end component;

    component ALU
        generic(
            DATA_WIDTH  : natural := 32                                 --! Data width in bits.
        );
        port(
            clk         : in  std_logic;                                --! Clock input.
            op1         : in  std_logic_vector(DATA_WIDTH-1 downto 0);  --! Operand 1.
            op2         : in  std_logic_vector(DATA_WIDTH-1 downto 0);  --! Operand 2.
            operation   : in  std_logic_vector(3 downto 0);             --! Operation code.
            result      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Opeartion output.
            zero        : out std_logic                                 --! Zero result flag.
        );
    end component;

    component ALUCtrl
        generic(
            DATA_WIDTH : natural := 32                                  --! Data width in bits.
            );
        port(
            clk         : in std_logic;                                 --! Clock signal.
            func3       : in std_logic_vector(2 downto 0);              --! 3-bit function code.
            func7       : in std_logic_vector(6 downto 0);              --! 7-bit function code.
            alu_op      : in std_logic_vector(1 downto 0);              --! ALU operation.
            alu_ctrl    : out std_logic_vector(3 downto 0)              --! ALU operation code.
            );
    end component;

    component RAM
        generic(
            DATA_WIDTH  : natural := 32;                                --! Data width in bits.
            SIZE        : natural := 1024                               --! Memory size in bytes.
        );
        port(
            clk         : in std_logic;                                 --! Clock input.
            wr_en       : in std_logic;                                 --! Write enable.
            rd_en       : in std_logic;                                 --! Read enable.
            adr         : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Memory address to access.
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

    component IF_ID
        generic(
            DATA_WIDTH          : natural := 32;                                --! Data width in bits.
            ADR_WIDTH           : natural := 64                                 --! Address width in bits.
            );
        port(
            clk                 : in std_logic;                                 --! Clock input.
            rst                 : in std_logic;                                 --! Reset signal.

            -- EX
            pc_adr_in           : in std_logic_vector(ADR_WIDTH-1 downto 0);    --! PC address input.
            pc_adr_out          : out std_logic_vector(ADR_WIDTH-1 downto 0);   --! PC address output.

            -- ID
            inst_in             : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Instruction input.
            inst_out            : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Instruction output.
            );
    end component;

    component ID_EX
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
            func7_out           : out std_logic_vector(6 downto 0)                      --! func7 output.
            );
    end component;

    component EX_MEM
        generic(
            DATA_WIDTH          : natural := 32;                                        --! Data width in bits.
            ADR_WIDTH           : natural := 64;                                        --! Address width in bits.
            WB_MUX_SEL_WIDTH    : natural := 1;                                         --! WB mux select width in bits.
            REGFILE_ADR_WIDTH   : natural := 5                                          --! Register file address width in bits
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
            pc_adr_in           : in std_logic_vector(ADR_WIDTH-1 downto 0);            --! PC address input.
            pc_adr_out          : out std_logic_vector(ADR_WIDTH-1 downto 0);           --! PC address output.
            alu_zero_in         : in std_logic;                                         --! ALU zero flag input.
            alu_zero_out        : out std_logic;                                        --! ALU zero flag output.
            alu_res_in          : in std_logic_vector(DATA_WIDTH-1 downto 0);           --! ALU result input.
            alu_res_out         : out std_logic_vector(DATA_WIDTH-1 downto 0);          --! ALU result output.
            op2_in              : in std_logic_vector(DATA_WIDTH-1 downto 0);           --! Operand 2 input.
            op2_out             : out std_logic_vector(DATA_WIDTH-1 downto 0)           --! Operand 2 output.
            );
    end component;

    component MEM_WB
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
    end component;

    -- General signals
    signal clk_sig              : std_logic := '0';
    signal rst_sig              : std_logic := '1';
    signal sig_006              : std_logic := '0';
    signal sig_026              : std_logic_vector(4 downto 0)                  := (others => '0');
    signal sig_025              : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');

    -- IF signals
    signal pc_adr_sig           : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)    := (others => '0');
    signal inst_sig             : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');
    signal pc_add_res_sig       : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)    := (others => '0');
    signal pc_next_adr_sig      : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)    := (others => '0');
    signal pc_in_sig            : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)    := (others => '0');

    -- ID signals
    signal inst_if_id_sig       : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');
    signal pc_adr_if_id_sig     : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)    := (others => '0');
    signal regfile_wr_en_sig    : std_logic                                     := '0';
    signal op1_sig              : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');
    signal op2_sig              : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');
    signal imm_gen_sig          : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)    := (others => '0');
    signal branch_sig           : std_logic                                     := '0';
    signal sig_027              : std_logic                                     := '0';
    signal sig_028              : std_logic_vector(0 downto 0)                  := (others => '0');
    signal sig_029              : std_logic                                     := '0';
    signal sig_030              : std_logic                                     := '0';
    signal sig_031              : std_logic_vector(1 downto 0)                  := (others => '0');
    signal sig_032              : std_logic_vector(0 downto 0)                  := (others => '0');

    -- EX signals
    signal sig_001              : std_logic                                     := '0';
    signal sig_002              : std_logic_vector(0 downto 0)                  := (others => '0');
    signal sig_008              : std_logic_vector(4 downto 0)                  := (others => '0');
    signal sig_016              : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)    := (others => '0');
    signal sig_017              : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)    := (others => '0');
    signal sig_022              : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)    := (others => '0');
    signal sig_014              : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');
    signal sig_013              : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)    := (others => '0');
    signal sig_010              : std_logic_vector(0 downto 0)                  := (others => '0');
    signal sig_015              : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');
    signal sig_011              : std_logic_vector(3 downto 0)                  := (others => '0');
    signal sig_012              : std_logic_vector(2 downto 0)                  := (others => '0');
    signal sig_033              : std_logic_vector(6 downto 0)                  := (others => '0');
    signal sig_023              : std_logic                                     := '0';
    signal sig_024              : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');
    signal sig_018              : std_logic                                     := '0';
    signal sig_019              : std_logic                                     := '0';
    signal sig_020              : std_logic                                     := '0';

    -- MEM signals
    signal dmem_output_sig      : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');
    signal op2_ex_mem_sig       : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');
    signal alu_res_ex_mem_sig   : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');
    signal dmem_rden_ex_mem_sig : std_logic                                     := '0';
    signal mem2reg_ex_mem_sig   : std_logic_vector(0 downto 0)                  := (others => '0');
    signal rf_wr_en_ex_mem_sig  : std_logic                                     := '0';
    signal sig_003              : std_logic                                     := '0';
    signal sig_004              : std_logic                                     := '0';
    signal sig_005              : std_logic                                     := '0';
    signal sig_007              : std_logic_vector(4 downto 0)                  := (others => '0');
    signal sig_021              : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');
    signal sig_009              : std_logic_vector(1 downto 0)                  := (others => '0');

    -- WB signals
    signal dmem_out_mem_wb_sig  : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');
    signal alu_res_mem_wb_sig   : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');
    signal mem2reg_mem_wb_sig   : std_logic_vector(0 downto 0)                  := (others => '0');

begin

    clk_sig <= clk;
    rst_sig <= rst;

    sig_006 <= sig_004 and sig_005;
    sig_017 <= sig_013(MEM_ADR_WIDTH-2 downto 0) & '0';

    -- ##########################################################################
    -- ##########################################################################
    -- == IF Stage ==============================================================
    -- ##########################################################################
    -- ##########################################################################


    pc_mux : Mux2x1      generic map(
                             DATA_WIDTH         => MEM_ADR_WIDTH
                             )
                         port map(
                             input1             => pc_add_res_sig,
                             input2             => pc_next_adr_sig,
                             sel                => sig_006,
                             output             => pc_in_sig
                             );

    pc : Reg           generic map(
                            DATA_WIDTH          => MEM_ADR_WIDTH
                            )
                        port map(
                            clk                 => clk_sig,
                            rst                 => rst_sig,
                            input               => pc_in_sig,
                            output              => pc_adr_sig
                            );

    pc_add : Adder      generic map(
                            DATA_WIDTH          => MEM_ADR_WIDTH
                            )
                        port map(
                            a                   => x"0000000000000001",
                            b                   => pc_adr_sig,
                            result              => pc_add_res_sig
                            );

    imem : ROM          generic map(
                            DATA_WIDTH          => DATA_WIDTH,
                            SIZE                => IMEM_SIZE_BYTES,
                            MEM_FILE            => PROGRAM_FILE
                            )
                        port map(
                            clk                 => clk_sig,
                            adr                 => pc_adr_sig,
                            data_out            => inst_sig
                            );

    if_id_reg : IF_ID   generic map(
                            DATA_WIDTH          => DATA_WIDTH,
                            ADR_WIDTH           => MEM_ADR_WIDTH
                            )
                        port map(
                            clk                 => clk_sig,
                            rst                 => rst_sig,
                            pc_adr_in           => pc_adr_sig,
                            pc_adr_out          => pc_adr_if_id_sig,
                            inst_in             => inst_sig,
                            inst_out            => inst_if_id_sig
                            );

    -- ##########################################################################
    -- ##########################################################################
    -- == ID Stage ==============================================================
    -- ##########################################################################
    -- ##########################################################################

    ctrl : Controller   generic map(
                            DATA_WIDTH          => DATA_WIDTH,
                            DEBUG_MODE          => DEBUG_MODE
                            )
                        port map(
                            clk                 => clk_sig,
                            rst                 => rst_sig,
                            opcode              => inst_if_id_sig(6 downto 0),
                            func3               => inst_if_id_sig(14 downto 12),
                            func7               => inst_if_id_sig(31 downto 25),
                            reg_write           => sig_027,
                            alu_src             => sig_032(0),
                            alu_op              => sig_031,
                            dmem_wr_en          => sig_030,
                            dmem_rd_en          => sig_029,
                            mem_to_reg          => sig_028(0),
                            branch              => branch_sig
                            );

    regs : RegFile       generic map(
                             DATA_WIDTH         => DATA_WIDTH,
                             REG_NUMBER         => 32
                             )
                         port map(
                             clk                => clk_sig,
                             rs1                => inst_if_id_sig(19 downto 15),
                             rs2                => inst_if_id_sig(24 downto 20),
                             rd                 => sig_026,
                             wr_en              => regfile_wr_en_sig,
                             data_write         => sig_025,
                             op1                => op1_sig,
                             op2                => op2_sig
                             );

    imm_g : ImmGen       generic map(
                             DATA_WIDTH         => DATA_WIDTH
                             )
                         port map(
                             inst               => inst_if_id_sig,
                             imm                => imm_gen_sig
                             );

    id_ex_reg : ID_EX   generic map(
                            DATA_WIDTH          => DATA_WIDTH,
                            ADR_WIDTH           => MEM_ADR_WIDTH,
                            WB_MUX_SEL_WIDTH    => 1,
                            REGFILE_ADR_WIDTH   => 5,
                            ALU_OP_WIDTH        => 2,
                            ALU_SRC_SEL_WIDTH   => 1
                            )
                        port map(
                            clk                 => clk_sig,
                            rst                 => rst_sig,
                            wb_sel_in           => sig_028,
                            wb_sel_out          => sig_002,
                            regfile_wr_en_in    => sig_027,
                            regfile_wr_en_out   => sig_001,
                            regfile_adr_in      => inst_if_id_sig(11 downto 7),
                            regfile_adr_out     => sig_008,
                            mem_wr_en_in        => sig_030,
                            mem_wr_en_out       => sig_020,
                            mem_rd_en_in        => sig_029,
                            mem_rd_en_out       => sig_019,
                            branch_in           => branch_sig,
                            branch_out          => sig_018,
                            alu_op_in           => sig_031,
                            alu_op_out          => sig_009,
                            alu_src_sel_in      => sig_032,
                            alu_src_sel_out     => sig_010,
                            pc_adr_in           => pc_adr_if_id_sig,
                            pc_adr_out          => sig_016,
                            op1_in              => op1_sig,
                            op1_out             => sig_015,
                            op2_in              => op2_sig,
                            op2_out             => sig_014,
                            imm_gen_in          => imm_gen_sig,
                            imm_gen_out         => sig_013,
                            func3_in            => inst_if_id_sig(14 downto 12),
                            func3_out           => sig_012,
                            func7_in            => inst_if_id_sig(31 downto 25),
                            func7_out           => sig_033
                            );

    -- ##########################################################################
    -- ##########################################################################
    -- == EX Stage ==============================================================
    -- ##########################################################################
    -- ##########################################################################

    imm_add : Adder      generic map(
                             DATA_WIDTH         => MEM_ADR_WIDTH
                             )
                         port map(
                             a                  => sig_016,
                             b                  => sig_017,
                             result             => sig_022
                             );

    alu_src : Mux2x1     generic map(
                             DATA_WIDTH         => DATA_WIDTH
                             )
                         port map(
                             input1             => sig_014,
                             input2             => sig_013(DATA_WIDTH-1 downto 0),
                             sel                => sig_010(0),
                             output             => sig_021
                             );

    alu_0 : ALU          generic map(
                             DATA_WIDTH         => DATA_WIDTH
                             )
                         port map(
                             clk                => clk_sig,
                             op1                => sig_015,
                             op2                => sig_021,
                             operation          => sig_011,
                             result             => sig_024,
                             zero               => sig_023
                             );

    alu_ctrl : ALUCtrl   generic map(
                             DATA_WIDTH         => DATA_WIDTH
                             )
                         port map(
                             clk                => clk_sig,
                             func3              => sig_012,
                             func7              => sig_033,
                             alu_op             => sig_009,
                             alu_ctrl           => sig_011
                             );

    ex_mem_reg : EX_MEM generic map(
                            DATA_WIDTH          => DATA_WIDTH,
                            ADR_WIDTH           => MEM_ADR_WIDTH,
                            WB_MUX_SEL_WIDTH    => 1,
                            REGFILE_ADR_WIDTH   => 5
                            )
                        port map(
                            clk                 => clk_sig,
                            rst                 => rst_sig,
                            wb_sel_in           => sig_002,
                            wb_sel_out          => mem2reg_ex_mem_sig,
                            regfile_wr_en_in    => sig_001,
                            regfile_wr_en_out   => rf_wr_en_ex_mem_sig,
                            regfile_adr_in      => sig_008,
                            regfile_adr_out     => sig_007,
                            mem_wr_en_in        => sig_020,
                            mem_wr_en_out       => sig_003,
                            mem_rd_en_in        => sig_019,
                            mem_rd_en_out       => dmem_rden_ex_mem_sig,
                            branch_in           => sig_018,
                            branch_out          => sig_004,
                            pc_adr_in           => sig_022,
                            pc_adr_out          => pc_next_adr_sig,
                            alu_zero_in         => sig_023,
                            alu_zero_out        => sig_005,
                            alu_res_in          => sig_024,
                            alu_res_out         => alu_res_ex_mem_sig,
                            op2_in              => sig_014,
                            op2_out             => op2_ex_mem_sig
                            );

    -- ##########################################################################
    -- ##########################################################################
    -- == MEM Stage =============================================================
    -- ##########################################################################
    -- ##########################################################################

    data_mem : RAM       generic map(
                             DATA_WIDTH         => DATA_WIDTH,
                             SIZE               => DMEM_SIZE_BYTES
                             )
                         port map(
                             clk                => clk_sig,
                             wr_en              => sig_003,
                             rd_en              => dmem_rden_ex_mem_sig,
                             adr                => alu_res_ex_mem_sig,
                             data_in            => op2_ex_mem_sig,
                             data_out           => dmem_output_sig
                             );

    mem_wb_reg : MEM_WB generic map(
                            DATA_WIDTH          => DATA_WIDTH,
                            ADR_WIDTH           => MEM_ADR_WIDTH,
                            WB_MUX_SEL_WIDTH    => 1,
                            REGFILE_ADR_WIDTH   => 5
                            )
                        port map(
                            clk                 => clk_sig,
                            rst                 => rst_sig,
                            wb_sel_in           => mem2reg_ex_mem_sig,
                            wb_sel_out          => mem2reg_mem_wb_sig,
                            regfile_wr_en_in    => rf_wr_en_ex_mem_sig,
                            regfile_wr_en_out   => regfile_wr_en_sig,
                            regfile_wr_adr_in   => sig_007,
                            regfile_wr_adr_out  => sig_026,
                            alu_res_in          => alu_res_ex_mem_sig,
                            alu_res_out         => alu_res_mem_wb_sig,
                            data_mem_in         => dmem_output_sig,
                            data_mem_out        => dmem_out_mem_wb_sig
                            );

    -- ##########################################################################
    -- ##########################################################################
    -- == WB Stage ==============================================================
    -- ##########################################################################
    -- ##########################################################################

    wb : Mux2x1         generic map(
                            DATA_WIDTH          => DATA_WIDTH
                            )
                        port map(
                            input1              => alu_res_mem_wb_sig,
                            input2              => dmem_out_mem_wb_sig,
                            sel                 => mem2reg_mem_wb_sig(0),
                            output              => sig_025
                            );

end behavior;
