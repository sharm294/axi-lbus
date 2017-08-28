`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/14/2017 05:49:15 PM
// Design Name: 
// Module Name: cmac_bringup
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


module cmac_bringup(
    input init_clk,
    input reset,
    input stat_rx_aligned,
    input stat_rx_remote_fault,

    output ctl_tx_enable,
    output ctl_tx_send_idle,
    output ctl_tx_send_rfi,
    output ctl_rx_enable
);

    localparam state_reset = 2'b0;
    localparam state_gt_locked = 2'b01;
    localparam state_rx_aligned = 2'b10;
    localparam state_ready = 2'b11;

    reg [1:0] current_state = state_reset;
    reg [1:0] next_state = state_reset;

    always @(*) begin
        case(current_state)
            state_reset:
                begin
                    if(reset) next_state = state_reset;
                    else next_state = state_gt_locked;
                end
            state_gt_locked:
                begin
                    if(stat_rx_aligned) next_state = state_rx_aligned;
                    else next_state = state_gt_locked;
                end
            state_rx_aligned:
                begin
                    if(!stat_rx_remote_fault) next_state = state_ready;
                    else next_state = state_rx_aligned;
                end
            state_ready:
                begin
                    next_state = state_ready;
                end
        endcase
    end

    assign ctl_tx_enable = current_state == state_ready;
    assign ctl_tx_send_rfi = current_state == state_gt_locked;
    assign ctl_rx_enable = current_state != state_reset;
    assign ctl_tx_send_idle = stat_rx_remote_fault;

    always @(posedge init_clk) begin
        if(reset)
            current_state <= state_reset;
        else
            current_state <= next_state;
    end

    
endmodule