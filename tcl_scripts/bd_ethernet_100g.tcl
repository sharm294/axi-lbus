
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2017.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcvu095-ffvc1517-2-e
}


# CHANGE DESIGN NAME HERE
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set gt_ref_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 gt_ref_clk ]
  set_property -dict [ list \
CONFIG.FREQ_HZ {161132812} \
 ] $gt_ref_clk
  set gt_rx [ create_bd_intf_port -mode Slave -vlnv xilinx.com:display_cmac:gt_ports:2.0 gt_rx ]
  set gt_tx [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_cmac:gt_ports:2.0 gt_tx ]
  set m_axis [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis ]
  set s_axis [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis ]
  set_property -dict [ list \
CONFIG.HAS_TKEEP {1} \
CONFIG.HAS_TLAST {1} \
CONFIG.HAS_TREADY {1} \
CONFIG.HAS_TSTRB {0} \
CONFIG.LAYERED_METADATA {undef} \
CONFIG.TDATA_NUM_BYTES {8} \
CONFIG.TDEST_WIDTH {0} \
CONFIG.TID_WIDTH {0} \
CONFIG.TUSER_WIDTH {0} \
 ] $s_axis

  # Create ports
  set init_clk [ create_bd_port -dir I -type clk init_clk ]
  set sys_clk [ create_bd_port -dir I -type clk sys_clk ]
  set_property -dict [ list \
CONFIG.ASSOCIATED_BUSIF {m_axis:s_axis} \
 ] $sys_clk
  set sys_resetn [ create_bd_port -dir I -type rst sys_resetn ]

  # Create instance: axi_to_lbus_0, and set properties
  set axi_to_lbus_0 [ create_bd_cell -type ip -vlnv varun.org:varun:axi_to_lbus:1.0 axi_to_lbus_0 ]
  set_property -dict [ list \
CONFIG.FIFO_DEPTH {16} \
 ] $axi_to_lbus_0

  # Create instance: cmac_0, and set properties
  set cmac_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cmac:2.2 cmac_0 ]
  set_property -dict [ list \
CONFIG.CMAC_CAUI4_MODE {1} \
CONFIG.CMAC_CORE_SELECT {CMAC_SITE_X0Y1} \
CONFIG.ENABLE_AXI_INTERFACE {0} \
CONFIG.GT_GROUP_SELECT {X0Y16~X0Y19} \
CONFIG.GT_REF_CLK_FREQ {161.1328125} \
CONFIG.INCLUDE_AUTO_NEG_LT_LOGIC {0} \
CONFIG.LANE10_GT_LOC {NA} \
CONFIG.LANE1_GT_LOC {X0Y16} \
CONFIG.LANE2_GT_LOC {X0Y17} \
CONFIG.LANE3_GT_LOC {X0Y18} \
CONFIG.LANE4_GT_LOC {X0Y19} \
CONFIG.LANE5_GT_LOC {NA} \
CONFIG.LANE6_GT_LOC {NA} \
CONFIG.LANE7_GT_LOC {NA} \
CONFIG.LANE8_GT_LOC {NA} \
CONFIG.LANE9_GT_LOC {NA} \
CONFIG.NUM_LANES {4} \
CONFIG.RX_EQ_MODE {AUTO} \
CONFIG.RX_FLOW_CONTROL {0} \
CONFIG.TX_FLOW_CONTROL {0} \
 ] $cmac_0

  # Create instance: cmac_bringup_0, and set properties
  set cmac_bringup_0 [ create_bd_cell -type ip -vlnv varun.org:varun:cmac_bringup:1.0 cmac_bringup_0 ]

  # Create instance: const_12h000_0, and set properties
  set const_12h000_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_12h000_0 ]
  set_property -dict [ list \
CONFIG.CONST_VAL {0} \
CONFIG.CONST_WIDTH {12} \
 ] $const_12h000_0

  # Create instance: const_1b0_0, and set properties
  set const_1b0_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_1b0_0 ]
  set_property -dict [ list \
CONFIG.CONST_VAL {0} \
 ] $const_1b0_0

  # Create instance: lbus_to_axi_0, and set properties
  set lbus_to_axi_0 [ create_bd_cell -type ip -vlnv varun.org:varun:lbus_to_axi:1.0 lbus_to_axi_0 ]

  # Create instance: not_rxAligned_0, and set properties
  set not_rxAligned_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 not_rxAligned_0 ]
  set_property -dict [ list \
CONFIG.C_OPERATION {not} \
CONFIG.C_SIZE {1} \
CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $not_rxAligned_0

  # Create instance: not_rxReset_0, and set properties
  set not_rxReset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 not_rxReset_0 ]
  set_property -dict [ list \
CONFIG.C_OPERATION {not} \
CONFIG.C_SIZE {1} \
CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $not_rxReset_0

  # Create instance: not_sysResetn_0, and set properties
  set not_sysResetn_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 not_sysResetn_0 ]
  set_property -dict [ list \
CONFIG.C_OPERATION {not} \
CONFIG.C_SIZE {1} \
CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $not_sysResetn_0

  # Create instance: not_txReset_0, and set properties
  set not_txReset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 not_txReset_0 ]
  set_property -dict [ list \
CONFIG.C_OPERATION {not} \
CONFIG.C_SIZE {1} \
CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $not_txReset_0

  # Create interface connections
  connect_bd_intf_net -intf_net cmac_0_gt_tx [get_bd_intf_ports gt_tx] [get_bd_intf_pins cmac_0/gt_tx]
  connect_bd_intf_net -intf_net gt_ref_clk_1 [get_bd_intf_ports gt_ref_clk] [get_bd_intf_pins cmac_0/gt_ref_clk]
  connect_bd_intf_net -intf_net gt_rx_1 [get_bd_intf_ports gt_rx] [get_bd_intf_pins cmac_0/gt_rx]
  connect_bd_intf_net -intf_net lbus_to_axi_0_s_axis [get_bd_intf_ports m_axis] [get_bd_intf_pins lbus_to_axi_0/m_axis]
  connect_bd_intf_net -intf_net s_axis_0_1 [get_bd_intf_ports s_axis] [get_bd_intf_pins axi_to_lbus_0/s_axis_0]

  # Create port connections
  connect_bd_net -net axi_to_lbus_0_mtyin0 [get_bd_pins axi_to_lbus_0/tx_mtyin0] [get_bd_pins cmac_0/tx_mtyin0]
  connect_bd_net -net axi_to_lbus_0_mtyin1 [get_bd_pins axi_to_lbus_0/tx_mtyin1] [get_bd_pins cmac_0/tx_mtyin1]
  connect_bd_net -net axi_to_lbus_0_mtyin2 [get_bd_pins axi_to_lbus_0/tx_mtyin2] [get_bd_pins cmac_0/tx_mtyin2]
  connect_bd_net -net axi_to_lbus_0_mtyin3 [get_bd_pins axi_to_lbus_0/tx_mtyin3] [get_bd_pins cmac_0/tx_mtyin3]
  connect_bd_net -net axi_to_lbus_0_tx_datain0 [get_bd_pins axi_to_lbus_0/tx_datain0] [get_bd_pins cmac_0/tx_datain0]
  connect_bd_net -net axi_to_lbus_0_tx_datain1 [get_bd_pins axi_to_lbus_0/tx_datain1] [get_bd_pins cmac_0/tx_datain1]
  connect_bd_net -net axi_to_lbus_0_tx_datain2 [get_bd_pins axi_to_lbus_0/tx_datain2] [get_bd_pins cmac_0/tx_datain2]
  connect_bd_net -net axi_to_lbus_0_tx_datain3 [get_bd_pins axi_to_lbus_0/tx_datain3] [get_bd_pins cmac_0/tx_datain3]
  connect_bd_net -net axi_to_lbus_0_tx_enain0 [get_bd_pins axi_to_lbus_0/tx_enain0] [get_bd_pins cmac_0/tx_enain0]
  connect_bd_net -net axi_to_lbus_0_tx_enain1 [get_bd_pins axi_to_lbus_0/tx_enain1] [get_bd_pins cmac_0/tx_enain1]
  connect_bd_net -net axi_to_lbus_0_tx_enain2 [get_bd_pins axi_to_lbus_0/tx_enain2] [get_bd_pins cmac_0/tx_enain2]
  connect_bd_net -net axi_to_lbus_0_tx_enain3 [get_bd_pins axi_to_lbus_0/tx_enain3] [get_bd_pins cmac_0/tx_enain3]
  connect_bd_net -net axi_to_lbus_0_tx_eopin0 [get_bd_pins axi_to_lbus_0/tx_eopin0] [get_bd_pins cmac_0/tx_eopin0]
  connect_bd_net -net axi_to_lbus_0_tx_eopin1 [get_bd_pins axi_to_lbus_0/tx_eopin1] [get_bd_pins cmac_0/tx_eopin1]
  connect_bd_net -net axi_to_lbus_0_tx_eopin2 [get_bd_pins axi_to_lbus_0/tx_eopin2] [get_bd_pins cmac_0/tx_eopin2]
  connect_bd_net -net axi_to_lbus_0_tx_eopin3 [get_bd_pins axi_to_lbus_0/tx_eopin3] [get_bd_pins cmac_0/tx_eopin3]
  connect_bd_net -net axi_to_lbus_0_tx_errin0 [get_bd_pins axi_to_lbus_0/tx_errin0] [get_bd_pins cmac_0/tx_errin0]
  connect_bd_net -net axi_to_lbus_0_tx_errin1 [get_bd_pins axi_to_lbus_0/tx_errin1] [get_bd_pins cmac_0/tx_errin1]
  connect_bd_net -net axi_to_lbus_0_tx_errin2 [get_bd_pins axi_to_lbus_0/tx_errin2] [get_bd_pins cmac_0/tx_errin2]
  connect_bd_net -net axi_to_lbus_0_tx_errin3 [get_bd_pins axi_to_lbus_0/tx_errin3] [get_bd_pins cmac_0/tx_errin3]
  connect_bd_net -net axi_to_lbus_0_tx_sopin0 [get_bd_pins axi_to_lbus_0/tx_sopin0] [get_bd_pins cmac_0/tx_sopin0]
  connect_bd_net -net axi_to_lbus_0_tx_sopin1 [get_bd_pins axi_to_lbus_0/tx_sopin1] [get_bd_pins cmac_0/tx_sopin1]
  connect_bd_net -net axi_to_lbus_0_tx_sopin2 [get_bd_pins axi_to_lbus_0/tx_sopin2] [get_bd_pins cmac_0/tx_sopin2]
  connect_bd_net -net axi_to_lbus_0_tx_sopin3 [get_bd_pins axi_to_lbus_0/tx_sopin3] [get_bd_pins cmac_0/tx_sopin3]
  connect_bd_net -net cmac_0_gt_txusrclk2 [get_bd_pins axi_to_lbus_0/tx_clk] [get_bd_pins cmac_0/gt_txusrclk2] [get_bd_pins cmac_0/rx_clk] [get_bd_pins lbus_to_axi_0/rx_clk]
  connect_bd_net -net cmac_0_rx_dataout0 [get_bd_pins cmac_0/rx_dataout0] [get_bd_pins lbus_to_axi_0/rx_datain0]
  connect_bd_net -net cmac_0_rx_dataout1 [get_bd_pins cmac_0/rx_dataout1] [get_bd_pins lbus_to_axi_0/rx_datain1]
  connect_bd_net -net cmac_0_rx_dataout2 [get_bd_pins cmac_0/rx_dataout2] [get_bd_pins lbus_to_axi_0/rx_datain2]
  connect_bd_net -net cmac_0_rx_dataout3 [get_bd_pins cmac_0/rx_dataout3] [get_bd_pins lbus_to_axi_0/rx_datain3]
  connect_bd_net -net cmac_0_rx_enaout0 [get_bd_pins cmac_0/rx_enaout0] [get_bd_pins lbus_to_axi_0/rx_enain0]
  connect_bd_net -net cmac_0_rx_enaout1 [get_bd_pins cmac_0/rx_enaout1] [get_bd_pins lbus_to_axi_0/rx_enain1]
  connect_bd_net -net cmac_0_rx_enaout2 [get_bd_pins cmac_0/rx_enaout2] [get_bd_pins lbus_to_axi_0/rx_enain2]
  connect_bd_net -net cmac_0_rx_enaout3 [get_bd_pins cmac_0/rx_enaout3] [get_bd_pins lbus_to_axi_0/rx_enain3]
  connect_bd_net -net cmac_0_rx_eopout0 [get_bd_pins cmac_0/rx_eopout0] [get_bd_pins lbus_to_axi_0/rx_eopin0]
  connect_bd_net -net cmac_0_rx_eopout1 [get_bd_pins cmac_0/rx_eopout1] [get_bd_pins lbus_to_axi_0/rx_eopin1]
  connect_bd_net -net cmac_0_rx_eopout2 [get_bd_pins cmac_0/rx_eopout2] [get_bd_pins lbus_to_axi_0/rx_eopin2]
  connect_bd_net -net cmac_0_rx_eopout3 [get_bd_pins cmac_0/rx_eopout3] [get_bd_pins lbus_to_axi_0/rx_eopin3]
  connect_bd_net -net cmac_0_rx_errout0 [get_bd_pins cmac_0/rx_errout0] [get_bd_pins lbus_to_axi_0/rx_errin0]
  connect_bd_net -net cmac_0_rx_errout1 [get_bd_pins cmac_0/rx_errout1] [get_bd_pins lbus_to_axi_0/rx_errin1]
  connect_bd_net -net cmac_0_rx_errout2 [get_bd_pins cmac_0/rx_errout2] [get_bd_pins lbus_to_axi_0/rx_errin2]
  connect_bd_net -net cmac_0_rx_errout3 [get_bd_pins cmac_0/rx_errout3] [get_bd_pins lbus_to_axi_0/rx_errin3]
  connect_bd_net -net cmac_0_rx_mtyout0 [get_bd_pins cmac_0/rx_mtyout0] [get_bd_pins lbus_to_axi_0/rx_mtyin0]
  connect_bd_net -net cmac_0_rx_mtyout1 [get_bd_pins cmac_0/rx_mtyout1] [get_bd_pins lbus_to_axi_0/rx_mtyin1]
  connect_bd_net -net cmac_0_rx_mtyout2 [get_bd_pins cmac_0/rx_mtyout2] [get_bd_pins lbus_to_axi_0/rx_mtyin2]
  connect_bd_net -net cmac_0_rx_mtyout3 [get_bd_pins cmac_0/rx_mtyout3] [get_bd_pins lbus_to_axi_0/rx_mtyin3]
  connect_bd_net -net cmac_0_rx_sopout0 [get_bd_pins cmac_0/rx_sopout0] [get_bd_pins lbus_to_axi_0/rx_sopin0]
  connect_bd_net -net cmac_0_rx_sopout1 [get_bd_pins cmac_0/rx_sopout1] [get_bd_pins lbus_to_axi_0/rx_sopin1]
  connect_bd_net -net cmac_0_rx_sopout2 [get_bd_pins cmac_0/rx_sopout2] [get_bd_pins lbus_to_axi_0/rx_sopin2]
  connect_bd_net -net cmac_0_rx_sopout3 [get_bd_pins cmac_0/rx_sopout3] [get_bd_pins lbus_to_axi_0/rx_sopin3]
  connect_bd_net -net cmac_0_stat_rx_aligned [get_bd_pins cmac_0/stat_rx_aligned] [get_bd_pins cmac_bringup_0/stat_rx_aligned] [get_bd_pins not_rxAligned_0/Op1]
  connect_bd_net -net cmac_0_stat_rx_remote_fault [get_bd_pins cmac_0/stat_rx_remote_fault] [get_bd_pins cmac_bringup_0/stat_rx_remote_fault]
  connect_bd_net -net cmac_0_tx_ovfout [get_bd_pins axi_to_lbus_0/tx_ovfout] [get_bd_pins cmac_0/tx_ovfout]
  connect_bd_net -net cmac_0_tx_rdyout [get_bd_pins axi_to_lbus_0/tx_rdyout] [get_bd_pins cmac_0/tx_rdyout]
  connect_bd_net -net cmac_0_tx_unfout [get_bd_pins axi_to_lbus_0/tx_unfout] [get_bd_pins cmac_0/tx_unfout]
  connect_bd_net -net cmac_0_usr_rx_reset [get_bd_pins cmac_0/usr_rx_reset] [get_bd_pins not_rxReset_0/Op1]
  connect_bd_net -net cmac_0_usr_tx_reset [get_bd_pins cmac_0/usr_tx_reset] [get_bd_pins not_txReset_0/Op1]
  connect_bd_net -net cmac_bringup_0_ctl_rx_enable [get_bd_pins cmac_0/ctl_rx_enable] [get_bd_pins cmac_bringup_0/ctl_rx_enable]
  connect_bd_net -net cmac_bringup_0_ctl_tx_enable [get_bd_pins cmac_0/ctl_tx_enable] [get_bd_pins cmac_bringup_0/ctl_tx_enable]
  connect_bd_net -net cmac_bringup_0_ctl_tx_send_idle [get_bd_pins cmac_0/ctl_tx_send_idle] [get_bd_pins cmac_bringup_0/ctl_tx_send_idle]
  connect_bd_net -net cmac_bringup_0_ctl_tx_send_rfi [get_bd_pins cmac_0/ctl_tx_send_rfi] [get_bd_pins cmac_bringup_0/ctl_tx_send_rfi]
  connect_bd_net -net init_clk_1 [get_bd_ports init_clk] [get_bd_pins cmac_0/init_clk] [get_bd_pins cmac_bringup_0/init_clk]
  connect_bd_net -net sys_clk_1 [get_bd_ports sys_clk] [get_bd_pins axi_to_lbus_0/sys_clk] [get_bd_pins lbus_to_axi_0/sys_clk]
  connect_bd_net -net sys_resetn_1 [get_bd_ports sys_resetn] [get_bd_pins axi_to_lbus_0/sys_resetn] [get_bd_pins lbus_to_axi_0/sys_resetn] [get_bd_pins not_sysResetn_0/Op1]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins lbus_to_axi_0/rx_resetn] [get_bd_pins not_rxReset_0/Res]
  connect_bd_net -net util_vector_logic_1_Res [get_bd_pins axi_to_lbus_0/tx_resetn] [get_bd_pins not_txReset_0/Res]
  connect_bd_net -net util_vector_logic_2_Res [get_bd_pins cmac_0/sys_reset] [get_bd_pins not_sysResetn_0/Res]
  connect_bd_net -net util_vector_logic_3_Res [get_bd_pins cmac_bringup_0/reset] [get_bd_pins not_rxAligned_0/Res]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins cmac_0/core_drp_reset] [get_bd_pins cmac_0/core_rx_reset] [get_bd_pins cmac_0/core_tx_reset] [get_bd_pins cmac_0/ctl_rx_force_resync] [get_bd_pins cmac_0/ctl_rx_test_pattern] [get_bd_pins cmac_0/ctl_tx_test_pattern] [get_bd_pins cmac_0/drp_clk] [get_bd_pins cmac_0/gtwiz_reset_rx_datapath] [get_bd_pins cmac_0/gtwiz_reset_tx_datapath] [get_bd_pins const_1b0_0/dout]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins cmac_0/gt_loopback_in] [get_bd_pins const_12h000_0/dout]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  regenerate_bd_layout
  group_bd_cells ethernet [get_bd_cells not_txReset_0] [get_bd_cells not_rxAligned_0] [get_bd_cells axi_to_lbus_0] [get_bd_cells cmac_bringup_0] [get_bd_cells not_sysResetn_0] [get_bd_cells const_12h000_0] [get_bd_cells const_1b0_0] [get_bd_cells cmac_0] [get_bd_cells not_rxReset_0] [get_bd_cells lbus_to_axi_0]

  regenerate_bd_layout
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


common::send_msg_id "BD_TCL-1000" "WARNING" "This Tcl script was generated from a block design that has not been validated. It is possible that design <$design_name> may result in errors during validation."

