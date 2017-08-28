`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Varun Sharma
//
// Create Date: 07/25/2017 04:09:49 PM
// Design Name:
// Module Name: axi_to_lbus
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments: This version provides async FIFOs right at the end
//
////////////////////////////////////////////////////////////////////////////////


module axi_to_lbus #(
    parameter S_TDATA_WIDTH = 8,
    parameter FIFO_DEPTH = 32,
    parameter SYNC_STAGES = 2,
    parameter AXIS_INTERFACES = 1
)(
    //clocking and reset
    input sys_clk,
    input sys_resetn,
    input tx_clk,
    input tx_resetn,

    //AXI4-Stream input interfaces - need to manually keep consistent with MAX_AXIS_INTERFACES
    input s_axis_tvalid_0,
    output s_axis_tready_0,
    input [(S_TDATA_WIDTH*8)-1:0] s_axis_tdata_0,
    input [S_TDATA_WIDTH-1:0] s_axis_tkeep_0,
    input s_axis_tlast_0,

    input s_axis_tvalid_1,
    output s_axis_tready_1,
    input [(S_TDATA_WIDTH*8)-1:0] s_axis_tdata_1,
    input [S_TDATA_WIDTH-1:0] s_axis_tkeep_1,
    input s_axis_tlast_1,

    input s_axis_tvalid_2,
    output s_axis_tready_2,
    input [(S_TDATA_WIDTH*8)-1:0] s_axis_tdata_2,
    input [S_TDATA_WIDTH-1:0] s_axis_tkeep_2,
    input s_axis_tlast_2,

    input s_axis_tvalid_3,
    output s_axis_tready_3,
    input [(S_TDATA_WIDTH*8)-1:0] s_axis_tdata_3,
    input [S_TDATA_WIDTH-1:0] s_axis_tkeep_3,
    input s_axis_tlast_3,

    input s_axis_tvalid_4,
    output s_axis_tready_4,
    input [(S_TDATA_WIDTH*8)-1:0] s_axis_tdata_4,
    input [S_TDATA_WIDTH-1:0] s_axis_tkeep_4,
    input s_axis_tlast_4,

    input s_axis_tvalid_5,
    output s_axis_tready_5,
    input [(S_TDATA_WIDTH*8)-1:0] s_axis_tdata_5,
    input [S_TDATA_WIDTH-1:0] s_axis_tkeep_5,
    input s_axis_tlast_5,

    input s_axis_tvalid_6,
    output s_axis_tready_6,
    input [(S_TDATA_WIDTH*8)-1:0] s_axis_tdata_6,
    input [S_TDATA_WIDTH-1:0] s_axis_tkeep_6,
    input s_axis_tlast_6,

    input s_axis_tvalid_7,
    output s_axis_tready_7,
    input [(S_TDATA_WIDTH*8)-1:0] s_axis_tdata_7,
    input [S_TDATA_WIDTH-1:0] s_axis_tkeep_7,
    input s_axis_tlast_7,

    //LBUS output interface - need to manually keep consistent with localparams
    input tx_rdyout,
    input tx_ovfout,
    input tx_unfout,

    output [127:0] tx_datain0,
    output tx_enain0,
    output tx_sopin0,
    output tx_eopin0,
    output tx_errin0,
    output [3:0] tx_mtyin0,

    output [127:0] tx_datain1,
    output tx_enain1,
    output tx_sopin1,
    output tx_eopin1,
    output tx_errin1,
    output [3:0] tx_mtyin1,

    output [127:0] tx_datain2,
    output tx_enain2,
    output tx_sopin2,
    output tx_eopin2,
    output tx_errin2,
    output [3:0] tx_mtyin2,

    output [127:0] tx_datain3,
    output tx_enain3,
    output tx_sopin3,
    output tx_eopin3,
    output tx_errin3,
    output [3:0] tx_mtyin3
);

    localparam LBUS_SEGMENT_SIZE = 16; //each LBUS segment is 16 bytes (128 bit)
    localparam LBUS_SEGMENT_CNT = 4; //number of LBUS segments - dependency on being a power of 2
    localparam MAX_AXIS_INTERFACES = 8;
    localparam DELAY_FACTOR = 3; //experimentally determined

    localparam LBUS_SEG_WIDTH = LBUS_SEGMENT_SIZE*8;
    localparam LBUS_SEG_CNT_LOG = $clog2(LBUS_SEGMENT_CNT);
    localparam TUSER_WIDTH = $clog2(LBUS_SEGMENT_SIZE) + 1 + 1 + 1; //mytin + ena + sop + eop

    //pack AXIS interfaces into arrays for easier access
    wire s_axis_tvalid [MAX_AXIS_INTERFACES] = '{s_axis_tvalid_0, s_axis_tvalid_1, s_axis_tvalid_2, 
        s_axis_tvalid_3, s_axis_tvalid_4, s_axis_tvalid_5, s_axis_tvalid_6, s_axis_tvalid_7};
    wire s_axis_tready [MAX_AXIS_INTERFACES];
    wire [(S_TDATA_WIDTH*8)-1:0] s_axis_tdata [MAX_AXIS_INTERFACES] = '{s_axis_tdata_0, s_axis_tdata_1, 
        s_axis_tdata_2, s_axis_tdata_3, s_axis_tdata_4, s_axis_tdata_5, s_axis_tdata_6, s_axis_tdata_7};
    wire [S_TDATA_WIDTH-1:0] s_axis_tkeep [MAX_AXIS_INTERFACES] = '{s_axis_tkeep_0, s_axis_tkeep_1, 
        s_axis_tkeep_2, s_axis_tkeep_3, s_axis_tkeep_4, s_axis_tkeep_5, s_axis_tkeep_6, s_axis_tkeep_7};
    wire s_axis_tlast [MAX_AXIS_INTERFACES] = '{s_axis_tlast_0, s_axis_tlast_1, s_axis_tlast_2, 
        s_axis_tlast_3, s_axis_tlast_4, s_axis_tlast_5, s_axis_tlast_6, s_axis_tlast_7};

    wire m_packed_tvalid [AXIS_INTERFACES];
    wire m_packed_tready [AXIS_INTERFACES];
    wire [LBUS_SEG_WIDTH-1:0] m_packed_tdata_little [AXIS_INTERFACES];
    wire [LBUS_SEG_WIDTH-1:0] m_packed_tdata [AXIS_INTERFACES];
    wire [LBUS_SEG_WIDTH-1:0] m_packed_tdata_reversed [AXIS_INTERFACES];
    wire [LBUS_SEGMENT_SIZE-1:0] m_packed_tkeep [AXIS_INTERFACES];
    wire m_packed_tlast [AXIS_INTERFACES];
    
    wire tx_tready [AXIS_INTERFACES][LBUS_SEGMENT_CNT];
    wire m_fifo_tready [AXIS_INTERFACES];
    reg insert_idles [AXIS_INTERFACES];
    reg [LBUS_SEG_CNT_LOG-1:0] fifo_load_counter [AXIS_INTERFACES];
    genvar g;
    genvar h;
    genvar f;
    generate
        if(S_TDATA_WIDTH < LBUS_SEGMENT_SIZE) begin
            for( g = 0; g < AXIS_INTERFACES; g=g+1 ) begin : gen_width_conversion
                assign m_packed_tready[g] = m_fifo_tready[g] & (~insert_idles[g]);
                assign m_fifo_tready[g] = tx_tready[g][fifo_load_counter[g]];
                axis_dwidth_converter_0 inst (
                    .aclk(sys_clk),                    // input wire aclk
                    .aresetn(sys_resetn),              // input wire aresetn
                    .s_axis_tvalid(s_axis_tvalid[g]),  // input wire s_axis_tvalid
                    .s_axis_tready(s_axis_tready[g]),  // output wire s_axis_tready
                    .s_axis_tdata(s_axis_tdata[g]),    // input wire [31 : 0] s_axis_tdata
                    .s_axis_tkeep(s_axis_tkeep[g]),    // input wire [3 : 0] s_axis_tkeep
                    .s_axis_tlast(s_axis_tlast[g]),    // input wire s_axis_tlast
                    .m_axis_tvalid(m_packed_tvalid[g]),  // output wire m_axis_tvalid
                    .m_axis_tready(m_packed_tready[g]),  // input wire m_axis_tready
                    .m_axis_tdata(m_packed_tdata_little[g]),    // output wire [63 : 0] m_axis_tdata
                    .m_axis_tkeep(m_packed_tkeep[g]),    // output wire [7 : 0] m_axis_tkeep
                    .m_axis_tlast(m_packed_tlast[g])    // output wire m_axis_tlast
                );
                for( f = 0; f < LBUS_SEGMENT_SIZE; f=f+S_TDATA_WIDTH ) begin : byte_reverse_0
                    for( h = 0; h < S_TDATA_WIDTH; h=h+1 ) begin : byte_reverse_1
                        assign m_packed_tdata_reversed[g][(f*8)+(h*8)+7-:8] = m_packed_tdata_little[g][(f*8)+(S_TDATA_WIDTH*8)-(h*8)-1-:8];
                    end
                    assign m_packed_tdata[g][((LBUS_SEGMENT_SIZE-f)*8)-1-:(S_TDATA_WIDTH*8)] = m_packed_tdata_reversed[g][((S_TDATA_WIDTH+f)*8)-1-:(S_TDATA_WIDTH*8)];
                end
                
                /*for( f = 0; f < LBUS_SEGMENT_SIZE; f=f+S_TDATA_WIDTH ) begin : beat_reverse
                    //assign m_packed_tdata[g] = {m_packed_tdata_reversed[g][63:0], m_packed_tdata_reversed[g][127:64]};
                    assign m_packed_tdata[g][((LBUS_SEG_WIDTH-f)*8)-1-:(S_TDATA_WIDTH*8)] = m_packed_tdata_reversed[g][((S_TDATA_WIDTH+f)*8)-1-:(S_TDATA_WIDTH*8)];
                end*/
            end
        end
        else begin
            $error("S_TDATA_WIDTH is not currently allowed to be larger than or equal to %d", LBUS_SEGMENT_SIZE);
        end
    endgenerate

    integer i;
    reg tlast_latched [AXIS_INTERFACES];

    always_ff @(posedge sys_clk) begin : proc_0
        if(~sys_resetn) begin
            for (i = 0; i < AXIS_INTERFACES; i=i+1) begin : proc_0_1
                fifo_load_counter[i] <= '0;
                tlast_latched[i] <= 1'b1;
                insert_idles[i] <= 1'b0;
            end
        end else begin
            for( i = 0; i < AXIS_INTERFACES; i=i+1 ) begin : proc_0_0
                if(m_packed_tvalid[i] & m_packed_tready[i]) begin
                    fifo_load_counter[i] <= fifo_load_counter[i] + 1'b1;
                    tlast_latched[i] <= m_packed_tlast[i];
                    if(~&fifo_load_counter[i])
                        insert_idles[i] <= m_packed_tlast[i]; //insert idles if last packet is not on last segment
                end
                else if(insert_idles[i]) begin
                    fifo_load_counter[i] <= fifo_load_counter[i] + 1'b1;
                    if(&fifo_load_counter[i])
                        insert_idles[i] <= m_packed_tlast[i]&m_packed_tvalid[i]; //insert idles if last packet is not on last segment
                end
            end
        end
    end

    
    reg [$clog2(LBUS_SEGMENT_SIZE)-1:0] mytin [AXIS_INTERFACES];
    wire [TUSER_WIDTH-1:0] m_packed_tuser [AXIS_INTERFACES];
    reg [$clog2(FIFO_DEPTH+1)-1:0] fifo_packet_counter_user [AXIS_INTERFACES][DELAY_FACTOR*SYNC_STAGES]; //maintains count of full packets in FIFO
    wire m_tlast_rising [AXIS_INTERFACES];
    integer l;
    integer m;
    generate
        for( g = 0; g < AXIS_INTERFACES; g=g+1 ) begin : gen_tkeep_mytin
            always_comb begin
                /*case(m_packed_tkeep[g]) //need to update if LBUS_SEGMENT_SIZE != 16
                    16'hFFFF: mytin[g] = 4'h0;
                    16'hFFFE: mytin[g] = 4'h1;
                    16'hFFFC: mytin[g] = 4'h2;
                    16'hFFF8: mytin[g] = 4'h3;
                    16'hFFF0: mytin[g] = 4'h4;
                    16'hFFE0: mytin[g] = 4'h5;
                    16'hFFC0: mytin[g] = 4'h6;
                    16'hFF80: mytin[g] = 4'h7;
                    16'hFF00: mytin[g] = 4'h8;
                    16'hFE00: mytin[g] = 4'h9;
                    16'hFC00: mytin[g] = 4'hA;
                    16'hF800: mytin[g] = 4'hB;
                    16'hF000: mytin[g] = 4'hC;
                    16'hE000: mytin[g] = 4'hD;
                    16'hC000: mytin[g] = 4'hE;
                    16'h8000: mytin[g] = 4'hF;
                    default: mytin[g] = 4'hX;
                endcase*/
                case(m_packed_tkeep[g]) //need to update if LBUS_SEGMENT_SIZE != 16
                    16'hFFFF: mytin[g] = 4'h0;
                    16'h7FFF: mytin[g] = 4'h1;
                    16'h3FFF: mytin[g] = 4'h2;
                    16'h1FFF: mytin[g] = 4'h3;
                    16'h0FFF: mytin[g] = 4'h4;
                    16'h07FF: mytin[g] = 4'h5;
                    16'h03FF: mytin[g] = 4'h6;
                    16'h01FF: mytin[g] = 4'h7;
                    16'h00FF: mytin[g] = 4'h8;
                    16'h007F: mytin[g] = 4'h9;
                    16'h003F: mytin[g] = 4'hA;
                    16'h001F: mytin[g] = 4'hB;
                    16'h000F: mytin[g] = 4'hC;
                    16'h0007: mytin[g] = 4'hD;
                    16'h0003: mytin[g] = 4'hE;
                    16'h0001: mytin[g] = 4'hF;
                    default: mytin[g] = 4'hX;
                endcase
            end

            assign m_tlast_rising[g] = m_packed_tlast[g] & m_packed_tvalid[g]; //TLAST is high for two cycles so only increment on first cycle

            always_ff @(posedge sys_clk) begin : proc_1
                if(~sys_resetn) begin
                    for(l = 0; l < SYNC_STAGES*DELAY_FACTOR; l=l+1) begin : reset_count
                        fifo_packet_counter_user[g][l] <= '0;
                    end
                end else begin
                    if(m_tlast_rising[g]) 
                        fifo_packet_counter_user[g][0] <= fifo_packet_counter_user[g][0] + 1'b1;
                    for(m = 1; m < SYNC_STAGES*DELAY_FACTOR; m=m+1) begin : count
                        fifo_packet_counter_user[g][m] <= fifo_packet_counter_user[g][m-1];
                    end
                end
            end

            /*
            LBUS control signals (SOP, EOP, MTY, ENA) behave differently from AXIS so they are stripped from AXI
            and packed into TUSER of the FIFO as below (in LSB to MSB order):
                ENA, SOP, EOP, MTY[0:3], count[0:N]
            */
            assign m_packed_tuser[g] = {mytin[g], m_tlast_rising[g], tlast_latched[g], m_packed_tvalid[g]&(~insert_idles[g])};
        end
    endgenerate

    wire tx_tvalid [AXIS_INTERFACES][LBUS_SEGMENT_CNT];
    wire [LBUS_SEG_WIDTH-1:0] tx_tdata [AXIS_INTERFACES][LBUS_SEGMENT_CNT];
    wire [TUSER_WIDTH-1:0] tx_tuser [AXIS_INTERFACES][LBUS_SEGMENT_CNT];
    reg [$clog2(MAX_AXIS_INTERFACES)-1:0] fifo_index = '0;
    
    wire tx_fifo_valid [AXIS_INTERFACES];
    wire read_interface [AXIS_INTERFACES];
    
    generate
        for( g = 0; g < AXIS_INTERFACES; g=g+1 ) begin : gen_fifo_interface
            assign read_interface[g] = tx_rdyout&tx_fifo_valid[g]&(fifo_index==g);
            for( h = 0; h < LBUS_SEGMENT_CNT; h=h+1 ) begin : gen_fifo_segment
                
                axis_data_fifo_0 fifo (
                    .s_axis_aresetn(sys_resetn),          // input wire s_axis_aresetn
                    .m_axis_aresetn(tx_resetn),          // input wire m_axis_aresetn
                    .s_axis_aclk(sys_clk),                // input wire s_axis_aclk
                    .s_axis_tvalid((m_packed_tvalid[g]|insert_idles[g])&(fifo_load_counter[g]==h)),            // input wire s_axis_tvalid
                    .s_axis_tready(tx_tready[g][h]),            // output wire s_axis_tready
                    .s_axis_tdata(m_packed_tdata[g]),              // input wire [127 : 0] s_axis_tdata
                    .s_axis_tuser(m_packed_tuser[g]),              // input wire [6 : 0] s_axis_tuser
                    .m_axis_aclk(tx_clk),                // input wire m_axis_aclk
                    .m_axis_tvalid(tx_tvalid[g][h]),            // output wire m_axis_tvalid
                    .m_axis_tready(read_interface[g]),            // input wire m_axis_tready
                    .m_axis_tdata(tx_tdata[g][h]),              // output wire [127 : 0] m_axis_tdata
                    .m_axis_tuser(tx_tuser[g][h]),              // output wire [6 : 0] m_axis_tuser
                    .axis_data_count(),        // output wire [31 : 0] axis_data_count
                    .axis_wr_data_count(),  // output wire [31 : 0] axis_wr_data_count
                    .axis_rd_data_count()  // output wire [31 : 0] axis_rd_data_count
                );
            end
        end
    endgenerate

    reg [$clog2(FIFO_DEPTH+1)-1:0] tx_fifo_packet_counter [AXIS_INTERFACES];
    reg [$clog2(FIFO_DEPTH+1)-1:0] fifo_packet_counter_tx [AXIS_INTERFACES][SYNC_STAGES]; //maintains count of full packets in FIFO
    wire [$clog2(LBUS_SEGMENT_SIZE)-1:0] mytin_tx [AXIS_INTERFACES][LBUS_SEGMENT_CNT];
    wire [LBUS_SEGMENT_CNT-1:0] eop_tx [AXIS_INTERFACES];
    wire sop_tx [AXIS_INTERFACES][LBUS_SEGMENT_CNT];
    wire ena_tx [AXIS_INTERFACES][LBUS_SEGMENT_CNT];
    
    integer j;
    integer k;
    generate
        for( g = 0; g < AXIS_INTERFACES; g=g+1 ) begin : gen_tx
            always_ff @(posedge tx_clk) begin : proc_2
                if(~tx_resetn) begin
                    tx_fifo_packet_counter[g] <= '0;
                end else begin
                    if((|eop_tx[g])&read_interface[g])
                        tx_fifo_packet_counter[g] <= tx_fifo_packet_counter[g] + 1'b1;
                end
            end

            always_ff @(posedge tx_clk) begin : proc_5
                if(~tx_resetn) begin
                    for(j = 0; j < SYNC_STAGES; j=j+1) begin : reset_sync_count
                        fifo_packet_counter_tx[g][j] <= '0;
                    end
                end else begin
                    fifo_packet_counter_tx[g][0] <= fifo_packet_counter_user[g][(SYNC_STAGES*DELAY_FACTOR)-1]; //clock crossing
                    for(k = 1; k < SYNC_STAGES; k=k+1) begin : sync_count
                        fifo_packet_counter_tx[g][k] <= fifo_packet_counter_tx[g][k-1];
                    end
                end
            end

            //assign fifo_packet_counter_tx[g] = tx_tuser[g][LBUS_SEGMENT_CNT-1][TUSER_WIDTH-1-:$clog2(FIFO_DEPTH+1)]; //use last segments count as latest value
            assign tx_fifo_valid[g] = |(fifo_packet_counter_tx[g][SYNC_STAGES-1] - tx_fifo_packet_counter[g]); //if non-zero, there is at least 1 full packet

            for( h = 0; h < LBUS_SEGMENT_CNT; h=h+1 ) begin : gen_tx_user
                //assign mytin_tx[g][h] = tx_tuser[g][h][TUSER_WIDTH-1-$clog2(FIFO_DEPTH+1)-:$clog2(LBUS_SEGMENT_SIZE)];
                assign mytin_tx[g][h] = tx_tuser[g][h][6:3];
                assign eop_tx[g][h] = tx_tuser[g][h][2] & tx_fifo_valid[g];
                assign sop_tx[g][h] = tx_tuser[g][h][1] & tx_fifo_valid[g];
                assign ena_tx[g][h] = tx_tuser[g][h][0] & tx_fifo_valid[g];
            end
        end
    endgenerate
    
    

    generate

        if(AXIS_INTERFACES > 1) begin
            always_ff @(posedge tx_clk) begin : proc_3
                if(~tx_resetn) begin
                    fifo_index <= '0;
                end else begin
                    if(~tx_fifo_valid[fifo_index])
                        fifo_index <= fifo_index == AXIS_INTERFACES - 1 ? '0 : fifo_index + 1'b1;
                    else if(|eop_tx[fifo_index])
                        fifo_index <= fifo_index == AXIS_INTERFACES - 1 ? '0 : fifo_index + 1'b1;
                end
            end
        end
        else begin
            always_comb begin : proc_4
                fifo_index = 0;
            end
        end

    endgenerate

    assign s_axis_tready_0 = s_axis_tready[0];
    assign s_axis_tready_1 = s_axis_tready[1];
    assign s_axis_tready_2 = s_axis_tready[2];
    assign s_axis_tready_3 = s_axis_tready[3];
    assign s_axis_tready_4 = s_axis_tready[4];
    assign s_axis_tready_5 = s_axis_tready[5];
    assign s_axis_tready_6 = s_axis_tready[6];
    assign s_axis_tready_7 = s_axis_tready[7];

    assign tx_datain0 = tx_tdata[fifo_index][0];
    assign tx_enain0 = ena_tx[fifo_index][0];
    assign tx_sopin0 = sop_tx[fifo_index][0];
    assign tx_eopin0 = eop_tx[fifo_index][0];
    assign tx_errin0 = 1'b0;
    assign tx_mtyin0 = mytin_tx[fifo_index][0];

    assign tx_datain1 = tx_tdata[fifo_index][1];
    assign tx_enain1 = ena_tx[fifo_index][1];
    assign tx_sopin1 = sop_tx[fifo_index][1];
    assign tx_eopin1 = eop_tx[fifo_index][1];
    assign tx_errin1 = 1'b0;
    assign tx_mtyin1 = mytin_tx[fifo_index][1];

    assign tx_datain2 = tx_tdata[fifo_index][2];
    assign tx_enain2 = ena_tx[fifo_index][2];
    assign tx_sopin2 = sop_tx[fifo_index][2];
    assign tx_eopin2 = eop_tx[fifo_index][2];
    assign tx_errin2 = 1'b0;
    assign tx_mtyin2 = mytin_tx[fifo_index][2];

    assign tx_datain3 = tx_tdata[fifo_index][3];
    assign tx_enain3 = ena_tx[fifo_index][3];
    assign tx_sopin3 = sop_tx[fifo_index][3];
    assign tx_eopin3 = eop_tx[fifo_index][3];
    assign tx_errin3 = 1'b0;
    assign tx_mtyin3 = mytin_tx[fifo_index][3];

endmodule
