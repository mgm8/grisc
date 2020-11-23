--! 
--! \brief N-bit adder.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.8
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
