`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2017 03:04:31 PM
// Design Name: 
// Module Name: lbus_to_axi
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


module lbus_to_axi #(
    parameter M_TDATA_WIDTH = 16,
    parameter FIFO_DEPTH = 64,
    parameter FILTER = 0, //0 = no filtering, 1 = only destination, 2 = broadcast + destination, 3 = reserved
    parameter MAC = 48'hAABBCCDDEEFF
)(

    //clocking and reset
    input sys_clk,
    input sys_resetn,
    input rx_clk,
    input rx_resetn,

    //LBUS input interface
    input [127:0] rx_datain0,
    input rx_enain0,
    input rx_sopin0,
    input rx_eopin0,
    input rx_errin0,
    input [3:0] rx_mtyin0,

    input [127:0] rx_datain1,
    input rx_enain1,
    input rx_sopin1,
    input rx_eopin1,
    input rx_errin1,
    input [3:0] rx_mtyin1,

    input [127:0] rx_datain2,
    input rx_enain2,
    input rx_sopin2,
    input rx_eopin2,
    input rx_errin2,
    input [3:0] rx_mtyin2,

    input [127:0] rx_datain3,
    input rx_enain3,
    input rx_sopin3,
    input rx_eopin3,
    input rx_errin3,
    input [3:0] rx_mtyin3,

    //AXI4-Stream output interface
    output s_axis_tvalid,
    input s_axis_tready,
    output [(M_TDATA_WIDTH*8)-1:0] s_axis_tdata,
    output [M_TDATA_WIDTH-1:0] s_axis_tkeep,
    output reg s_axis_tlast,
    
    //overflow counter
    output [31:0] overflow_counter
);

    localparam LBUS_SEGMENT_WIDTH = 16; //each LBUS segment is 16 bytes (128 bit)
    localparam LBUS_SEGMENT_CNT = 4; //number of LBUS segments - dependency on being a power of 2
    localparam TUSER_PER_BYTE = 1;
    localparam TUSER_WIDTH = 28; //4*sop, 4*ena, 4*mytin, 4*eop

    localparam LBUS_SEG_BITS = LBUS_SEGMENT_WIDTH*8;
    localparam LBUS_SEG_CNT_LOG = $clog2(LBUS_SEGMENT_CNT);
    localparam M_TUSER_WIDTH = TUSER_PER_BYTE*LBUS_SEGMENT_WIDTH*LBUS_SEGMENT_CNT;
    localparam S_TUSER_WIDTH = TUSER_PER_BYTE*M_TDATA_WIDTH;

    localparam FILTER_NONE = 0;
    localparam FILTER_DEST = 1;
    localparam FILTER_BRDE = 2; //BRoadcast + DEstination
    
    wire s_lbus_tvalid;
    wire s_lbus_tready;
    wire [LBUS_SEG_BITS-1:0] s_lbus_tdata_big [LBUS_SEGMENT_CNT] = '{rx_datain0,rx_datain1,rx_datain2,rx_datain3};
    wire [LBUS_SEG_BITS-1:0] s_lbus_tdata_reversed [LBUS_SEGMENT_CNT];
    wire [LBUS_SEG_BITS-1:0] s_lbus_tdata_raw [LBUS_SEGMENT_CNT];
    wire [(LBUS_SEG_BITS*LBUS_SEGMENT_CNT)-1:0] s_lbus_tdata;
    wire [3:0] s_lbus_mtyin [LBUS_SEGMENT_CNT];
    reg [LBUS_SEGMENT_WIDTH-1:0] s_lbus_tkeep_raw [LBUS_SEGMENT_CNT];
    wire [(LBUS_SEGMENT_WIDTH*LBUS_SEGMENT_CNT)-1:0] s_lbus_tkeep;
    wire [TUSER_WIDTH-1:0] fifo_1_tuser;

    wire [M_TUSER_WIDTH-1:0] s_lbus_tuser = {{(LBUS_SEGMENT_WIDTH){fifo_1_tuser[3]}},
        {(LBUS_SEGMENT_WIDTH){fifo_1_tuser[2]}},
        {(LBUS_SEGMENT_WIDTH){fifo_1_tuser[1]}},
        {(LBUS_SEGMENT_WIDTH){fifo_1_tuser[0]}}};

    assign s_lbus_tvalid = |{rx_enain0, rx_enain1, rx_enain2, rx_enain3};
    
    genvar g;
    genvar f;
    genvar h;
    generate
        for( g = 0; g < 4; g=g+1 ) begin : gen_concatenate
            assign s_lbus_mtyin[g] = fifo_1_tuser[(g*4)+8-1-:4];
            //byte reverse and packet reverse - opposite as in axi_to_lbus.sv
            for( f = 0; f < LBUS_SEGMENT_WIDTH; f=f+M_TDATA_WIDTH ) begin : byte_reverse_0
                for( h = 0; h < M_TDATA_WIDTH; h=h+1 ) begin : byte_reverse_1
                    assign s_lbus_tdata_reversed[g][(f*8)+(M_TDATA_WIDTH*8)-(h*8)-1-:8] = 
                        s_lbus_tdata_big[g][(f*8)+(h*8)+7-:8];
                end
                assign s_lbus_tdata_raw[g][((M_TDATA_WIDTH+f)*8)-1-:(M_TDATA_WIDTH*8)] = 
                    s_lbus_tdata_reversed[g][((LBUS_SEGMENT_WIDTH-f)*8)-1-:(M_TDATA_WIDTH*8)];
            end
            
            always_comb begin : mtyin_tkeep
                case(s_lbus_mtyin[g]) //need to update if LBUS_SEGMENT_WIDTH != 16
                    4'h0: s_lbus_tkeep_raw[g] = 16'hFFFF;
                    4'h1: s_lbus_tkeep_raw[g] = 16'h7FFF;
                    4'h2: s_lbus_tkeep_raw[g] = 16'h3FFF;
                    4'h3: s_lbus_tkeep_raw[g] = 16'h1FFF;
                    4'h4: s_lbus_tkeep_raw[g] = 16'h0FFF;
                    4'h5: s_lbus_tkeep_raw[g] = 16'h07FF;
                    4'h6: s_lbus_tkeep_raw[g] = 16'h03FF;
                    4'h7: s_lbus_tkeep_raw[g] = 16'h01FF;
                    4'h8: s_lbus_tkeep_raw[g] = 16'h00FF;
                    4'h9: s_lbus_tkeep_raw[g] = 16'h007F;
                    4'hA: s_lbus_tkeep_raw[g] = 16'h003F;
                    4'hB: s_lbus_tkeep_raw[g] = 16'h001F;
                    4'hC: s_lbus_tkeep_raw[g] = 16'h000F;
                    4'hD: s_lbus_tkeep_raw[g] = 16'h0007;
                    4'hE: s_lbus_tkeep_raw[g] = 16'h0003;
                    4'hF: s_lbus_tkeep_raw[g] = 16'h0001;
                endcase
            end
        end
    endgenerate

    assign s_lbus_tkeep = {fifo_1_tuser[23] ? s_lbus_tkeep_raw[3] : 16'h0,
        fifo_1_tuser[22] ? s_lbus_tkeep_raw[2] : 16'h0,
        fifo_1_tuser[21] ? s_lbus_tkeep_raw[1] : 16'h0,
        fifo_1_tuser[20] ? s_lbus_tkeep_raw[0] : 16'h0};
    assign s_lbus_tdata = {s_lbus_tdata_raw[3],s_lbus_tdata_raw[2],s_lbus_tdata_raw[1],s_lbus_tdata_raw[0]};

    wire [15:0] mtyin = {rx_mtyin3,rx_mtyin2, rx_mtyin1, rx_mtyin0};
    wire [3:0] eop = {rx_eopin3,rx_eopin2,rx_eopin1,rx_eopin0};
    wire [3:0] ena = {rx_enain3,rx_enain2,rx_enain1,rx_enain0};
    wire [3:0] sop = {rx_sopin3,rx_sopin2,rx_sopin1,rx_sopin0};

    wire fifo_1_tvalid;
    wire [(LBUS_SEG_BITS*LBUS_SEGMENT_CNT)-1:0] fifo_1_tdata;
    
    
    wire [(LBUS_SEG_BITS*LBUS_SEGMENT_CNT)-1:0] s_lbus_tdata_wire;    
    wire s_lbus_tvalid_wire;
    wire [TUSER_WIDTH-1:0] s_lbus_tuser_wire;
    
    wire [47:0] destination_mac [LBUS_SEGMENT_CNT];

    reg [LBUS_SEGMENT_CNT-1:0] packet_valid_latched;
    wire [LBUS_SEGMENT_CNT-1:0] packet_valid;
    wire [LBUS_SEGMENT_CNT-1:0] rx_sop_others = |sop ? ~sop : '0; 

    reg [(LBUS_SEG_BITS*LBUS_SEGMENT_CNT)-1:0] s_lbus_tdata_reg;
    reg s_lbus_tvalid_reg;
    reg [TUSER_WIDTH-1:0] s_lbus_tuser_reg;
    
    always @(posedge rx_clk) begin
        s_lbus_tdata_reg <= s_lbus_tdata;
        s_lbus_tvalid_reg <= s_lbus_tvalid;
        s_lbus_tuser_reg <= {sop,ena,mtyin,eop};
    end

    assign s_lbus_tdata_wire = s_lbus_tdata_reg;
    assign s_lbus_tvalid_wire = s_lbus_tvalid_reg;
    assign s_lbus_tuser_wire = s_lbus_tuser_reg;
            
    wire [3:0] eop_wire = s_lbus_tuser_reg[3:0];
    wire [3:0] ena_wire = s_lbus_tuser_wire[23:20];
    wire [15:0] mytin_wire = s_lbus_tuser_wire[19:4];
    wire [3:0] sop_wire = s_lbus_tuser_reg[TUSER_WIDTH-1-:4];
    
    generate
        for( g=0; g<LBUS_SEGMENT_CNT; g=g+1) begin : gen_macAddress
            assign destination_mac[g] = {s_lbus_tdata_wire[7+(g*LBUS_SEG_BITS)-:8], 
                 s_lbus_tdata_wire[15+(g*LBUS_SEG_BITS)-:8], s_lbus_tdata_wire[23+(g*LBUS_SEG_BITS)-:8], 
                 s_lbus_tdata_wire[31+(g*LBUS_SEG_BITS)-:8], s_lbus_tdata_wire[39+(g*LBUS_SEG_BITS)-:8], 
                 s_lbus_tdata_wire[47+(g*LBUS_SEG_BITS)-:8]};
            
            if(FILTER == FILTER_NONE) begin
                always_ff @(posedge rx_clk) begin
                    packet_valid_latched[g] <= 1'b1;
                end
                assign packet_valid[g] = 1'b1;
            end

            if(FILTER == FILTER_DEST) begin
                assign packet_valid[g] = destination_mac[g] == MAC;
            end

            if(FILTER == FILTER_BRDE) begin
                assign packet_valid[g] = destination_mac[g] == MAC | (&destination_mac[g]);
            end

            if(FILTER == FILTER_DEST || FILTER == FILTER_BRDE) begin
                always_ff @(posedge rx_clk) begin
                    if(~rx_resetn)
                        packet_valid_latched[g] <= 1'b0;
                    else begin
                        if(sop_wire[g]) begin
                            packet_valid_latched[g] <= packet_valid[g];
                        end
                        else if(rx_sop_others[g]) begin
                            packet_valid_latched[g] <= 1'b0;
                        end
                    end
                end
            end
        end        
    endgenerate

    wire [LBUS_SEGMENT_CNT-1:0] packet_valid_sop = {
        ((sop_wire[3] & packet_valid[3]) | (packet_valid_latched[3] & !sop_wire[3])),
        ((sop_wire[2] & packet_valid[2]) | (packet_valid_latched[2] & !sop_wire[2])),
        ((sop_wire[1] & packet_valid[1]) | (packet_valid_latched[1] & !sop_wire[1])),
        ((sop_wire[0] & packet_valid[0]) | (packet_valid_latched[0] & !sop_wire[0]))};
    
    wire filter_valid;
    wire [TUSER_WIDTH-1:0] s_lbus_tuser_enabled;
    reg filter_valid_latched;
    
    always_ff @(posedge rx_clk) begin
        if(~rx_resetn) begin
            filter_valid_latched <= 1'b0;
        end else begin
            filter_valid_latched <= filter_valid;
        end
    end
    
    generate
        if(FILTER == FILTER_NONE) begin
            assign filter_valid = 1'b1;
            assign s_lbus_tuser_enabled = s_lbus_tuser_wire;
        end
        if(FILTER == FILTER_DEST || FILTER == FILTER_BRDE) begin
            wire [LBUS_SEGMENT_CNT-1:0] enable_valid;
            assign filter_valid = |packet_valid_sop;

            /*the condition to check is:
                Previous packet is valid:
                    Current packet is invalid and SOP: filter out the end segments
                    else: pass enable
                Previous packet is invalid:
                    Current packet is valid and SOP: filter out the beginning segments
                    else: zero enable
            */

            assign enable_valid = filter_valid_latched /*previous packet valid?*/ ?
                ( ~|(packet_valid_sop & sop_wire) & |sop_wire /*!curr&SOP*/ ? 
                    (sop_wire[3] ? 4'b0111 : 
                    (sop_wire[2] ? 4'b0011 : 
                    (sop_wire[1] ? 4'b0001 : 4'b0000))) : 
                    s_lbus_tuser_wire[23:20] /*pass enable*/ ) :
                ( |(packet_valid_sop & sop_wire) & |sop_wire /*curr&SOP*/ ? 
                    (sop_wire[3] ? 4'b1000 : 
                    (sop_wire[2] ? 4'b1100 : 
                    (sop_wire[1] ? 4'b1110 : 4'b1111))) : 
                    4'b0000 /*zero enable*/ );

            assign s_lbus_tuser_enabled = {s_lbus_tuser_wire[TUSER_WIDTH-1-:4], enable_valid, s_lbus_tuser_wire[19:0]};
        end
    endgenerate

    wire fifo_valid = s_lbus_tvalid_wire & filter_valid;
    
    wire [7:0] valid_data_out;
    wire valid_data_out_valid;

    enum{
        state_reset,
        state_wait,
        state_overflow,
        state_new_packet
    } currentState, nextState;

    reg validPacket_valid;
    reg valid_data;
    always_comb begin
        case(currentState)
            state_reset: begin
                validPacket_valid = 1'b0;
                valid_data = 1'b0;
                if(~rx_resetn) nextState = state_reset;
                else nextState = state_wait;
            end
            state_wait: begin
                validPacket_valid = |eop_wire & fifo_valid & s_lbus_tready;
                valid_data = 1'b1;
                if(fifo_valid & ~s_lbus_tready) nextState = state_overflow;
                else nextState = state_wait;
            end
            state_overflow: begin
                validPacket_valid = 1'b1;
                valid_data = 1'b0;
                nextState = state_new_packet;
            end
            state_new_packet: begin
                validPacket_valid = 1'b0;
                valid_data = 1'b0;
                if(s_lbus_tready & |sop) nextState = state_wait;
                else nextState = state_new_packet;
            end
            default: begin
                validPacket_valid = 1'b0;
                valid_data = 1'b0;
                nextState = state_reset;
            end
        endcase // currentState
    end

    always @(posedge rx_clk) begin
        if(~rx_resetn)
            currentState <= state_reset;
        else
            currentState <= nextState;
    end

    reg valid_data_tready;
    
    generate
        if(FIFO_DEPTH == 64) begin
            l2a_validPacketFIFO_64 l2a_validPacketFIFO_0 (
                .s_axis_aresetn(rx_resetn),          // input wire s_axis_aresetn
                .s_axis_aclk(rx_clk),                // input wire s_axis_aclk
                .s_axis_tvalid(validPacket_valid), // input wire s_axis_tvalid
                .s_axis_tready(),
                .s_axis_tdata({7'b0,valid_data}),              // input wire [7 : 0] s_axis_tdata
                .m_axis_tvalid(valid_data_out_valid),            // output wire m_axis_tvalid
                .m_axis_tready(valid_data_tready),            // input wire m_axis_tready
                .m_axis_tdata(valid_data_out),              // output wire [7 : 0] m_axis_tdata
                .axis_data_count(),        // output wire [31 : 0] axis_data_count
                .axis_wr_data_count(),  // output wire [31 : 0] axis_wr_data_count
                .axis_rd_data_count()  // output wire [31 : 0] axis_rd_data_count
            );
        end
        else if(FIFO_DEPTH == 256) begin
            l2a_validPacketFIFO_256 l2a_validPacketFIFO_0 (
                .s_axis_aresetn(rx_resetn),          // input wire s_axis_aresetn
                .s_axis_aclk(rx_clk),                // input wire s_axis_aclk
                .s_axis_tvalid(validPacket_valid), // input wire s_axis_tvalid
                .s_axis_tready(),
                .s_axis_tdata({7'b0,valid_data}),              // input wire [7 : 0] s_axis_tdata
                .m_axis_tvalid(valid_data_out_valid),            // output wire m_axis_tvalid
                .m_axis_tready(valid_data_tready),            // input wire m_axis_tready
                .m_axis_tdata(valid_data_out),              // output wire [7 : 0] m_axis_tdata
                .axis_data_count(),        // output wire [31 : 0] axis_data_count
                .axis_wr_data_count(),  // output wire [31 : 0] axis_wr_data_count
                .axis_rd_data_count()  // output wire [31 : 0] axis_rd_data_count
            );
        end
        else if(FIFO_DEPTH == 1024) begin
            l2a_validPacketFIFO_1024 l2a_validPacketFIFO_0 (
                .s_axis_aresetn(rx_resetn),          // input wire s_axis_aresetn
                .s_axis_aclk(rx_clk),                // input wire s_axis_aclk
                .s_axis_tvalid(validPacket_valid), // input wire s_axis_tvalid
                .s_axis_tready(),
                .s_axis_tdata({7'b0,valid_data}),              // input wire [7 : 0] s_axis_tdata
                .m_axis_tvalid(valid_data_out_valid),            // output wire m_axis_tvalid
                .m_axis_tready(valid_data_tready),            // input wire m_axis_tready
                .m_axis_tdata(valid_data_out),              // output wire [7 : 0] m_axis_tdata
                .axis_data_count(),        // output wire [31 : 0] axis_data_count
                .axis_wr_data_count(),  // output wire [31 : 0] axis_wr_data_count
                .axis_rd_data_count()  // output wire [31 : 0] axis_rd_data_count
            );
        end
        else if(FIFO_DEPTH == 4096) begin
            l2a_validPacketFIFO_4096 l2a_validPacketFIFO_0 (
                .s_axis_aresetn(rx_resetn),          // input wire s_axis_aresetn
                .s_axis_aclk(rx_clk),                // input wire s_axis_aclk
                .s_axis_tvalid(validPacket_valid), // input wire s_axis_tvalid
                .s_axis_tready(),
                .s_axis_tdata({7'b0,valid_data}),              // input wire [7 : 0] s_axis_tdata
                .m_axis_tvalid(valid_data_out_valid),            // output wire m_axis_tvalid
                .m_axis_tready(valid_data_tready),            // input wire m_axis_tready
                .m_axis_tdata(valid_data_out),              // output wire [7 : 0] m_axis_tdata
                .axis_data_count(),        // output wire [31 : 0] axis_data_count
                .axis_wr_data_count(),  // output wire [31 : 0] axis_wr_data_count
                .axis_rd_data_count()  // output wire [31 : 0] axis_rd_data_count
            );
        end
        else
            $error("FIFO_DEPTH is not currently allowed to be the value %d", FIFO_DEPTH);
    endgenerate

    enum{
        state2_reset,
        state2_wait,
        state2_valid,
        state2_new_packet,
        state2_clear
    } currentState2, nextState2;

    reg fifo_1_tready;
    reg converter_tvalid;
    wire converter_tready;
    
    always_comb begin
        case(currentState2)
            state2_reset: begin
                fifo_1_tready = 1'b0;
                converter_tvalid = 1'b0;
                valid_data_tready = 1'b0;
                if(~rx_resetn) nextState2 = state2_reset;
                else nextState2 = state2_wait;
            end
            state2_wait: begin
                fifo_1_tready = 1'b0;
                converter_tvalid = 1'b0;
                valid_data_tready = 1'b0;
                if(valid_data_out_valid) nextState2 = state2_valid;
                else nextState2 = state2_wait;
            end
            state2_valid: begin
                fifo_1_tready = valid_data_out[0] ? converter_tready : 1'b1;
                converter_tvalid = valid_data_out[0] ? fifo_1_tvalid : 1'b0;
                valid_data_tready = 1'b0;
                if(fifo_1_tready) nextState2 = state2_new_packet;
                else nextState2 = state2_valid;
            end
            state2_new_packet: begin
                fifo_1_tready = valid_data_out[0] ? converter_tready : ~|fifo_1_tuser[TUSER_WIDTH-1-:4];
                converter_tvalid = valid_data_out[0] ? fifo_1_tvalid : 1'b0;
                valid_data_tready = 1'b0;
                if(|fifo_1_tuser[TUSER_WIDTH-1-:4]) nextState2 = state2_clear;
                else nextState2 = state2_new_packet;
            end
            state2_clear: begin
                fifo_1_tready = 1'b0;
                converter_tvalid = 1'b0;
                valid_data_tready = 1'b1;
                nextState2 = state2_wait;
            end
            default: begin
                fifo_1_tready = 1'b0;
                converter_tvalid = 1'b0;
                valid_data_tready = 1'b0;
                nextState2 = state2_reset;
            end
                            
        endcase // currentState2
    end

    always @(posedge rx_clk) begin
        if(~rx_resetn)
            currentState2 <= state2_reset;
        else
            currentState2 <= nextState2;
    end
    
    generate
        if(FIFO_DEPTH == 64) begin
            l2a_bufferFIFO_64 l2a_bufferFIFO_0 (
                .s_axis_aresetn(rx_resetn),          // input wire s_axis_aresetn
                .s_axis_aclk(rx_clk),                // input wire s_axis_aclk
                .s_axis_tvalid(fifo_valid & (currentState == state_wait)), // input wire s_axis_tvalid
                .s_axis_tready(s_lbus_tready),
                .s_axis_tdata(s_lbus_tdata_wire),              // input wire [127 : 0] s_axis_tdata
                .s_axis_tuser(s_lbus_tuser_enabled),              // input wire [6 : 0] s_axis_tuser
                .m_axis_tvalid(fifo_1_tvalid),            // output wire m_axis_tvalid
                .m_axis_tready(fifo_1_tready),            // input wire m_axis_tready
                .m_axis_tdata(fifo_1_tdata),              // output wire [127 : 0] m_axis_tdata
                .m_axis_tuser(fifo_1_tuser),              // output wire [6 : 0] m_axis_tuser
                .axis_data_count(),        // output wire [31 : 0] axis_data_count
                .axis_wr_data_count(),  // output wire [31 : 0] axis_wr_data_count
                .axis_rd_data_count()  // output wire [31 : 0] axis_rd_data_count
            );
        end
        else if(FIFO_DEPTH == 256) begin
            l2a_bufferFIFO_256 l2a_bufferFIFO_0 (
                .s_axis_aresetn(rx_resetn),          // input wire s_axis_aresetn
                .s_axis_aclk(rx_clk),                // input wire s_axis_aclk
                .s_axis_tvalid(fifo_valid & (currentState == state_wait)), // input wire s_axis_tvalid
                .s_axis_tready(s_lbus_tready),
                .s_axis_tdata(s_lbus_tdata_wire),              // input wire [127 : 0] s_axis_tdata
                .s_axis_tuser(s_lbus_tuser_enabled),              // input wire [6 : 0] s_axis_tuser
                .m_axis_tvalid(fifo_1_tvalid),            // output wire m_axis_tvalid
                .m_axis_tready(fifo_1_tready),            // input wire m_axis_tready
                .m_axis_tdata(fifo_1_tdata),              // output wire [127 : 0] m_axis_tdata
                .m_axis_tuser(fifo_1_tuser),              // output wire [6 : 0] m_axis_tuser
                .axis_data_count(),        // output wire [31 : 0] axis_data_count
                .axis_wr_data_count(),  // output wire [31 : 0] axis_wr_data_count
                .axis_rd_data_count()  // output wire [31 : 0] axis_rd_data_count
            );
        end
        else if(FIFO_DEPTH == 1024) begin
            l2a_bufferFIFO_1024 l2a_bufferFIFO_0 (
                .s_axis_aresetn(rx_resetn),          // input wire s_axis_aresetn
                .s_axis_aclk(rx_clk),                // input wire s_axis_aclk
                .s_axis_tvalid(fifo_valid & (currentState == state_wait)), // input wire s_axis_tvalid
                .s_axis_tready(s_lbus_tready),
                .s_axis_tdata(s_lbus_tdata_wire),              // input wire [127 : 0] s_axis_tdata
                .s_axis_tuser(s_lbus_tuser_enabled),              // input wire [6 : 0] s_axis_tuser
                .m_axis_tvalid(fifo_1_tvalid),            // output wire m_axis_tvalid
                .m_axis_tready(fifo_1_tready),            // input wire m_axis_tready
                .m_axis_tdata(fifo_1_tdata),              // output wire [127 : 0] m_axis_tdata
                .m_axis_tuser(fifo_1_tuser),              // output wire [6 : 0] m_axis_tuser
                .axis_data_count(),        // output wire [31 : 0] axis_data_count
                .axis_wr_data_count(),  // output wire [31 : 0] axis_wr_data_count
                .axis_rd_data_count()  // output wire [31 : 0] axis_rd_data_count
            );
        end
        else if(FIFO_DEPTH == 4096) begin
            l2a_bufferFIFO_4096 l2a_bufferFIFO_0 (
                .s_axis_aresetn(rx_resetn),          // input wire s_axis_aresetn
                .s_axis_aclk(rx_clk),                // input wire s_axis_aclk
                .s_axis_tvalid(fifo_valid & (currentState == state_wait)), // input wire s_axis_tvalid
                .s_axis_tready(s_lbus_tready),
                .s_axis_tdata(s_lbus_tdata_wire),              // input wire [127 : 0] s_axis_tdata
                .s_axis_tuser(s_lbus_tuser_enabled),              // input wire [6 : 0] s_axis_tuser
                .m_axis_tvalid(fifo_1_tvalid),            // output wire m_axis_tvalid
                .m_axis_tready(fifo_1_tready),            // input wire m_axis_tready
                .m_axis_tdata(fifo_1_tdata),              // output wire [127 : 0] m_axis_tdata
                .m_axis_tuser(fifo_1_tuser),              // output wire [6 : 0] m_axis_tuser
                .axis_data_count(),        // output wire [31 : 0] axis_data_count
                .axis_wr_data_count(),  // output wire [31 : 0] axis_wr_data_count
                .axis_rd_data_count()  // output wire [31 : 0] axis_rd_data_count
            );
        end
        else
            $error("FIFO_DEPTH is not currently allowed to be the value %d", FIFO_DEPTH);
    endgenerate
    
    reg [31:0] overflowCount;
    always @(posedge rx_clk) begin
        if(~rx_resetn) begin
            overflowCount <= '0;
        end
        else begin
            // if(|sop_wire & ~((fifo_valid & fifo_override) & s_lbus_tready))
            // two cases: first case checks for overflow on currently stored packet
            // second case checks for a new valid packet while the core isn't ready
            if(fifo_valid & ((currentState == state_wait & ~s_lbus_tready) | (currentState != state_wait & |sop_wire)))
                overflowCount <= overflowCount + 1'b1;
        end
    end
    
    reg [31:0] overflowCount_sys [2];
    always @(posedge sys_clk) begin
        overflowCount_sys[0] <= overflowCount;
        overflowCount_sys[1] <= overflowCount_sys[0];
    end
    
    assign overflow_counter = overflowCount_sys[1];
    
    wire m_lbus_tvalid;
    wire m_lbus_tready;
    wire [(M_TDATA_WIDTH*8)-1:0] m_lbus_tdata;
    wire [M_TDATA_WIDTH-1:0] m_lbus_tkeep;
    wire [(TUSER_PER_BYTE*M_TDATA_WIDTH)-1:0] m_lbus_tuser;
    
    l2a_converter l2a_converter_0 (
        .aclk(rx_clk),                    // input wire aclk
        .aresetn(rx_resetn),              // input wire aresetn
        .s_axis_tvalid(converter_tvalid),  // input wire s_axis_tvalid
        .s_axis_tready(converter_tready),  // output wire s_axis_tready
        .s_axis_tdata(fifo_1_tdata),    // input wire [31 : 0] s_axis_tdata
        .s_axis_tkeep(s_lbus_tkeep),    // input wire [3 : 0] s_axis_tkeep
        .s_axis_tuser(s_lbus_tuser),    // input wire s_axis_tlast
        .m_axis_tvalid(m_lbus_tvalid),  // output wire m_axis_tvalid
        .m_axis_tready(m_lbus_tready),  // input wire m_axis_tready
        .m_axis_tdata(m_lbus_tdata),    // output wire [63 : 0] m_axis_tdata
        .m_axis_tkeep(m_lbus_tkeep),    // output wire [7 : 0] m_axis_tkeep
        .m_axis_tuser(m_lbus_tuser)    // output wire m_axis_tlast
    );

    wire [M_TDATA_WIDTH+1-1:0] m_lbus_tuser_keep = {m_lbus_tuser[0], m_lbus_tkeep};
    wire m_fifo_tvalid;
    wire m_fifo_tready;
    wire [(M_TDATA_WIDTH*8)-1:0] m_fifo_tdata;
    wire [M_TDATA_WIDTH+1-1:0] m_fifo_tuser;

    l2a_syncFIFO l2a_syncFIFO_0 (
        .s_axis_aresetn(rx_resetn),          // input wire s_axis_aresetn
        .m_axis_aresetn(sys_resetn),          // input wire m_axis_aresetn
        .s_axis_aclk(rx_clk),                // input wire s_axis_aclk
        .s_axis_tvalid(m_lbus_tvalid),            // input wire s_axis_tvalid
        .s_axis_tready(m_lbus_tready),            // output wire s_axis_tready
        .s_axis_tdata(m_lbus_tdata),              // input wire [127 : 0] s_axis_tdata
        .s_axis_tuser(m_lbus_tuser_keep),              // input wire [6 : 0] s_axis_tuser
        .m_axis_aclk(sys_clk),                // input wire m_axis_aclk
        .m_axis_tvalid(m_fifo_tvalid),            // output wire m_axis_tvalid
        .m_axis_tready(m_fifo_tready),            // input wire m_axis_tready
        .m_axis_tdata(m_fifo_tdata),              // output wire [127 : 0] m_axis_tdata
        .m_axis_tuser(m_fifo_tuser),              // output wire [6 : 0] m_axis_tuser
        .axis_data_count(),        // output wire [31 : 0] axis_data_count
        .axis_wr_data_count(),  // output wire [31 : 0] axis_wr_data_count
        .axis_rd_data_count()  // output wire [31 : 0] axis_rd_data_count
    );

    assign s_axis_tvalid = m_fifo_tvalid & (|m_fifo_tuser[M_TDATA_WIDTH-1:0]);
    assign m_fifo_tready = s_axis_tready;
    assign s_axis_tdata = m_fifo_tdata;
    assign s_axis_tkeep = m_fifo_tuser[M_TDATA_WIDTH-1:0];
    
    reg tlast_latched;
    always_ff @(posedge sys_clk) begin
        if(~sys_resetn) begin
            tlast_latched <= 1'b0;
        end else begin
            tlast_latched <= m_fifo_tuser[M_TDATA_WIDTH];
        end
    end

    assign s_axis_tlast = m_fifo_tuser[M_TDATA_WIDTH] & s_axis_tvalid;

endmodule
