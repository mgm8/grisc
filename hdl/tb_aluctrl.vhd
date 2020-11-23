--! 
--! \brief Aritmetic Logic Unit Controller testbench.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.14
--! 
--! \date 2020/11/22
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity TB_ALUCtrl is
end TB_ALUCtrl;

architecture behavior of TB_ALUCtrl is

    component Clock
        port(
            clk : out std_logic
            );
    end component;

    component ALUCtrl is
        generic(
            DATA_WIDTH : natural := 32                              --! Data width in bits.
        );
        port(
            clk         : in std_logic;                             --! Clock signal.
            func3       : in std_logic_vector(2 downto 0);          --! 3-bit function code.
            func7       : in std_logic_vector(6 downto 0);          --! 7-bit function code.
            alu_op      : in std_logic_vector(1 downto 0);          --! ALU operation.
            alu_ctrl    : out std_logic_vector(3 downto 0)          --! ALU operation code.
        );
    end component;

    constant DATA_WIDTH     : natural := 32;

    constant ALU_OP_ID_AND : std_logic_vector(3 downto 0) := "0000";    --! AND operation.
    constant ALU_OP_ID_OR  : std_logic_vector(3 downto 0) := "0001";    --! OR operation.
    constant ALU_OP_ID_ADD : std_logic_vector(3 downto 0) := "0010";    --! ADD operation.
    constant ALU_OP_ID_XOR : std_logic_vector(3 downto 0) := "0011";    --! XOR operation.
    constant ALU_OP_ID_SUB : std_logic_vector(3 downto 0) := "0110";    --! SUB operation.

    signal clk_sig          : std_logic := '0';
    signal func3_sig        : std_logic_vector(2 downto 0) := (others => '0');
    signal func7_sig        : std_logic_vector(6 downto 0) := (others => '0');
    signal alu_op_sig       : std_logic_vector(1 downto 0) := (others => '0');
    signal alu_ctrl_sig     : std_logic_vector(3 downto 0) := (others => '0');

begin

    clk_src : Clock port map(
                        clk         => clk_sig
                        );

    dut : ALUCtrl   generic map(
                        DATA_WIDTH  => DATA_WIDTH
                        )
                    port map(
                        clk         => clk_sig,
                        func3       => func3_sig,
                        func7       => func7_sig,
                        alu_op      => alu_op_sig,
                        alu_ctrl    => alu_ctrl_sig
                        );

    process is
    begin
        -- ld/sd test
        alu_op_sig <= "00";
        func3_sig <= "101";
        func7_sig <= "1010101";
        wait for 50 ns;

        if alu_ctrl_sig /= ALU_OP_ID_ADD then
            assert false report "Error: ld/sd failed!" severity failure;
        end if;

        -- beq test
        alu_op_sig <= "01";
        func3_sig <= "101";
        func7_sig <= "1010101";
        wait for 50 ns;

        if alu_ctrl_sig /= ALU_OP_ID_SUB then
            assert false report "Error: beq failed!" severity failure;
        end if;

        -- add test
        alu_op_sig <= "10";
        func3_sig <= "000";
        func7_sig <= "0000000";
        wait for 50 ns;

        if alu_ctrl_sig /= ALU_OP_ID_ADD then
            assert false report "Error: add failed!" severity failure;
        end if;

        -- sub test
        alu_op_sig <= "10";
        func3_sig <= "000";
        func7_sig <= "0100000";
        wait for 50 ns;

        if alu_ctrl_sig /= ALU_OP_ID_SUB then
            assert false report "Error: sub failed!" severity failure;
        end if;

        -- and test
        alu_op_sig <= "10";
        func3_sig <= "111";
        func7_sig <= "0000000";
        wait for 50 ns;

        if alu_ctrl_sig /= ALU_OP_ID_AND then
            assert false report "Error: and failed!" severity failure;
        end if;

        -- or test
        alu_op_sig <= "10";
        func3_sig <= "110";
        func7_sig <= "0000000";
        wait for 50 ns;

        if alu_ctrl_sig /= ALU_OP_ID_OR then
            assert false report "Error: or failed!" severity failure;
        end if;

        assert false report "Test completed with SUCCESS!" severity note;
        wait;
    end process;

end behavior;
