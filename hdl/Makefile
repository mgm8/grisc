ifndef STOP_TIME
	STOP_TIME = 500ns
endif

GHDL=ghdl
FLAGS = --stop-time=$(STOP_TIME)

rom:
	$(GHDL) -a --std=08 clock.vhd
	$(GHDL) -a -fsynopsys --std=08 rom.vhd
	$(GHDL) -a -fsynopsys --std=08 tb_rom.vhd
	$(GHDL) -e -fsynopsys --std=08 TB_ROM
	$(GHDL) -r TB_ROM $(FLAGS) --vcd=tb_rom.vcd

counter:
	$(GHDL) -a clock.vhd
	$(GHDL) -a counter.vhd
	$(GHDL) -a tb_counter.vhd
	$(GHDL) -e TB_Counter
	$(GHDL) -r TB_Counter $(FLAGS) --vcd=tb_counter.vcd

regfile:
	$(GHDL) -a clock.vhd
	$(GHDL) -a regfile.vhd
	$(GHDL) -a tb_regfile.vhd
	$(GHDL) -e TB_RegFile
	$(GHDL) -r TB_RegFile $(FLAGS) --vcd=tb_regfile.vcd

ram:
	$(GHDL) -a clock.vhd
	$(GHDL) -a ram.vhd
	$(GHDL) -a tb_ram.vhd
	$(GHDL) -e TB_RAM
	$(GHDL) -r TB_RAM $(FLAGS) --vcd=tb_ram.vcd

mux:
	$(GHDL) -a clock.vhd
	$(GHDL) -a mux2x1.vhd
	$(GHDL) -a tb_mux.vhd
	$(GHDL) -e TB_Mux
	$(GHDL) -r TB_Mux $(FLAGS) --vcd=tb_mux.vcd

alu:
	$(GHDL) -a clock.vhd
	$(GHDL) -a -fsynopsys alu.vhd
	$(GHDL) -a -fsynopsys tb_alu.vhd
	$(GHDL) -e -fsynopsys TB_ALU
	$(GHDL) -r TB_ALU $(FLAGS) --vcd=tb_alu.vcd

aluctrl:
	$(GHDL) -a clock.vhd
	$(GHDL) -a -fsynopsys aluctrl.vhd
	$(GHDL) -a -fsynopsys tb_aluctrl.vhd
	$(GHDL) -e -fsynopsys TB_ALUCtrl
	$(GHDL) -r TB_ALUCtrl $(FLAGS) --vcd=tb_aluctrl.vcd

adder:
	$(GHDL) -a clock.vhd
	$(GHDL) -a -fsynopsys adder.vhd
	$(GHDL) -a -fsynopsys tb_adder.vhd
	$(GHDL) -e -fsynopsys TB_Adder
	$(GHDL) -r TB_Adder $(FLAGS) --vcd=tb_adder.vcd

immgen:
	$(GHDL) -a clock.vhd
	$(GHDL) -a -fsynopsys immgen.vhd
	$(GHDL) -a -fsynopsys tb_immgen.vhd
	$(GHDL) -e -fsynopsys TB_ImmGen
	$(GHDL) -r TB_ImmGen --stop-time=100ns --vcd=tb_immgen.vcd

clean:
	$(GHDL) --clean
	rm *.cf *.o
