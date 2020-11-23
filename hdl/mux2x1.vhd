--! 
--! \brief 2x1 multiplexer.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.5
--! 
--! \date 2020/11/22
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity Mux2x1 is
    generic(
        DATA_WIDTH  : natural := 32                             --! Width (in bits) of the inputs.
        );
    port(
        input1  : in  std_logic_vector(DATA_WIDTH-1 downto 0);  --! Input 1.
        input2  : in  std_logic_vector(DATA_WIDTH-1 downto 0);  --! Input 2.
        sel     : in  std_logic;                                --! Input selection.
        output  : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Output.
        );
end Mux2x1;

architecture behavior of Mux2x1 is

begin

    output <= input1 when (sel = '0') else
              input2 when (sel = '1') else
              input1;

end behavior;
