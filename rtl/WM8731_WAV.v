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
    output				WM_I2C_SCLK,
    inout				WM_I2C_SDAT,
    output				WM_BCLK,
	output				WM_ADCLRC,
	input				WM_ADCDAT,
	output				WM_DACLRC,
	output				WM_DACDAT,
	output				WM_CFG_DONE
);

wire		clk_50m;
wire		rst_n;

// CRG
CRG U_CRG (
	.clk			(CLK	),
	.rst			(RST	),
	.clk_50m		(clk_50m),
	.rst_n			(rst_n	)
);

// WM8731 I2C Init
DEV_I2C_CONFIG U_WMCFG (
	.iCLK			(clk_50m	),
	.iRST_N			(rst_n		),
	.I2C_SCLK		(WM_I2C_SCLK),
	.I2C_SDAT		(WM_I2C_SDAT),
	.I2C_DONE		(WM_CFG_DONE)
);

assign WM_BCLK = 1'b0;
assign WM_ADCLRC = 1'b0;
assign WM_DACLRC = 1'b0;
assign WM_DACDAT = WM_I2C_SDAT;

endmodule
