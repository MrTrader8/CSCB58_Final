`include "vga_adapter/vga_adapter.v"
`include "vga_adapter/vga_address_translator.v"
`include "vga_adapter/vga_controller.v"
`include "vga_adapter/vga_pll.v"
module Match4
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		LEDR,
		HEX7,
		HEX6,
		HEX5,
		HEX4,
		HEX3,
		HEX2,
		HEX0,
		LEDG
	);

	input			CLOCK_50;				//	50 MHz
	input   [17:0]   SW;
	input   [3:0]   KEY;
	output   [6:0]   HEX0;

	output   [6:0]   HEX2;
	output   [6:0]   HEX3;
	output   [6:0]   HEX4;
	output   [6:0]   HEX5;
	output   [6:0]   HEX6;
	output   [6:0]   HEX7;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	output [5:0] LEDR;
	output [4:0] LEDG;
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [6:0] Xout;
	wire [6:0] Yout;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(Xout),
			.y(Yout),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "image.colour.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    wire go;
	 wire loadX;
	 wire loadY;
	 wire loadColour;
	 wire plotX;
	 wire plotY;
	 wire player1turn;
	 wire player2turn;
	 wire move;
	 wire Xctrl2grid;
	 wire Yctrl2grid;
	 wire [3:0]Xgrid;
	 wire [3:0]Ygrid;
	 wire [6:0]XtoSquare;
	 wire [6:0]YtoSquare;
	 wire drawPiece;
	 wire winner;
	 wire start;
	 wire [2:0] pieceColour;
	 wire [3:0] p1pieces;
	 wire [3:0] p2pieces;
	 wire [3:0] turncounter;
	 assign go = KEY[3];
	 localparam white = 3'b111;
	 localparam yellow = 3'b110;
	 localparam RNG = 12'b100111010;
// Declare all the modules		
	 control ctrl0(
	.go(go),
		.resetn(resetn),
		.clock(CLOCK_50),
		.player1turn(player1turn),
		.player2turn(player2turn),
		.p1out(Xgrid),
		.p1in(SW[3:0]),
		.p2in(SW[7:4]),
		.p2out(Ygrid),
		.move(move),
		.start(start),
		.colour(colour)
	 );
	 
	 datapath d0(
		.winner(winner),
		.p1input(Xgrid),
		.p2input(Ygrid),
		.move(move),  
		.Xout(XtoSquare), 
		.Yout(YtoSquare), 
		.colour(pieceColour), 
		.plot(drawPiece), 
		.clock(CLOCK_50), 
		.resetn(resetn),
		.p1turn(player1turn),
		.p2turn(player2turn),
		.go(go)
	 );
	 
	 square s0(
		.X(XtoSquare),
		.Y(YtoSquare),
		.clock(CLOCK_50),
		.resetn(resetn),
		.plot(move),
		.Xout(Xout),
		.Yout(Yout),
		.newPlot(writeEn)
	);
	
	hex_display Decoder7(
    .OUT(HEX7[6:0]),
    .IN(3'b000)
        );

hex_display Decoder6(
    .OUT(HEX6[6:0]),
    .IN(3'b001)
    );

hex_display Decoder5(
    .OUT(HEX5[6:0]),
    .IN(3'b010)
);
    
hex_display Decoder4(
    .OUT(HEX4[6:0]),
    .IN(3'b011)
);
    
hex_display Decoder3(
    .OUT(HEX3[6:0]),
    .IN(3'b100)
);

hex_display Decoder2(
    .OUT(HEX2[6:0]),
    .IN(3'b101)
);

hex_display2 Decoder0(
    .OUT(HEX0[6:0]),
    .IN(player1turn)
);

	 buf(LEDG[0],player1turn);
	 buf(LEDG[1],player2turn);
endmodule
// control module that handles when pieces are drawn and whos players move it is
// control module contains the FSM for the game
module control(go,resetn,clock,player1turn,player2turn,move,finish,p1out,p2out,p1in,p2in,start,colour);
		// declare the input and outputs
		input go;
		input resetn;
		input clock;
		input finish;
		input [4:0]p1in;
		input [4:0]p2in;
		
		output reg player1turn;
		output reg player2turn;
		output reg move;
		output reg [4:0]p1out;
		output reg [4:0]p2out;
		output reg start;
		output reg[2:0]colour;
		// create the states
		localparam initial_state = 5'd0,
					  player1_state = 5'd1,
					  player1_wait = 5'd2,
					  player2_state = 5'd4,
					  player2_wait = 5'd6,
					  plot1 = 5'd8,
					  plot2 = 5'd10,
					  enable = 5'd30;
		// case table for the FSM	  
		reg [6:0] current_state, next_state; 
		always@(*)
		 begin: state_table 
					case (current_state)
						 initial_state: next_state = go ? player1_state : initial_state;
						 player1_state: next_state = go ? player1_wait : player1_state;
						 player1_wait: next_state = go ? player1_wait : plot1;
						 plot1: next_state = go ? player2_state : plot1;
						 player2_state: next_state = go ? player2_wait : player2_state;
						 player2_wait: next_state = go ? player2_wait :plot2;
						 plot2: next_state = go ? player1_state : plot2;

					default:     next_state = initial_state;
			  endcase
		 end // state_table
		// the player states handle which player is moving
		// the plot states give time for the square to draw on the vga
		always @(*)
		 begin: enable_signals
		         player1turn = 1'b0;
					player2turn = 1'b0;
					move = 1'b0;
		      case (current_state)
				player1_state: begin
					player2turn = 1'b0;
					player1turn = 1'b1;
				end
				player1_wait: begin
					p1out <= p1in;
					colour <= 3'b100;
					player2turn = 1'b0;
					player1turn = 1'b1;
					move = 1'b0;
				end
				player2_state:begin
					player1turn = 1'b0;
					player2turn = 1'b1;
				end
				player2_wait: begin
					p2out <= p2in;
					colour <= 3'b110;
					player1turn = 1'b0;
					player2turn = 1'b1;
					move = 1'b0;
				end
				plot1:begin
					move = 1'b1;
				end
				plot2:begin
					move = 1'b1;
				end
			endcase
		end
			
			
		// if the reset button is pressed
    always@(posedge clock)
    begin: state_FFs
        if(!resetn)
            current_state <= initial_state;
        else
            current_state <= next_state;
    end 
endmodule
// datapath handles where the pieces should be draw based on informationfor the contol module
module datapath(winner,p1input,p2input, move, Xout, Yout, colour, plot, clock, resetn, go,moveout,p1turn,p2turn,player1win,player2win);
	//declare the inputs and outputs
	input move;
	input resetn;
	input clock;
	input go;
	input [4:0]p1input;
	input [4:0]p2input;
	input p1turn;
	input p2turn;
	
	output reg [6:0] Xout;
	output reg [6:0] Yout;
	output reg [2:0] colour;
	output reg plot;
	output reg winner;
	output reg moveout;
	output reg player1win;
	output reg player2win;
	localparam p1c = 3'b100, 
		p2c = 3'b110;
	
	reg j = 1'd6;
	reg [15:0] player1  = 16'b0000000000000000;
	reg  [15:0] player2  = 16'b0000000000000000;
	reg p1win = 1'b0;
	reg p2win = 1'b0;
	//always block to keep processing moves as long as one player has not won yet
	always@(posedge clock)
			if(p1win == 0 && p2win == 0)
				begin
				// if it is the player 1's turn
					if(p1turn == 1'b1)
					begin
					case (p1input) 
					// check the register for the boards if there is not a piece there and it is the players turn create the 
					// correct X and Y coordinate to draw the square
						4'b0000: if(player1[0] == 0 && player2[0] == 0 && p1turn == 1'b1) begin 
									player1[0]<= 1;
									moveout<= 0;
									Xout <= 4'b0100;
									Yout <= 4'b0100;
									plot = 1'b1;
								end
						4'b0001: if (p1turn == 1 && player1[1] == 0 && player2[1] == 0 && p1turn == 1'b1)
								begin 
									player1[1]<= 1;
									moveout<= 0;
									plot = 1'b1;
									Xout <= 4'b1100;
									Yout <= 4'b0100;
								end
						4'b0010: if (p1turn == 1 && player1[2] == 0 && player2[2] == 0 && p1turn == 1'b1)
								begin 
									player1[2]<= 1;
									moveout<= 0;
									plot = 1'b1;
									Xout <= 5'b10100;
									Yout <= 4'b0100;
								end
						4'b0011: if (p1turn == 1 && player1[3] == 0 && player2[3] == 0 && p1turn == 1'b1)
								begin 
									player1[3]<= 1;
									moveout<= 0;
									plot = 1'b1;
									Xout <= 5'b11100;
									Yout <= 4'b0100;
								end
						4'b0100:if (p1turn == 1 && player1[4] == 0 && player2[4] == 0 && p1turn == 1'b1)
									begin 
										player1[4]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 4'b0100;
										Yout <= 4'b1100;
									end
						4'b0101:if (p1turn == 1 && player1[5] == 0 && player2[5] == 0 && p1turn == 1'b1)
									begin 
										player1[5]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 4'b1100;
										Yout <= 4'b1100;
									end
						4'b0110:if (p1turn == 1&& player1[6] == 0 && player2[6] == 0 && p1turn == 1'b1)
									begin 
										player1[6]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 5'b10100;
										Yout <= 4'b1100;										
									end
						4'b0111:if (p1turn == 1&& player1[7] == 0 && player2[7] == 0 && p1turn == 1'b1)
									begin 
										player1[7]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 5'b11100;
										Yout <= 4'b1100;										
									end					
						4'b1000:if (p1turn == 1 && player1[8] == 0 && player2[8] == 0 && p1turn == 1'b1)
									begin 
										player1[8]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 4'b0100;
										Yout <= 5'b10100;
									end					
						4'b1001:if (p1turn == 1 && player1[9] == 0 && player2[9] == 0 && p1turn == 1'b1)
									begin 
										player1[9]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 4'b1100;
										Yout <= 5'b10100;
									end					
						4'b1010:if (p1turn == 1 && player1[10] == 0 && player2[10] == 0 && p1turn == 1'b1)
									begin 
										player1[10]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 5'b10100;
										Yout <= 5'b10100;
									end
						4'b1011:if (p1turn == 1&& player1[11] == 0 && player2[11] == 0 && p1turn == 1'b1)
									begin 
										player1[11]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 5'b11100;
										Yout <= 5'b10100;
									end
						4'b1100:if (p1turn == 1&& player1[12] == 0 && player2[12] == 0 && p1turn == 1'b1)
									begin 
										player1[12]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 4'b0100;
										Yout <= 5'b11100;
									end
						4'b1101:if (p1turn == 1&& player1[13] == 0 && player2[13] == 0 && p1turn == 1'b1)
									begin 
										player1[13]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 4'b1100;
										Yout <= 5'b11100;
									end
						4'b1110:if (p1turn == 1 && player1[14] == 0 && player2[14] == 0 && p1turn == 1'b1)
									begin 
										player1[14]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 5'b10100;
										Yout <= 5'b11100;
									end
						4'b1111:if (p1turn == 1 && player1[15] == 0 && player2[15] == 0 && p1turn == 1'b1)
									begin 
										player1[15]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 5'b11100;
										Yout <= 5'b11100;
									end
						endcase
					end
					// same as player 1 expect checking for player2's turn
					if (p2turn == 1'b1)begin 
					case (p2input) 
						4'b0000: if(player1[0] == 0 && player2[0] == 0 && p2turn == 1'b1) begin 
									player2[0]<= 1;
									moveout<= 0;
									Xout <= 4'b0100;
									Yout <= 4'b0100;
									plot = 1'b1;
								end
						4'b0001: if (player1[1] == 0 && player2[1] == 0 && p2turn == 1'b1)
								begin 
									player2[1]<= 1;
									moveout<= 0;
									plot = 1'b1;
									Xout <= 4'b1100;
									Yout <= 4'b0100;
								end
						4'b0010: if (p2turn == 1&& player1[2] == 0 && player2[2] == 0)
								begin 
									player2[2]<= 1;
									moveout<= 0;
									plot = 1'b1;
									Xout <= 5'b10100;
									Yout <= 4'b0100;
								end
						4'b0011: if (p2turn == 1 && player1[3] == 0 && player2[3] == 0 )
								begin 
									player2[3]<= 1;
									moveout<= 0;
									plot = 1'b1;
									Xout <= 5'b10100;
									Yout <= 4'b0100;
								end
						4'b0100:if (p2turn == 1 && player1[4] == 0 && player2[4] == 0 )
									begin 
										player2[4]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 4'b0100;
										Yout <= 4'b1100;
									end
						4'b0101:if (p2turn == 1 && player1[5] == 0 && player2[5] == 0)
									begin 
										player2[5]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 4'b1100;
										Yout <= 4'b1100;
									end
						4'b0110:if (p2turn == 1 && player1[6] == 0 && player2[6] == 0)
									begin 
										player2[6]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 5'b10100;
										Yout <= 4'b1100;										
									end
						4'b0111:if (p2turn == 1&& player1[7] == 0 && player2[7] == 0)
									begin 
										player2[7]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 5'b11100;
										Yout <= 4'b1100;
									end					
						4'b1000:if (p2turn == 1 && player1[8] == 0 && player2[8] == 0)
									begin 
										player2[8]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 4'b0100;
										Yout <= 5'b10100;										
									end					
						4'b1001:if (p2turn == 1&& player1[9] == 0 && player2[9] == 0)
									begin 
										player2[9]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 4'b1100;
										Yout <= 5'b10100;										
									end					
						4'b1010:if (p2turn == 1&& player1[10] == 0 && player2[10] == 0)
									begin 
										player2[10]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 5'b10100;
										Yout <= 5'b10100;	
									end
						4'b1011:if (p2turn == 1  && player1[11] == 0 && player2[11] == 0)
									begin 
										player2[11]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 5'b11100;
										Yout <= 5'b10100;	
									end
						4'b1100:if (p2turn == 1 && player1[12] == 0 && player2[12] == 0)
									begin 
										player2[12]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 4'b0100;
										Yout <= 5'b11100;										
									end
						4'b1101:if (p2turn == 1&& player1[13] == 0 && player2[13] == 0)
									begin 
										player2[13]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 4'b1100;
										Yout <= 5'b11100;										
									end
						4'b1110:if (p2turn == 1&& player1[14] == 0 && player2[14] == 0)
									begin 
										player2[14]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 5'b10100;
										Yout <= 5'b11100;										
									end
						4'b1111:if (p2turn == 1 && player1[15] == 0 && player2[15] == 0)
									begin 
										player2[15]<= 1;
										moveout<= 0;
										plot = 1'b1;
										Xout <= 5'b11100;
										Yout <= 5'b11100;	
									end
					endcase
					end
			end
// check for the win condition of player 1
always@(posedge clock)
			begin
				// check the horizontal win conditions of the player 1 if they are 1 then set player 1 to win
				if(player1[0] == 1 && player1[1] == 1 && player1[2] == 1 && player1[3] == 1)
					begin
						player1win <= 1;
					end
				else if (player1[4] == 1 && player1[5] == 1 && player1[6] == 1 && player1[7] == 1)
					begin
						player1win <= 1;
					end
				else if (player1[8] == 1 && player1[9] == 1 && player1[10] == 1 && player1[11] == 1)
					begin
						player1win <= 1;
					end
				else if (player1[12] == 1 && player1[13] == 1 && player1[14] == 1 && player1[15] == 1)
					begin
						player1win <= 1;
					end
				//check the vertical win conditions of player 1 if they are 1 then set the player 1 to win
				else if (player1[0] == 1 && player1[4] == 1 && player1[8] == 1 && player1[12] == 1)
					begin
						player1win <= 1;
					end
				else if (player1[1] == 1 && player1[5] == 1 && player1[9] == 1 && player1[13] == 1)
					begin
						player1win <= 1;
					end
				else if (player1[2] == 1 && player1[6] == 1 && player1[10] == 1 && player1[14] == 1)
					begin
						player1win <= 1;
					end
				else if (player1[3] == 1 && player1[7] == 1 && player1[11] == 1 && player1[15] == 1)
					begin
						player1win <= 1;
					end
				//check the diagonal win conditions of the player 1
				else if (player1[0] == 1 && player1[5] == 1 && player1[10] == 1 && player1[15] == 1)
					begin
						player1win <= 1;
					end
				else if (player1[3] == 1 && player1[6] == 1 && player1[9] == 1 && player1[12] == 1)
					begin
						player1win <= 1;
					end
				//check the win conditions of player2
				else if(player2[0] == 1 && player2[1] == 1 && player2[2] == 1 && player2[3] == 1)
					begin
						player2win <= 1;
					end
				else if (player2[4] == 1 && player2[5] == 1 && player2[6] == 1 && player2[7] == 1)
					begin
						player2win <= 1;
					end
				else if (player2[8] == 1 && player2[9] == 1 && player2[10] == 1 && player2[11] == 1)
					begin
						player2win <= 1;
					end
				else if (player2[12] == 1 && player2[13] == 1 && player2[14] == 1 && player2[15] == 1)
					begin
						player2win <= 1;
					end
				//check the vertical win conditions of player 2 if they are 1 then set the player 2 to win
				else if (player2[0] == 1 && player2[4] == 1 && player2[8] == 1 && player2[12] == 1)
					begin
						player2win <= 1;
					end
				else if (player2[1] == 1 && player2[5] == 1 && player2[9] == 1 && player2[13] == 1)
					begin
						player2win <= 1;
					end
				else if (player2[2] == 1 && player2[6] == 1 && player2[10] == 1 && player2[14] == 1)
					begin
						player2win <= 1;
					end
				else if (player2[3] == 1 && player2[7] == 1 && player2[11] == 1 && player2[15] == 1)
					begin
						player2win <= 1;
					end
				//check the diagonal win conditions of the player 2
				else if (player2[0] == 1 && player2[5] == 1 && player2[10] == 1 && player2[15] == 1)
					begin
						player2win <= 1;
					end
				else if (player2[3] == 1 && player2[6] == 1 && player2[9] == 1 && player2[12] == 1)
					begin
						player2win <= 1;
					end

			end
endmodule

//hex display module to display the player letters onto the hexs
module hex_display(IN, OUT);
    input [2:0]IN;
     output reg [7:0] OUT;
     
     always @(*)
     begin
        case(IN[2:0])
            3'b000: OUT = 7'b0001100;
            3'b001: OUT = 7'b1000111;
            3'b010: OUT = 7'b0001000;
            3'b011: OUT = 7'b0010001;
            3'b100: OUT = 7'b0000110;
            3'b101: OUT = 7'b1001110;
            3'b110: OUT = 7'b1111001;
            3'b111: OUT = 7'b0100100;
            
            default: OUT = 7'b0111111;
        endcase

    end
endmodule
// hexdisplay to display which player is playing
module hex_display2(IN,OUT);
    input IN;
     output reg [7:0] OUT;
     
     always @(*)
     begin
        if(IN)
				OUT = 7'b1111001;
			else
				OUT = 7'b0100100;
    end
endmodule

// module to draw the square onto the vga from the VGA lab
module square(X,Y,clock,resetn,plot,Xout,Yout,newPlot);
	input [7:0]X;
	input [6:0]Y;
	input clock;
	input resetn;
	input plot;
	
	output reg newPlot;
	output reg [7:0] Xout;
	output reg [6:0] Yout;
	
	reg [4:0] counter;
	
	always@(posedge clock)
    begin: four
        if(!resetn)
            counter = 5'b0;
			else begin
				if (counter == 5'b10000)
					begin
					counter = 5'b0;
					Xout = 4'b0;
					Yout = 4'b0;
					newPlot = 1'b0;
					end
				else if (plot == 1'b1)
					begin
					newPlot = 1'b1;
					Xout <= X + counter[1:0];
					Yout <= Y + counter[3:2];
					counter <= counter + 1'b1;
					end
			end
	end
endmodule