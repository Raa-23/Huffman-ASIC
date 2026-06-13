`timescale 1ns / 1ps

module main;
    reg SEL;
    reg CLK1,CLK2,CLK3;                              // Clock signal
    reg reset;                            // Reset signal
    reg [7:0] input_ascii;                 // Input text (ASCII value)
    reg [15:0] input_enc;
    reg [27:0] encoding;             // ASCII value from encoding file
    wire [7:0] output_ascii;
    wire [15:0] output_encoding;
    wire [3:0] output_length;
    wire match_found;                     // Flag indicating a match
    wire stop;
    wire give_input;
    integer text_file, enc_file, out_file; // File handles
    reg [15:0] bit_shift1;          	// Temporary register for assembling bytes
    reg [7:0] bit_shift1x;
    integer bit_index1;            	// Bit index for assembling bytes 
    reg [27:0] bit_shift2;
    integer bit_index2;
    integer i,j,status,status2;

    // Instantiate the HuffmanDecoder module
    decoder dut (
    	.SEL(SEL),
        .CLK2(CLK2),
        .reset(reset),
        .input_enc(input_enc),
        .input_ascii(input_ascii),
        .encoding(encoding),
        .output_ascii(output_ascii),
        .output_encoding(output_encoding),
        .output_length(output_length),
        .match_found(match_found),
        .stop(stop),
        .give_input(give_input)
        
    );

    // Clock generation
    	always #100 CLK3 = ~CLK3;
	initial SEL = 1;
    // Testbench stimulus
   	
	initial begin
		if(SEL) begin
			$display("initializing the decoder");
			CLK1 = 1'b0;
			CLK2 = 1'b0;
			CLK3 = 1'b0;
			reset = 1;
			CLK2 = ~CLK2;
			#5 CLK2 = ~CLK2;
			input_enc = 16'b0;
			encoding = 28'b0;
			bit_shift1 = 16'b0;
			bit_index1 = 15;
			bit_shift2 = 28'b0;
			bit_index2 = 27;
			// Open files
			text_file = $fopen("outputfile.txt", "r");
			out_file = $fopen("outputfile2.txt", "w");
			
			if (text_file == 0 || enc_file == 0 || out_file == 0) begin
			    $display("Error: Unable to open one or more files.");
			    $finish;
			end

			// Reset the DUT
			#10 reset = 0;
			//#5 CLK2 = ~CLK2;
			//#5 CLK2 = ~CLK2;
		end
		else begin
			$display("initializing the encoder");
			CLK1 = 1'b0;
			CLK2 = 1'b0;
			CLK3 = 1'b0;
			reset = 1;
			CLK2 = ~CLK2;
			#5 CLK2 = ~CLK2;
			input_ascii = 8'b0;
			encoding = 28'b0;
			bit_shift1x = 8'b0;
			bit_index1 = 7;
			bit_shift2 = 28'b0;
			bit_index2 = 27;
			// Open files
			text_file = $fopen("textfile", "r");
			out_file = $fopen("outputfile.txt", "w");
			
			if (text_file == 0 || enc_file == 0 || out_file == 0) begin
			    $display("Error: Unable to open one or more files.");
			    $finish;
			end

			// Reset the DUT
			#10 reset = 0;
			CLK2 = ~CLK2;
			#5 CLK2 =~CLK2;
		end
	end
	always @(posedge CLK3) begin
		if(SEL) begin
		
			//$display("reeached %b",input_enc);
	       	 	// Read text file line-by-line
		    	if (stop == 1'b0) begin
		        	status = $fgetc(text_file);  // Read one character from the file
		        
				// Check for valid binary character
				if (status == "0" || status == "1") begin
				    // Shift bits and assemble one byte
				    bit_shift1[bit_index1] = (status == "1") ? 1'b1 : 1'b0;
				    bit_index1 = bit_index1 - 1;

				    // If one byte (8 bits) is assembled
				    if (bit_index1 < 0) begin
				        input_enc = bit_shift1;  // Store the assembled byte
				       $display("Read byte: %b", input_enc); // Display the byte
				        bit_shift1 = 16'b0;       // Reset the bit_shift register
				        bit_index1 = 15;          // Reset the bit index
				        CLK1 = ~CLK1;
				    end
				end 
				else if (status != 10 && status != 13) begin
				    // Handle invalid characters
				    CLK1 = ~CLK1;
				    $display("Unknown character in text file", status);
				    CLK1 = ~CLK1;
				    #5000;
				    $finish;
				end
				else begin
				// Handle partial byte if file ends before completing a full byte
			     	   if (bit_index1 != 15) begin
				    	input_enc = bit_shift1;
				    	$display("Read partial byte: %b",text_file);
				    	$finish;
				    end
			     	end  
		        end
		        else begin
		        	$fclose(out_file);
		        	$fclose(text_file);
		        	$display("End of file reached. Encoded Succesfully");
		        	$finish;
		        end
		end
		else begin
			$display("stop = ",stop);
			if (stop == 1'b0) begin
		        	status = $fgetc(text_file);  // Read one character from the file
		        
				// Check for valid binary character
				if (status == "0" || status == "1") begin
				    // Shift bits and assemble one byte
				    bit_shift1x[bit_index1] = (status == "1") ? 1'b1 : 1'b0;
				    bit_index1 = bit_index1 - 1;

				    // If one byte (8 bits) is assembled
				    if (bit_index1 < 0) begin
				        input_ascii = bit_shift1x;  // Store the assembled byte
				       //$display("Read byte: %b", input_ascii); // Display the byte
				        bit_shift1x = 8'b0;       // Reset the bit_shift register
				        bit_index1 = 7;          // Reset the bit index
				        CLK1 = ~CLK1;
				    end
				end 
				else if (status != 10 && status != 13) begin
				    // Handle invalid characters
				    $display("Unknown character in text file", status);
				    $finish;
				end
				else begin
				// Handle partial byte if file ends before completing a full byte
			     	   if (bit_index1 != 7) begin
				    	input_ascii = bit_shift1;
				    	$display("Read partial byte: %b",text_file);
				    	$finish;
				    end
			     	end  
		        end
		        else begin
		        	$fclose(out_file);
		        	$fclose(text_file);
		        	$display("End of file reached. Encoded Succesfully");
		        	$finish;
		        end   
		end  
		           
	end
	always @(CLK1) begin
		if(SEL) begin
			if(give_input) begin
				#5 CLK2 = ~CLK2;
				#5 CLK2 = ~CLK2;
			end
			while(!give_input) begin
				//$display("give input %b and match found = %b",give_input,match_found);
				//$display("encoding_valid = %b",encoding_valid);
				enc_file = $fopen("encoding", "r");
				
				while(!match_found & !give_input) begin 
						
						status2 = $fgetc(enc_file);
						if (status2 == "0" || status2 == "1") begin
					    		// Shift bits and assemble one byte
					    		bit_shift2[bit_index2] = (status2 == "1") ? 1'b1 : 1'b0;
					    		bit_index2 = bit_index2 - 1;

					   		 // If one byte (8 bits) is assembled
					    		if (bit_index2 < 0) begin
								encoding = bit_shift2;  // Store the assembled byte
							//$display("Read encoding: %b", encoding); // Display the byte
								bit_shift2 = 8'b0;       // Reset the bit_shift register
								bit_index2 = 27;          // Reset the bit index
								//encoding_valid = 1'b1;
								#5 CLK2 = ~CLK2;
								#5 CLK2 = ~CLK2;
					    		end
						end 
						else if (status != 10 && status != 13) begin
					    		//Handle invalid characters
					    		$display("Error: Invalid character in enc_file: %c", status);
					    		$finish;
						end
						else if(encoding[7:0] == 8'b01011010) begin
							$display("Unknown character: %b lost ",text_file);
							text_file =  8'b00000000;
							$fclose(enc_file);
							enc_file = $fopen("encoding", "r");
						end
				    		else begin
							// Handle partial byte if file ends before completing a full byte					
							//$display("bit_index2 = %d",bit_index2);
							if (bit_index2 != 27) begin
						    		encoding = bit_shift2;
						    		$display("Read partial byte: %b", encoding);
							end  
						end      		
				end
				if(match_found) begin
					for(j=7;j>=0;j=j-1) begin
						//$display("writting");
						$fwrite(out_file, "%b",output_ascii[j]);
					end
					$display("Written %b as %c",encoding,output_ascii);
					//$display("\n");
					//$display("\n");
					//$display("\n");
					//$display("\n");
					//$fclose(enc_file);
					//encoding_valid = 1'b0;
				//input_ascii = 16'b0000000000000000;
					//encoding = 28'b0;
					#5 CLK2 = ~CLK2;
					#5 CLK2 = ~CLK2;
					//$display("give input = ",give_input);
				end	
			end
		end
		else begin
			//$display("input : ",input_ascii);
			enc_file = $fopen("encoding", "r");
			//$display("match found",match_found);
			while(!match_found) begin 
					status2 = $fgetc(enc_file);
					if (status2 == "0" || status2 == "1") begin
				    		// Shift bits and assemble one byte
				    		bit_shift2[bit_index2] = (status2 == "1") ? 1'b1 : 1'b0;
				    		bit_index2 = bit_index2 - 1;

				   		 // If one byte (8 bits) is assembled
				    		if (bit_index2 < 0) begin
							encoding = bit_shift2;  // Store the assembled byte
							//$display("Read encoding: %b", encoding); // Display the byte
							bit_shift2 = 28'b0;       // Reset the bit_shift register
							bit_index2 = 27;          // Reset the bit index
							//encoding_valid = 1'b1;
							#5 CLK2 = ~CLK2;
							#5 CLK2 = ~CLK2;
				    		end
					end 
					else if (status != 10 && status != 13) begin
				    		//Handle invalid characters
				    		$display("Error: Invalid character in enc_file: %c", status);
				    		$finish;
					end
					else if(encoding[7:0] == 8'b01011010) begin
						$display("Unknown character: %b lost ",text_file);
						text_file =  8'b00000000;
						$fclose(enc_file);
						enc_file = $fopen("encoding", "r");
					end
			    		else begin
						// Handle partial byte if file ends before completing a full byte					
						//$display("bit_index2 = %d",bit_index2);
						if (bit_index2 != 27) begin
					    		encoding = bit_shift2;
					    		$display("Read partial byte: %b", encoding);
						end  
					end      		
			end
			if(match_found) begin
				for(j=output_length-1;j>=0;j=j-1) begin
					//$display("writting");
					$fwrite(out_file, "%b",output_encoding[j]);
				end
				$display("Written %c as %b",input_ascii,output_encoding);
				$fclose(enc_file);
				//encoding_valid = 1'b0;
				input_ascii = 8'b11111111;
				encoding = 28'b0;
				CLK2 = ~CLK2;
				#5 CLK2 = ~CLK2;
				
			end	
		end		
							
	end
	initial begin
		$dumpfile("waveforms.vcd");
		$dumpvars(0,dut);
		$dumpvars(1,main);
	end
endmodule

