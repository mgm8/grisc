--
-- clock.vhd
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
--! \brief Clock generation block for simulation.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.15
--! 
--! \date 2017/12/13
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity Clock is
    port(
        clk : out std_logic
        );
end Clock;

architecture behavior of Clock is

    signal clock_signal : std_logic := '0';

begin

    clock_signal <= not (clock_signal) after 10 ns;     -- Clock with 20 ns time period

    clk <= clock_signal;

end behavior;
