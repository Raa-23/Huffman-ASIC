`timescale 1ns / 1ps

module decoder (
    input wire SEL,
    input wire CLK2,                         // Clock signal
    input wire reset,                       // Reset signal
    input wire [15:0] input_enc,            // Input text (ASCII value)
    input wire [7:0] input_ascii,            // Input text (ASCII value)
    input wire [27:0] encoding,        // ASCII value from encoding file
    output reg [7:0] output_ascii,      // Output Huffman encoding value
    output reg [15:0] output_encoding,      // Output Huffman encoding value
    output reg [3:0] output_length,         // Length of the output encoding
    output reg match_found,                  // Flag indicating a match
    output reg stop,
    output reg give_input
);
	reg [31:0] buffer;
	reg [15:0] dummy;
	reg [3:0] enc_len;
	reg [4:0] buff_ind;
	reg [31:0] mask;
	reg input_given;
	
    always @(posedge CLK2) begin
    	if(SEL == 1'b1) begin
		if (reset) begin
		    output_ascii = 8'b0;
		    match_found = 1'b0;
		    stop = 1'b0;
		    give_input = 1'b0;
		    buffer = 32'b0;
		    dummy = 16'b0;
  		    enc_len = 4'b0;
		    buff_ind = 5'b0;
 		    mask = 32'b11111111111111111111111111111111;
		    input_given = 0;

		end 
		else begin
		    give_input = 1'b0;
		    match_found = 1'b0;
		    if (buff_ind < encoding[27:24] | buff_ind == 0) begin
		    	buffer = (buffer<<16);
		    	buffer = buffer + input_enc;
		    	buff_ind = buff_ind + 5'b10000;
		    	give_input = 1'b1;
		    	input_given = 1'b1;
		    end
		    enc_len = encoding[27:24];
		    dummy = (buffer >> (buff_ind - enc_len));    
		    mask = ((32'b00000000000000000000000000000001 << (buff_ind - enc_len)) - 1); 
		    if (encoding[23:8] == dummy & match_found == 0) begin
		        output_ascii = encoding[7:0];
		        match_found = 1'b1;
			$display("buffer = %b, buff_ind = %d , dummy = %b",buffer,buff_ind,dummy);
			//$finish;
			//$display("mask = %b",mask);
		        buffer = buffer & mask;
		        buff_ind = buff_ind - enc_len;
		        if (buffer == 16'b0000000000100100) begin
		        	stop = 1'b1;
		        end
		        if (buff_ind < enc_len) begin
		        	give_input = 1'b1;
		        end
		    end
		    
		    else begin
		        match_found = 1'b0;
		       //stop = 1'b0;
		    end
		    if (buffer == 0 & buff_ind != 0) begin
		    //$display("ERROR buffer became zero");
		    	//$finish;
		    end
		end
	end
	else begin

		if (reset) begin
		    $display("reseting the encoder");
		    output_encoding = 16'b0;
		    output_length = 4'b0;
		    match_found = 1'b0;
		    stop = 1'b0;
		end 
		else begin
		    // Compare input text with encoding ASCII value
		   // $display("comparing %b and %b ",input_ascii,encoding[7:0]);
		    if (input_ascii == encoding[7:0] & stop == 1'b0) begin
		        output_encoding = encoding[23:8];
		        output_length = encoding[27:24];
		        match_found = 1'b1;
		        if (input_ascii == 8'b00000011) begin
				$display("stopping the reader");
		        	stop = 1'b1;
		        end
		    end
		     
		    else begin
		        match_found = 1'b0;
		        //stop = 1'b0;
		    end
        	end
        end
    end

endmodule

