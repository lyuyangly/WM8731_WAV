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
	output			rst_n
);

reg		rst_ff0, rst_ff1;

assign clk_50m = clk;

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

endmodule
