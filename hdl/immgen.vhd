--! 
--! \brief Immediate Generator.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.11
--! 
--! \date 2020/11/23
--!

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

entity ImmGen is
    generic(
        DATA_WIDTH : natural := 32                                  --! Data width in bits.
        );
    port(
        inst    : in std_logic_vector(DATA_WIDTH-1 downto 0);       --! Instruction.
        imm     : out std_logic_vector((2*DATA_WIDTH)-1 downto 0)   --! Generated immediate.
        );
end ImmGen;

architecture behavior of ImmGen is

begin

    process(inst)
    begin
        if (inst(6) = '0' and inst(5) = '0') then       -- Load instructions
            imm(11 downto 0) <= inst(31 downto 20);
        elsif (inst(6) = '0' and inst(5) = '1') then    -- Store instructions
            imm(11 downto 0) <= inst(31 downto 25) & inst(11 downto 7);
        elsif (inst(6) = '1' and inst(5) = '0') then    -- Conditional branches
            imm(11 downto 0) <= inst(31) & inst(7) & inst(30 downto 25) & inst(11 downto 8);
        else
            imm(11 downto 0) <= inst(31) & inst(7) & inst(30 downto 25) & inst(11 downto 8);
        end if;
    end process;

    -- Sign-extension
    gen : for i in 12 to 63 generate
        imm(i) <= inst(31);
    end generate;

end behavior;
