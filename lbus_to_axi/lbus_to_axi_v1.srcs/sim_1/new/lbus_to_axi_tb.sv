`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/11/2017 03:35:12 PM
// Design Name: 
// Module Name: lbus_to_axi_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lbus_to_axi_tb(

    );

	localparam M_TDATA_WIDTH = 16;

	//clocking and reset
    reg sys_clk;
    reg sys_resetn;
    reg rx_clk;
    reg rx_resetn;

	reg [127:0] rx_datain0;
    reg rx_enain0;
    reg rx_sopin0;
    reg rx_eopin0;
    reg rx_errin0;
    reg [3:0] rx_mtyin0;

    reg [127:0] rx_datain1;
    reg rx_enain1;
    reg rx_sopin1;
    reg rx_eopin1;
    reg rx_errin1;
    reg [3:0] rx_mtyin1;

    reg [127:0] rx_datain2;
    reg rx_enain2;
    reg rx_sopin2;
    reg rx_eopin2;
    reg rx_errin2;
    reg [3:0] rx_mtyin2;

    reg [127:0] rx_datain3;
    reg rx_enain3;
    reg rx_sopin3;
    reg rx_eopin3;
    reg rx_errin3;
    reg [3:0] rx_mtyin3;

    //AXI4-Stream input interfaces - need to manually keep consistent with MAX_AXIS_INTERFACES
    wire s_axis_tvalid;
    reg s_axis_tready;
    wire [(M_TDATA_WIDTH*8)-1:0] s_axis_tdata;
    wire [M_TDATA_WIDTH-1:0] s_axis_tkeep;
    wire s_axis_tlast;
    
    wire [31:0] overflow_counter;
    wire [47:0] dbg_mac_addr;
    wire [47:0] dbg_assign_MAC;
    wire [127:0] dbg_data;
    wire dbg_fifo_valid;
    wire dbg_data_valid;
    wire dbg_fifo_override;
    wire dbg_validPacket_valid;
    wire dbg_valid_data;
    
    reg [7:0] counter;

    initial begin
    	sys_clk = 1'b1;
		sys_resetn = 1'b0;
    	rx_clk = 1'b1;
    	rx_resetn = 1'b0;

    	rx_datain0 = '0;
	    rx_enain0 = '0;
	    rx_sopin0 = '0;
	    rx_eopin0 = '0;
	    rx_errin0 = '0;
	    rx_mtyin0 = '0;

	    rx_datain1 = '0;
	    rx_enain1 = '0;
	    rx_sopin1 = '0;
	    rx_eopin1 = '0;
	    rx_errin1 = '0;
	    rx_mtyin1 = '0;

	    rx_datain2 = '0;
	    rx_enain2 = '0;
	    rx_sopin2 = '0;
	    rx_eopin2 = '0;
	    rx_errin2 = '0;
	    rx_mtyin2 = '0;

	    rx_datain3 = '0;
	    rx_enain3 = '0;
	    rx_sopin3 = '0;
	    rx_eopin3 = '0;
	    rx_errin3 = '0;
	    rx_mtyin3 = '0;
	    
	    counter = '0;

	    s_axis_tready = 1'b1;
    end

    always #5 rx_clk = ~rx_clk;
    always #10 sys_clk = ~sys_clk;

    initial begin
    	#49 sys_resetn = 1'b1;
    		rx_resetn = 1'b1;
		#440 rx_resetn = 1'b1; //dummy
		
		repeat (64) begin
        //#440 rx_resetn = 1'b1; //dummy
		rx_datain0 = 128'hAABBCCDDEEFFA7A8B1B2B3B4B5B6B700 + counter;
		rx_enain0 = 1'b1;
		rx_sopin0 = 1'b1;
		rx_mtyin0 = 4'h0;

		rx_datain1 = 128'hCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDD;
		rx_enain1 = 1'b1;

		rx_datain2 = 128'hEEEEEEEEEEEEEEEEFFFFFFFFFFFFFFFF;
		rx_enain2 = 1'b1;

		rx_datain3 = 128'h11111111111111112222222222222222;
		rx_enain3 = 1'b1;
		rx_mtyin3 = 4'h0;
		rx_eopin3 = 1'b0;
		
		repeat (2) begin

		    #10 

            rx_datain0 = 128'hAAAAAAAAAAAAAAA8BBBBBBBBBBBBBBBB;
            rx_enain0 = 1'b1;
            rx_sopin0 = 1'b0;
    
            rx_datain1 = 128'hCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDD;
            rx_enain1 = 1'b1;
            rx_eopin1 = 1'b0;
    
            rx_datain2 = 128'hEEEEEEEEEEEEEEEEFFFFFFFFFFFFFFFF;
            rx_enain2 = 1'b1;
            rx_sopin2 = 1'b0;
            rx_eopin2 = 1'b0;
    
            rx_datain3 = 128'h11111111111111112222222222222222;
            rx_enain3 = 1'b1;
            rx_mtyin3 = 4'h0;
            rx_sopin3 = 1'b0;
            rx_eopin3 = 1'b0;
            
        end

		#10 

		rx_datain0 = 128'hAAAAAAAAAAAAAAA8BBBBBBBBBBBBBBBB;
		rx_enain0 = 1'b1;
		rx_sopin0 = 1'b0;
		rx_eopin0 = 1'b0;

		rx_datain1 = 128'hAABBCCDDEEFFA7A8BBBBBBBBBBBBBBBB;
		rx_enain1 = 1'b1;
		rx_sopin1 = 1'b0;
		rx_eopin1 = 1'b0;

		rx_datain2 = 128'hEEEEEEEEEEEEEEEEFFFFFFFFFFFFFFFF;
		rx_enain2 = 1'b1;
		rx_eopin2 = 1'b0;

		rx_datain3 = 128'h11111111111111112222222222222222;
		rx_enain3 = 1'b1;
		rx_mtyin3 = 4'h0;
		rx_sopin3 = 1'b0;
		rx_eopin3 = 1'b1;
		
		counter = counter + 1;
		
		#10 

		rx_datain0 = 128'hCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDD;
		rx_enain0 = 1'b1;
		rx_sopin0 = 1'b1;
		rx_eopin0 = 1'b0;

		rx_datain1 = 128'hCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDD;
		rx_enain1 = 1'b1;
		rx_sopin1 = 1'b0;
		rx_eopin1 = 1'b0;

		rx_datain2 = 128'hEEEEEEEEEEEEEEEEFFFFFFFFFFFFFFFF;
		rx_enain2 = 1'b1;
		rx_eopin2 = 1'b0;

		rx_datain3 = 128'h11111111111111112222222222222222;
		rx_enain3 = 1'b1;
		rx_mtyin3 = 4'h0;
		rx_sopin3 = 1'b0;
		rx_eopin3 = 1'b1;

		#10 rx_datain0 = '0;
			rx_enain0 = 1'b0;
			rx_sopin0 = 1'b0;
			rx_eopin0 = 1'b0;

			rx_datain1 = '0;
			rx_enain1 = 1'b0;
			rx_sopin1 = 1'b0;
			rx_eopin1 = 1'b0;

			rx_datain2 = '0;
			rx_enain2 = 1'b0;
			rx_sopin2 = 1'b0;
			rx_eopin2 = 1'b0;

			rx_datain3 = '0;
			rx_enain3 = 1'b0;
			rx_sopin3 = 1'b0;
			rx_eopin3 = 1'b0;
			rx_mtyin3 = '0;
        end
	end


    lbus_to_axi #(
    	.M_TDATA_WIDTH(M_TDATA_WIDTH),
    	.FIFO_DEPTH(32),
    	.SYNC_STAGES(2),
    	.REGISTERED(0),
    	.FILTER(2)
	) lbus_to_axi_0 (.*);

endmodule
