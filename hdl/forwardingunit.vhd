--
-- forwardingunit.vhd
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
--! \brief Forwarding Unit.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.37
--! 
--! \date 2020/12/05
--!

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

library work;
    use work.grisc.all;

entity ForwardingUnit is
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
end ForwardingUnit;

architecture behavior of ForwardingUnit is

    constant ZERO_CONST : std_logic_vector(RF_ADR_WIDTH-1 downto 0) := (others => '0');

begin

    process(id_reg1_idx, mem_reg_wr_idx, mem_reg_wr_en, wb_reg_wr_idx, wb_reg_wr_en)
    begin
        if id_reg1_idx = ZERO_CONST then
            alu_reg1_forwarding_ctrl <= GRISC_FORWARDING_SRC_ID_STAGE;
        elsif ((id_reg1_idx = mem_reg_wr_idx) and (mem_reg_wr_en = '1')) then
            alu_reg1_forwarding_ctrl <= GRISC_FORWARDING_SRC_MEM_STAGE;
        elsif ((id_reg1_idx = wb_reg_wr_idx) and (wb_reg_wr_en = '1')) then
            alu_reg1_forwarding_ctrl <= GRISC_FORWARDING_SRC_WB_STAGE;
        else
            alu_reg1_forwarding_ctrl <= GRISC_FORWARDING_SRC_ID_STAGE;
        end if;
    end process;

    process(id_reg2_idx, mem_reg_wr_idx, mem_reg_wr_en, wb_reg_wr_idx, wb_reg_wr_en)
    begin
        if id_reg2_idx = ZERO_CONST then
            alu_reg2_forwarding_ctrl <= GRISC_FORWARDING_SRC_ID_STAGE;
        elsif ((id_reg2_idx = mem_reg_wr_idx) and (mem_reg_wr_en = '1')) then
            alu_reg2_forwarding_ctrl <= GRISC_FORWARDING_SRC_MEM_STAGE;
        elsif ((id_reg2_idx = wb_reg_wr_idx) and (wb_reg_wr_en = '1')) then
            alu_reg2_forwarding_ctrl <= GRISC_FORWARDING_SRC_WB_STAGE;
        else
            alu_reg2_forwarding_ctrl <= GRISC_FORWARDING_SRC_ID_STAGE;
        end if;
    end process;

end behavior;
