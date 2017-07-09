//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:49:49 07/09/2017 
// Design Name: 
// Module Name:    I2S_ITF_TB 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100ps
module I2S_ITF_TB(
    );
reg			clk;
reg			rst_n;
wire		adc_vld;
wire	[15:0]	adc_dat;
wire		dac_req;
reg	[15:0]	dac_dat;
wire		i2s_bclk;
wire	i2s_adclrc;
wire	i2s_daclrc;
wire	i2s_dacdat;
reg	   i2s_adcdat;

always #10 clk = !clk;
always @ (posedge clk)
begin
	if(dac_req)
		dac_dat <= dac_dat + 1;
	i2s_adcdat <= i2s_adcdat ^ 1;
end
initial begin
	clk = 0;
	rst_n = 0;
	i2s_adcdat = 0;
	dac_dat = 16'hdeab;
	#100;
	rst_n = 1;
	#8000;
	$finish;
end

I2S_ITF ins (
	// Clock and Reset
	.clk(clk),
	.rst_n(rst_n),
	
	// ADC
	.adc_vld(adc_vld),
	.adc_dat(adc_dat),
	.dac_req(dac_req),
	.dac_dat(dac_dat),
	
	// I2S Ports
	.i2s_bclk(i2s_bclk),
	.i2s_adclrc(i2s_adclrc),
	.i2s_adcdat	(i2s_adcdat),
	.i2s_daclrc	(i2s_daclrc),
	.i2s_dacdat(i2s_dacdat)
);


endmodule
