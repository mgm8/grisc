--! 
--! \brief ALU Control.
--! 
--! \author Gabriel Mariano Marcelino <gabriel.mm8@gmail.com>
--! 
--! \version 0.0.14
--! 
--! \date 2020/11/23
--!

library ieee;
    use ieee.std_logic_1164.all;

entity ALUCtrl is
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
end ALUCtrl;

architecture behavior of ALUCtrl is

    constant ALU_OP_ID_AND : std_logic_vector(alu_ctrl'range) := "0000";    --! AND operation.
    constant ALU_OP_ID_OR  : std_logic_vector(alu_ctrl'range) := "0001";    --! OR operation.
    constant ALU_OP_ID_ADD : std_logic_vector(alu_ctrl'range) := "0010";    --! ADD operation.
    constant ALU_OP_ID_XOR : std_logic_vector(alu_ctrl'range) := "0011";    --! XOR operation.
    constant ALU_OP_ID_SUB : std_logic_vector(alu_ctrl'range) := "0110";    --! SUB operation.

begin

    process(func3, func7, alu_op)
    begin
        if alu_op = "00" then
            alu_ctrl <= ALU_OP_ID_ADD;
        elsif alu_op = "01" then
            alu_ctrl <= ALU_OP_ID_SUB;
        elsif (alu_op = "10" and func7 = "0000000" and func3 = "000") then
            alu_ctrl <= ALU_OP_ID_ADD;
        elsif (alu_op = "10" and func7 = "0100000" and func3 = "000") then
            alu_ctrl <= ALU_OP_ID_SUB;
        elsif (alu_op = "10" and func7 = "0000000" and func3 = "111") then
            alu_ctrl <= ALU_OP_ID_AND;
        elsif (alu_op = "10" and func7 = "0000000" and func3 = "110") then
            alu_ctrl <= ALU_OP_ID_OR;
        else
            alu_ctrl <= "1111";
        end if;
    end process;

end behavior;
