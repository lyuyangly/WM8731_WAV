//***************************************************************************
//   File name        :   I2C_Controller.v
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
module I2C_Controller 
(
	//Global iCLK
	input				iCLK,		
	input				iRST_N,		
	
	//I2C Transfer
	input				I2C_CLK,	//DATA Transfer Enable
	input				I2C_EN,		//I2C DATA ENABLE
	input		[23:0]	I2C_WDATA,	//DATA:[SLAVE_ADDR, SUB_ADDR, DATA]
	output				I2C_SCLK,	//I2C iCLK
 	inout				I2C_SDAT,	//I2C DATA
	input				GO,      	//GO transfor
	output				ACK,      	//ACK
	output	reg			END     	//END
);

//------------------------------------
//I2C Signal
reg			I2C_BIT;
reg 		SCLK;
reg	[5:0]	SD_COUNTER;

//Write: ID-Address + SUB-Address + W-Data
assign 	I2C_SCLK	= 	(GO == 1 &&
						((SD_COUNTER >= 5 && SD_COUNTER <=12 || SD_COUNTER == 14) ||	
						(SD_COUNTER >= 16 && SD_COUNTER <=23 || SD_COUNTER == 25) ||
						(SD_COUNTER >= 27 && SD_COUNTER <=34 || SD_COUNTER == 36))) ? I2C_CLK : SCLK;

wire	SDO		=		((SD_COUNTER == 13 || SD_COUNTER == 14)|| 
						(SD_COUNTER == 24 || SD_COUNTER == 25) || 
						(SD_COUNTER == 35 || SD_COUNTER == 36)) ? 1'b0 : 1'b1;		//input | output

assign	I2C_SDAT = SDO ? I2C_BIT : 1'bz;

// Write ACK
reg		ACKW1, ACKW2, ACKW3;		//0 AVTIVE
assign	ACK = ACKW1 | ACKW2 | ACKW3;


//------------------------------------
//I2C COUNTER
always @(posedge iCLK or negedge iRST_N) 
begin
	if (!iRST_N) 
		SD_COUNTER <= 6'b0;
	else if(I2C_EN)
		begin
		if (GO == 1'b0 || END == 1'b1) 
			SD_COUNTER <= 6'b0;
		else if (SD_COUNTER < 6'd63) 
			SD_COUNTER <= SD_COUNTER + 6'd1;	
		end
	else
		SD_COUNTER <= SD_COUNTER;
end

// I2C Transfer
always @(posedge iCLK or negedge iRST_N) 
begin
    if(!iRST_N)
	begin 
		SCLK <= 1'b1;
		I2C_BIT <= 1'b1; 
		ACKW1 <= 1'b1; ACKW2 <= 1'b1; ACKW3 <= 1'b1; 
		END <= 0;
	end
	else if(I2C_EN)
	begin
		if(GO) begin
			case(SD_COUNTER)
				//IDLE
				6'd0 :	begin
						SCLK <= 1'b1;
						I2C_BIT <= 1'b1;
						ACKW1 <= 1'b1; ACKW2 <= 1'b1; ACKW3 <= 1'b1;
						END <= 1'b0;
						end
				//Start
				6'd1 :	begin 
						SCLK <= 1'b1;
						I2C_BIT <= 1'b1;
						ACKW1 <= 1'b1; ACKW2 <= 1'b1; ACKW3 <= 1'b1; 
						END <= 1'b0;
						end
				6'd2  : I2C_BIT <= 1'b0;		//I2C_SDAT = 0
				6'd3  : SCLK <= 1'b0;			//I2C_SCLK = 0
		
				//SLAVE ADDR--ACK1
				6'd4  : I2C_BIT <= I2C_WDATA[23];	//Bit8
				6'd5  : I2C_BIT <= I2C_WDATA[22];	//Bit7
				6'd6  : I2C_BIT <= I2C_WDATA[21];	//Bit6
				6'd7  : I2C_BIT <= I2C_WDATA[20];	//Bit5
				6'd8  : I2C_BIT <= I2C_WDATA[19];	//Bit4
				6'd9  : I2C_BIT <= I2C_WDATA[18];	//Bit3
				6'd10 : I2C_BIT <= I2C_WDATA[17];	//Bit2
				6'd11 : I2C_BIT <= I2C_WDATA[16];	//Bit1
				6'd12 : I2C_BIT <= 1'b0;				//High-Z, Input
				6'd13 : ACKW1 	<= I2C_SDAT;		//ACK1
				6'd14 : I2C_BIT <= 1'b0;				//Delay
		
				//SUB ADDR--ACK2
				6'd15 : I2C_BIT <= I2C_WDATA[15];	//Bit8
				6'd16 : I2C_BIT <= I2C_WDATA[14];	//Bit7
				6'd17 : I2C_BIT <= I2C_WDATA[13];	//Bit6
				6'd18 : I2C_BIT <= I2C_WDATA[12];	//Bit5
				6'd19 : I2C_BIT <= I2C_WDATA[11];	//Bit4
				6'd20 : I2C_BIT <= I2C_WDATA[10];	//Bit3
				6'd21 : I2C_BIT <= I2C_WDATA[9];   //Bit2
				6'd22 : I2C_BIT <= I2C_WDATA[8];	//Bit1
				6'd23 : I2C_BIT <= 1'b0;				//High-Z, Input
				6'd24 : ACKW2 	<= I2C_SDAT;		//ACK2
				6'd25 : I2C_BIT <= 1'b0;				//Delay
		
				//Write DATA--ACK3
				6'd26 : I2C_BIT <= I2C_WDATA[7];	//Bit8 
				6'd27 : I2C_BIT <= I2C_WDATA[6];	//Bit7
				6'd28 : I2C_BIT <= I2C_WDATA[5];	//Bit6
				6'd29 : I2C_BIT <= I2C_WDATA[4];	//Bit5
				6'd30 : I2C_BIT <= I2C_WDATA[3];	//Bit4
				6'd31 : I2C_BIT <= I2C_WDATA[2];	//Bit3
				6'd32 : I2C_BIT <= I2C_WDATA[1];	//Bit2
				6'd33 : I2C_BIT <= I2C_WDATA[0];	//Bit1
				6'd34 : I2C_BIT <= 1'b0;				//High-Z, Input
				6'd35 : ACKW3 	<= I2C_SDAT;		//ACK3
				6'd36 : I2C_BIT <= 1'b0;				//Delay

				//Stop
				6'd37 : begin	SCLK <= 1'b0; I2C_BIT <= 1'b0; end
				6'd38 : SCLK <= 1'b1;	
				6'd39 : begin I2C_BIT <= 1'b1; END <= 1'b1; end 
				default : begin I2C_BIT <= 1'b1; SCLK <= 1'b1; end
			endcase
		end
		else begin
			SCLK <= 1'b1;
			I2C_BIT <= 1'b1; 
			ACKW1 <= 1'b1; ACKW2 <= 1'b1; ACKW3 <= 1'b1; 
			END <= 1'b0;
		end
	end
end
		
endmodule
