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

clean:
	$(GHDL) --clean
	rm *.cf *.o
