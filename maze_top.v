module maze_top(
    	//////////// ADC //////////
	//output		          		ADC_CONVST,
	//output		          		ADC_DIN,
	//input 		          		ADC_DOUT,
	//output		          		ADC_SCLK,

	//////////// Audio //////////
	//input 		          		AUD_ADCDAT,
	//inout 		          		AUD_ADCLRCK,
	//inout 		          		AUD_BCLK,
	//output		          		AUD_DACDAT,
	//inout 		          		AUD_DACLRCK,
	//output		          		AUD_XCK,

	//////////// CLOCK //////////
	//input 		          		CLOCK2_50,
	//input 		          		CLOCK3_50,
	//input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// SDRAM //////////
	//output		    [12:0]		DRAM_ADDR,
	//output		     [1:0]		DRAM_BA,
	//output		          		DRAM_CAS_N,
	//output		          		DRAM_CKE,
	//output		          		DRAM_CLK,
	//output		          		DRAM_CS_N,
	//inout 		    [15:0]		DRAM_DQ,
	//output		          		DRAM_LDQM,
	//output		          		DRAM_RAS_N,
	//output		          		DRAM_UDQM,
	//output		          		DRAM_WE_N,

	//////////// I2C for Audio and Video-In //////////
	//output		          		FPGA_I2C_SCLK,
	//inout 		          		FPGA_I2C_SDAT,

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	//output		     [6:0]		HEX5,

	//////////// IR //////////
	//input 		          		IRDA_RXD,
	//output		          		IRDA_TXD,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// PS2 //////////
	//inout 		          		PS2_CLK,
	//inout 		          		PS2_CLK2,
	//inout 		          		PS2_DAT,
	//inout 		          		PS2_DAT2,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// Video-In //////////
	//input 		          		TD_CLK27,
	//input 		     [7:0]		TD_DATA,
	//input 		          		TD_HS,
	//output		          		TD_RESET_N,
	//input 		          		TD_VS,

	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	//inout 		    [35:0]		GPIO_0,

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	//inout 		    [35:0]		GPIO_1

);




wire [6:0]seg7_dig0;
wire [6:0]seg7_dig1;
wire [6:0]seg7_dig2;
wire [6:0]seg7_dig3;
wire [6:0]seg7_dig4;

// Turn off all displays.
assign	HEX0		=	seg7_dig0;
assign	HEX1		=	seg7_dig1;
assign	HEX2		=	seg7_dig2;
assign	HEX3		=	seg7_dig3;
assign 	HEX4     = 	seg7_dig4;

wire time_end;
reg time_start;
reg time_stop;
reg time_rst;
wire [11:0] minutes;			// changed from wire for both
wire [7:0] seconds;
wire [7:0] miliseconds;

reg [7:0] score_wait;
reg [17:0] score;
reg show_score;

timer game_timer (clk, time_rst, time_start, time_stop, time_end, minutes, seconds, miliseconds);
timer_display display (miliseconds, seconds, minutes, show_score, seg7_dig0, seg7_dig1, seg7_dig2, seg7_dig3, seg7_dig4);		// extra signal to display score vs time







// DONE STANDARD PORT DECLARATION ABOVE
/* HANDLE SIGNALS FOR CIRCUIT */
wire clk;
reg rst;
assign clk = CLOCK_50;
//assign rst = ~SW_db[9]; // switches dont work properly for whatever reason, actually they might if it pulses a 1 ill try that after maple

always@(*) 	// this block is for the reset the switch only reset did not work properly so I am using the keys
	begin		// but to also use the keys for movement I have a block to detect for proper key pressing. which is all of them
					
		//if ((SW_db[9] == 1'd1 && KEY[3] == 1'd0)||(SW_db[9] == 1'd1 && KEY[2] == 1'd0)||(SW_db[9] == 1'd1 && KEY[1] == 1'd0)||(SW_db[9] == 1'd1 && KEY[0] == 1'd0))
		if (KEY[3] == 1'b0 && KEY[2] == 1'b0 && KEY[1] == 1'b0 && KEY[0] == 1'b0 && SW[9] == 1'b1)
				rst = 1'd0;
			else
				rst = 1'd1;
	end

wire [9:0]SW_db;
reg input_rst;
debounce_switches db(clk, input_rst, SW, SW_db);

// VGA DRIVER
wire active_pixels; // is on when we're in the active draw space
wire frame_done;
wire [9:0]x; // current x
wire [9:0]y; // current y - 10 bits = 1024 ... a little bit more than we need

/* the 3 signals to set to write to the picture */
reg [14:0] the_vga_draw_frame_write_mem_address;
reg [23:0] the_vga_draw_frame_write_mem_data;
reg the_vga_draw_frame_write_a_pixel;

/* This is the frame driver point that you can write to the draw_frame */
vga_frame_driver my_frame_driver(
	.clk(clk),
	.rst(rst),

	.active_pixels(active_pixels),
	.frame_done(frame_done),

	.x(x),
	.y(y),

	.VGA_BLANK_N(VGA_BLANK_N),
	.VGA_CLK(VGA_CLK),
	.VGA_HS(VGA_HS),
	.VGA_SYNC_N(VGA_SYNC_N),
	.VGA_VS(VGA_VS),
	.VGA_B(VGA_B),
	.VGA_G(VGA_G),
	.VGA_R(VGA_R),

	/* writes to the frame buf - you need to figure out how x and y or other details provide a translation */
	.the_vga_draw_frame_write_mem_address(the_vga_draw_frame_write_mem_address),
	.the_vga_draw_frame_write_mem_data(the_vga_draw_frame_write_mem_data),
	.the_vga_draw_frame_write_a_pixel(the_vga_draw_frame_write_a_pixel)
);

//reg [15:0]i;
//reg [7:0]S;
//reg [7:0]NS;
/**
parameter 
	START 			= 8'd0,
	// W2M is write to memory
	W2M_INIT 		= 8'd1,
	W2M_COND 		= 8'd2,
	W2M_INC 			= 8'd3,
	W2M_DONE 		= 8'd4,
	// The RFM = READ_FROM_MEMOERY reading cycles
	RFM_INIT_START = 8'd5,
	RFM_INIT_WAIT 	= 8'd6,
	RFM_DRAWING 	= 8'd7,
	ERROR 			= 8'hFF;
*/


	/* Mif file for storing the maze */
/* memory signals */
reg [14:0] maze_address;
wire maze_out;
reg maze_in;
reg read_write_maze_mem;

maze_init_full maze_memory (maze_address, clk, maze_in, read_write_maze_mem, maze_out);

/* Signals to relate the maze coordinates to the VGA coordinates while drawing */
reg [14:0] addr_from_maze;
reg [14:0] m_location_vga;

/* Signals to relate the maze coordinates to the VGA coordinates while moving (playing the game) */
//reg [14:0] ch_in_maze;
reg [14:0] addr_to_maze;
reg [14:0] next_addr;

/* Temporary signal for flipping the coords */ 
reg [14:0] flip_count;
reg [14:0] x_Pos;				// signals to help fix the flipping situtation
reg [14:0] y_Pos;

parameter MEMORY_SIZE = 16'd19200; // 160*120 // Number of memory spots ... highly reduced since memory is slow
parameter PIXEL_VIRTUAL_SIZE = 16'd4; // Pixels per spot - therefore 4x4 pixels are drawn per memory location

/* ACTUAL VGA RESOLUTION */
parameter VGA_WIDTH = 16'd640; 
parameter VGA_HEIGHT = 16'd480;

/* Our reduced RESOLUTION 160 by 120 needs a memory of 19,200 words each 24 bits wide */
parameter VIRTUAL_PIXEL_WIDTH = VGA_WIDTH/PIXEL_VIRTUAL_SIZE; // 160
parameter VIRTUAL_PIXEL_HEIGHT = VGA_HEIGHT/PIXEL_VIRTUAL_SIZE; // 120

/* idx_location stores all the locations in the */
reg [14:0] idx_location;
reg [14:0] prev_location;

/* locations of the key and the finish */
reg [14:0] key_location;
reg [14:0] finish_location;
reg key_collected;

// Just so I can see the address being calculated
assign LEDR[7:0] = S[7:0];
assign LEDR[9] = time_end;
assign LEDR[8] = key_collected;

wire [3:0]movement;
assign movement = KEY[3:0];
parameter DOWN = 4'b0111, 		// plus 1 to move down
			LEFT = 4'b1011,		// minus 120 to move left
			RIGHT = 4'b1101,		// plus 120 to move right
			UP = 4'b1110;			// minus 1 to move up


reg [9:0]S;
reg [9:0]NS;
reg [21:0]fps; // counter for time, the frames per second

/* Signals to change the FPS */
parameter FPS_SIXTY_FRAMES = 20'd800000;
parameter FPS_FIFTY_FRAMES = 21'd1000000;
parameter FPS_ONE_TWENTY_FRAMES = 20'd400000;
parameter FPS_THIRTY_FRAMES = 21'd1600000;
parameter FPS_FIFHTEEN_FRAMES = 22'd3200000;

parameter // missing 52
	/* Initialization states to begin the game */
			START = 10'd0,				// does the same as the reset signal as the reset might not be implemented like normal
			INIT = 10'd1,				// the initialization state, here it places the "character" in the starting position (right now the top left of the screen).
			INIT_DONE = 10'd2,		// sets the_vga_draw_frame_write_a_pixel <= 1'b0 to avoid drawing issues
			WAIT_FOR_BEGIN = 10'd3,// waits a key press to begin the maze
			KEY_UNPRESS = 10'd67,	//makes sure that teh reset is "complete" by making sure all the keys are not pressed
			
	/* Initialization states to create the maze */
			MAZE_LOAD = 10'd4,		// loads the maze file from the memory RAM mif file
			WAIT_FOR_LOAD = 10'd5,	// makes sure the maze data is loaded
			MAZE_DRAW = 10'd6,		// draws the maze based on the file postions and relating those to the VGA coordinates
			MDRAW_DONE = 10'd7,		// sets the_vga_draw_frame_write_a_pixel <= 1'b0 to avoid drawing issues
			LOAD_COND = 10'd8,		// checks to see if the whole maze is loaded
			UPDATE_MPOS = 10'd9,	// relates the maze coordinates to the VGA coordinates
			
	/* "Changing the coords" to flip the maze */
			FLIP_FOR = 10'd10,		// the foor loop for fliping the maze coordinates so that they appear from top to bottom and not left to right
			FLIP_IF = 10'd11,			// the if statement for flipping the coordinates
			FLIP_CT = 10'd12,			// the counter for the flip logic
			CT_RESET = 10'd13,		// the reset for the flip counter
			UPDATE_MC = 10'd14,		// updates the relative maze coords
			
			
			
	/* Movement states to move the character */
			MOVE = 10'd15,				// checks for the movement inputs
			MOVE_U = 10'd16,			// moves the idx_location upward one position
			MOVE_L = 10'd17,			// moves the idx_location leftward one position
			MOVE_R = 10'd18,			// moves the idx_location rightward one position
			MOVE_D = 10'd19,			// moves the idx_location downward one position
			
			
	/* Drawing states to draw the character to the VGA monitor */
			DRAW = 10'd20,				// draws the "character" based on their position
			REMOVE = 10'd21,			// "removes" the old characters position based on their current position
			DRAW_DONE = 10'd22,		// sets the_vga_draw_frame_write_a_pixel <= 1'b0 to avoid drawing issues
			REMOVE_DONE = 10'd23,	// sets the_vga_draw_frame_write_a_pixel <= 1'b0 to avoid drawing issues
			
	/* Wating states to simulate more resaonable FPS */
			WAIT = 10'd24,				// the wait signal to make the charcters movement actually visible and trackable
			WAIT_DONE = 10'd25, 		// the end of the wait signal, resets the FPS signal
			
	/* Collison states to run collsion logic */
			CHECK_R = 10'd26,			// checks the right of the character
			CHECK_L = 10'd27,			// checks the left of the character
			CHECK_U = 10'd28,			// checks the up of the character
			CHECK_D = 10'd29,			// checks the down of the character
			COLL_R = 10'd30,			// checks for collisions in each respective direction (this was split up per direction to make the FSM linking more smooth)
			COLL_L = 10'd31,
			COLL_U = 10'd32,
			COLL_D = 10'd33,
			MOVE_WAIT_U = 10'd34,		// waits for the memory grab in respective direction, was split up to make the flow easier to follow even if this is not the most efficient way to code it
			MOVE_WAIT_D = 10'd35,
			MOVE_WAIT_L = 10'd36,
			MOVE_WAIT_R = 10'd37,
			MAZE_LOAD_R = 10'd38,		// loading address form the maze
			MAZE_LOAD_L = 10'd39,
			MAZE_LOAD_D = 10'd40,
			MAZE_LOAD_U = 10'd41,
			COLL_U_S = 10'd42,			// colision success's versus fails, success means it does not go on fail means it does
			COLL_D_S = 10'd43,
			COLL_L_S = 10'd44,
			COLL_R_S = 10'd45,
			COLL_U_F = 10'd46,
			COLL_D_F = 10'd47,
			COLL_L_F = 10'd48,
			COLL_R_F = 10'd49,
			// these states then go to moving states if collision is false, if true then returns to move (might need to have wait in there)
			
	/* Key states to check if the current state is on a key */ 
		// when random is implemented then it will have to go after the random part
			INIT_KEY = 10'd50,
			KEY_DONE = 10'd51,
			IS_KEY = 10'd52,				// checking to see if the key was already collected
			KEY_COLL = 10'd53,			// collecting the key
			CHECK_KEY = 10'd54,			// checking to see if the location equals the key location
		
	/* Done states to finish the game and stop the timer and calculate the score */
		// these should not be bad to make adn this is where the rst will be implemented, as any key press
			INIT_FIN = 10'd55,
			FIN_DONE = 10'd56,
			ADD_DONE = 10'd57,
			EN_RST = 10'd58,				// enabling the rst
			DONE = 10'd59,					// the done state, it loops here
			CHECK_FIN = 10'd60,			// checing to see if location equals finish
			CHECK_KF = 10'd61,			// checking to see if the key was collected, finishing the game if so and not finishing the game if not so
		
	/* timer states, to check the status and to start and end the timer */
			TIME_INIT = 10'd62,			// resets the timer
			TIME_START = 10'd63,			// starts the timer
			TIME_STOP = 10'd64,			// stops the timer
			TIME_END = 10'd65,			// use this state as a check to see if the time end signal is high
			
			
	/* Score states, for calcualtion and display */
			SCORE_CALC = 10'd66,
			//DISPLAY_SCORE = 10'd68,
			 
		
	/* Randomness generator */
		// this will be instantiated for sure, it will also most likely use the UN-debounced switch to generate a "random" starting number
		
		
	/* Error State to show if an error occurs in the sequence logic of the FSM */
			ERROR = 10'hFFF;

always@(posedge clk or negedge rst)
	begin
		if (rst == 1'b0)
			begin
				the_vga_draw_frame_write_mem_address <= 15'd0;
				the_vga_draw_frame_write_mem_data <= 24'd0;
				the_vga_draw_frame_write_a_pixel <= 1'b0;
				idx_location <= 15'd2521;
				prev_location <= 15'd2521;
				fps <= 22'd0;
				// signals for drawing
				
				addr_from_maze <= 15'd0;
				m_location_vga <= 15'd0;
				flip_count <= 15'd0;
				read_write_maze_mem <= 1'b0;
				maze_address <= 15'd0;
				// signals for moving
				
				//ch_in_maze <= 15'd121;
				addr_to_maze <= 15'd121;
				next_addr <= 15'd121;
				// signals for key and finish
				
				key_location <= 15'd2637;
				finish_location <= 15'd16557;		// could be made a parameter as it doesnt and wont change
				key_collected <= 1'b0;
				// timer singals
				
				time_rst <= 1'b0;
				time_start <= 1'b0;
				time_stop <= 1'b0;
				
				// for debounced
				input_rst <= 1'b0;
				
				// for the score
				show_score <= 1'b0;
				
				// rerelate the coords
				x_Pos <= 15'd0;
				y_Pos <= 15'd0;
			end
		else
			case(S)
				START:			// in logic add the enable switch, before the timers
					begin
						the_vga_draw_frame_write_mem_address <= 15'd0;
						the_vga_draw_frame_write_mem_data <= 24'd0;
						the_vga_draw_frame_write_a_pixel <= 1'b0;
						idx_location <= 15'd2521;
						prev_location <= 15'd2521;
						fps <= 22'd0;
						// signals for drawing
						
						addr_from_maze <= 15'd0;
						m_location_vga <= 15'd0;
						flip_count <= 15'd0;
						read_write_maze_mem <= 1'b0;
						maze_address <= 15'd0;
						// signals for moving
						
						//ch_in_maze <= 15'd121;
						addr_to_maze <= 15'd121;
						next_addr <= 15'd121;
						// signals for key and finish
						
						key_location <= 15'd2637;
						finish_location <= 15'd16557;
						key_collected <= 1'b0;
						
						// timer singals
				
						time_rst <= 1'b0;
						time_start <= 1'b0;
						time_stop <= 1'b0;
						
						// for debounced
						input_rst <= 1'b0;
					
						// for the score
						show_score <= 1'b0;
						
						// rerelate the coords
						x_Pos <= 15'd0;
						y_Pos <= 15'd0;
					end
					
				LOAD_COND:
					begin
						input_rst <= 1'b1;
						//show_score <= 1'b0;
					end
					
				INIT:
					begin
						the_vga_draw_frame_write_mem_address <= idx_location;
						the_vga_draw_frame_write_mem_data <= {8'hF9, 8'h42, 8'h20};
						the_vga_draw_frame_write_a_pixel <= 1'b1;
						
						
					end
				INIT_DONE:
					begin
						the_vga_draw_frame_write_a_pixel <= 1'b0;
					end
					
				INIT_KEY: 
					begin
						the_vga_draw_frame_write_mem_address <= key_location;
						the_vga_draw_frame_write_mem_data <= {8'h00, 8'hFF, 8'h00};
						the_vga_draw_frame_write_a_pixel <= 1'b1;
						
						
					end
					
				KEY_DONE:
					begin
						the_vga_draw_frame_write_a_pixel <= 1'b0;
					end
					
				INIT_FIN: 
					begin
						the_vga_draw_frame_write_mem_address <= finish_location;
						the_vga_draw_frame_write_mem_data <= {8'h00, 8'hFF, 8'hFF};
						the_vga_draw_frame_write_a_pixel <= 1'b1;
					end
				
				KEY_COLL:
					begin
						key_collected <= 1'b1;
					end
				
				FIN_DONE: 
					begin
						the_vga_draw_frame_write_a_pixel <= 1'b0;
					end
					
				//LOAD_COND:
						
				MAZE_LOAD:
					begin
						maze_address <= addr_from_maze;
					end
					
				//WAIT_FOR_LOAD: 
				/*
				UPDATE_MTO: // i am guessing here no clue whats gonna happen
					if (m_location_vga > 14'd14279)
							begin
								m_location_vga <= addr_from_maze - 14'd120;
							end
						else
							begin
								m_location_vga <= 14'd120 + addr_from_maze;
							end
				*/
				
				FLIP_CT:
					begin
						flip_count <= flip_count + 1'b1;
					end
					
				UPDATE_MC:
					begin
						m_location_vga <= (flip_count *15'd120) + (addr_from_maze / 15'd120);		// changed from 14
					end
					
				CT_RESET:
					begin
						flip_count <= 15'd0;
						m_location_vga <= addr_from_maze / 15'd120;
					end
							
				UPDATE_MPOS:
					begin
						m_location_vga <= m_location_vga  + 15'd2400; // relates to the middle of the screen
					end
					
				MAZE_DRAW:
					begin
						if (maze_out == 1)
							begin
								the_vga_draw_frame_write_mem_address <= m_location_vga;
								the_vga_draw_frame_write_mem_data <= {8'hEE, 8'hEE, 8'h00};
								the_vga_draw_frame_write_a_pixel <= 1'b1;
							end
						else
							begin
								the_vga_draw_frame_write_mem_address <= m_location_vga;
								the_vga_draw_frame_write_mem_data <= {8'h00, 8'h00, 8'hEE};
								the_vga_draw_frame_write_a_pixel <= 1'b1;
							end
					end
					
				MDRAW_DONE:
					begin
						the_vga_draw_frame_write_a_pixel <= 1'b0;
						addr_from_maze <= addr_from_maze + 1'b1;
					end
					
					
				DRAW_DONE:
					begin
						the_vga_draw_frame_write_a_pixel <= 1'b0;
					end
				REMOVE_DONE:
					begin
						the_vga_draw_frame_write_a_pixel <= 1'b0;
					end
					
				WAIT:
					begin
						fps <= fps + 1'b1;
					end
				
				WAIT_DONE:
					begin
						fps <= 22'd0;
					end
				MOVE:
					begin
						the_vga_draw_frame_write_a_pixel <= 1'b0;
						prev_location <= idx_location;
						addr_to_maze <= next_addr;
					
					end
				MOVE_U:
					begin
						//idx_location <= idx_location - 1'b1;
						idx_location <= addr_to_maze - (y_Pos * 7'd119) + (x_Pos * 7'd119) + 15'd2400;
					end
				MOVE_L:
					begin
						//idx_location <= idx_location - 7'd120;
						idx_location <= addr_to_maze + (x_Pos * 7'd119) - (y_Pos * 7'd119) + 15'd2400;
					end
				MOVE_R:
					begin
						//idx_location <= idx_location + 7'd120;
						idx_location <= addr_to_maze + (x_Pos * 7'd119) - (y_Pos * 7'd119) + 15'd2400;
					end
				MOVE_D:
					begin
						//idx_location <= idx_location + 1'b1;
						idx_location <= addr_to_maze - (y_Pos * 7'd119) + (x_Pos * 7'd119) + 15'd2400;
					end
				DRAW:
					begin
						the_vga_draw_frame_write_mem_address <= idx_location;
						the_vga_draw_frame_write_mem_data <= {8'hF9, 8'h42, 8'h20};
						the_vga_draw_frame_write_a_pixel <= 1'b1;
					
					end
					
				ADD_DONE:
					begin
						the_vga_draw_frame_write_mem_address <= finish_location;
						the_vga_draw_frame_write_mem_data <= {8'h00, 8'hFF, 8'hFF};
						the_vga_draw_frame_write_a_pixel <= 1'b1;
					end

				REMOVE:			// add another state to refill the exit if it was coverd up to repaint correctly, should be easy to implement, logic done in draw_done
					begin
						the_vga_draw_frame_write_mem_address <= prev_location;
						the_vga_draw_frame_write_mem_data <= {8'hFF, 8'hFF, 8'hFF};
						the_vga_draw_frame_write_a_pixel <= 1'b1;
					end
					
					
				CHECK_R: 
					begin
						next_addr <= next_addr + 1'b1;
					end
				CHECK_L:
					begin
						next_addr <= next_addr - 1'b1;
					end
				CHECK_U:
					begin
						next_addr <= next_addr - 7'd120;
					end
				CHECK_D:
					begin
						next_addr <= next_addr + 7'd120;
					end
				
				MAZE_LOAD_R:
					begin
						maze_address <= next_addr;
					end
				MAZE_LOAD_L: 
					begin
						maze_address <= next_addr;
					end
				MAZE_LOAD_U:
					begin
						maze_address <= next_addr;
					end
				MAZE_LOAD_D:
					begin
						maze_address <= next_addr;
					end
					
					
				COLL_U_F:
					begin
							addr_to_maze <= addr_to_maze - 7'd120;
							y_Pos <= y_Pos - 1'b1;
					end
				COLL_D_F:
					begin
							addr_to_maze <= addr_to_maze + 7'd120;
							y_Pos <= y_Pos + 1'b1;
					end
				COLL_L_F:
					begin
							addr_to_maze <= addr_to_maze - 1'b1;
							x_Pos <= x_Pos - 1'b1;
					end
				COLL_R_F:
					begin
							addr_to_maze <= addr_to_maze + 1'b1;
							x_Pos <= x_Pos + 1'b1;
					end
					
					
				COLL_U_S:
					begin
						next_addr <= addr_to_maze;
					end
				COLL_D_S:
					begin
						next_addr <= addr_to_maze;
					end
				COLL_L_S: 
					begin
						next_addr <= addr_to_maze;
					end
				COLL_R_S:
					begin
						next_addr <= addr_to_maze;
					end
				//MOVE_WAIT_R:
				//MOVE_WAIT_L:
				//MOVE_WAIT_U:
				//MOVE_WAIT_D:
				
				//COLL_U:
					
				//COLL_D:
					
				//COLL_R:
					
				//COLL_L:
				
				TIME_INIT:
					begin
						time_rst <= 1'b1;
					end
				TIME_START:
					begin
						time_start <= 1'b1;
					end
				TIME_STOP:
					begin
						time_stop <= 1'b1;
					end
				//TIME_END:
				
				SCORE_CALC:
					begin
						show_score <= 1'b1;
					end
				
			endcase
	
	end
	
	
	always@(*)
		begin
			//if (rst == 1'b0)
			//	NS = START;
			//else
				case(S)
					START: NS = KEY_UNPRESS; // initializes the maze first so that the character overrides the maze (written last)
					
					
					KEY_UNPRESS:
						if (movement != 4'b1111)
							NS = KEY_UNPRESS;
						else
							NS = LOAD_COND;
					//WAIT_FOR_SW:
						//begin
						//	if (SW_db[8] == 1'b1)
						//		NS = LOAD_COND;
						//	else
						//		NS = WAIT_FOR_SW;
						//end
					
					TIME_INIT: NS =  WAIT_FOR_BEGIN;
					TIME_START: NS = WAIT;
					
					TIME_STOP: NS = EN_RST;
					
					TIME_END:
						begin
							if (time_end == 1'b1)
								NS = TIME_STOP;
							else
								NS = MOVE;
						end
					
					WAIT_FOR_BEGIN:
						begin
							case(movement)
								DOWN: NS = TIME_START;
								UP: NS = TIME_START;
								RIGHT: NS = TIME_START;
								LEFT: NS = TIME_START;
								default: NS = WAIT_FOR_BEGIN;
							endcase
						end
					
					INIT: NS = INIT_DONE;
					
					INIT_DONE: NS = INIT_KEY; 
					
					INIT_KEY: NS = KEY_DONE;
					
					KEY_DONE: NS = INIT_FIN;

					INIT_FIN: NS = FIN_DONE;
					
					FIN_DONE: NS = TIME_INIT;
					
					LOAD_COND:
						begin
							if (addr_from_maze >= 14'd14400)
								NS = INIT;
							else
								NS = MAZE_LOAD;
						end
					
					//FLIP_FOR:

					
					FLIP_IF:
						begin
							if(addr_from_maze % 14'd120 == 14'd0)
								NS = CT_RESET;
							else
								NS = FLIP_CT;
						end
					
					FLIP_CT: NS = UPDATE_MC;
					
					CT_RESET: NS = UPDATE_MPOS;
					
					UPDATE_MC: NS = UPDATE_MPOS;
					
					MAZE_LOAD: NS = WAIT_FOR_LOAD;
					
					WAIT_FOR_LOAD: NS = FLIP_IF;
					
					UPDATE_MPOS: NS = MAZE_DRAW;
					
					MAZE_DRAW: NS = MDRAW_DONE;
					
					MDRAW_DONE: NS = LOAD_COND;
					
					WAIT: 
						if (fps >= FPS_FIFHTEEN_FRAMES)
							NS = WAIT_DONE;
						else
							NS = WAIT;
							
					WAIT_DONE: NS = TIME_END;
					
					MOVE:
						
					
						begin
						if (KEY[0] == 1'b0 && KEY[1] == 1'b1 && KEY[2] == 1'b1 && KEY[3] == 1'b1)
							NS = CHECK_U;
						else
							if (KEY[0] == 1'b1 && KEY[1] == 1'b0 && KEY[2] == 1'b1 && KEY[3] == 1'b1)
								NS = CHECK_R;
							else
								if (KEY[0] == 1'b1 && KEY[1] == 1'b1 && KEY[2] == 1'b0 && KEY[3] == 1'b1)
									NS = CHECK_L;
								else
									if (KEY[0] == 1'b1 && KEY[1] == 1'b1 && KEY[2] == 1'b1 && KEY[3] == 1'b0)
										NS = CHECK_D;
									else
										NS = MOVE;
						/*
							case(movement)
								DOWN: NS = CHECK_D;
								UP: NS = CHECK_U;
								RIGHT: NS = CHECK_R;
								LEFT: NS = CHECK_L;
								default: NS = MOVE;
							endcase
						*/
						end
						
						
					CHECK_KEY:
						begin
							if (idx_location == key_location)
								NS = IS_KEY;
							else
								NS = CHECK_FIN;
						end
					KEY_COLL:
						begin
							NS = CHECK_FIN;
						end
					IS_KEY:
						begin
							if (key_collected == 1'b0)
								NS = KEY_COLL;
							else
								NS = CHECK_FIN;
						end
						
					MAZE_LOAD_R: NS = MOVE_WAIT_R;
					MAZE_LOAD_L: NS = MOVE_WAIT_L;
					MAZE_LOAD_U: NS = MOVE_WAIT_U;
					MAZE_LOAD_D: NS = MOVE_WAIT_D;
					
					CHECK_R: NS = MAZE_LOAD_R;
					CHECK_L: NS = MAZE_LOAD_L;
					CHECK_U: NS = MAZE_LOAD_U;
					CHECK_D: NS = MAZE_LOAD_D;
					
					MOVE_WAIT_R: NS = COLL_R;
					MOVE_WAIT_L: NS = COLL_L;
					MOVE_WAIT_U: NS = COLL_U;
					MOVE_WAIT_D: NS = COLL_D;
					
					
					COLL_U_S: NS = WAIT;		
					COLL_D_S: NS = WAIT;
					COLL_L_S: NS = WAIT;
					COLL_R_S: NS = WAIT;
					
					
					COLL_U_F: NS = MOVE_U;
					COLL_D_F: NS = MOVE_D;
					COLL_L_F: NS = MOVE_L;
					COLL_R_F: NS = MOVE_R;
					
					COLL_R:
						begin
							if (maze_out == 1'b1)
								NS = COLL_R_S;
							else
								NS = COLL_R_F;
						end
					COLL_L: 
						begin
							if (maze_out == 1'b1)
								NS = COLL_L_S;
							else
								NS = COLL_L_F;
						end
					COLL_U: 
						begin
							if (maze_out == 1'b1)
								NS = COLL_U_S;
							else
								NS = COLL_U_F;
						end
					COLL_D:
						begin
							if (maze_out == 1'b1)
								NS = COLL_D_S;
							else
								NS = COLL_D_F;
						end
						
					MOVE_U: NS = DRAW;
					
					MOVE_L: NS = DRAW;
					
					MOVE_R: NS = DRAW;
					
					MOVE_D: NS = DRAW;
					
					DRAW: NS = DRAW_DONE;
					
					DRAW_DONE:
						begin
							if (prev_location == finish_location)
								NS = ADD_DONE;
							else
								NS = REMOVE;
						end
					ADD_DONE: NS = REMOVE_DONE;
					
					REMOVE_DONE: NS = CHECK_KEY;

					REMOVE: 
						begin
							NS = REMOVE_DONE;
						end
						
					EN_RST: NS = SCORE_CALC; // state that will probably do nothing more as a reminder to add a rst
					
					SCORE_CALC:
						begin
								NS = DONE;
						end					
					
					
					DONE: 				// reset could happen via putting back to start, if it has same parameters then that works
						begin
							case(movement)
								UP: NS = START;
								default: NS = DONE;
							endcase
						end		
					
					CHECK_FIN:
						begin
							if (idx_location == finish_location)
								NS = CHECK_KF;
							else
								NS = WAIT;
						end
					
					CHECK_KF:
						begin
							if (key_collected == 1'b1)
								NS = TIME_STOP;
							else
								NS = WAIT;
						end
						
						
						
				default: NS = ERROR;
			endcase
		end
		
		
	always@(posedge clk or negedge rst)
		begin
			if (rst == 1'b0)
				S <= START;
				
			else
				S <= NS;
		end




endmodule