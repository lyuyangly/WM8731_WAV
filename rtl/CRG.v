//***************************************************************************
//   File name        :   CRG.v
//   Module name      :   
//   Author           :   Lyu Yang
//   Email            :
//   Date             :   2017-07-08
//   Version          :   v1.0
//
//   Abstract         :   
//
//   Modification history
//   ------------------------------------------------------------------------
// Version       Date(yyyy/mm/dd)   name
// Description
//
// $Log$
//***************************************************************************
module CRG
(
	input			clk,
	input			rst,
	output			clk_50m,
	output	reg		clk_i2s,
	output			rst_n,
	output			i2s_rst_n
);

reg		rst_ff0, rst_ff1;
reg		i2s_rst_ff0, i2s_rst_ff1;

// I2S Fs = 20K
reg	[7:0]	clk_div_cnt;

assign clk_50m = clk;

// I2S CLK
always @ (posedge clk or negedge rst_n)
	if(!rst_n) begin
		clk_div_cnt <= 'd0;
		clk_i2s <= 1'b0;
	end
	else begin
		if(clk_div_cnt == 8'd34) begin
			clk_div_cnt <= 8'd0;
			clk_i2s <= ~clk_i2s;
		end
		else begin
			clk_i2s <= clk_i2s;
			clk_div_cnt <= clk_div_cnt + 1'b1;
		end
	end

// Reset Generation
always @ (posedge clk or posedge rst)
begin
	if(rst) begin
		rst_ff0 <= 1'b0;
		rst_ff1 <= 1'b0;
	end
	else begin
		rst_ff0 <= 1'b1;
		rst_ff1 <= rst_ff0;
	end
end

assign rst_n = rst_ff1;

// Reset Generation
always @ (posedge clk_i2s or posedge rst)
begin
	if(rst) begin
		i2s_rst_ff0 <= 1'b0;
		i2s_rst_ff1 <= 1'b0;
	end
	else begin
		i2s_rst_ff0 <= 1'b1;
		i2s_rst_ff1 <= i2s_rst_ff0;
	end
end

assign i2s_rst_n = i2s_rst_ff1;


endmodule
