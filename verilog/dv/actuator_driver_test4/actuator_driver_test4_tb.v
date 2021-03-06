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

module actuator_driver_test4_tb;
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
	wire [4:0] h_ROWS;
	wire [1:0] h_COLS;
	wire [9:0] h_dots;
	wire [9:0] dots;
	reg [9:0] b_set_state;
	wire trigger_out_n;

	reg [9:0] rand_num [49:0];

	assign mprj_io[37] =	enable_n;     	
	assign mprj_io[36] =	trigger_in_n; 	  
	assign mprj_io[35] = 	latch_data_n;	
	assign miso        = 	mprj_io[34];
	assign mprj_io[33] =  	mosi; 	   	
	assign mprj_io[32] = 	ss_n; 	   	
	assign mprj_io[31] = 	sclk; 	   	

	assign trigger_out_n = mprj_io[16];
	assign mprj_io[7] = 1'b0;
	assign uart_tx = mprj_io[6];
	assign mprj_io[5] = 1'b0;
	assign mprj_io[4] = 1'b0;
	assign mprj_io[3] = 1'b1;
	assign mprj_io[2] = 1'b0;
	assign mprj_io[1] = tb_to_core;
	assign core_to_tb = mprj_io[0];


	always #12.5 clock <= (clock === 1'b0);
	always #100 spi_clock <= ~spi_clock;


  	assign sclk = ~ss_n & spi_clock;
	
	initial begin
		rand_num[0] = 691;
		rand_num[1] = 792;
		rand_num[2] = 856;
		rand_num[3] = 372;
		rand_num[4] = 213;
		rand_num[5] = 122;
		rand_num[6] = 357;
		rand_num[7] = 40;
		rand_num[8] = 554;
		rand_num[9] = 850;
		rand_num[10] = 866;
		rand_num[11] = 259;
		rand_num[12] = 583;
		rand_num[13] = 1011;
		rand_num[14] = 120;
		rand_num[15] = 34;
		rand_num[16] = 722;
		rand_num[17] = 646;
	end

	initial begin
		clock 		= 0;
      		spi_clock     	= 1;
	end

	// Set the init state of input pins to asic
	task init_signals;
      	begin
		tb_to_core 	= 1'b0;
        	enable_n 	= 1;
        	trigger_in_n	= 1;
        	latch_data_n	= 1;
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
		$dumpfile("actuator_driver_test4.vcd");
		$dumpvars(0, actuator_driver_test4_tb);

		// Repeat cycles of 1000 clock edges as needed to complete testbench
		repeat (400) begin
			repeat (1000) @(posedge clock);
			//$display("+1000 cycles");
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

  	task write_data;
    	input [7:0] address;
    	input [15:0] data;
    	reg [31:0] pass;
    	begin
      		@(posedge clock); 
      		latch_data_n = 1;
      		wait_n_clks(20);
      		spi_shift({8'h02,address,data},pass);
      		wait_n_clks(10);
      		latch_data_n = 0;
      		wait_n_clks(100);
      		latch_data_n = 1;
      		wait_n_clks(20);
    	end
  	endtask

  	task read_data;
    	input [7:0] address;
    	output [15:0] data_out;
    	reg [31:0] pass;
    	begin
      		@(posedge clock); 
      		latch_data_n = 1;
      		wait_n_clks(20);
      		spi_shift({8'h01,address,16'b0},pass);
      		wait_n_clks(100);
      		latch_data_n = 0;
      		wait_n_clks(20);
      		latch_data_n = 1;
      		wait_n_clks(20);
      		spi_shift(32'b0,data_out);
      		wait_n_clks(20);
    	end
  	endtask


	task memory_test;
    	input [7:0] address;
	input [15:0] data;
	reg [15:0] tmp;
	begin
		tmp = data;
		write_data(address,tmp);
		wait_n_clks(100);
		read_data(address,tmp);
		if(data === tmp)
		begin
			$display("SPI MEMORY TEST passed");
			$display("address:%h\tdata:%h",address,tmp);
		end
		else
		begin
			$display("SPI MEMORY Test Failed");
			$display("address:%h\tdata:%h",address,tmp);
			$display("%c[0m",27);
			$finish;
		end

	end
	endtask

  	task write_ccr0;
    	input [31:0] data;
    	integer j;
    	begin
      		wait_n_clks(20);
      		write_data(8'h02,data[15:0]);
      		wait_n_clks(20);
      		write_data(8'h03,data[31:16]);
      		wait_n_clks(20);
    	end
  	endtask

  	task write_ccr1;
    	input [31:0] data;
    	integer j;
    	begin
    		wait_n_clks(20);
    		write_data(8'h04,data[15:0]);
    		wait_n_clks(20);
    		write_data(8'h05,data[31:16]);
    		wait_n_clks(20);
    	end
  	endtask

  	task write_ccr2;
    	input [31:0] data;
    	integer j;
    	begin
    		wait_n_clks(20);
    		write_data(8'h06,data[15:0]);
    		wait_n_clks(20);
    		write_data(8'h07,data[31:16]);
    		wait_n_clks(20);
    	end
  	endtask

  	task write_ccr3;
    	input [31:0] data;
    	integer j;
    	begin
    		wait_n_clks(20);
    		write_data(8'h08,data[15:0]);
    		wait_n_clks(20);
    		write_data(8'h09,data[31:16]);
    		wait_n_clks(20);
    	end
  	endtask

  	task ccr_set;
    	begin
		$display("Writing CCR0");
      		write_ccr0(32'h00_00_00_04);
		$display("Writing CCR1");
      		write_ccr1(32'h00_00_00_0f);
		$display("Writing CCR2");
      		write_ccr2(32'h00_00_00_80);
		$display("Writing CCR3");
      		write_ccr3(32'h00_00_00_f0);
    	end
  	endtask

	task check_ccr_set;
	reg [15:0] tmp;
	reg [7:0] address;
	begin
		address = 8'h02;
		read_data(address,tmp);
		if(16'h00_04 === tmp)
		begin
			$display("CCR0 Low bit set PASSED");
			$display("address:%h\tccr0_low:%h",address,tmp);
		end
		else
		begin
			$display("CCR0 Low bit set FAILED");
			$display("address:%h\tccr0_low:%h",address,tmp);
			$display("%c[0m",27);
			$finish;
		end
		address = 8'h03;
		read_data(address,tmp);
		if(16'h00_00 === tmp)
		begin
			$display("CCR0 High bit set PASSED");
			$display("address:%h\tccr0_high:%h",address,tmp);
		end
		else
		begin
			$display("CCR0 High bit set FAILED");
			$display("address:%h\tccr0_high:%h",address,tmp);
			$display("%c[0m",27);
			$finish;
		end
		address = 8'h04;
		read_data(address,tmp);
		if(16'h00_0f === tmp)
		begin
			$display("CCR1 Low bit set PASSED");
			$display("address:%h\tccr0_low:%h",address,tmp);
		end
		else
		begin
			$display("CCR1 Low bit set FAILED");
			$display("address:%h\tccr0_low:%h",address,tmp);
			$display("%c[0m",27);
			$finish;
		end
		address = 8'h05;
		read_data(address,tmp);
		if(16'h00_00 === tmp)
		begin
			$display("CCR1 High bit set PASSED");
			$display("address:%h\tccr0_high:%h",address,tmp);
		end
		else
		begin
			$display("CCR1 High bit set FAILED");
			$display("address:%h\tccr0_high:%h",address,tmp);
			$display("%c[0m",27);
			$finish;
		end
		address = 8'h06;
		read_data(address,tmp);
		if(16'h00_80 === tmp)
		begin
			$display("CCR2 Low bit set PASSED");
			$display("address:%h\tccr0_low:%h",address,tmp);
		end
		else
		begin
			$display("CCR2 Low bit set FAILED");
			$display("address:%h\tccr0_low:%h",address,tmp);
			$display("%c[0m",27);
			$finish;
		end
		address = 8'h07;
		read_data(address,tmp);
		if(16'h00_00 === tmp)
		begin
			$display("CCR2 High bit set PASSED");
			$display("address:%h\tccr0_high:%h",address,tmp);
		end
		else
		begin
			$display("CCR2 High bit set FAILED");
			$display("address:%h\tccr0_high:%h",address,tmp);
			$display("%c[0m",27);
			$finish;
		end
		
	end
	endtask

  	task check_b_state;
    	input [9:0] b_state;
	reg [9:0] translation_dots ;
    	begin
		$display("########## TEST ############");
		{translation_dots[9],translation_dots[4],translation_dots[8],translation_dots[3],translation_dots[7:5],translation_dots[2:0]} = b_state;
		if((translation_dots === dots) && (translation_dots === h_dots))
		begin
			$display("b_state dot test: PASSED");
			$display("b_state:\t%b",b_state);
			$display("trans  :\t%b",translation_dots);
			$display("dots   :\t%b",dots);
			$display("h_dots :\t%b",h_dots);
		end
		else
		begin
			$display("b_state set faild");
			$display("b_state:\t%b",b_state);
			$display("trans  :\t%b",translation_dots);
			$display("dots   :\t%b",dots);
			$display("h_dots :\t%b",h_dots);
			$display("%c[0m",27);
			$finish;
		end
	end
	endtask

  	task write_b_state;
    	input [9:0] b_state;
    	begin
    		wait_n_clks(20);
    		write_data(8'h00,{6'b0,b_state});
    		wait_n_clks(100);
    	end
  	endtask

  	task set_trigger_mode_no_wait;
    	input past_state_bit;
    	input inv_bit;
    	integer j;
    	reg [31:0] pass;
    	begin
      		@(posedge clock); 
      		latch_data_n = 1'b1;
      		trigger_in_n = 1'b1;
      		wait_n_clks(20);
      		spi_shift({2'b0,past_state_bit,inv_bit,4'h8,24'b0},pass);
      		wait_n_clks(100);
      		latch_data_n = 0;
      		wait_n_clks(20);
      		latch_data_n = 1;
      		wait_n_clks(20);
      		trigger_in_n = 1'b0;
      		wait_n_clks(20);
      		trigger_in_n = 1'b1;
      		//@(negedge trigger_out_n);
      		wait_n_clks(20);
    	end
  	endtask

  	task advance_b_state_and_check;
	input [9:0] b_state;
    	input past_state_bit;
    	input inv_bit;
    	integer j;
    	reg [31:0] pass;
    	begin
  		write_b_state(b_state);
      		@(posedge clock); 
      		latch_data_n = 1'b1;
      		trigger_in_n = 1'b1;
      		wait_n_clks(20);
      		spi_shift({2'b0,past_state_bit,inv_bit,4'h8,24'b0},pass);
      		wait_n_clks(100);
      		latch_data_n = 0;
      		wait_n_clks(20);
      		latch_data_n = 1;
      		wait_n_clks(20);
      		trigger_in_n = 1'b0;
      		wait_n_clks(20);
      		trigger_in_n = 1'b1;
      		@(negedge trigger_out_n);
		if(inv_bit)
			check_b_state(~b_state);
		else
			check_b_state(b_state);
      		wait_n_clks(20);
    	end
  	endtask

	task to_high_test;
    	input past_state_bit;
    	input inv_bit;
	integer i;
	reg [9:0] state;
	begin
		state = 10'b0;
		advance_b_state_and_check(state,past_state_bit,inv_bit);
		for(i=0;i<11;i=i+1)
		begin
			state = 10'b00_0000_0001 << i;
		advance_b_state_and_check(state,past_state_bit,inv_bit);
		end
		
	end
	endtask

	task to_low_test;
    	input past_state_bit;
    	input inv_bit;
	integer i;
	reg [9:0] state;
	begin
		state = 10'b11_1111_1111;
		advance_b_state_and_check(state,past_state_bit,inv_bit);
		for(i=0;i<11;i=i+1)
		begin
			state = ~(10'b00_0000_0001 << i);
		advance_b_state_and_check(state,past_state_bit,inv_bit);
		end
		
	end
	endtask

	task one_bit_advance;
	input past_state_bit;
	begin
		to_high_test(past_state_bit,1'b0);
		to_low_test(past_state_bit,1'b0);
		to_high_test(past_state_bit,1'b1);
		to_low_test(past_state_bit,1'b1);
	end
	endtask

	task init_system;
	begin
		enable_chip();
		wait_n_clks(50);
		ccr_set();
		check_ccr_set();
	end
	endtask

	task reset_system;
	begin
      		wait_n_clks(20);
		disable_chip();
      		wait_n_clks(100);
		enable_chip();
      		wait_n_clks(100);
	end
	endtask

	task set_state_to_auto_update;
    	input past_state_bit;
    	input inv_bit;
	reg [31:0] pass;
	begin
      		@(posedge clock); 
      		latch_data_n = 1'b1;
      		trigger_in_n = 1'b1;
      		wait_n_clks(20);
      		spi_shift({2'b0,past_state_bit,inv_bit,4'h4,24'b0},pass);
      		wait_n_clks(100);
      		latch_data_n = 0;
      		wait_n_clks(20);
      		latch_data_n = 1;
      		wait_n_clks(20);
	end
	endtask	

	task set_state_to_idle;
	reg [31:0] pass;
	begin
      		@(posedge clock); 
      		latch_data_n = 1'b1;
      		trigger_in_n = 1'b1;
      		wait_n_clks(20);
      		spi_shift({2'b0,1'b0,1'b0,4'h0,24'b0},pass);
      		wait_n_clks(100);
      		latch_data_n = 0;
      		wait_n_clks(20);
      		latch_data_n = 1;
      		wait_n_clks(20);
	end
	endtask

	task check_n_updates;
	input [7:0] n;
	input [9:0] b_state;
	reg [9:0] state;
	integer i;
	begin
		for(i=0;i<n;i=i+1)
		begin
			@(negedge trigger_out_n);
			check_b_state(b_state);
		end
	end
	endtask
	




	task check_n_updates_rand;
	input [7:0] n;
    	input past_state_bit;
    	input inv_bit;
	reg [9:0] b_state;
	integer i;
	integer ran;
	begin
		$display("######### Runing Rand Test ###########");
		$display("pram: n:%d, past_state_bit:%h, inv_bit:%h",n,past_state_bit,inv_bit);
		ran = 10;
		for(i=0;i<n;i=i+1)
		begin
			//b_state = $random();
			b_state = rand_num[i];
			write_b_state(b_state);
			set_state_to_auto_update(past_state_bit,inv_bit);
			if(inv_bit)
				check_n_updates(8'h04,~b_state);
			else
				check_n_updates(8'h04,b_state);
			set_state_to_idle();
		end
	end
	endtask


	initial begin
		init_signals();
		wait(core_to_tb === 1'b1);
		$display("LA Test 1 started");
		init_system();
  		write_b_state(10'b01_0101_0101);
		set_state_to_auto_update(1'b0,1'b0);
		check_n_updates(8'h04,10'b01_0101_0101);
		set_state_to_idle();
  		write_b_state(10'b10_1010_1010);
		set_state_to_auto_update(1'b0,1'b0);
		check_n_updates(8'h04,10'b10_1010_1010);
		set_state_to_idle();
		check_n_updates_rand(8'h12,1'b0,1'b0);
		check_n_updates_rand(8'h12,1'b0,1'b1);
		check_n_updates_rand(8'h12,1'b1,1'b0);
		check_n_updates_rand(8'h12,1'b1,1'b1);
		tb_to_core = 1'b1;
		wait(core_to_tb === 1'b0);
		tb_to_core = 1'b0;
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
		.FILENAME("actuator_driver_test4.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);

	// Testbench UART
	//tbuart tbuart (
	//	.ser_rx(uart_tx)
	//);

	hbrige_cells hbrige_drivers_ic(
	  .rows(mprj_io[30:21]),
	  .cols(mprj_io[20:17]),
	  .ROWS(h_ROWS),
	  .COLS(h_COLS)
	);
	actuator_cell h_cell_ic(
	  .cols(h_COLS),
	  .rows(h_ROWS),
	  .dots(h_dots)
	);

	actuator_cell cell_ic(
	  .cols(mprj_io[9:8]),
	  .rows(mprj_io[14:10]),
	  .dots(dots)
	);
	

endmodule

module hbrige(
  output reg line,
  input wire p,
  input wire n
);
  always@(*)
  begin
    case({p,n})
        2'b00: line = 1'b0;
        2'b11: line = 1'b1;
        2'b10: line = 1'bz;
        2'b01: line = 1'bx;
    endcase
  end
endmodule

module hbrige_cells(
  input wire [9:0] rows,
  input wire [3:0] cols,
  output wire [4:0] ROWS,
  output wire [1:0] COLS
);

  wire [4:0] MEM [1:0];
  genvar i;
  genvar j;

  for(i=0;i<2;i=i+1)
  begin
    hbrige brige_line(
      .line (COLS[i]),
      .p    (cols[2*i+1]),
      .n    (cols[2*i])
    );
  end
  for(j=0;j<5;j=j+1)
  begin
    hbrige brige_line(
      .line (ROWS[j]),
      .p    (rows[2*j+1]),
      .n    (rows[2*j])
    );
  end

  for(i=0;i<2;i=i+1)
  begin
    for(j=0;j<5;j=j+1)
    begin
      assign MEM[i][j] = ((ROWS[j] === 1'bz) || (COLS[i] === 1'bz)) ? 1'bz : ((ROWS[j] == 1'b1) && (COLS[i] == 1'b0)) ? 1'b1 : ((ROWS[j] == 1'b0) && (COLS[i] == 1'b1)) ? 1'b0 : 1'bx;
    end
  end

endmodule


module actuator_cell(
  input wire [1:0] cols,
  input wire [4:0] rows,
  output reg [9:0] dots
);
	genvar i;
	genvar j;

	generate
	for(i=0;i<5;i=i+1)
	begin
		for(j=0;j<2;j=j+1)
		begin
			always@(*)
			begin
				if((cols[j] === 1'bz) | (rows[i] === 1'bz))
				begin
				    dots[i+5*j] = dots[i+5*j];
				end
				else
				begin
					if((cols[j] === 1'b0) && (rows[i] === 1'b1))
						dots[i+5*j] = 1'b1;
				    	else if((cols[j] === 1'b1) && (rows[i] === 1'b0))
					      	dots[i+5*j] = 1'b0;
					else if((cols[j] === 1'b1) && (rows[i] === 1'b1))
					    	dots[i+5*j] = dots[i+5*j];
				    	else if((cols[j] === 1'b0) && (rows[i] === 1'b0))
					    	dots[i+5*j] = dots[i+5*j];
				      	else
				      	begin
						$display("%c[0m",27);
						$display("cols[%h] = %h,rows[%h] = %h",j,cols[j],i,rows[i]);
						#1;
						$finish;
				     	end
				end
			end
			/*
			  always@(*)
			  begin
				    dots[i+5*j] = dots[i+5*j];
				    if((cols[j] === 1'b0) && (rows[i] === 1'b1))
					      dots[i+5*j] = 1'b1;
				    else if((cols[j] === 1'b1) && (rows[i] === 1'b0))
					      dots[i+5*j] = 1'b0;
			  end
			  */
		end
	end
	endgenerate
/*
  always@(*)
  begin
    dots[0] = dots[0];
    if((cols[0] === 1'b0) && (rows[0] === 1'b1))
      dots[0] = 1'b1;
    else if((cols[0] === 1'b1) && (rows[0] === 1'b0))
      dots[0] = 1'b0;
  end

  always@(*)
  begin
    dots[1] = dots[1];
    if((cols[0] === 1'b0) && (rows[1] === 1'b1))
      dots[1] = 1'b1;
    else if((cols[0] === 1'b1) && (rows[1] === 1'b0))
      dots[1] = 1'b0;
  end

  always@(*)
  begin
    dots[2] = dots[2];
    if((cols[0] === 1'b0) && (rows[2] === 1'b1))
      dots[2] = 1'b1;
    else if((cols[0] === 1'b1) && (rows[2] === 1'b0))
      dots[2] = 1'b0;
  end

  always@(*)
  begin
    dots[3] = dots[3];
    if((cols[0] === 1'b0) && (rows[3] === 1'b1))
      dots[3] = 1'b1;
    else if((cols[0] === 1'b1) && (rows[3] === 1'b0))
      dots[3] = 1'b0;
  end

  always@(*)
  begin
    dots[4] = dots[4];
    if((cols[0] === 1'b0) && (rows[4] === 1'b1))
      dots[4] = 1'b1;
    else if((cols[0] === 1'b1) && (rows[4] === 1'b0))
      dots[4] = 1'b0;
  end

  always@(*)
  begin
    dots[5] = dots[5];
    if((cols[1] === 1'b0) && (rows[0] === 1'b1))
      dots[5] = 1'b1;
    else if((cols[1] === 1'b1) && (rows[0] === 1'b0))
      dots[5] = 1'b0;
  end

  always@(*)
  begin
    dots[6] = dots[6];
    if((cols[1] === 1'b0) && (rows[1] === 1'b1))
      dots[6] = 1'b1;
    else if((cols[1] === 1'b1) && (rows[1] === 1'b0))
      dots[6] = 1'b0;
  end

  always@(*)
  begin
    dots[7] = dots[7];
    if((cols[1] === 1'b0) && (rows[2] === 1'b1))
      dots[7] = 1'b1;
    else if((cols[1] === 1'b1) && (rows[2] === 1'b0))
      dots[7] = 1'b0;
  end

  always@(*)
  begin
    dots[8] = dots[8];
    if((cols[1] === 1'b0) && (rows[3] === 1'b1))
      dots[8] = 1'b1;
    else if((cols[1] === 1'b1) && (rows[3] === 1'b0))
      dots[8] = 1'b0;
  end

  always@(*)
  begin
    dots[9] = dots[9];
    if((cols[1] === 1'b0) && (rows[4] === 1'b1))
      dots[9] = 1'b1;
    else if((cols[1] === 1'b1) && (rows[4] === 1'b0))
      dots[9] = 1'b0;
  end
  */
endmodule
`default_nettype wire
