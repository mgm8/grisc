--
-- adder.vhd
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
--! \brief N-bit adder.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.15
--! 
--! \date 2020/09/07
--!

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

entity Adder is
    generic(
        DATA_WIDTH : natural := 32                              --! Data width in bits.
        );
    port(
        a       : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Input A.
        b       : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Input B.
        result  : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Result (A + B).
        );
end Adder;

architecture behavior of Adder is

begin

    result <= a + b;

end behavior;
