`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/28/2017 09:51:24 AM
// Design Name: 
// Module Name: axi_to_lbus_tb
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


module axi_to_lbus_tb(

    );
    
    localparam S_TDATA_WIDTH = 16;
    localparam FIFO_DEPTH = 32;
    localparam SYNC_STAGES = 2;
    localparam AXIS_INTERFACES = 1;

	//clocking and reset
    reg sys_clk;
    reg sys_resetn;
    reg tx_clk;
    reg tx_resetn;

    //AXI4-Stream input interfaces - need to manually keep consistent with MAX_AXIS_INTERFACES
    reg s_axis_tvalid_0;
    wire s_axis_tready_0;
    reg [(S_TDATA_WIDTH*8)-1:0] s_axis_tdata_0;
    reg [S_TDATA_WIDTH-1:0] s_axis_tkeep_0;
    reg s_axis_tlast_0;

    reg s_axis_tvalid_1;
    wire s_axis_tready_1;
    reg [(S_TDATA_WIDTH*8)-1:0] s_axis_tdata_1;
    reg [S_TDATA_WIDTH-1:0] s_axis_tkeep_1;
    reg s_axis_tlast_1;

    reg s_axis_tvalid_2;
    wire s_axis_tready_2;
    reg [(S_TDATA_WIDTH*8)-1:0] s_axis_tdata_2;
    reg [S_TDATA_WIDTH-1:0] s_axis_tkeep_2;
    reg s_axis_tlast_2;

    reg s_axis_tvalid_3;
    wire s_axis_tready_3;
    reg [(S_TDATA_WIDTH*8)-1:0] s_axis_tdata_3;
    reg [S_TDATA_WIDTH-1:0] s_axis_tkeep_3;
    reg s_axis_tlast_3;

    reg s_axis_tvalid_4;
    wire s_axis_tready_4;
    reg [(S_TDATA_WIDTH*8)-1:0] s_axis_tdata_4;
    reg [S_TDATA_WIDTH-1:0] s_axis_tkeep_4;
    reg s_axis_tlast_4;

    reg s_axis_tvalid_5;
    wire s_axis_tready_5;
    reg [(S_TDATA_WIDTH*8)-1:0] s_axis_tdata_5;
    reg [S_TDATA_WIDTH-1:0] s_axis_tkeep_5;
    reg s_axis_tlast_5;

    reg s_axis_tvalid_6;
    wire s_axis_tready_6;
    reg [(S_TDATA_WIDTH*8)-1:0] s_axis_tdata_6;
    reg [S_TDATA_WIDTH-1:0] s_axis_tkeep_6;
    reg s_axis_tlast_6;

    reg s_axis_tvalid_7;
    wire s_axis_tready_7;
    reg [(S_TDATA_WIDTH*8)-1:0] s_axis_tdata_7;
    reg [S_TDATA_WIDTH-1:0] s_axis_tkeep_7;
    reg s_axis_tlast_7;

    //LBUS wire interface - need to manually keep consistent with localparams
    reg tx_rdyout;
    reg tx_ovfout;
    reg tx_unfout;

    wire [127:0] tx_datain0;
    wire tx_enain0;
    wire tx_sopin0;
    wire tx_eopin0;
    wire tx_errin0;
    wire [3:0] tx_mtyin0;

    wire [127:0] tx_datain1;
    wire tx_enain1;
    wire tx_sopin1;
    wire tx_eopin1;
    wire tx_errin1;
    wire [3:0] tx_mtyin1;

    wire [127:0] tx_datain2;
    wire tx_enain2;
    wire tx_sopin2;
    wire tx_eopin2;
    wire tx_errin2;
    wire [3:0] tx_mtyin2;

    wire [127:0] tx_datain3;
    wire tx_enain3;
    wire tx_sopin3;
    wire tx_eopin3;
    wire tx_errin3;
    wire [3:0] tx_mtyin3;

    initial begin
    	sys_clk = 1'b0;
		sys_resetn = 1'b0;
    	tx_clk = 1'b0;
    	tx_resetn = 1'b0;
    	
    	tx_rdyout = 1'b1;
    	tx_ovfout = 1'b0;
    	tx_unfout = 1'b0;

    	s_axis_tvalid_0 = 1'b0;
	    s_axis_tdata_0 = 512'h01234567_11234567_21234567_31234567_41234567_51234567_61234567_71234567_81234567_91234567_a1234567_b1234567_c1234567_d1234567_e1234567_f1234567;
	    s_axis_tkeep_0 = '1;
	    s_axis_tlast_0 = 1'b0;

	    s_axis_tvalid_1 = 1'b0;
	    s_axis_tdata_1 = '0;
	    s_axis_tkeep_1 = '1;
	    s_axis_tlast_1 = 1'b0;

	    s_axis_tvalid_2 = 1'b0;
	    s_axis_tdata_2 = '0;
	    s_axis_tkeep_2 = '1;
	    s_axis_tlast_2 = 1'b0;

	    s_axis_tvalid_3 = 1'b0;
	    s_axis_tdata_3 = '0;
	    s_axis_tkeep_3 = '1;
	    s_axis_tlast_3 = 1'b0;

	    s_axis_tvalid_4 = 1'b0;
	    s_axis_tdata_4 = '0;
	    s_axis_tkeep_4 = '1;
	    s_axis_tlast_4 = 1'b0;

	    s_axis_tvalid_5 = 1'b0;
	    s_axis_tdata_5 = '0;
	    s_axis_tkeep_5 = '1;
	    s_axis_tlast_5 = 1'b0;

	    s_axis_tvalid_6 = 1'b0;
	    s_axis_tdata_6 = '0;
	    s_axis_tkeep_6 = '1;
	    s_axis_tlast_6 = 1'b0;

	    s_axis_tvalid_7 = 1'b0;
	    s_axis_tdata_7 = '0;
	    s_axis_tkeep_7 = '1;
	    s_axis_tlast_7 = 1'b0;
    end

    always #5 tx_clk = ~tx_clk;
    always #10 sys_clk = ~sys_clk;

    localparam AXIS_BEATS_0 = 15;
    localparam AXIS_BEATS_1 = 7;
    localparam AXIS_BEATS_2 = 15;
    localparam AXIS_BEATS_3 = 15;
    localparam AXIS_BEATS_4 = 15;
    localparam AXIS_BEATS_5 = 15;
    localparam AXIS_BEATS_6 = 15;
    localparam AXIS_BEATS_7 = 15;

    initial begin
    	#50 sys_resetn = 1'b1;
    		tx_resetn = 1'b1;
		//#440 tx_resetn = 1'b1; //dummy
		repeat (3) begin
		  #441 tx_resetn = 1'b1; //dummy
			s_axis_tvalid_0 = 1'b1;
			/*s_axis_tvalid_1 = 1'b1;
			s_axis_tvalid_2 = 1'b1;
			s_axis_tvalid_3 = 1'b1;
			s_axis_tvalid_4 = 1'b1;
			s_axis_tvalid_5 = 1'b1;
			s_axis_tvalid_6 = 1'b1;
			s_axis_tvalid_7 = 1'b1;*/
			fork
				begin 
					repeat (AXIS_BEATS_0) begin
						#20 s_axis_tvalid_0 = 1'b1; //dummy
						if(s_axis_tready_0)
							s_axis_tdata_0 = s_axis_tdata_0 + 1'b1;
						else
							wait(s_axis_tready_0) #20 s_axis_tdata_0 = s_axis_tdata_0 + 1'b1;
					end
					#0 s_axis_tlast_0 = 1'b1;
				        s_axis_tkeep_0 = 64'h1FFFF;

					wait(s_axis_tready_0) begin 
						#20	s_axis_tvalid_0 = 1'b0;
    						s_axis_tlast_0 = 1'b0;
    						s_axis_tdata_0 = s_axis_tdata_0 + 1'b1;;
    						s_axis_tkeep_0 = '1;
					end
				end/*
				begin
					repeat (AXIS_BEATS_1) begin
						#20 s_axis_tvalid_1 = 1'b1; //dummy
						if(s_axis_tready_1)
							s_axis_tdata_1 = s_axis_tdata_1 + 1'b1;
						else
							wait(s_axis_tready_1) #20 s_axis_tdata_1 = s_axis_tdata_1 + 1'b1;
					end
					s_axis_tlast_1 = 1'b1;
					//s_axis_tkeep_1 = 8'h01;

					wait(s_axis_tready_1) begin 
						#20	s_axis_tvalid_1 = 1'b0;
							s_axis_tlast_1 = 1'b0;
							s_axis_tdata_1 = s_axis_tdata_1 + 1'b1;;
							s_axis_tkeep_1 = '1;
					end
				end
				begin 
					repeat (AXIS_BEATS_2) begin
						#20 s_axis_tvalid_2 = 1'b1; //dummy
						if(s_axis_tready_2)
							s_axis_tdata_2 = s_axis_tdata_2 + 1'b1;
						else
							wait(s_axis_tready_2) #20 s_axis_tdata_2 = s_axis_tdata_2 + 1'b1;
					end
					#0 s_axis_tlast_2 = 1'b1;
					//s_axis_tkeep_2 = 8'h01;

					wait(s_axis_tready_2) begin 
						#20	s_axis_tvalid_2 = 1'b0;
    						s_axis_tlast_2 = 1'b0;
    						s_axis_tdata_2 = s_axis_tdata_2 + 1'b1;;
    						s_axis_tkeep_2 = '1;
					end
				end
				begin
					repeat (AXIS_BEATS_3) begin
						#20 s_axis_tvalid_3 = 1'b1; //dummy
						if(s_axis_tready_3)
							s_axis_tdata_3 = s_axis_tdata_3 + 1'b1;
						else
							wait(s_axis_tready_3) #20 s_axis_tdata_3 = s_axis_tdata_3 + 1'b1;
					end
					s_axis_tlast_3 = 1'b1;
					//s_axis_tkeep_3 = 8'h01;

					wait(s_axis_tready_3) begin 
						#20	s_axis_tvalid_3 = 1'b0;
							s_axis_tlast_3 = 1'b0;
							s_axis_tdata_3 = s_axis_tdata_3 + 1'b1;;
							s_axis_tkeep_3 = '1;
					end
				end
				begin
					repeat (AXIS_BEATS_4) begin
						#20 s_axis_tvalid_4 = 1'b1; //dummy
						if(s_axis_tready_4)
							s_axis_tdata_4 = s_axis_tdata_4 + 1'b1;
						else
							wait(s_axis_tready_4) #20 s_axis_tdata_4 = s_axis_tdata_4 + 1'b1;
					end
					s_axis_tlast_4 = 1'b1;
					//s_axis_tkeep_4 = 8'h01;

					wait(s_axis_tready_4) begin 
						#20	s_axis_tvalid_4 = 1'b0;
							s_axis_tlast_4 = 1'b0;
							s_axis_tdata_4 = s_axis_tdata_4 + 1'b1;;
							s_axis_tkeep_4 = '1;
					end
				end
				begin
					repeat (AXIS_BEATS_5) begin
						#20 s_axis_tvalid_5 = 1'b1; //dummy
						if(s_axis_tready_5)
							s_axis_tdata_5 = s_axis_tdata_5 + 1'b1;
						else
							wait(s_axis_tready_5) #20 s_axis_tdata_5 = s_axis_tdata_5 + 1'b1;
					end
					s_axis_tlast_5 = 1'b1;
					//s_axis_tkeep_5 = 8'h01;

					wait(s_axis_tready_5) begin 
						#20	s_axis_tvalid_5 = 1'b0;
							s_axis_tlast_5 = 1'b0;
							s_axis_tdata_5 = s_axis_tdata_5 + 1'b1;;
							s_axis_tkeep_5 = '1;
					end
				end
				begin
					repeat (AXIS_BEATS_6) begin
						#20 s_axis_tvalid_6 = 1'b1; //dummy
						if(s_axis_tready_6)
							s_axis_tdata_6 = s_axis_tdata_6 + 1'b1;
						else
							wait(s_axis_tready_6) #20 s_axis_tdata_6 = s_axis_tdata_6 + 1'b1;
					end
					s_axis_tlast_6 = 1'b1;
					//s_axis_tkeep_6 = 8'h01;

					wait(s_axis_tready_6) begin 
						#20	s_axis_tvalid_6 = 1'b0;
							s_axis_tlast_6 = 1'b0;
							s_axis_tdata_6 = s_axis_tdata_6 + 1'b1;;
							s_axis_tkeep_6 = '1;
					end
				end
				begin
					repeat (AXIS_BEATS_7) begin
						#20 s_axis_tvalid_7 = 1'b1; //dummy
						if(s_axis_tready_7)
							s_axis_tdata_7 = s_axis_tdata_7 + 1'b1;
						else
							wait(s_axis_tready_7) #20 s_axis_tdata_7 = s_axis_tdata_7 + 1'b1;
					end
					s_axis_tlast_7 = 1'b1;
					//s_axis_tkeep_7 = 8'h01;

					wait(s_axis_tready_7) begin 
						#20	s_axis_tvalid_7 = 1'b0;
							s_axis_tlast_7 = 1'b0;
							s_axis_tdata_7 = s_axis_tdata_7 + 1'b1;;
							s_axis_tkeep_7 = '1;
					end
				end*/
			join_none
	    end
	end

    axi_to_lbus #(
    	.S_TDATA_WIDTH(S_TDATA_WIDTH),
    	.SYNC_STAGES(SYNC_STAGES),
    	.FIFO_DEPTH(FIFO_DEPTH),
    	.AXIS_INTERFACES(AXIS_INTERFACES)
	) axi_to_lbus_0 (.*);

endmodule
