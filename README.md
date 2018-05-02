# axi-lbus

This provides a protocol conversion between LBUS (used in the 100G ethernet subsystem) and AXI-S. On the transmit side, it supports up to eight AXI-S slave inputs which transmit in round-robin fashion. On the receive side, it has one AXI-S interface.

There are three IP blocks that are configurable: *axi_to_lbus*, *cmac*, and *lbus_to_axi*. The options for *axi_to_lbus* and *lbus_to_axi* are shown in tooltips. Refer to the 100G Ethernet Subsystem documentation from Xilinx for the *cmac* options.

## Usage

1. Clone the repository and add it as an IP repository in Vivado. 
2. Source the *ethernet.tcl* script in Vivado with an open block design. This will create a hiearchy for the ethernet subsystem, which allows you to configure the options for the individual IPs.

## Ports

### Input
* *gt_ref_clk* - the gt transceiver reference clock
* *gt_rx* - the gt transceiver serial rx connection
* *s_axis_\** - configurable number of slave AXI-S ports
* *core_reset* - active-high reset for the 100G subsystem
* *init_clk* - initialization clock for 100G subsystem (must be less than 250 MHz)
* *sys_clk* - clock for AXI-S transactions on the transmit and receive sides
* *sys_resetn* - active-low reset for AXI-S

### Output
* *gt_tx* - the gt transceiver serial tx connection
* *m_axis* - master AXI-S port
* *overflow_counter* - running counter of the number of dropped packets

## Warning

While it has been tested in simulation, I haven't fully tested in HW yet so there may be some bugs. I have some ideas on a v2 for this project that I will get to in a few months.
