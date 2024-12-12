module timer_display (

input [7:0] miliseconds,
input [7:0] seconds,
input [11:0] minutes,
input show_score,
//input [17:0] score,

output [6:0]seg7_dig0,
output [6:0]seg7_dig1,
output [6:0]seg7_dig2,
output [6:0]seg7_dig3,
output [6:0]seg7_dig4


);

reg [3:0]minutes_ones;
reg [3:0]seconds_tens;
reg [3:0]seconds_ones;
reg [3:0]mili_tens;
reg [3:0]mili_ones;

reg [17:0] score;

/*
always@(posedge clk or negedge rst)
	begin
		if (rst == 1'b0)
			begin
				if (seconds == 8'd60)
						begin
							seconds_tens <= 4'd0;
							seconds_ones <= 4'd0;
						end
					else
						begin
							seconds_tens <= (seconds / 10) % 12;
							seconds_ones <= seconds % 10;
						end
					minutes_ones <= minutes % 10;
					mili_tens <= (miliseconds / 10) % 10;
					mili_ones <= miliseconds % 10;
			end
		else
			begin
				if (show_score == 1'b0)
				begin
					if (seconds == 8'd60)
						begin
							seconds_tens <= 4'd0;
							seconds_ones <= 4'd0;
						end
					else
						begin
							seconds_tens <= (seconds / 10) % 12;
							seconds_ones <= seconds % 10;
						end
					minutes_ones <= minutes % 10;
					mili_tens <= (miliseconds / 10) % 10;
					mili_ones <= miliseconds % 10;
				end
			else
				begin
					minutes_ones <= (score / 10000) % 10;
					seconds_tens <= (score / 1000) % 10;
					seconds_ones <= (score / 100) % 10;
					mili_tens <= (score / 10) % 10;
					mili_ones <= score % 10;
				end
			end
	end
*/





	always@(*)
		begin
			score = (minutes * 11'd520) + ((seconds + 8'd37) * 8'd4) + ((miliseconds / 8'd10));
			case(show_score)
			1'b0:
				begin
					if (seconds == 8'd60)
						begin
							seconds_tens = 4'd0;
							seconds_ones = 4'd0;
						end
					else
						begin
							seconds_tens = (seconds / 10) % 12;
							seconds_ones = seconds % 10;
						end
					minutes_ones = minutes % 10;
					mili_tens = (miliseconds / 10) % 10;
					mili_ones = miliseconds % 10;
				end
			1'b1:
				begin
					minutes_ones = (score / 10000) % 10;
					seconds_tens = (score / 1000) % 10;
					seconds_ones = (score / 100) % 10;
					mili_tens = (score / 10) % 10;
					mili_ones = score % 10;
				end
			endcase
		end

seven_segment mili_one (mili_ones, seg7_dig0);
seven_segment mili_ten (mili_tens, seg7_dig1);
seven_segment seconds_one (seconds_ones, seg7_dig2);
seven_segment seconds_ten (seconds_tens, seg7_dig3);
seven_segment minute_one (minutes_ones, seg7_dig4);
	


endmodule