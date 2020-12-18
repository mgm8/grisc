--
-- tb_datapath.vhd
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

--! 
--! \brief Datapath testbench.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.31
--! 
--! \date 2020/11/23
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity TB_Datapath is
end TB_Datapath;

architecture behavior of TB_Datapath is

    component Clock
        port(
            clk : out std_logic
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

    constant DATA_WIDTH         : natural   := 32;
    constant MEM_ADR_WIDTH      : natural   := 64;
    constant IMEM_SIZE_BYTES    : natural   := 4*1024;
    constant DMEM_SIZE_BYTES    : natural   := 16*1024;
    constant PROGRAM_FILE       : string    := "program.hex";

    signal clk_sig              : std_logic := '0';

    signal pc_new_adr_sig       : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)    := (others => '0');
    signal pc_adr_sig           : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)    := (others => '0');
    signal inst_sig             : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');
    signal imm_sig              : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)    := (others => '0');
    signal imm_sig_shift        : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)    := (others => '0');
    signal op1_sig              : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');
    signal op2_sig              : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');
    signal alu_ctrl_sig         : std_logic_vector(3 downto 0)                  := (others => '0');
    signal alu_src_mux_sig      : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');
    signal alu_result_sig       : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');
    signal alu_zero_sig         : std_logic                                     := '0';
    signal dmem_data_sig        : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');
    signal wb_sig               : std_logic_vector(DATA_WIDTH-1 downto 0)       := (others => '0');
    signal pc_adr_res_sig       : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)    := (others => '0');
    signal pc_adr_mux_sel_sig   : std_logic                                     := '0'; 
    signal imm_add_res_sig      : std_logic_vector(MEM_ADR_WIDTH-1 downto 0)    := (others => '0');

    -- Controller signals
    signal branch_sig           : std_logic                                     := '0';
    signal mem_read_sig         : std_logic                                     := '0';
    signal mem_to_reg_sig       : std_logic                                     := '0';
    signal alu_op_sig           : std_logic_vector(1 downto 0)                  := (others => '0');
    signal mem_write_sig        : std_logic                                     := '0';
    signal alu_src_sig          : std_logic                                     := '0';
    signal reg_write_sig        : std_logic                                     := '0';

begin

    imm_sig_shift <= imm_sig(MEM_ADR_WIDTH-2 downto 0) & '0';
    pc_adr_mux_sel_sig <= branch_sig and alu_zero_sig;

    clk_src : Clock port map(
                        clk         => clk_sig
                        );

    pc : Reg           generic map(
                            DATA_WIDTH      => MEM_ADR_WIDTH
                            )
                        port map(
                            clk             => clk_sig,
                            rst             => '1',
                            en              => '1',
                            input           => pc_new_adr_sig,
                            output          => pc_adr_sig
                            );

    pc_add : Adder      generic map(
                            DATA_WIDTH      => MEM_ADR_WIDTH
                            )
                        port map(
                            a               => x"0000000000000001",
                            b               => pc_adr_sig,
                            result          => pc_adr_res_sig
                            );

    imem : ROM          generic map(
                            DATA_WIDTH      => DATA_WIDTH,
                            SIZE            => IMEM_SIZE_BYTES,
                            MEM_FILE        => PROGRAM_FILE
                            )
                        port map(
                            clk             => clk_sig,
                            adr             => pc_adr_sig,
                            data_out        => inst_sig
                            );

   regs : RegFile       generic map(
                            DATA_WIDTH      => DATA_WIDTH,
                            REG_NUMBER      => 32
                            )
                        port map(
                            clk             => clk_sig,
                            rs1             => inst_sig(19 downto 15),
                            rs2             => inst_sig(24 downto 20),
                            rd              => inst_sig(11 downto 7),
                            wr_en           => reg_write_sig,
                            data_write      => wb_sig,
                            op1             => op1_sig,
                            op2             => op2_sig
                            );

   imm_g : ImmGen       generic map(
                            DATA_WIDTH      => DATA_WIDTH
                            )
                        port map(
                            inst            => inst_sig,
                            imm             => imm_sig
                            );

   alu_mux : Mux2x1     generic map(
                            DATA_WIDTH      => DATA_WIDTH
                            )
                        port map(
                            input1          => op2_sig,
                            input2          => imm_sig(31 downto 0),
                            sel             => alu_src_sig,
                            output          => alu_src_mux_sig
                            );

   imm_add : Adder      generic map(
                            DATA_WIDTH      => MEM_ADR_WIDTH
                            )
                        port map(
                            a               => pc_adr_sig,
                            b               => imm_sig_shift,
                            result          => imm_add_res_sig
                            );

   alu_a : ALU          generic map(
                            DATA_WIDTH      => DATA_WIDTH
                            )
                        port map(
                            clk             => clk_sig,
                            op1             => op1_sig,
                            op2             => alu_src_mux_sig,
                            operation       => alu_ctrl_sig,
                            result          => alu_result_sig,
                            zero            => alu_zero_sig
                            );

   alu_ctrl : ALUCtrl   generic map(
                            DATA_WIDTH      => DATA_WIDTH
                            )
                        port map(
                            clk             => clk_sig,
                            func3           => inst_sig(14 downto 12),
                            func7           => inst_sig(31 downto 25),
                            alu_op          => alu_op_sig,
                            alu_ctrl        => alu_ctrl_sig
                            );

   pc_mux : Mux2x1      generic map(
                            DATA_WIDTH      => MEM_ADR_WIDTH
                            )
                        port map(
                            input1          => pc_adr_res_sig,
                            input2          => imm_add_res_sig,
                            sel             => pc_adr_mux_sel_sig,
                            output          => pc_new_adr_sig
                            );

   dmem : RAM          generic map(
                            DATA_WIDTH      => DATA_WIDTH,
                            SIZE            => DMEM_SIZE_BYTES
                            )
                        port map(
                            clk             => clk_sig,
                            wr_en           => mem_write_sig,
                            rd_en           => mem_read_sig,
                            adr             => alu_result_sig,
                            data_in         => op2_sig,
                            data_out        => dmem_data_sig
                            );

    wb : Mux2x1         generic map(
                            DATA_WIDTH      => DATA_WIDTH
                            )
                        port map(
                            input1          => alu_result_sig,
                            input2          => dmem_data_sig,
                            sel             => mem_to_reg_sig,
                            output          => wb_sig
                            );

    process is
    begin
        -- Load instruction test
        branch_sig      <= '0';
        mem_read_sig    <= '1';
        mem_to_reg_sig  <= '1';
        alu_op_sig      <= "00";
        mem_write_sig   <= '0';
        alu_src_sig     <= '1';
        reg_write_sig   <= '1';
        wait for 70 ns;

        -- Load instruction test
        branch_sig      <= '0';
        mem_read_sig    <= '1';
        mem_to_reg_sig  <= '1';
        alu_op_sig      <= "00";
        mem_write_sig   <= '0';
        alu_src_sig     <= '1';
        reg_write_sig   <= '1';
        wait for 70 ns;

        -- R-Type instruction test
        branch_sig      <= '0';
        mem_read_sig    <= '0';
        mem_to_reg_sig  <= '0';
        alu_op_sig      <= "10";
        mem_write_sig   <= '0';
        alu_src_sig     <= '0';
        reg_write_sig   <= '1';
        wait for 70 ns;

        reg_write_sig   <= '0';

        assert false report "Test completed with SUCCESS!" severity note;
        wait;
    end process;

end behavior;
