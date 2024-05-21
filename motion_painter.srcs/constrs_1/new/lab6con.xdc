set_property PACKAGE_PIN W5 [get_ports clk_100MHz]
set_property IOSTANDARD LVCMOS33 [get_ports clk_100MHz]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk_100MHz]
##Buttons
set_property PACKAGE_PIN U18 [get_ports reset]						
	set_property IOSTANDARD LVCMOS33 [get_ports reset]

set_property PACKAGE_PIN V17 [get_ports {colour[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {colour[0]}]
set_property PACKAGE_PIN V16 [get_ports {colour[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {colour[1]}]
set_property PACKAGE_PIN W16 [get_ports {colour[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {colour[2]}]
   
set_property PACKAGE_PIN W17 [get_ports {send_configuration}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {send_configuration}]

set_property PACKAGE_PIN U1 [get_ports {threshold[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {threshold[0]}]
set_property PACKAGE_PIN T1 [get_ports {threshold[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {threshold[1]}]
set_property PACKAGE_PIN R2 [get_ports {threshold[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {threshold[2]}]
	
set_property PACKAGE_PIN T2 [get_ports {negthreshold[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {negthreshold[0]}]
set_property PACKAGE_PIN R3 [get_ports {negthreshold[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {negthreshold[1]}]
set_property PACKAGE_PIN W2 [get_ports {negthreshold[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {negthreshold[2]}]

##Pmod Header JA
##Sch name = JA1
set_property PACKAGE_PIN J1 [get_ports {sda}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sda}]
##Sch name = JA2
set_property PACKAGE_PIN L2 [get_ports {scl}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {scl}]

#Pmod Header JB
#Sch name = JB1
set_property PACKAGE_PIN A14 [get_ports {data[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[0]}]
#Sch name = JB2
set_property PACKAGE_PIN A16 [get_ports {data[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[1]}]
#Sch name = JB3
set_property PACKAGE_PIN B15 [get_ports {data[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[2]}]
#Sch name = JB4
set_property PACKAGE_PIN B16 [get_ports {data[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[3]}]
#Sch name = JB7
set_property PACKAGE_PIN A15 [get_ports {data[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[4]}]
#Sch name = JB8
set_property PACKAGE_PIN A17 [get_ports {data[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[5]}]
#Sch name = JB9
set_property PACKAGE_PIN C15 [get_ports {data[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[6]}]
#Sch name = JB10
set_property PACKAGE_PIN C16 [get_ports {data[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[7]}]




##Pmod Header JC

##Sch name = JC2
set_property PACKAGE_PIN M18 [get_ports vsynccam]
set_property IOSTANDARD LVCMOS33 [get_ports vsynccam]
##Sch name = JC3
set_property PACKAGE_PIN N17 [get_ports pclk]
set_property IOSTANDARD LVCMOS33 [get_ports pclk]
create_clock -period 42.000 -name pclk_pin -waveform {0.000 5.000} -add [get_ports pclk]

##Sch name = JC4
set_property PACKAGE_PIN P18 [get_ports href]
set_property IOSTANDARD LVCMOS33 [get_ports href]
##Sch name = JC7
set_property PACKAGE_PIN L17 [get_ports xclk]
set_property IOSTANDARD LVCMOS33 [get_ports xclk]


##VGA Connector
set_property PACKAGE_PIN G19 [get_ports {vgaRed[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[0]}]
set_property PACKAGE_PIN H19 [get_ports {vgaRed[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[1]}]
set_property PACKAGE_PIN J19 [get_ports {vgaRed[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[2]}]
set_property PACKAGE_PIN N19 [get_ports {vgaRed[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[3]}]
set_property PACKAGE_PIN N18 [get_ports {vgaBlue[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[0]}]
set_property PACKAGE_PIN L18 [get_ports {vgaBlue[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[1]}]
set_property PACKAGE_PIN K18 [get_ports {vgaBlue[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[2]}]
set_property PACKAGE_PIN J18 [get_ports {vgaBlue[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[3]}]
set_property PACKAGE_PIN J17 [get_ports {vgaGreen[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[0]}]
set_property PACKAGE_PIN H17 [get_ports {vgaGreen[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[1]}]
set_property PACKAGE_PIN G17 [get_ports {vgaGreen[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[2]}]
set_property PACKAGE_PIN D17 [get_ports {vgaGreen[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[3]}]
set_property PACKAGE_PIN P19 [get_ports horizontal_sync]
set_property IOSTANDARD LVCMOS33 [get_ports horizontal_sync]
set_property PACKAGE_PIN R19 [get_ports vertical_sync]
set_property IOSTANDARD LVCMOS33 [get_ports vertical_sync]

set_input_delay -clock [get_clocks pclk_pin] -clock_fall -min -add_delay 0.000 [get_ports {data[*]}]
set_input_delay -clock [get_clocks pclk_pin] -clock_fall -max -add_delay 6.000 [get_ports {data[*]}]
set_input_delay -clock [get_clocks pclk_pin] -clock_fall -min -add_delay 0.000 [get_ports href]
set_input_delay -clock [get_clocks pclk_pin] -clock_fall -max -add_delay 6.000 [get_ports href]
set_input_delay -clock [get_clocks pclk_pin] -clock_fall -min -add_delay 0.000 [get_ports vsynccam]
set_input_delay -clock [get_clocks pclk_pin] -clock_fall -max -add_delay 6.000 [get_ports vsynccam]

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
