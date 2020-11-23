--! 
--! \brief Aritmetic Logic Unit (ALU).
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.14
--! 
--! \date 2020/11/22
--! 

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

entity ALU is
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
end ALU;

architecture behavior of ALU is

    constant ALU_OP_ID_AND : std_logic_vector(operation'range) := "0000";   --! AND operation.
    constant ALU_OP_ID_OR  : std_logic_vector(operation'range) := "0001";   --! OR operation.
    constant ALU_OP_ID_ADD : std_logic_vector(operation'range) := "0010";   --! ADD operation.
    constant ALU_OP_ID_XOR : std_logic_vector(operation'range) := "0011";   --! XOR operation.
    constant ALU_OP_ID_SUB : std_logic_vector(operation'range) := "0110";   --! SUB operation.

    signal result_sig : std_logic_vector(result'range) := (others => '0');

begin

    result <= result_sig;
    zero <= not (result_sig(31) or result_sig(30) or result_sig(29) or result_sig(28) or result_sig(27) or
                 result_sig(26) or result_sig(25) or result_sig(24) or result_sig(23) or result_sig(22) or
                 result_sig(21) or result_sig(20) or result_sig(19) or result_sig(18) or result_sig(17) or
                 result_sig(16) or result_sig(15) or result_sig(14) or result_sig(13) or result_sig(12) or
                 result_sig(11) or result_sig(10) or result_sig(9)  or result_sig(8)  or result_sig(7) or
                 result_sig(6)  or result_sig(5)  or result_sig(4)  or result_sig(3)  or result_sig(2) or
                 result_sig(1)  or result_sig(0));

    process(clk)
    begin
        if rising_edge(clk) then
            case operation is
                when ALU_OP_ID_AND => result_sig <= op1 and op2;
                when ALU_OP_ID_OR  => result_sig <= op1 or op2;
                when ALU_OP_ID_ADD => result_sig <= op1 + op2;
                when ALU_OP_ID_XOR => result_sig <= op1 xor op2;
                when ALU_OP_ID_SUB => result_sig <= op1 - op2;
                when others => result_sig <= (others => '0');
            end case;
        end if;
    end process;

end behavior;
