// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

`timescale 1 ns / 1 ps

module spi_transfer_test_tb;
	reg clock;
	reg spi_clock;
    	reg RSTB;
	reg CSB;

	reg power1, power2;

	wire gpio;
	wire uart_tx;
	wire [37:0] mprj_io;

	wire core_to_tb;
	reg  tb_to_core;

        reg  enable_n;
        reg  trigger_in_n;
        reg  latch_data_n;
        wire  sclk;
        reg  mosi;
        reg  ss_n;
        wire miso;
	reg [31:0] tmp_data;

	assign mprj_io[37] =	enable_n;     	
	assign mprj_io[36] =	trigger_in_n; 	  
	assign mprj_io[35] = 	latch_data_n;	
	assign miso        = 	mprj_io[34];
	assign mprj_io[33] =  	mosi; 	   	
	assign mprj_io[32] = 	ss_n; 	   	
	assign mprj_io[31] = 	sclk; 	   	

	assign mprj_io[7] = 1'b0;
	assign uart_tx = mprj_io[6];
	assign mprj_io[5] = 1'b0;
	assign mprj_io[4] = 1'b0;
	assign mprj_io[3] = 1'b1;
	assign mprj_io[2] = 1'b0;
	assign mprj_io[1] = tb_to_core;
	assign core_to_tb = mprj_io[0];


	always #12.5 clock <= (clock === 1'b0);
	always #56.5 spi_clock <= ~spi_clock;


  	assign sclk = ~ss_n & spi_clock;

	initial begin
		clock 		= 0;
      		spi_clock     	= 1;
	end

	// Set the init state of input pins to asic
	task init_signals;
      	begin
		tb_to_core 	= 1'b0;
        	enable_n 	= 0;
        	trigger_in_n	= 0;
        	latch_data_n	= 0;
        	mosi 		= 0;
        	ss_n		= 1;
		wait_n_clks(50);
    	end
  	endtask
	// set the enable signal to chip
	task enable_chip;
	begin
	      	enable_n      = 0; 
	end
	endtask

	// unset the enable signal to chip
	task disable_chip;
	begin
	      	enable_n      = 1; 
	end
	endtask
	
	// pass time 
  	task wait_n_clks;
    	input integer i;
    	integer j;
    	begin
      		for(j=0;j<i;j=j+1)
        	@(posedge clock);
    	end
  	endtask

	initial begin
		$dumpfile("spi_transfer_test.vcd");
		$dumpvars(0, spi_transfer_test_tb);

		// Repeat cycles of 1000 clock edges as needed to complete testbench
		repeat (200) begin
			repeat (1000) @(posedge clock);
			// $display("+1000 cycles");
		end
		$display("%c[1;31m",27);
		`ifdef GL
			$display ("Monitor: Timeout, Test LA (GL) Failed");
		`else
			$display ("Monitor: Timeout, Test LA (RTL) Failed");
		`endif
		$display("%c[0m",27);
		$finish;
	end
	
	// transfer data on spi bus 
  	task spi_shift;
    	input [31:0] data_in;
    	output [31:0] data_out;
    	integer j;
    	begin
      		for(j=0;j<32;j=j+1)
      		begin
        		@(negedge spi_clock);
        		ss_n = 1'b0;
        		mosi = data_in[31];
        		data_in = data_in << 1;
        		@(posedge spi_clock)
        		data_out = {data_out[31:0],miso};
      		end
      		@(negedge spi_clock);
      		ss_n = 1'b1;
      		@(posedge clock);
      		@(posedge clock);
    	end
  	endtask

	initial begin
		init_signals();
		wait(core_to_tb === 1'b1);
		$display("LA Test 1 started");
		enable_chip();
		wait_n_clks(50);
		spi_shift(32'hBEEF_FACE,tmp_data);
		wait_n_clks(50);
		spi_shift(32'h0000_0000,tmp_data);
		tb_to_core = 1'b1;
		wait(core_to_tb === 1'b0);
		tb_to_core = 1'b0;
		if(tmp_data === 32'hBEEF_FACE)
		begin
			$display("SPI Passthrough 1 passed");
			$display("%h",tmp_data);
		end
		else
		begin
			$display("SPI Passthrough Test Failed");
			$display("%h",tmp_data);
		end
		#10000;
		$finish;
	end

	initial begin
		RSTB <= 1'b0;
		CSB  <= 1'b1;		// Force CSB high
		#2000;
		RSTB <= 1'b1;	    	// Release reset
		#170000;
		CSB = 1'b0;		// CSB can be released
	end

	initial begin		// Power-up sequence
		power1 <= 1'b0;
		power2 <= 1'b0;
		#200;
		power1 <= 1'b1;
		#200;
		power2 <= 1'b1;
	end

	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;

	wire VDD1V8;
	wire VDD3V3;
	wire VSS;
    
	assign VDD3V3 = power1;
	assign VDD1V8 = power2;
	assign VSS = 1'b0;

	//assign mprj_io[3] = 1;  // Force CSB high.
	//assign mprj_io[0] = 0;  // Disable debug mode

	caravel uut (
		.vddio	  (VDD3V3),
		.vddio_2  (VDD3V3),
		.vssio	  (VSS),
		.vssio_2  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (VDD3V3),
		.vdda1_2  (VDD3V3),
		.vdda2    (VDD3V3),
		.vssa1	  (VSS),
		.vssa1_2  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (VDD1V8),
		.vccd2	  (VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock    (clock),
		.gpio     (gpio),
		.mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("spi_transfer_test.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);

	// Testbench UART
	tbuart tbuart (
		.ser_rx(uart_tx)
	);

endmodule
`default_nettype wire
