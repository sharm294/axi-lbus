# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set AXIS_INTERFACES [ipgui::add_param $IPINST -name "AXIS_INTERFACES" -parent ${Page_0}]
  set_property tooltip {Number of AXIS Interfaces} ${AXIS_INTERFACES}


}

proc update_PARAM_VALUE.AXIS_INTERFACES { PARAM_VALUE.AXIS_INTERFACES } {
	# Procedure called to update AXIS_INTERFACES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXIS_INTERFACES { PARAM_VALUE.AXIS_INTERFACES } {
	# Procedure called to validate AXIS_INTERFACES
	return true
}

proc update_PARAM_VALUE.FIFO_DEPTH { PARAM_VALUE.FIFO_DEPTH } {
	# Procedure called to update FIFO_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FIFO_DEPTH { PARAM_VALUE.FIFO_DEPTH } {
	# Procedure called to validate FIFO_DEPTH
	return true
}

proc update_PARAM_VALUE.SYNC_STAGES { PARAM_VALUE.SYNC_STAGES } {
	# Procedure called to update SYNC_STAGES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SYNC_STAGES { PARAM_VALUE.SYNC_STAGES } {
	# Procedure called to validate SYNC_STAGES
	return true
}

proc update_PARAM_VALUE.S_TDATA_WIDTH { PARAM_VALUE.S_TDATA_WIDTH } {
	# Procedure called to update S_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_TDATA_WIDTH { PARAM_VALUE.S_TDATA_WIDTH } {
	# Procedure called to validate S_TDATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.S_TDATA_WIDTH { MODELPARAM_VALUE.S_TDATA_WIDTH PARAM_VALUE.S_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_TDATA_WIDTH}] ${MODELPARAM_VALUE.S_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.FIFO_DEPTH { MODELPARAM_VALUE.FIFO_DEPTH PARAM_VALUE.FIFO_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FIFO_DEPTH}] ${MODELPARAM_VALUE.FIFO_DEPTH}
}

proc update_MODELPARAM_VALUE.SYNC_STAGES { MODELPARAM_VALUE.SYNC_STAGES PARAM_VALUE.SYNC_STAGES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SYNC_STAGES}] ${MODELPARAM_VALUE.SYNC_STAGES}
}

proc update_MODELPARAM_VALUE.AXIS_INTERFACES { MODELPARAM_VALUE.AXIS_INTERFACES PARAM_VALUE.AXIS_INTERFACES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIS_INTERFACES}] ${MODELPARAM_VALUE.AXIS_INTERFACES}
}

