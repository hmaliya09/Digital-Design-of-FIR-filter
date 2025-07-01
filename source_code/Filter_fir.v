///////////////////////////////////////////////////////////////////////////////
// Module: Configurable FIR Filter (50th Order with Dynamic Coefficients)
// Author: Harsh Maliya (Rewritten)
// Date  : 10 Mar 2024
// Description:
//   A flexible and parameterized FIR filter with runtime coefficient updates.
//   Supports a 50th-order low-pass filter with a dynamic tap write interface.
///////////////////////////////////////////////////////////////////////////////

module fir_filter #(
    parameter ORDER            = 50,
    parameter DATA_IN_WIDTH   = 16,
    parameter DATA_OUT_WIDTH  = 32,
    parameter TAP_DATA_WIDTH  = 16,
    parameter TAP_ADDR_WIDTH  = 6
)(
    input  wire signed [DATA_IN_WIDTH-1:0]   i_fir_data_in,
    input  wire                              i_fir_en,
    input  wire                              i_tap_wr_en,
    input  wire       [TAP_ADDR_WIDTH-1:0]   i_tap_wr_addr,
    input  wire       [TAP_DATA_WIDTH-1:0]   i_tap_wr_data,
    input  wire                              i_clk,
    input  wire                              i_rst_n,
    output reg  signed [DATA_OUT_WIDTH-1:0]  o_fir_data_out
);

// -----------------------------------------------------------------------------
// Internal Registers: Tap Memory, Shift Buffer, Accumulators
// -----------------------------------------------------------------------------
reg signed [TAP_DATA_WIDTH-1:0]  tap[0:ORDER];
reg signed [DATA_IN_WIDTH-1:0]   buffer[0:ORDER];
reg signed [DATA_OUT_WIDTH-1:0]  accumulator[0:ORDER];

integer i;

// -----------------------------------------------------------------------------
// Coefficient Initialization or Update Logic
// -----------------------------------------------------------------------------
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        // Default FIR Coefficients Initialization (symmetric, 51 taps)
        tap[ 0] <= 16'sb1111111111111101;
        tap[ 1] <= 16'sb1111111111101011;
        tap[ 2] <= 16'sb1111111111011010;
        tap[ 3] <= 16'sb1111111111001011;
        tap[ 4] <= 16'sb1111111111000101;
        tap[ 5] <= 16'sb1111111111010010;
        tap[ 6] <= 16'sb1111111111111010;
        tap[ 7] <= 16'sb0000000000111110;
        tap[ 8] <= 16'sb0000000010010011;
        tap[ 9] <= 16'sb0000000011011111;
        tap[10] <= 16'sb0000000100000010;
        tap[11] <= 16'sb0000000011011010;
        tap[12] <= 16'sb0000000001010001;
        tap[13] <= 16'sb1111111101101110;
        tap[14] <= 16'sb1111111001010110;
        tap[15] <= 16'sb1111110101010001;
        tap[16] <= 16'sb1111110010111110;
        tap[17] <= 16'sb1111110011111101;
        tap[18] <= 16'sb1111111001010110;
        tap[19] <= 16'sb0000000011100011;
        tap[20] <= 16'sb0000010010000000;
        tap[21] <= 16'sb0000100011000111;
        tap[22] <= 16'sb0000110100100100;
        tap[23] <= 16'sb0001000011101001;
        tap[24] <= 16'sb0001001101110111;
        tap[25] <= 16'sb0001010001011111;
        tap[26] <= 16'sb0001001101110111;
        tap[27] <= 16'sb0001000011101001;
        tap[28] <= 16'sb0000110100100100;
        tap[29] <= 16'sb0000100011000111;
        tap[30] <= 16'sb0000010010000000;
        tap[31] <= 16'sb0000000011100011;
        tap[32] <= 16'sb1111111001010110;
        tap[33] <= 16'sb1111110011111101;
        tap[34] <= 16'sb1111110010111110;
        tap[35] <= 16'sb1111110101010001;
        tap[36] <= 16'sb1111111001010110;
        tap[37] <= 16'sb1111111101101110;
        tap[38] <= 16'sb0000000001010001;
        tap[39] <= 16'sb0000000011011010;
        tap[40] <= 16'sb0000000100000010;
        tap[41] <= 16'sb0000000011011111;
        tap[42] <= 16'sb0000000010010011;
        tap[43] <= 16'sb0000000000111110;
        tap[44] <= 16'sb1111111111111010;
        tap[45] <= 16'sb1111111111010010;
        tap[46] <= 16'sb1111111111000101;
        tap[47] <= 16'sb1111111111001011;
        tap[48] <= 16'sb1111111111011010;
        tap[49] <= 16'sb1111111111101011;
        tap[50] <= 16'sb1111111111111101;
    end else if (i_tap_wr_en && !i_fir_en) begin
        tap[i_tap_wr_addr] <= i_tap_wr_data; // Safe coefficient update
    end
end

// -----------------------------------------------------------------------------
// Shift Register (Delay Line) for Input Samples
// -----------------------------------------------------------------------------
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        for (i = 0; i <= ORDER; i = i + 1)
            buffer[i] <= '0;
    end else if (i_fir_en) begin
        buffer[0] <= i_fir_data_in;
        for (i = 1; i <= ORDER; i = i + 1)
            buffer[i] <= buffer[i - 1];
    end
end

// -----------------------------------------------------------------------------
// Multiply Each Tap with Corresponding Buffered Input Sample
// -----------------------------------------------------------------------------
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        for (i = 0; i <= ORDER; i = i + 1)
            accumulator[i] <= '0;
    end else if (i_fir_en) begin
        for (i = 0; i <= ORDER; i = i + 1)
            accumulator[i] <= buffer[i] * tap[i];
    end
end

// -----------------------------------------------------------------------------
// Final Output by Summing All Tap Products
// -----------------------------------------------------------------------------
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n)
        o_fir_data_out <= '0;
    else if (i_fir_en) begin
        o_fir_data_out <= 0;
        for (i = 0; i <= ORDER; i = i + 1)
            o_fir_data_out <= o_fir_data_out + accumulator[i];
    end
end

endmodule
