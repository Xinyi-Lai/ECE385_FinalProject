//-------------------------------------------------------------------------
//    game_logic.sv Spring 2020											 --
//    decide the game status                                             --
//    Tell the ColorMapper whether this pixel is a part of the stickman  --
//-------------------------------------------------------------------------


module game_logic ( input	Clk,				// 50 MHz clock
							Reset,				// Active-high reset signal
							frame_clk,			// The clock indicating a new frame (~60Hz)
					input [9:0] StickmanBottom, GroundY, // The bottom of the stickman and current ground height
					input [7:0] keycode,		// Accept the last received key 
					output[3:0] status			// Game status {waiting, playing, win, lose}
				);

	logic stickman_crash, stickman_fall;
	assign stickman_crash = StickmanBottom > GroundY + 10'd50;
	assign stickman_fall = StickmanBottom >= 10'd470;

    // FSM
	enum logic [4:0] { WAIT, PLAY, WIN, LOSE, PREWAIT } curr_state, next_state;   // Internal state logic

	always_ff @ (posedge Clk)
	begin
		if (Reset)
			curr_state <= WAIT;
		else 
			curr_state <= next_state;	
	end

	always_comb
	begin
		// Default, nothing happens
		next_state = curr_state;
		
		// Assign next state
		unique case (curr_state)
		
			WAIT:
				if (keycode == 8'h2c)
					next_state = PLAY;
			PLAY:
            begin
                if (stickman_fall || stickman_crash)
                    next_state = LOSE;
            end

			WIN:
				if (keycode == 8'h2c)
					next_state = PREWAIT;
			LOSE:
				if (keycode == 8'h2c)
                    next_state = PREWAIT;
            PREWAIT:
                if (keycode != 8'h2c)
                    next_state = WAIT;
			default : ;
		
		endcase
		

		// Assign status
		unique case (curr_state)
            WAIT:
				status = 4'b1000;
			PREWAIT:
				status = 4'b1000;
            PLAY:
                status = 4'b0100;
			WIN:
                status = 4'b0010;
            LOSE:
                status = 4'b0001;
            default: 
                status = 4'b0000;   // will never happen
		endcase

	end

    
endmodule
