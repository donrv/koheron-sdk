# Add PS and AXI Interconnect
set board_preset $board_path/config/board_preset.tcl
source $sdk_path/fpga/lib/starting_point.tcl

source $board_path/adc_dac.tcl

# Add config and status registers
source $sdk_path/fpga/lib/ctl_sts.tcl
add_ctl_sts adc_dac/adc_clk rst_adc_clk/peripheral_aresetn

# Expansion connector IOs

for {set i 0} {$i < 8} {incr i} {
  create_bd_port -dir I exp_io_${i}_p
  create_bd_port -dir O exp_io_${i}_n
}

# Loopback

#connect_pins adc_dac/adc0 adc_dac/dac0
#connect_pins adc_dac/adc1 adc_dac/dac1
