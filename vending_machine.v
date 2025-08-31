module vending_machine(clk,coin1,coin2,select,buy,load,money,products,outofstock);
// EXERCISE : explain the logic of vending machine
	input clk; 
	input coin1; //25 cents
	input coin2; //1 dollar (100 cents)
	input [3:0] select;
	input buy;
	input [3:0] load;
	output signed  [11:0] money;
	//to count the register count each bit
	//output reg [11:0] money=0;
	output reg [3:0] products=0;
	output reg [3:0] outofstock=0;
	reg signed [7:0] encrypted_money = 0;
	reg coin1_prev,coin2_prev;
	reg buy_prev;
	reg [3:0] stock1=4'b1010;
	reg [3:0] stock2=4'b1010;
	reg [3:0] stock3=4'b1010;
	reg [3:0] stock4=4'b1010;
	assign money = encrypted_money * 25;
	always @ (posedge clk) begin
		coin1_prev <= coin1;
		coin2_prev <= coin2;
		buy_prev <= buy;

		if (coin1_prev == 1'b0 && coin1 == 1'b1) encrypted_money <= encrypted_money + 7'd1;
		else if (coin2_prev == 1'b0 && coin2 == 1'b1) encrypted_money <= encrypted_money + 7'd4;
		else if (buy_prev == 1'b0 && buy == 1'b1) begin
			case (select)
			4'b0001: if (money >= 12'd25 && stock1 > 0) begin
							products[0] <= 1'b1; stock1 <= stock1 - 1'b1; encrypted_money <= encrypted_money - 7'd1;
							end
			4'b0010: if (money >= 12'd75 && stock2 > 0) begin
							products[1] <= 1'b1; stock2 <= stock2 - 1'b1; encrypted_money <= encrypted_money - 7'd3;
							end
			4'b0100: if (money >= 12'd150 && stock3 > 0) begin
							products[2] <= 1'b1; stock3 <= stock3 - 1'b1; encrypted_money <= encrypted_money - 7'd6;
							end
			4'b1000: if (money >= 12'd200 && stock4 > 0) begin
							products[3] <= 1'b1; stock4 <= stock4 - 1'b1; encrypted_money <= encrypted_money - 7'd8;
							end
			endcase
		end
		
		else if (buy_prev == 1'b1 && buy == 1'b0) begin
			products[0] <= 1'b0; products[1] <= 1'b0; products[2] <= 1'b0; products[3] <= 1'b0;
			end
		else begin
			if (stock1 == 4'b0) outofstock[0] <= 1'b1; else outofstock[0] <= 1'b0;
			if (stock2 == 4'b0) outofstock[1] <= 1'b1; else outofstock[1] <= 1'b0;
			if (stock3 == 4'b0) outofstock[2] <= 1'b1; else outofstock[2] <= 1'b0;
			if (stock4 == 4'b0) outofstock[3] <= 1'b1; else outofstock[3] <= 1'b0;
		case (load)
		4'b0001: stock1 <= 4'b1111;
		4'b0010: stock2 <= 4'b1111;
		4'b0100: stock3 <= 4'b1111;
		4'b1000: stock4 <= 4'b1111;
		endcase
		end
		end
endmodule

module vend_machine_wrapper 
	(input dut_clk, output signed  [11:0] dut_money, output [3:0] dut_products, output [3:0] outofstock, output [7:0] rom_out);
	wire clk, coin1, coin2;
	wire [3:0] select;
	wire buy;
	wire [3:0] load;
	wire [7:0] out;
	reg [7:0] rom [0:31]; // rom has 32 register each of 19 bit wide ( 16 + 2 to 0)
	reg [7:0] romout;
	reg [4:0] romaddr =0;		// 5 address line for addresing 32 register
	//wire result_rdy;
	wire [3:0] out_p;
	wire [3:0] out_o;
	always @(*) begin romout<= rom[romaddr]; // assigning output of rom from selected rom address
	end
	always @(posedge dut_clk) begin
	if( romaddr < 32) romaddr <= romaddr +1; // if result is not ready then rom addr is getting incremented by 1
	end
	assign clk=romout[0];
	assign coin1= romout[1];
	assign coin2=romout[2];
	assign select=romout[6:3];	
	assign buy=romout[7];
	//assign load=romout[11:8];
	assign dut_money = out;
	assign dut_products = out_p;
	assign dut_outofstock = out_o;
	assign rom_out = romout;
	vending_machine dut(clk,coin1,coin2,select,buy,load,out,out_p,out_o);
	integer i;
	initial begin
		rom[0] = {1'b0,4'b0000,1'b0,1'b0,1'b0};
		rom[1] = {1'b0,4'b0000,1'b0,1'b0,1'b1};
		rom[2] = {1'b0,4'b0000,1'b0,1'b1,1'b0};
		rom[3] = {1'b0,4'b0000,1'b0,1'b1,1'b1};
		rom[4] = {1'b0,4'b0000,1'b1,1'b0,1'b0};
		rom[5] = {1'b0,4'b0000,1'b1,1'b0,1'b1};
		rom[6] = {1'b0,4'b0000,1'b0,1'b1,1'b0};
		rom[7] = {1'b0,4'b0000,1'b0,1'b1,1'b1};
		rom[8] = {1'b0,4'b0000,1'b1,1'b0,1'b0};
		rom[9] = {1'b0,4'b0000,1'b1,1'b0,1'b1};
		rom[10] = {1'b0,4'b0100,1'b0,1'b0,1'b0};
		rom[11] = {1'b0,4'b0100,1'b0,1'b0,1'b1};
		rom[12] = {1'b1,4'b0100,1'b0,1'b0,1'b0};
		rom[13] = {1'b1,4'b0100,1'b0,1'b0,1'b1};
		rom[14] = {1'b0,4'b0100,1'b0,1'b0,1'b0};
		rom[15] = {1'b0,4'b0100,1'b0,1'b0,1'b1};
		rom[16] = {1'b0,4'b0010,1'b0,1'b0,1'b0};
		rom[17] = {1'b0,4'b0010,1'b0,1'b0,1'b1};
		rom[18] = {1'b1,4'b0010,1'b0,1'b0,1'b0};
		rom[19] = {1'b1,4'b0010,1'b0,1'b0,1'b1};
		rom[20] = {1'b0,4'b0010,1'b0,1'b0,1'b0};
		rom[21] = {1'b0,4'b0010,1'b0,1'b0,1'b1};
		for(i=22;i<32;i=i+2)
			begin
			rom[i] = {1'b0,4'b0010,1'b0,1'b0,1'b0};
			rom[i+1] = {1'b0,4'b0010,1'b0,1'b0,1'b1};
		end
	end
endmodule
