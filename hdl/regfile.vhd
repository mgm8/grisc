--! 
--! \brief Register file.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.7
--! 
--! \date 2020/11/22
--! 

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity RegFile is
    generic(
        DATA_WIDTH  : natural := 32;                                --! Data width in bits.
        REG_NUMBER  : natural := 32                                 --! Total number of registers.
    );
    port(
        clk         : in std_logic;                                 --! Clock input.
        rs1         : in std_logic_vector(4 downto 0);              --! First source register number.
        rs2         : in std_logic_vector(4 downto 0);              --! Second source register number.
        rd          : in std_logic_vector(4 downto 0);              --! Destination register number.
        wr_en       : in std_logic;                                 --! Write register enable.
        data_write  : in std_logic_vector(DATA_WIDTH-1 downto 0);   --! Data to write into register.
        op1         : out std_logic_vector(DATA_WIDTH-1 downto 0);  --! Operand 1.
        op2         : out std_logic_vector(DATA_WIDTH-1 downto 0)   --! Operand 2.
    );
end RegFile;

architecture behavior of RegFile is

    type bank is array(0 to REG_NUMBER) of std_logic_vector(DATA_WIDTH-1 downto 0);

    signal reg_bank : bank := (others => (others => '0'));

begin

    process(clk)
    begin
        if rising_edge(clk) then
            op1 <= reg_bank(to_integer(unsigned(rs1)));
            op2 <= reg_bank(to_integer(unsigned(rs2)));

            if wr_en = '1' then
                if to_integer(unsigned(rd)) /= 0 then   -- 0 = x0 = The constant zero register
                    reg_bank(to_integer(unsigned(rd))) <= data_write;
                end if;
            end if;
        end if;
    end process;

end behavior;
