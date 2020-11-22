--! 
--! \brief Counter testbench.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.2
--! 
--! \date 2020/11/22
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity TB_Counter is
end TB_Counter;

architecture behavior of TB_Counter is

    component Clock
        port(
            clk : out std_logic
            );
    end component;

    component Counter
        generic(
            DATA_WIDTH  : natural := 2;                                 --! Data width in bits.
            INIT_VALUE  : natural := 0;                                 --! Initial value.
            MAX_VALUE   : natural := 1024;                              --! Maximum value.
            INCREMENT_VALUE : natural := 1                              --! Counter increment.
        );
        port(
            clk         : in std_logic;                                 --! Reference clock.
            rst         : in std_logic;                                 --! Resets counting (go back to 0).
            output      : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Counter output.
        );
    end component;

    signal clk_sig      : std_logic := '0';
    signal rst_sig      : std_logic := '1';
    signal output_sig   : std_logic_vector(31 downto 0) := (others => '0');

begin

    clk_src : Clock port map(
                        clk             => clk_sig
                        );

    dut : Counter   generic map(
                        DATA_WIDTH      => 32,
                        INIT_VALUE      => 0,
                        MAX_VALUE       => 1024,
                        INCREMENT_VALUE => 4
                        )
                    port map(
                        clk             => clk_sig,
                        rst             => rst_sig,
                        output          => output_sig
                        );

    process is
    begin
        rst_sig <= '1';
        wait for 200 ns;
        if output_sig /= x"00000028" then
            assert false report "Error: Counter not working as expected!" severity failure;
        end if;
        rst_sig <= '0';
        wait for 50 ns;
        if output_sig /= x"00000000" then
            assert false report "Error: Reset signal not working!" severity failure;
        end if;
        rst_sig <= '1';
        assert false report "Test completed!" severity note;
        wait;
    end process;

end behavior;
