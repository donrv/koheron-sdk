# Add PS and AXI Interconnect
set board_preset $board_path/config/board_preset.tcl
source $sdk_path/fpga/lib/starting_point.tcl

set adc_dac_extra_delay 2
source $board_path/adc_dac.tcl

# Add config and status registers
source $sdk_path/fpga/lib/ctl_sts.tcl
add_ctl_sts adc_dac/adc_clk rst_adc_clk/peripheral_aresetn

connect_cell adc_dac {
    adc0 [sts_pin adc0]
    adc1 [sts_pin adc1]
}

# Expansion connector IOs

for {set i 0} {$i < 8} {incr i} {
  create_bd_port -dir I exp_io_${i}_p
  create_bd_port -dir O exp_io_${i}_n
}

# Add BRAMs for ADC and DAC
# "adc" and "dac" BRAM ranges and offsets are defined in the "memory" part of config.yml
source $sdk_path/fpga/lib/bram.tcl
add_bram adc
add_bram dac

# Add a counter for BRAM addressing
cell koheron:user:address_counter:1.0 address_counter {
  COUNT_WIDTH [get_memory_addr_width adc]
} {
  clken [get_constant_pin 1 1]
  clk adc_dac/adc_clk
  trig [get_slice_pin [ctl_pin trig] 0 0]
}

connect_cell blk_mem_gen_adc {
  addrb address_counter/address
  clkb adc_dac/adc_clk
  dinb [get_concat_pin [list adc_dac/adc0 adc_dac/adc1]]
  enb [get_constant_pin 1 1]
  rstb [get_constant_pin 0 1]
  web address_counter/wen
}

connect_cell blk_mem_gen_dac {
  addrb address_counter/address
  clkb adc_dac/adc_clk
  enb [get_constant_pin 1 1]
  rstb [get_constant_pin 0 1]
  web [get_constant_pin 0 4]
}

connect_pins adc_dac/dac0 [get_slice_pin blk_mem_gen_dac/doutb 15 0]
connect_pins adc_dac/dac1 [get_slice_pin blk_mem_gen_dac/doutb 31 16]