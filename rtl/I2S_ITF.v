//***************************************************************************
//   File name        :   I2S_ITF.v
//   Module name      :   
//   Author           :   Lyu Yang
//   Email            :
//   Date             :   2017-07-09
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
`timescale 1ns / 100ps
module I2S_ITF #(
	parameter	W = 16
	)(
	// Clock and Reset
	input	wire			clk,
	input	wire			rst_n,
	
	// I2S ADC
	output	reg				adc_vld,
	output	wire	[W-1:0]	adc_dat,
	// I2S DAC
	output	reg				dac_req,
	input	wire	[W-1:0]	dac_dat,
	
	// I2S Ports
	output	wire			i2s_bclk,
	output	wire			i2s_adclrc,
	input	wire			i2s_adcdat,
	output	wire			i2s_daclrc,
	output	reg				i2s_dacdat
);

// Since it is I2S Format, the input clock frequency should be: N * Fs
localparam	N = 2*W + 4;
reg		[$clog2(N) : 0]	i2s_cnt;
reg		[W-1 : 0]			i2s_dat_dac;
reg		[W-1 : 0]			i2s_dat_adc;

// I2S Timing Counter
always @ (negedge clk or negedge rst_n)
	if(!rst_n) begin
		i2s_cnt <= 'd0;
	end
	else begin
		if(i2s_cnt == N - 1)
			i2s_cnt <= 'd0;
		else
			i2s_cnt <= i2s_cnt + 1'b1;
	end

// DAC Timing
always @ (negedge clk or negedge rst_n)
	if(!rst_n ) begin
		dac_req <= 1'b0;
		i2s_dat_dac <= 'd0;
		i2s_dacdat <= 1'b0;
	end
	else begin
		if(i2s_cnt == N - 2) begin
			dac_req <= 1'b1;
			i2s_dat_dac <= 'd0;
		end
		else if(i2s_cnt == N - 1) begin
			dac_req <= 1'b0;
			i2s_dat_dac <= dac_dat;
		end
		
		if(i2s_cnt >= 0 && i2s_cnt < W) begin
			i2s_dacdat <= i2s_dat_dac[W - i2s_cnt - 1];
		end
		else if(i2s_cnt >= N/2 && i2s_cnt < N/2 + W) begin
			i2s_dacdat <= i2s_dat_dac[W + N/2 - i2s_cnt - 1];
		end
		else begin
			i2s_dacdat <= 1'b0;
		end
	end

// ADC Timing
always @ (posedge clk or negedge rst_n)
	if(!rst_n) begin
		adc_vld <= 1'b0;
		i2s_dat_adc <= 'd0;
	end
	else begin
		if(i2s_cnt == N -1) begin
			adc_vld <= 1'b1;
		end
		else if(i2s_cnt == 'd0) begin
			adc_vld <= 1'b0;
			i2s_dat_adc <= 'd0;
		end
		else if(i2s_cnt > 0 && i2s_cnt < W + 1) begin
			i2s_dat_adc[W - i2s_cnt] <= i2s_adcdat;
		end
		else if(i2s_cnt > N/2 && i2s_cnt < N/2 + W + 1) begin
			i2s_dat_adc[W + N/2 - i2s_cnt] <= i2s_adcdat;
		end
		else 
			i2s_dat_adc <= i2s_dat_adc;
	end

assign i2s_bclk = clk;

assign i2s_adclrc = i2s_cnt < N/2 ? 1'b0 : 1'b1;

assign i2s_daclrc = i2s_cnt < N/2 ? 1'b0 : 1'b1;

assign adc_dat = i2s_dat_adc;

endmodule
