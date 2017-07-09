//***************************************************************************
//   File name        :   I2S_TOP.v
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
module I2S_TOP #(
	parameter	W = 16 )(
	// Clock and Reset
	input				clk,
	input				rst_n,
	
	// ADC FIFO
	input				adc_clk,
	input				adc_rd,
	output				adc_empty,
	output	[W-1:0]		adc_rdat,
	
	// DAC FIFO
	input				dac_clk,
	input				dac_wr,
	output				dac_full,
	input	[W-1:0]		dac_wdat,
	
	// I2S Ports
	output				i2s_bclk,
	output				i2s_adclrc,
	input				i2s_adcdat,
	output				i2s_daclrc,
	output				i2s_dacdat
);

// Since it is I2S Format, the input clock frequency should be: N * Fs
wire			i2s_adc_vld;
wire 			adc_fifo_wr;
wire [W-1:0]	adc_fifo_wdat;
wire 			adc_fifo_full;

wire			i2s_dac_req;
wire 			dac_fifo_rd;
wire [W-1:0]	dac_fifo_rdat;
wire 			dac_fifo_empty;

// FiFo for DAC
async_fifo U_I2S_FIFO_DAC (
	.wr_clk			(dac_clk		),
	.wr_reset_n		(rst_n			),
	.wr_en			(dac_wr			),
	.wr_data		(dac_wdat		),
	.full			(				),
	.afull			(dac_full		),
	.rd_clk			(clk			),
	.rd_reset_n		(rst_n			),
	.rd_en			(dac_fifo_rd	),
	.rd_data		(dac_fifo_rdat	),
	.empty			(dac_fifo_empty	),
	.aempty			(				)
	);

// FiFo for ADC
async_fifo U_I2S_FIFO_ADC (
	.wr_clk			(clk			),
	.wr_reset_n		(rst_n			),
	.wr_en			(adc_fifo_wr	),
	.wr_data		(adc_fifo_wdat	),
	.full			(adc_fifo_full	),
	.afull			(				),
	.rd_clk			(adc_clk		),
	.rd_reset_n		(rst_n			),
	.rd_en			(adc_rd			),
	.rd_data		(adc_rdat		),
	.empty			(				),
	.aempty			(adc_empty		)
);

// I2S Interface
I2S_ITF #(.W(W)
	) U_I2S_ITF (
	// Clock and Reset
	.clk				(clk			),
	.rst_n				(rst_n			),
	
	// ADC
	.adc_vld			(i2s_adc_vld	),
	.adc_dat			(adc_fifo_wdat	),
	// DAC
	.dac_req			(i2s_dac_req),
	.dac_dat			(dac_fifo_rdat	),
	
	// I2S Ports
	.i2s_bclk			(i2s_bclk		),
	.i2s_adclrc			(i2s_adclrc		),
	.i2s_adcdat			(i2s_adcdat		),
	.i2s_daclrc			(i2s_daclrc		),
	.i2s_dacdat			(i2s_dacdat		)
);

// FIFO Read & Write Control
assign adc_fifo_wr = i2s_adc_vld & ~adc_fifo_full;
assign dac_fifo_rd = i2s_dac_req & ~dac_fifo_empty;

endmodule
