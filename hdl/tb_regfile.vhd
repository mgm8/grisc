--! 
--! \brief Register file testbench.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.3
--! 
--! \date 2020/11/22
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity TB_RegFile is
end TB_RegFile;

architecture behavior of TB_RegFile is

    component Clock
        port(
            clk : out std_logic
            );
    end component;

    component RegFile
        generic(
            DATA_WIDTH  : natural := 32;                                --! Data width in bits.
            REG_NUMBER  : natural := 32                                 --! Total number of registers.
        );
        port(
            clk         : in std_logic;                                 --! Clock input.
            inst        : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Instruction.
            wr_en       : in std_logic;                                 --! Write register enable.
            reg_write   : in std_logic_vector(4 downto 0);              --! Register number to write.
            data_write  : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Data to write into register.
            op1         : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Operand 1.
            op2         : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Operand 2.
        );
    end component;

    constant DATA_WIDTH     : natural := 32;

    signal clk_sig          : std_logic := '0';
    signal inst_sig         : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal wr_en_sig        : std_logic := '0';
    signal reg_write_sig    : std_logic_vector(4 downto 0) := (others => '0');
    signal data_write_sig   : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal op1_sig          : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal op2_sig          : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

begin

    clk_src : Clock port map(
                        clk             => clk_sig
                        );

    dut : RegFile   generic map(
                        DATA_WIDTH      => 32,
                        REG_NUMBER      => 32
                        )
                    port map(
                        clk             => clk_sig,
                        inst            => inst_sig,
                        wr_en           => wr_en_sig,
                        reg_write       => reg_write_sig,
                        data_write      => data_write_sig,
                        op1             => op1_sig,
                        op2             => op2_sig
                        );

    process is
    begin
        wr_en_sig <= '1';

        reg_write_sig <= "00101";
        data_write_sig <= x"00000001";  -- Writes 0x01 to register 5
        wait for 30 ns;

        reg_write_sig <= "00111";
        data_write_sig <= x"00000002";  -- Writes 0x02 to register 7
        wait for 30 ns;

        wr_en_sig <= '0';
        wait for 30 ns;

        inst_sig <= x"00728000";        -- rs1 = 0x05, rs2 = 0x07
        wait for 30 ns;

        if op1_sig /= x"00000001" then
            assert false report "Error: op1 is different from the expected value!" severity failure;
        end if;

        if op2_sig /= x"00000002" then
            assert false report "Error: op2 is different from the expected value!" severity failure;
        end if;

        assert false report "Test completed!" severity note;
        wait;
    end process;

end behavior;
