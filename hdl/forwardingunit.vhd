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
--! \version 0.0.28
--! 
--! \date 2020/12/05
--!

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

entity ForwardingUnit is
    generic(
        RF_ADR_WIDTH    : natural := 5                                  --! Regfile address width in bits.
        );
    port(
        id_ex_rs1       : in std_logic_vector(RF_ADR_WIDTH-1 downto 0); --! ID/EX RS1.
        id_ex_rs2       : in std_logic_vector(RF_ADR_WIDTH-1 downto 0); --! ID/EX RS2.
        ex_mem_rd       : in std_logic_vector(RF_ADR_WIDTH-1 downto 0); --! EX/MEM RD.
        mem_wb_rd       : in std_logic_vector(RF_ADR_WIDTH-1 downto 0); --! MEM/WB RD.
        ex_mem_rf_wr_en : in std_logic;                                 --! EX/MEM register file write enable.
        mem_wb_rf_wr_en : in std_logic;                                 --! MEM/WB register file write enable.
        fwd_a           : out std_logic_vector(1 downto 0);             --! Forward A.
        fwd_b           : out std_logic_vector(1 downto 0)              --! Forward B.
        );
end ForwardingUnit;

architecture behavior of ForwardingUnit is

    constant zero_const : std_logic_vector(RF_ADR_WIDTH-1 downto 0) := (others => '0');

begin

    process(id_ex_rs1, ex_mem_rd, mem_wb_rd, ex_mem_rf_wr_en, mem_wb_rf_wr_en)
    begin
        if ((mem_wb_rf_wr_en = '1')
            and (mem_wb_rd /= zero_const)
            and not ((ex_mem_rf_wr_en = '1') and (ex_mem_rd /= zero_const) and (ex_mem_rd /= id_ex_rs1)) and (mem_wb_rd = id_ex_rs1)) then
            fwd_a <= "01";
        elsif ((ex_mem_rf_wr_en = '1')
               and (ex_mem_rd /= zero_const)
               and (ex_mem_rd = id_ex_rs1)) then
            fwd_a <= "10";
        else
            fwd_a <= "00";
        end if;
    end process;

    process(id_ex_rs2, ex_mem_rd, mem_wb_rd, ex_mem_rf_wr_en, mem_wb_rf_wr_en)
    begin
        if ((mem_wb_rf_wr_en = '1')
            and (mem_wb_rd /= zero_const)
            and not ((ex_mem_rf_wr_en = '1') and (ex_mem_rd /= zero_const) and (ex_mem_rd /= id_ex_rs2))
            and (mem_wb_rd = id_ex_rs2)) then
            fwd_b <= "01";
        elsif ((ex_mem_rf_wr_en = '1')
               and (ex_mem_rd /= zero_const)
               and (ex_mem_rd = id_ex_rs2)) then
            fwd_b <= "10";
        else
            fwd_b <= "00";
        end if;
    end process;

end behavior;
