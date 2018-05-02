# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "MAC" -parent ${Page_0}
  set FIFO_DEPTH [ipgui::add_param $IPINST -name "FIFO_DEPTH" -parent ${Page_0} -widget comboBox]
  set_property tooltip {Number of 64 byte words to buffer} ${FIFO_DEPTH}
  set FILTER [ipgui::add_param $IPINST -name "FILTER" -parent ${Page_0} -widget comboBox]
  set_property tooltip {Enable incoming packet filtering} ${FILTER}


}

proc update_PARAM_VALUE.FIFO_DEPTH { PARAM_VALUE.FIFO_DEPTH } {
	# Procedure called to update FIFO_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FIFO_DEPTH { PARAM_VALUE.FIFO_DEPTH } {
	# Procedure called to validate FIFO_DEPTH
	return true
}

proc update_PARAM_VALUE.FILTER { PARAM_VALUE.FILTER } {
	# Procedure called to update FILTER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FILTER { PARAM_VALUE.FILTER } {
	# Procedure called to validate FILTER
	return true
}

proc update_PARAM_VALUE.MAC { PARAM_VALUE.MAC } {
	# Procedure called to update MAC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAC { PARAM_VALUE.MAC } {
	# Procedure called to validate MAC
	return true
}

proc update_PARAM_VALUE.M_TDATA_WIDTH { PARAM_VALUE.M_TDATA_WIDTH } {
	# Procedure called to update M_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_TDATA_WIDTH { PARAM_VALUE.M_TDATA_WIDTH } {
	# Procedure called to validate M_TDATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.M_TDATA_WIDTH { MODELPARAM_VALUE.M_TDATA_WIDTH PARAM_VALUE.M_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_TDATA_WIDTH}] ${MODELPARAM_VALUE.M_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.FIFO_DEPTH { MODELPARAM_VALUE.FIFO_DEPTH PARAM_VALUE.FIFO_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FIFO_DEPTH}] ${MODELPARAM_VALUE.FIFO_DEPTH}
}

proc update_MODELPARAM_VALUE.FILTER { MODELPARAM_VALUE.FILTER PARAM_VALUE.FILTER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FILTER}] ${MODELPARAM_VALUE.FILTER}
}

proc update_MODELPARAM_VALUE.MAC { MODELPARAM_VALUE.MAC PARAM_VALUE.MAC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAC}] ${MODELPARAM_VALUE.MAC}
}

