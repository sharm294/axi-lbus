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
    parameter M_TDATA_WIDTH = 8,
    parameter FIFO_DEPTH = 16,
    parameter SYNC_STAGES = 2
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
    output reg s_axis_tlast
);

    localparam LBUS_SEGMENT_WIDTH = 16; //each LBUS segment is 16 bytes (128 bit)
    localparam LBUS_SEGMENT_CNT = 4; //number of LBUS segments - dependency on being a power of 2
    localparam TUSER_PER_BYTE = 1;

    localparam LBUS_SEG_BITS = LBUS_SEGMENT_WIDTH*8;
    localparam LBUS_SEG_CNT_LOG = $clog2(LBUS_SEGMENT_CNT);
    localparam M_TUSER_WIDTH = TUSER_PER_BYTE*LBUS_SEGMENT_WIDTH*LBUS_SEGMENT_CNT;
    localparam S_TUSER_WIDTH = TUSER_PER_BYTE*M_TDATA_WIDTH;

    wire s_lbus_tvalid;
    wire s_lbus_tready;
    wire [LBUS_SEG_BITS-1:0] s_lbus_tdata_big [LBUS_SEGMENT_CNT] = '{rx_datain0,rx_datain1,rx_datain2,rx_datain3};
    wire [LBUS_SEG_BITS-1:0] s_lbus_tdata_reversed [LBUS_SEGMENT_CNT];
    wire [LBUS_SEG_BITS-1:0] s_lbus_tdata_raw [LBUS_SEGMENT_CNT];
    wire [(LBUS_SEG_BITS*LBUS_SEGMENT_CNT)-1:0] s_lbus_tdata;
    wire [3:0] s_lbus_mtyin [LBUS_SEGMENT_CNT];
    reg [LBUS_SEGMENT_WIDTH-1:0] s_lbus_tkeep_raw [LBUS_SEGMENT_CNT];
    wire [(LBUS_SEGMENT_WIDTH*LBUS_SEGMENT_CNT)-1:0] s_lbus_tkeep;
    wire [23:0] fifo_1_tuser;

    wire [M_TUSER_WIDTH-1:0] s_lbus_tuser = {{(LBUS_SEGMENT_WIDTH/2){packet_endianness[3],fifo_1_tuser[3]}},
        {(LBUS_SEGMENT_WIDTH/2){packet_endianness[2],fifo_1_tuser[2]}},
        {(LBUS_SEGMENT_WIDTH/2){packet_endianness[1],fifo_1_tuser[1]}},
        {(LBUS_SEGMENT_WIDTH/2){packet_endianness[0],fifo_1_tuser[0]}}};

    wire [3:0] packet_endianness; //1 means MSB half of packet is last, 0 means LSB side
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
                    assign s_lbus_tdata_reversed[g][(f*8)+(M_TDATA_WIDTH*8)-(h*8)-1-:8] = s_lbus_tdata_big[g][(f*8)+(h*8)+7-:8];
                end
                assign s_lbus_tdata_raw[g][((M_TDATA_WIDTH+f)*8)-1-:(M_TDATA_WIDTH*8)] = 
                    s_lbus_tdata_reversed[g][((LBUS_SEGMENT_WIDTH-f)*8)-1-:(M_TDATA_WIDTH*8)];
            end
            
            assign packet_endianness[g] = s_lbus_mtyin[g][3];

            always_comb begin : mtyin_tkeep
                case(s_lbus_mtyin[g]) //need to update if LBUS_SEGMENT_WIDTH != 16
                    /*4'h0: s_lbus_tkeep_raw[g] = 16'hFFFF;
                    4'h1: s_lbus_tkeep_raw[g] = 16'hFEFF;
                    4'h2: s_lbus_tkeep_raw[g] = 16'hFCFF;
                    4'h3: s_lbus_tkeep_raw[g] = 16'hF8FF;
                    4'h4: s_lbus_tkeep_raw[g] = 16'hF0FF;
                    4'h5: s_lbus_tkeep_raw[g] = 16'hE0FF;
                    4'h6: s_lbus_tkeep_raw[g] = 16'hC0FF;
                    4'h7: s_lbus_tkeep_raw[g] = 16'h80FF;
                    4'h8: s_lbus_tkeep_raw[g] = 16'h00FF;
                    4'h9: s_lbus_tkeep_raw[g] = 16'h00FE;
                    4'hA: s_lbus_tkeep_raw[g] = 16'h00FC;
                    4'hB: s_lbus_tkeep_raw[g] = 16'h00F8;
                    4'hC: s_lbus_tkeep_raw[g] = 16'h00F0;
                    4'hD: s_lbus_tkeep_raw[g] = 16'h00E0;
                    4'hE: s_lbus_tkeep_raw[g] = 16'h00C0;
                    4'hF: s_lbus_tkeep_raw[g] = 16'h0080;*/

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

    wire fifo_1_tvalid;
    wire [(LBUS_SEG_BITS*LBUS_SEGMENT_CNT)-1:0] fifo_1_tdata;

    axis_data_fifo_0 /*#(
        .TDATA_WIDTH_BYTES(LBUS_SEGMENT_WIDTH*LBUS_SEGMENT_CNT),
        .TUSER_WIDTH_BITS(20),
        .FIFO_DEPTH_WORDS(FIFO_DEPTH),
        .PACKET_MODE(1)
    )*/ fifo_0 (
        .s_axis_aresetn(rx_resetn),          // input wire s_axis_aresetn
        .s_axis_aclk(rx_clk),                // input wire s_axis_aclk
        .s_axis_tvalid(s_lbus_tvalid),            // input wire s_axis_tvalid
        .s_axis_tready(),
        .s_axis_tdata(s_lbus_tdata),              // input wire [127 : 0] s_axis_tdata
        .s_axis_tuser({ena,mtyin,eop}),              // input wire [6 : 0] s_axis_tuser
        .m_axis_tvalid(fifo_1_tvalid),            // output wire m_axis_tvalid
        .m_axis_tready(s_lbus_tready),            // input wire m_axis_tready
        .m_axis_tdata(fifo_1_tdata),              // output wire [127 : 0] m_axis_tdata
        .m_axis_tuser(fifo_1_tuser),              // output wire [6 : 0] m_axis_tuser
        .axis_data_count(),        // output wire [31 : 0] axis_data_count
        .axis_wr_data_count(),  // output wire [31 : 0] axis_wr_data_count
        .axis_rd_data_count()  // output wire [31 : 0] axis_rd_data_count
    );



    wire m_lbus_tvalid;
    wire m_lbus_tready;
    wire [(M_TDATA_WIDTH*8)-1:0] m_lbus_tdata;
    wire [M_TDATA_WIDTH-1:0] m_lbus_tkeep;
    wire [(TUSER_PER_BYTE*M_TDATA_WIDTH)-1:0] m_lbus_tuser;
    axis_dwidth_converter_0 /*#(
        .S_TDATA_WIDTH(LBUS_SEGMENT_WIDTH*LBUS_SEGMENT_CNT),
        .M_TDATA_WIDTH(M_TDATA_WIDTH),
        .TUSER_PER_BYTE(TUSER_PER_BYTE)
    )*/ dwidth_converter (
        .aclk(rx_clk),                    // input wire aclk
        .aresetn(rx_resetn),              // input wire aresetn
        .s_axis_tvalid(fifo_1_tvalid),  // input wire s_axis_tvalid
        .s_axis_tready(s_lbus_tready),  // output wire s_axis_tready
        .s_axis_tdata(fifo_1_tdata),    // input wire [31 : 0] s_axis_tdata
        .s_axis_tkeep(s_lbus_tkeep),    // input wire [3 : 0] s_axis_tkeep
        .s_axis_tuser(s_lbus_tuser),    // input wire s_axis_tlast
        .m_axis_tvalid(m_lbus_tvalid),  // output wire m_axis_tvalid
        .m_axis_tready(m_lbus_tready),  // input wire m_axis_tready
        .m_axis_tdata(m_lbus_tdata),    // output wire [63 : 0] m_axis_tdata
        .m_axis_tkeep(m_lbus_tkeep),    // output wire [7 : 0] m_axis_tkeep
        .m_axis_tuser(m_lbus_tuser)    // output wire m_axis_tlast
    );

    wire [M_TDATA_WIDTH+2-1:0] m_lbus_tuser_keep = {m_lbus_tuser[1:0], m_lbus_tkeep};
    wire m_fifo_tvalid;
    wire m_fifo_tready;
    wire [(M_TDATA_WIDTH*8)-1:0] m_fifo_tdata;
    wire [M_TDATA_WIDTH+2-1:0] m_fifo_tuser;

    axis_data_fifo_1 /*#(
        .TDATA_WIDTH_BYTES(M_TDATA_WIDTH),
        .TUSER_WIDTH_BITS(M_TDATA_WIDTH+1),
        .FIFO_DEPTH_WORDS(FIFO_DEPTH),
        .SYNC_STAGES(SYNC_STAGES)
    )*/ fifo_1 (
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

    assign s_axis_tvalid = m_fifo_tvalid;
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

    always_comb begin : tlast
        case(m_fifo_tuser[M_TDATA_WIDTH+1:M_TDATA_WIDTH])
            2'b00: s_axis_tlast = 1'b0;
            2'b01: s_axis_tlast = tlast_latched;
            2'b10: s_axis_tlast = 1'b0;
            2'b11: s_axis_tlast = ~tlast_latched;
        endcase
    end

    //assign s_axis_tlast = m_fifo_tuser[M_TDATA_WIDTH];

endmodule
