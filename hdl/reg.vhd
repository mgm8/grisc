--! 
--! \brief Flip-flop register.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.10
--! 
--! \date 2020/11/21
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity Reg is
    generic(
        DATA_WIDTH  : natural := 32                                 --! Data width in bits.
        );
    port(
        clk         : in std_logic;                                 --! Clock input.
        rst         : in std_logic;                                 --! Reset signal.
        input       : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Data input.
        output      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Data output.
        );
end Reg;

architecture behavior of Reg is

begin

    process(clk)
    begin
        if rst = '1' then
            output <= (others => 0);
        elsif rising_edge(clk) then
            output <= input;
        end if;
    end process;

end behavior;
