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
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */
`ifndef MPRJ_IO_PADS
  `define MPRJ_IO_PADS 38
`endif


module braille_driver_controller
(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Logic Analyzer Signals
    input  wire [127:0] la_data_in,
    output wire [127:0] la_data_out,
    input  wire [127:0] la_oenb,

    // IOs
    input  wire [`MPRJ_IO_PADS-1:0] io_in,
    output wire [`MPRJ_IO_PADS-1:0] io_out,
    output wire [`MPRJ_IO_PADS-1:0] io_oeb,


    // Independent clock (on independent integer divider)
    input wire   user_clock2,

    // User maskable interrupt signals
    output wire [2:0] irq

);
    wire 	clk;
    wire [37:0] user_data_out;
    wire [37:0] user_data_oeb;
    wire         enable_n; 
    wire [4:0]   rows;
    wire [1:0]   cols;
    wire [4:0]   rows_enable;
    wire [1:0]   cols_enable;
    wire [9:0]   rows_hbrige;
    wire [3:0]   cols_hbrige;
    reg [`MPRJ_IO_PADS-1:0] io_in_reg;
    wire         trigger_out_n;
    wire         trigger_in_n;
    wire         latch_data_n;
    wire         sclk;
    wire         mosi;
    wire         ss_n;
    wire         miso;


    // IRQ
    assign irq = 3'b000;	// Unused

    // Assuming LA probes [65:64] are for controlling the count clk & reset  
    assign clk = (~la_oenb[64]) ? la_data_in[64]: user_clock2;

    genvar i;
    generate
    for(i=0;i<38;i=i+1'b1)
    begin : io_port_assignment
        assign io_out[i]     = (~la_oenb[i]) ? la_data_in[i]    : user_data_out[i];
	assign io_oeb[i]     = (~la_oenb[i+38]) ? la_data_in[i+38] : user_data_oeb[i];
	assign la_data_out[i] = (~la_oenb[i]) ? 1'b0 : io_in_reg[i];
	//assign la_data_out[i] = (~la_oenb[i]) ? 1'b0 : io_in[i];
	always@(posedge clk)
	begin
		io_in_reg[i] = io_in[i];
	end
    end
    endgenerate
    // 15 16 18 19 21 23
    //  0 14 17 20 22  0
    // 12  0 13 24  0 25
    //  0  0  0  0 26 27
    //  0  0  0  0 28 29
    //  0  0  0  0 30 31
    //  0  0  0  0  0 32
    //  0  0  0 33 34 35
    //  0  0  0  0 36 37
    //  0  0  0  0  0  0
    //  28 decated pins

    assign user_data_out = {
	1'b0,		// 37 enable_n
	1'b0,		// 36 trigger_in_n
	1'b0,		// 35 latch_data_n
	miso,		// 34 miso
	1'b0,		// 33 mosi
	1'b0,		// 32 ss_n
	1'b0,		// 31 sclk
	rows_hbrige[9],	// 30
	rows_hbrige[8],	// 29
	rows_hbrige[7],	// 28
	rows_hbrige[6],	// 27
	rows_hbrige[5],	// 26
	rows_hbrige[4],	// 25
	rows_hbrige[3],	// 24
	rows_hbrige[2],	// 23
	rows_hbrige[1],	// 22
	rows_hbrige[0],	// 21
	cols_hbrige[3],	// 20
	cols_hbrige[2],	// 19
	cols_hbrige[1],	// 18
	cols_hbrige[0],	// 17
	trigger_out_n,	// 16
	1'b0,		// 15
	rows[4],	// 14	user_control_enable_6
	rows[3],	// 13	user_control_enable_5
	rows[2],	// 12	user_control_enable_4
	rows[1],	// 11   user_control_enable_3
	rows[0],	// 10	flash2_io  / user_control_enable_2
	cols[1],	// 9	flash2_io  / user_control_enable_1
	cols[0],	// 8	flash2_csb / user_control_enable_0
	1'b0,		// 7	irq
	1'b0,		// 6	ser_tx
	1'b0,		// 5	ser_rx
	1'b0,		// 4	SCK
	1'b0,		// 3	CSB
	1'b0,		// 2	SDI
	1'b0,		// 1	SDO  / CPU_TO_IO
	1'b0		// 0   	JTAG / IO_TO_CPU
	};

    assign user_data_oeb = {
	1'b1,			// 37 	enable_n     	: input
	1'b1,			// 36 	trigger_in_n 	: input  
	1'b1,			// 35 	latch_data_n 	: input
	1'b0,			// 34 	miso 	   	: output
	1'b1,			// 33 	mosi 	   	: input
	1'b1,			// 32 	ss_n 	   	: input
	1'b1,			// 31 	sclk 	   	: input
	1'b0,			// 30	hbrige_0 	: output
	1'b0,			// 29	hbrige_0 	: output
	1'b0,			// 28	hbrige_0 	: output
	1'b0,			// 27	hbrige_0 	: output
	1'b0,			// 26	hbrige_0 	: output
	1'b0,			// 25	hbrige_0 	: output
	1'b0,			// 24	hbrige_0 	: output
	1'b0,			// 23	hbrige_0 	: output
	1'b0,			// 22	hbrige_0 	: output
	1'b0,			// 21	hbrige_0 	: output
	1'b0,			// 20	hbrige_0 	: output
	1'b0,			// 19	hbrige_0 	: output
	1'b0,			// 18	hbrige_0 	: output
	1'b0,			// 17	hbrige_0 	: output
	1'b0,			// 16	triger_out_n 	: output
	1'b1,			// 15   n/a 		: input				
	~rows_enable[4],	// 14	user_control_enable_6
	~rows_enable[3],	// 13	user_control_enable_5
	~rows_enable[2],	// 12	user_control_enable_4
	~rows_enable[1],	// 11   user_control_enable_3
	~rows_enable[0],	// 10	flash2_io  / user_control_enable_2
	~cols_enable[1],	// 9	flash2_io  / user_control_enable_1
	~cols_enable[0],	// 8	flash2_csb / user_control_enable_0
	1'b1,		// 7	irq
	1'b1,		// 6	ser_tx
	1'b1,		// 5	ser_rx
	1'b1,		// 4	SCK
	1'b1,		// 3	CSB
	1'b1,		// 2	SDI
	1'b1,		// 1	SDO  / IO_TO_CPU : input
	1'b0		// 0   	JTAG / CPU_TO_IO : output
	};

	assign enable_n     =	io_in_reg[37]; 	
	assign trigger_in_n =   io_in_reg[36]; 	  
	assign latch_data_n =   io_in_reg[35];	
	assign mosi 	    =   io_in_reg[33];	
	assign ss_n 	    =   io_in_reg[32];	
	assign sclk 	    =   io_in_reg[31];	
    
	top user_design (
`ifdef USE_POWER_PINS
	    .vccd1		(vccd1		),	// User area 1 1.8V supply
	    .vssd1		(vssd1		),	// User area 1 digital ground
`endif
	  .clock		(clk		),
	  .enable_n		(enable_n	), 
	  .rows			(rows		),
	  .cols			(cols		),
	  .rows_enable		(rows_enable	),
	  .cols_enable		(cols_enable	),
	  .rows_hbrige		(rows_hbrige	),
	  .cols_hbrige		(cols_hbrige	),
	  .trigger_out_n	(trigger_out_n	),
	  .trigger_in_n		(trigger_in_n	),
	  .latch_data_n		(latch_data_n	),
	  .sclk			(sclk		),
	  .mosi			(mosi		),
	  .ss_n			(ss_n		),
	  .miso			(miso		)
	);

endmodule

`default_nettype wire
