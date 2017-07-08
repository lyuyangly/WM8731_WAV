//***************************************************************************
//   File name        :   DEV_I2C_CONFIG.v
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
module DEV_I2C_CONFIG (
	input				iCLK,
	input				iRST_N,
	output				I2C_SCLK,
	inout				I2C_SDAT,
	output	reg			I2C_DONE
);

// LUT for Configuration Data Number
parameter	LUT_SIZE	=	10;

// Clock Setting
parameter	CLK_Freq	=	50_000000;	//50 MHz
parameter	I2C_Freq	=	10_000;		//10 KHz
reg	[15:0]	mI2C_CLK_DIV;				//CLK DIV
reg			mI2C_CTRL_CLK;				//I2C Control Clock

// Internal Registers
wire		mI2C_END;					// I2C Transfer End
wire		mI2C_ACK;					// I2C Transfer ACK
reg	[7:0]	LUT_INDEX;					// LUT Index
reg	[1:0]	mSetup_ST;					// State Machine
reg			mI2C_GO;					// I2C Transfer Start
wire [15:0]	LUT_DATA;
reg			i2c_en_r0, i2c_en_r1;

// Clock Generation
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N) begin
		mI2C_CLK_DIV	<=	'd0;
		mI2C_CTRL_CLK	<=	1'b0;
	end
	else begin
		if(mI2C_CLK_DIV	< (CLK_Freq/I2C_Freq) / 2)
			mI2C_CLK_DIV	<=	mI2C_CLK_DIV + 1'd1;
		else begin
			mI2C_CLK_DIV	<=	'd0;
			mI2C_CTRL_CLK	<=	~mI2C_CTRL_CLK;
		end
	end
end

// Negdge I2C Clock
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		i2c_en_r0 <= 1'b0;
		i2c_en_r1 <= 1'b0;
	end
	else begin
		i2c_en_r0 <= mI2C_CTRL_CLK;
		i2c_en_r1 <= i2c_en_r0;
	end
end
wire	i2c_negclk = (i2c_en_r1 & ~i2c_en_r0) ? 1'b1 : 1'b0;

// Config Control
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		I2C_DONE	<=  'd0;
		LUT_INDEX	<=	'd0;
		mSetup_ST	<=	'd0;
		mI2C_GO		<=	'd0;	
	end
	else if(i2c_negclk) 
	begin
		if(LUT_INDEX < LUT_SIZE)
		begin
			I2C_DONE <= 'd0;
			case(mSetup_ST)
				2'd0:	begin
					if(~mI2C_END)
						mSetup_ST	<=	'd1;		
					else
						mSetup_ST	<=	'd0;				
					mI2C_GO	<= 1;
				end
				2'd1:	begin
					if(mI2C_END)
					begin
						mI2C_GO		<=	'd0;
						if(~mI2C_ACK)
							mSetup_ST	<=	'd2;
						else
							mSetup_ST	<=	'd0;
					end
				end
				2:	begin
					LUT_INDEX	<=	LUT_INDEX + 8'd1;
					mSetup_ST	<=	'd0;
					mI2C_GO		<=	'd0;
				end
			endcase
		end
		else begin
			I2C_DONE <= 1'b1;
			LUT_INDEX 	<= LUT_INDEX;
			mSetup_ST	<=	'd0;
			mI2C_GO		<=	'd0;
		end
	end
end


// Configuration Data LUT
WM8731_CFG_LUT	U_WM8731_LUT (
	.iCLK			(iCLK),
	.iRST_N			(iRST_N),
	.LUT_INDEX		(LUT_INDEX),
	.LUT_DATA		(LUT_DATA)
);

// I2C Controller
I2C_Controller 	U_I2C_CTRLER (	
	.iCLK			(iCLK),
	.iRST_N			(iRST_N),
		
	.I2C_CLK		(mI2C_CTRL_CLK),	//	Controller Work Clock
	.I2C_EN			(i2c_negclk),		//	I2C DATA ENABLE
	.I2C_WDATA		({8'h34, LUT_DATA}),//	DATA:[SLAVE_ADDR,SUB_ADDR,DATA]
	.I2C_SCLK		(I2C_SCLK),			//	I2C CLOCK
	.I2C_SDAT		(I2C_SDAT),			//	I2C DATA

	.GO				(mI2C_GO),			//	Go Transfer
	.ACK			(mI2C_ACK),			//	ACK
	.END			(mI2C_END) 			//	END transfer
);

endmodule

