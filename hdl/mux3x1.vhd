--
-- mux3x1.vhd
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
--! \brief 3x1 multiplexer.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.28
--! 
--! \date 2020/12/05
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity Mux3x1 is
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
end Mux3x1;

architecture behavior of Mux3x1 is

begin

    output <= input1 when (sel = "00") else
              input2 when (sel = "01") else
              input3 when (sel = "10") else
              input1;

end behavior;
