//***************************************************************************
//   File name        :   WM8731_CFG_LUT.v
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
module	WM8731_CFG_LUT
(
	input				iCLK,
	input				iRST_N,
	input		[7:0]	LUT_INDEX,
	output	reg	[15:0]	LUT_DATA
);

/////////////////////	Config Data LUT	  //////////////////////////	
always @ (posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
		LUT_DATA <= 'd0;
	else
		case(LUT_INDEX)
			0 	: 	LUT_DATA	<= 	{7'd0, 9'b000010111}; // L Line Input Vol
			1 	: 	LUT_DATA	<= 	{7'd1, 9'b000010111}; // R Line Input Vol
			2 	: 	LUT_DATA	<=	{7'd2, 9'b001110001}; // L Vol
			3 	: 	LUT_DATA	<= 	{7'd3, 9'b001110001}; // R Vol
			4 	: 	LUT_DATA	<= 	{7'd4, 9'b001111010}; // Analog Path
			5 	: 	LUT_DATA	<= 	{7'd5, 9'b000001000}; // Digital Path
			6 	: 	LUT_DATA	<= 	{7'd6, 9'b000000000}; // Power Down
			7 	: 	LUT_DATA	<= 	{7'd7, 9'b000000010}; // Interface Format
			8 	: 	LUT_DATA	<= 	{7'd8, 9'b000011000};
			9 	: 	LUT_DATA	<= 	{7'd9, 9'b000000001};
			default		 :	LUT_DATA	<=	'd0;
		endcase
end

endmodule
