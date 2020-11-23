--! 
--! \brief Immediate Generator testbench.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.11
--! 
--! \date 2020/11/23
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity TB_ImmGen is
end TB_ImmGen;

architecture behavior of TB_ImmGen is

    component Clock
        port(
            clk : out std_logic
            );
    end component;

    component ImmGen
        generic(
            DATA_WIDTH : natural := 32                                  --! Data width in bits.
        );
        port(
            inst    : in std_logic_vector(DATA_WIDTH-1 downto 0);       --! Instruction.
            imm     : out std_logic_vector((2*DATA_WIDTH)-1 downto 0)   --! Generated address.
        );
    end component;

    constant DATA_WIDTH : natural := 32;

    signal clk_sig      : std_logic := '0';
    signal inst_sig     : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal imm_sig      : std_logic_vector((2*DATA_WIDTH)-1 downto 0) := (others => '0');

begin

    clk_src : Clock port map(
                        clk         => clk_sig
                        );

    dut : ImmGen    generic map(
                        DATA_WIDTH  => DATA_WIDTH
                        )
                    port map(
                        inst        => inst_sig,
                        imm         => imm_sig
                        );

    process is
    begin
        inst_sig <= x"01700000";
        wait for 30 ns;

        if imm_sig /= x"0000000000000017" then
            assert false report "Error: Invalid result!" severity failure;
        end if;

        inst_sig <= x"0E0008A0";
        wait for 30 ns;

        if imm_sig /= x"00000000000000F1" then
            assert false report "Error: Invalid result!" severity failure;
        end if;

        inst_sig <= x"C20009C0";
        wait for 30 ns;

        if imm_sig /= x"FFFFFFFFFFFFFE19" then
            assert false report "Error: Invalid result!" severity failure;
        end if;

        assert false report "Test completed with SUCCESS!" severity note;
        wait;
    end process;

end behavior;
