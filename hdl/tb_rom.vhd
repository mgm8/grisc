--! 
--! \brief ROM testbench.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.1
--! 
--! \date 2020/11/21
--! 

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity TB_ROM is
end TB_ROM;

architecture behavior of TB_ROM is

    component Clock
        port(
            clk : out std_logic
            );
    end component;

    component ROM
        generic(
            DATA_WIDTH  : natural := 32;                                --! Data width in bits.
            SIZE        : natural := 1024;                              --! Memory size in bytes.
            MEM_FILE    : string := "rom.hex"                           --! File name of the memory file.
        );
        port(
            clk         : in std_logic;                                 --! Clock source.
            adr         : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Memory address.
            data_out    : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Data output.
        );
    end component;

    signal clk_sig      : std_logic := '0';
    signal adr_sig      : std_logic_vector(31 downto 0) := (others => '0');
    signal data_out_sig : std_logic_vector(31 downto 0) := (others => '0');

begin

    clk_src : Clock port map(
                        clk         => clk_sig
                        );

    dut : ROM       generic map(
                        DATA_WIDTH  => 32,
                        SIZE        => 16,
                        MEM_FILE    => "tb_rom.hex"
                        )
                    port map(
                        clk         => clk_sig,
                        adr         => adr_sig,
                        data_out    => data_out_sig
                        );

    process is
    begin
        adr_sig <= x"00000000";
        wait for 40 ns;

        if data_out_sig /= x"00000003" then
            assert false report "Wrong value on address 0x00000000!" severity failure;
        else
            report "Address 0x00000000 = 0x" & to_hstring(data_out_sig);
        end if;

        adr_sig <= x"00000001";
        wait for 40 ns;

        if data_out_sig /= x"0000F004" then
            assert false report "Wrong value on address 0x00000001!" severity failure;
        else
            report "Address 0x00000001 = 0x" & to_hstring(data_out_sig);
        end if;

        adr_sig <= x"00000002";
        wait for 40 ns;

        if data_out_sig /= x"00000B56" then
            assert false report "Wrong value on address 0x00000002!" severity failure;
        else
            report "Address 0x00000002 = 0x" & to_hstring(data_out_sig);
        end if;

        adr_sig <= x"00000003";
        wait for 40 ns;

        if data_out_sig /= x"023AC004" then
            assert false report "Wrong value on address 0x00000003!" severity failure;
        else
            report "Address 0x00000003 = 0x" & to_hstring(data_out_sig);
        end if;

        assert false report "Test completed with SUCCESS!" severity note;
        wait;
    end process;

end behavior;
