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
--! \version 0.0.30
--! 
--! \date 2020/12/06
--!

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

entity HazardDetection is
    generic(
        RF_ADR_WIDTH        : natural := 5                                  --! Regfile address width in bits.
        );
    port(
        if_id_rs1           : in std_logic_vector(RF_ADR_WIDTH-1 downto 0); --! IF/ID RS1.
        if_id_rs2           : in std_logic_vector(RF_ADR_WIDTH-1 downto 0); --! IF/ID RS2.
        id_ex_rd            : in std_logic_vector(RF_ADR_WIDTH-1 downto 0); --! ID/EX RD.
        id_ex_dmem_rd_en    : in std_logic;                                 --! ID/EX data memory read enable.
        pc_wr_en            : out std_logic;                                --! PC enable.
        if_id_wr_en         : out std_logic;                                --! IF/ID enable.
        ctrl_mux_sel        : out std_logic                                 --! Controller mux selection.
        );
end HazardDetection;

architecture behavior of HazardDetection is

begin

    process(id_ex_dmem_rd_en, id_ex_rd, if_id_rs1, if_id_rs2)
    begin
        if ((id_ex_dmem_rd_en = '1') and ((id_ex_rd = if_id_rs1) or (id_ex_rd = if_id_rs2))) then
            pc_wr_en <= '0';
            if_id_wr_en <= '0';
            ctrl_mux_sel <= '1';
        else
            pc_wr_en <= '1';
            if_id_wr_en <= '1';
            ctrl_mux_sel <= '0';
        end if;
    end process;

end behavior;
