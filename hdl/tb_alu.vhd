--! 
--! \brief Aritmetic Logic Unit testbench.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.6
--! 
--! \date 2020/11/22
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity TB_ALU is
end TB_ALU;

architecture behavior of TB_ALU is

    component Clock
        port(
            clk : out std_logic
            );
    end component;

    component ALU is
        generic(
            DATA_WIDTH  : natural := 32                                 --! Data width in bits.
        );
        port(
            clk         : in  std_logic;                                --! Clock input.
            op1         : in  std_logic_vector(DATA_WIDTH-1 downto 0);  --! Operand 1.
            op2         : in  std_logic_vector(DATA_WIDTH-1 downto 0);  --! Operand 2.
            operation   : in  std_logic_vector(3 downto 0);             --! Operation code.
            result      : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Opeartion output.
            zero        : out std_logic                                 --! Zero result flag.
        );
    end component;

    constant DATA_WIDTH     : natural := 32;

    signal clk_sig          : std_logic := '0';
    signal op1_sig          : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal op2_sig          : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal operation_sig    : std_logic_vector(3 downto 0) := (others => '0');
    signal result_sig       : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal zero_sig         : std_logic := '0';

begin

    clk_src : Clock port map(
                        clk             => clk_sig
                        );

    dut : ALU   generic map(
                    DATA_WIDTH  => DATA_WIDTH
                    )
                port map(
                    clk         => clk_sig,
                    op1         => op1_sig,
                    op2         => op2_sig,
                    operation   => operation_sig,
                    result      => result_sig,
                    zero        => zero_sig
                    );

    process is
    begin
        -- ADD test
        op1_sig <= x"00000002";
        op2_sig <= x"00000001";
        operation_sig <= "0000";
        wait for 50 ns;

        if result_sig /= x"00000003" then
            assert false report "Error: Wrong result on the ADD operator!" severity failure;
        end if;

        -- AND test
        op1_sig <= x"00000001";
        op2_sig <= x"00000001";
        operation_sig <= "0001";
        wait for 50 ns;

        if result_sig /= x"00000001" then
            assert false report "Error: Wrong result on the AND operator!" severity failure;
        end if;

        -- OR test
        op1_sig <= x"00000001";
        op2_sig <= x"00000004";
        operation_sig <= "0010";
        wait for 50 ns;

        if result_sig /= x"00000005" then
            assert false report "Error: Wrong result on the OR operator!" severity failure;
        end if;

        -- XOR test
        op1_sig <= x"00000021";
        op2_sig <= x"00000006";
        operation_sig <= "0011";
        wait for 50 ns;

        if result_sig /= x"00000027" then
            assert false report "Error: Wrong result on the XOR operator!" severity failure;
        end if;

        assert false report "Test completed!" severity note;
        wait;
    end process;

end behavior;
