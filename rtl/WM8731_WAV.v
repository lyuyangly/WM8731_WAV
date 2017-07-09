//***************************************************************************
//   File name        :   WM8731_WAV.v
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
module WM8731_WAV(
    input				CLK,
    input				RST,
	input	[3:0]		KEY,
    output				WM_I2C_SCLK,
    inout				WM_I2C_SDAT,
    output				WM_BCLK,
	output				WM_ADCLRC,
	input				WM_ADCDAT,
	output				WM_DACLRC,
	output				WM_DACDAT,
	output				WM_CFG_DONE
);


wire		clk_50m, clk_i2s, i2s_bclk;
wire		rst_n, i2s_rst_n;

wire				i2s_dac_wr;
wire				i2s_dac_full;
wire	[15:0]		i2s_dac_wdat;


// CRG
CRG U_CRG (
	.clk			(CLK		),
	.rst			(RST		),
	.clk_50m		(clk_50m	),
	.clk_i2s		(clk_i2s	),
	.i2s_rst_n		(i2s_rst_n	),
	.rst_n			(rst_n		)
);

// WM8731 I2C Init
DEV_I2C_CONFIG U_WMCFG (
	.iCLK			(clk_50m	),
	.iRST_N			(rst_n		),
	.I2C_SCLK		(WM_I2C_SCLK),
	.I2C_SDAT		(WM_I2C_SDAT),
	.I2C_DONE		(WM_CFG_DONE)
);

// Sine Wave
nco U_NCO (
	.clk_i			(WM_DACLRC),
	.rst_n			(i2s_rst_n	),
	.acc_i			({KEY, 1'b1,10'd0}),
	.cos_o			(i2s_dac_wdat),
	.sin_o			(			)
);	
	
// I2S
I2S_TOP U_I2S (
	// Clock and Reset
	.clk			(clk_i2s	),
	.rst_n			(i2s_rst_n	),
	
	// ADC FIFO
	.adc_clk		(),
	.adc_rd			(),
	.adc_empty		(),
	.adc_rdat		(),
	
	// DAC FIFO
	.dac_clk		(WM_DACLRC	),
	.dac_wr			(~i2s_dac_full),
	.dac_full		(i2s_dac_full),
	.dac_wdat		(i2s_dac_wdat),
	
	// I2S Ports
	.i2s_bclk		(i2s_bclk	),
	.i2s_adclrc		(WM_ADCLRC	),
	.i2s_adcdat		(WM_ADCDAT	),
	.i2s_daclrc		(WM_DACLRC	),
	.i2s_dacdat		(WM_DACDAT	)
);

// CLock BUF
OBUF U_BLCK_BUF (
	.I				(i2s_bclk	),
	.O				(WM_BCLK	)
);

/* Analyzer
wire	[35:0]		CONTROL;

ICON U_OCON (
	.CONTROL0	(CONTROL)
);

ILA U_ILA (
    .CLK		(clk_i2s),
    .CONTROL	(CONTROL),
    .TRIG0		(i2s_dac_wdat)
);
*/

endmodule
