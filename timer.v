module timer (
	input clk,
	input rst,
	
	input start,
	input stop,
	
	output reg time_end,
	
	
/* counters for each minute second and milisecond */
	output reg [11:0] minutes,
	output reg [7:0] seconds,
	output reg [7:0] miliseconds
	
);




/* state and next state */
reg [4:0] S;
reg [4:0] NS;

reg [8:0] minute_count;
reg [30:0] seconds_count;
reg [20:0] miliseconds_count;

parameter 
			RST = 4'd0,						// resets the timer counters
			WAIT_FOR_START = 4'd1,		// waits for the start signal
			MILI_COUNTDOWN = 4'd2,		// counts down by miliseconds
			MINUS_SECOND = 4'd4,
			MINUS_MILI = 4'd5,
			MINUS_MINUTE = 4'd6,
			CHECK_CONDS = 4'd7,
			SUB_MILI = 4'd9,
			SUB_SECOND = 4'd10,
			SUB_MINUTE = 4'd11,
			SEC_RESET = 10'd8,
			FINISH = 4'd3,		
			ERROR = 4'hF;
			
		always@(posedge clk or negedge rst)
			begin
				if (rst == 1'b0)
					S <= RST;
				else
					S <= NS;
			end
			
			
			
		always@(posedge clk or negedge rst)
			begin
				if (rst == 1'b0)
					begin
						minutes <= 8'd6;
						seconds <= 8'd0;
						miliseconds <= 8'd0;
						miliseconds_count <= 21'd0;
						time_end <= 1'b0;
					end
				else
				case(S)
				RST:
					begin
						minutes <= 8'd6;
						seconds <= 8'd0;
						miliseconds <= 8'd0;
						miliseconds_count <= 21'd0;
						time_end <= 1'b0;
					end
				MILI_COUNTDOWN:
					begin
						miliseconds_count <= miliseconds_count + 1'b1;
					end
					
				MINUS_MILI:
					begin
						miliseconds_count <= 21'd0;
					end
					
				MINUS_SECOND:
					begin
						
						miliseconds <= 8'd100;
					end
				MINUS_MINUTE:
					begin
						seconds <= 8'd59;
					end
					
				FINISH:
					begin
						time_end <= 1'b1;
					end
					
				SEC_RESET:
					begin
						seconds <= 8'd0;
					end
					
				SUB_MILI: miliseconds <= miliseconds - 1'b1;
				SUB_SECOND: seconds <= seconds - 1'b1;
				SUB_MINUTE: minutes <= minutes - 1'b1;
				
				
				
				endcase
			
			end 


		always@(*)
			begin
				if (rst == 1'b0)
					NS = RST;
				else
				case(S)
					RST: NS = WAIT_FOR_START;
					
					WAIT_FOR_START:
						begin
							if (start == 1'b1)
								NS = MILI_COUNTDOWN;
							else
								NS = WAIT_FOR_START;
						end
						
					MILI_COUNTDOWN:
						begin
							if (stop == 1'b1)
								NS = FINISH;
							else
								NS = CHECK_CONDS;
						end
					
					CHECK_CONDS:
						if (miliseconds_count == 21'd250000)
							NS = MINUS_MILI;
						else
							NS = MILI_COUNTDOWN;
							
					MINUS_MILI:
						begin
							if (miliseconds == 8'd0)
								NS = MINUS_SECOND;
							else
								NS = SUB_MILI;
						end
						
					MINUS_SECOND:
						begin
							if (seconds == 8'd0)
								NS = MINUS_MINUTE;
							else
								NS = SUB_SECOND;
						end
								
					MINUS_MINUTE:
						begin 
							if (minutes == 8'd0)
								NS = SEC_RESET;				// changed this
							else
								NS = SUB_MINUTE;
						end
						
					SEC_RESET: NS = FINISH;
					
					
					/*	
					CHECK_IF_DONE:
						begin
							if ((seconds == 8'd0)) // minute check removed as it is already done
								NS = CHECK_FOR_FIN;
							else
								NS = MILI_COUNTDOWN;
						end
						
					CHECK_FOR_FIN:
						begin
							if ((miliseconds == 8'd0)) // minute check removed as it is already done
								NS = FINISH;
							else
								NS = MILI_COUNTDOWN;
						end
					*/
					
						
					SUB_MILI: NS = MILI_COUNTDOWN;
					
					SUB_SECOND: NS = MILI_COUNTDOWN;
					
					SUB_MINUTE: NS = MILI_COUNTDOWN;
					
					FINISH: NS = FINISH;
					
					default: NS = ERROR;
					
				endcase
			end


endmodule