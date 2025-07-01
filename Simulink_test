///////////////////////////////////////////////////////////////////////////////
// Module: FIR Filter (50th Order, Modified for Simulink Compatibility)
// Author: Harsh Maliya
// Date  : 10 March 2024
// Description:
//     This Verilog module implements a 50th-order low-pass FIR filter.
//     Due to MATLAB HDL Coder constraints, this design avoids `for` loops
//     and dynamic addressing for memories.
///////////////////////////////////////////////////////////////////////////////

module fir_filter #(
    parameter ORDER           = 50,
    parameter DATA_IN_WIDTH  = 16,
    parameter DATA_OUT_WIDTH = 33,
    parameter TAP_DATA_WIDTH = 16
)(
    input  wire signed [DATA_IN_WIDTH-1:0]   i_fir_data_in,
    input  wire                              i_fir_en,
    input  wire                              i_clk,
    input  wire                              i_rst_n,
    output reg  signed [DATA_OUT_WIDTH-1:0]  o_fir_data_out
);

// Coefficients and shift register declarations
wire signed [TAP_DATA_WIDTH-1:0] tap[0:ORDER];
reg  signed [DATA_IN_WIDTH-1:0]  buffer[0:ORDER];
reg  signed [DATA_OUT_WIDTH-1:0] accumulator[0:ORDER];

integer i;

// -----------------------------------------------------------------------------
// FIR Tap Coefficients (Symmetric due to FIR nature)
// -----------------------------------------------------------------------------
assign tap[0]  = 16'sb1111111111111101;
assign tap[1]  = 16'sb1111111111101011;
assign tap[2]  = 16'sb1111111111011010;
assign tap[3]  = 16'sb1111111111001011;
assign tap[4]  = 16'sb1111111111000101;
assign tap[5]  = 16'sb1111111111010010;
assign tap[6]  = 16'sb1111111111111010;
assign tap[7]  = 16'sb0000000000111110;
assign tap[8]  = 16'sb0000000010010011;
assign tap[9]  = 16'sb0000000011011111;
assign tap[10] = 16'sb0000000100000010;
assign tap[11] = 16'sb0000000011011010;
assign tap[12] = 16'sb0000000001010001;
assign tap[13] = 16'sb1111111101101110;
assign tap[14] = 16'sb1111111001010110;
assign tap[15] = 16'sb1111110101010001;
assign tap[16] = 16'sb1111110010111110;
assign tap[17] = 16'sb1111110011111101;
assign tap[18] = 16'sb1111111001010110;
assign tap[19] = 16'sb0000000011100011;
assign tap[20] = 16'sb0000010010000000;
assign tap[21] = 16'sb0000100011000111;
assign tap[22] = 16'sb0000110100100100;
assign tap[23] = 16'sb0001000011101001;
assign tap[24] = 16'sb0001001101110111;
assign tap[25] = 16'sb0001010001011111;
assign tap[26] = 16'sb0001001101110111;
assign tap[27] = 16'sb0001000011101001;
assign tap[28] = 16'sb0000110100100100;
assign tap[29] = 16'sb0000100011000111;
assign tap[30] = 16'sb0000010010000000;
assign tap[31] = 16'sb0000000011100011;
assign tap[32] = 16'sb1111111001010110;
assign tap[33] = 16'sb1111110011111101;
assign tap[34] = 16'sb1111110010111110;
assign tap[35] = 16'sb1111110101010001;
assign tap[36] = 16'sb1111111001010110;
assign tap[37] = 16'sb1111111101101110;
assign tap[38] = 16'sb0000000001010001;
assign tap[39] = 16'sb0000000011011010;
assign tap[40] = 16'sb0000000100000010;
assign tap[41] = 16'sb0000000011011111;
assign tap[42] = 16'sb0000000010010011;
assign tap[43] = 16'sb0000000000111110;
assign tap[44] = 16'sb1111111111111010;
assign tap[45] = 16'sb1111111111010010;
assign tap[46] = 16'sb1111111111000101;
assign tap[47] = 16'sb1111111111001011;
assign tap[48] = 16'sb1111111111011010;
assign tap[49] = 16'sb1111111111101011;
assign tap[50] = 16'sb1111111111111101;

// -----------------------------------------------------------------------------
// Data Buffering (Shift Register Implementation)
// -----------------------------------------------------------------------------
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        for (i = 0; i <= ORDER; i = i + 1)
            buffer[i] <= '0;
    end else if (i_fir_en) begin
        buffer[0] <= i_fir_data_in;
        for (i = 1; i <= ORDER; i = i + 1)
            buffer[i] <= buffer[i-1];
    end
end

// -----------------------------------------------------------------------------
// Multiply Each Tap by Corresponding Buffered Value
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
// Output Calculation: Sum All Products
// -----------------------------------------------------------------------------
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n)
        o_fir_data_out <= '0;
    else if (i_fir_en) begin
        o_fir_data_out <= '0;
        for (i = 0; i <= ORDER; i = i + 1)
            o_fir_data_out <= o_fir_data_out + accumulator[i];
    end
end

endmodule
