module v_m_hw4
(input wire CLOCK_50,
input wire[0:0] KEY,
output wire [12:0] LEDR,
output wire [7:0] LEDG);

wire dut_clk;
wire[11:0] dut_money;
wire[3:0] dut_products;
wire[3:0] dut_outofstock;
wire[7:0] rom_out;
// clk and result mapping is done from GCD wrapper
vend_machine_wrapper  i0(dut_clk,dut_money,dut_products,dut_outofstock, rom_out);

assign LEDR[12:1] = dut_money[11:0]; // result is from LED 7 to LED1
assign LEDR[0] = dut_clk;				//LED 0 is showing CLK
assign LEDG[7:4] = dut_products[3:0];
assign LEDG[3:0] = dut_outofstock[3:0];

//localparam log2_slowdown_factor = 27;  // enable for FPGA
localparam log2_slowdown_factor = 1; //enable for modelsim
reg[log2_slowdown_factor - 1 : 0] k_bit_counter = 0;
assign dut_clk = k_bit_counter[log2_slowdown_factor-1];//dut_clk is taking change of MSB

always @(posedge CLOCK_50) begin
	k_bit_counter = k_bit_counter + 1;
	end
//At every posedge of CLK_50, k_bit_counter is incremented and effect of MSB is mapped to dut_clk
endmodule