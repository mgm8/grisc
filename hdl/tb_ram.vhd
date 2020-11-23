--! 
--! \brief RAM testbench.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.12
--! 
--! \date 2020/11/21
--! 

library ieee;
    use ieee.std_logic_1164.all;

entity TB_RAM is
end TB_RAM;

architecture behavior of TB_RAM is

    component Clock
        port(
            clk : out std_logic
            );
    end component;

    component RAM
        generic(
            DATA_WIDTH  : natural := 32;                                --! Data width in bits.
            ADR_WIDTH   : natural := 32;                                --! Address width in bits.
            SIZE        : natural := 1024                               --! Memory size in bytes.
        );
        port(
            clk         : in std_logic;                                 --! Clock input.
            wr_en       : in std_logic;                                 --! Write enable.
            rd_en       : in std_logic;                                 --! Read enable.
            adr         : in std_logic_vector(ADR_WIDTH-1 downto 0);    --! Memory address to access.
            data_in     : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Data input.
            data_out    : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Data output.
        );
    end component;

    signal clk_sig      : std_logic := '0';
    signal wr_en_sig    : std_logic := '0';
    signal rd_en_sig    : std_logic := '0';
    signal adr_sig      : std_logic_vector(31 downto 0) := (others => '0');
    signal data_in_sig  : std_logic_vector(31 downto 0) := (others => '0');
    signal data_out_sig : std_logic_vector(31 downto 0) := (others => '0');

begin

    clk_src : Clock port map(
                        clk         => clk_sig
                        );

    dut : RAM       generic map(
                        DATA_WIDTH  => 32,
                        ADR_WIDTH   => 32,
                        SIZE        => 16
                        )
                    port map(
                        clk         => clk_sig,
                        wr_en       => wr_en_sig,
                        rd_en       => rd_en_sig,
                        adr         => adr_sig,
                        data_in     => data_in_sig,
                        data_out    => data_out_sig
                        );

    process is
    begin
        wr_en_sig <= '0';
        rd_en_sig <= '1';
        adr_sig <= x"00000000";
        data_in_sig <= x"10101010";
        wait for 30 ns;

        if data_out_sig /= x"FFFFFFFF" then
            assert false report "Error: Invalid value on address 0x00000000!" severity failure;
        end if;

        wr_en_sig <= '1';
        rd_en_sig <= '1';
        wait for 30 ns;

        if data_out_sig /= x"10101010" then
            assert false report "Error: Invalid value on address 0x00000000!" severity failure;
        end if;

        wr_en_sig <= '0';
        rd_en_sig <= '1';
        adr_sig <= x"00000001";
        data_in_sig <= x"0000AAAA";
        wait for 30 ns;

        wr_en_sig <= '1';
        rd_en_sig <= '1';
        wait for 30 ns;

        if data_out_sig /= x"0000AAAA" then
            assert false report "Error: Invalid value on address 0x00000001!" severity failure;
        end if;

        rd_en_sig <= '1';
        wr_en_sig <= '0';
        wait for 30 ns;

        assert false report "Test completed!" severity note;
        wait;
    end process;

end behavior;
