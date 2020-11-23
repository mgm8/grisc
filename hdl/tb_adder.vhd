--! 
--! \brief Adder testbench.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.8
--! 
--! \date 2020/11/23
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity TB_Adder is
end TB_Adder;

architecture behavior of TB_Adder is

    component Clock
        port(
            clk : out std_logic
            );
    end component;

    component Adder
        generic(
            DATA_WIDTH : natural := 32                              --! Data width in bits.
            );
        port(
            a       : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Input A.
            b       : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Input B.
            result  : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Result (A + B).
            );
    end component;

    constant DATA_WIDTH : natural := 32;

    signal clk_sig      : std_logic := '0';
    signal a_sig        : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal b_sig        : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal res_sig      : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

begin

    clk_src : Clock port map(
                        clk         => clk_sig
                        );

    dut : Adder     generic map(
                        DATA_WIDTH  => DATA_WIDTH
                        )
                    port map(
                        a           => a_sig,
                        b           => b_sig,
                        result      => res_sig
                        );

    process is
    begin
        a_sig <= x"00000003";
        b_sig <= x"00000005";
        wait for 30 ns;

        if res_sig /= x"00000008" then
            assert false report "Error: Invalid result!" severity failure;
        end if;

        a_sig <= x"00000103";
        b_sig <= x"0000F005";
        wait for 30 ns;

        if res_sig /= x"0000F108" then
            assert false report "Error: Invalid result!" severity failure;
        end if;

        assert false report "Test completed with success!" severity note;
        wait;
    end process;

end behavior;
