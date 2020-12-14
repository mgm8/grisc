--
-- hazarddetection.vhd
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
--! \brief Hazard Detection Unit.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.37
--! 
--! \date 2020/12/06
--!

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.numeric_std.all;

library work;
    use work.grisc.all;

entity HazardDetection is
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
end HazardDetection;

architecture behavior of HazardDetection is

    signal hazard_sig           : std_logic := '0';
    signal ecall_hazard_sig     : std_logic := '0';
    signal load_use_hazard_sig  : std_logic := '0';

begin

    hazard_sig <= ecall_hazard_sig or load_use_hazard_sig;

    process(ex_reg_wr_idx, id_reg1_idx, id_reg2_idx, ex_do_mem_read_en)
    begin
        if (((ex_reg_wr_idx = id_reg1_idx) or (ex_reg_wr_idx = id_reg2_idx)) and (ex_do_mem_read_en = '1')) then
            load_use_hazard_sig <= '1';
        else
            load_use_hazard_sig <= '0';
        end if;
    end process;

    process(instr_id, mem_do_reg_write, wb_do_reg_write)
    begin
        if ((instr_id = RISCV_INSTR_ECALL) and ((mem_do_reg_write = '1') or (wb_do_reg_write = '1'))) then
            ecall_hazard_sig <= '1';
        else
            ecall_hazard_sig <= '0';
        end if;
    end process;

    hazard_fe_en <= not hazard_sig;
    hazard_id_ex_en <= not ecall_hazard_sig;
    hazard_ex_mem_clear <= not ecall_hazard_sig;

end behavior;
