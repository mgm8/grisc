--
-- if_id.vhd
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
--! \brief IF/ID register.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.31
--! 
--! \date 2020/11/28
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity IF_ID is
    generic(
        DATA_WIDTH          : natural := 32;                                --! Data width in bits.
        ADR_WIDTH           : natural := 64                                 --! Address width in bits.
        );
    port(
        clk                 : in std_logic;                                 --! Clock input.
        rst                 : in std_logic;                                 --! Reset signal.
        en                  : in std_logic;                                 --! Enable signal.

        -- EX
        pc_adr_in           : in std_logic_vector(ADR_WIDTH-1 downto 0);    --! PC address input.
        pc_adr_out          : out std_logic_vector(ADR_WIDTH-1 downto 0);   --! PC address output.

        -- ID
        inst_in             : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Instruction input.
        inst_out            : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Instruction output.
        );
end IF_ID;

architecture behavior of IF_ID is

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

begin

    -- PC address register
    pc_adr_reg : Reg    generic map(
                            DATA_WIDTH  => ADR_WIDTH
                            )
                        port map(
                            clk         => clk,
                            rst         => rst,
                            en          => en,
                            input       => pc_adr_in,
                            output      => pc_adr_out
                            );

    -- Instruction register
    inst_reg : Reg      generic map(
                            DATA_WIDTH  => DATA_WIDTH
                            )
                        port map(
                            clk         => clk,
                            rst         => rst,
                            en          => en,
                            input       => inst_in,
                            output      => inst_out
                            );

end behavior;
