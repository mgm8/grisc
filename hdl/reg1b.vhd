--
-- reg1b.vhd
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
--! \brief Flip-flop register (1-bit).
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.46
--! 
--! \date 2020/12/14
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity Reg1b is
    port(
        clk         : in std_logic;     --! Clock input.
        rst         : in std_logic;     --! Reset signal.
        en          : in std_logic;     --! Enable signal.
        input       : in std_logic;     --! Data input.
        output      : out std_logic     --! Data output.
        );
end Reg1b;

architecture behavior of Reg1b is

    signal output_sig : std_logic := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                output_sig <= '0';
            else
                if en = '1' then
                    output_sig <= input;
                end if;
            end if;
        end if;
    end process;

    output <= output_sig;

end behavior;
