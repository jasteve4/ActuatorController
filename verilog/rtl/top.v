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
 * top
 *
 *
 *-------------------------------------------------------------
 */
module top (
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
  input  wire         clock,
  input  wire         enable_n, 
  output wire [4:0]   rows,
  output wire [1:0]   cols,
  output wire [4:0]   rows_enable,
  output wire [1:0]   cols_enable,
  output wire [9:0]   rows_hbrige,
  output wire [3:0]   cols_hbrige,
  output wire         trigger_out_n,
  input  wire         trigger_in_n,
  input  wire         latch_data_n,
  input  wire         sclk,
  input  wire         mosi,
  input  wire         ss_n,
  output wire         miso
);
  // spi
  wire  [31:0] spi_data_out;
  wire [15:0]  spi_data_in;
  //wire         data_ready_n;
  wire         data_valid_n;
  wire         update_done;
  wire [31:0]  ccr0;
  wire [31:0]  ccr1;
  wire [31:0]  ccr2;
  wire [31:0]  ccr3;
  wire [7:0]   memory_address;
  wire         memory_enable_n;
  wire         memory_write_n;
  wire         memory_read_n;
  wire         system_enable_n;
  wire [15:0]  mem_to_sys_data;
  wire [15:0]  sys_to_mem_data;
  wire [7:0]   control_state;
  wire [15:0]  cell_state;
  wire         enable_sn;
  wire         trigger_in_sn;
  wire         latch_data_sn;



  sync_n trigger_sync
  (
`ifdef USE_POWER_PINS
	    .vccd1		(vccd1		),	// User area 1 1.8V supply
	    .vssd1		(vssd1		),	// User area 1 digital ground
`endif
    .signal_n         (trigger_in_n    ), 
    .signal_sn        (trigger_in_sn   ),
    .clock            (clock           )
  );
  sync_n latch_sync
  (
`ifdef USE_POWER_PINS
	    .vccd1		(vccd1		),	// User area 1 1.8V supply
	    .vssd1		(vssd1		),	// User area 1 digital ground
`endif
    .signal_n         (latch_data_n    ), 
    .signal_sn        (latch_data_sn   ),
    .clock            (clock           )
  );

  sync_n enable_sync
  (
`ifdef USE_POWER_PINS
	    .vccd1		(vccd1		),	// User area 1 1.8V supply
	    .vssd1		(vssd1		),	// User area 1 digital ground
`endif
    .signal_n         (enable_n       ), 
    .signal_sn        (enable_sn        ),
    .clock            (clock           )
  );

  spi_mod spi_core
  (
`ifdef USE_POWER_PINS
	    .vccd1		(vccd1		),	// User area 1 1.8V supply
	    .vssd1		(vssd1		),	// User area 1 digital ground
`endif
    .clock            (clock           ),
    .enable_sn        (enable_sn       ),
    .sclk             (sclk            ),
    .mosi             (mosi            ),
    .ss_n             (ss_n            ),
    .miso             (miso            ),
    .data_valid_n     (data_valid_n    ),
    //.data_ready_n     (data_ready_n    ),
    .data_out         (spi_data_out    ),
    .data_in          ({16'b0,
                       spi_data_in}    )
  );


  system_controller system_core
  (
`ifdef USE_POWER_PINS
	    .vccd1		(vccd1		),	// User area 1 1.8V supply
	    .vssd1		(vssd1		),	// User area 1 digital ground
`endif
    .clock            (clock           ),
    .enable_sn        (enable_sn       ),
    .update_done      (update_done     ),
    .spi_data         (spi_data_out    ),
    .ccr2             (ccr2            ),
    .ccr3             (ccr3            ),
    .memory_data_in   (mem_to_sys_data ),
    .memory_data_out  (sys_to_mem_data ),
    .memory_data      (spi_data_in     ),
    .memory_enable_n  (memory_enable_n ),
    .memory_write_n   (memory_write_n  ),
    .memory_read_n    (memory_read_n   ),
    .memory_address   (memory_address  ),
    .system_enable_n  (system_enable_n ),
    //.data_ready_n     (data_ready_n    ),
    .data_valid_n     (data_valid_n    ),
    .trigger_out_n    (trigger_out_n   ),
    .trigger_in_sn    (trigger_in_sn   ),
    .latch_data_sn    (latch_data_sn   ),
    .control_state    (control_state   )
  );

  memory_controller mem_core
  (
`ifdef USE_POWER_PINS
	    .vccd1		(vccd1		),	// User area 1 1.8V supply
	    .vssd1		(vssd1		),	// User area 1 digital ground
`endif
    .clock            (clock           ),
    .memory_enable_n  (memory_enable_n ),
    .memory_write_n   (memory_write_n  ),
    .memory_read_n    (memory_read_n   ),
    .memory_address   (memory_address  ),
    .memory_data_in   (sys_to_mem_data ),
    .memory_data_out  (mem_to_sys_data ),
    .cell_state       (cell_state      ),
    //.control_state    (control_state   ),
    .ccr0             (ccr0            ),
    .ccr1             (ccr1            ),
    .ccr2             (ccr2            ),
    .ccr3             (ccr3            )
  );


  cells_controller cell_core
  (
`ifdef USE_POWER_PINS
	    .vccd1		(vccd1		),	// User area 1 1.8V supply
	    .vssd1		(vssd1		),	// User area 1 digital ground
`endif
    .clock            (clock           ),
    .cells_state      (cell_state      ),
    .system_enable_n  (system_enable_n ),
    .ccr0             (ccr0            ),
    .ccr1             (ccr1            ),
    .update_done      (update_done     ),
    .rows             (rows            ),
    .cols             (cols            ),
    .rows_enable      (rows_enable     ),
    .cols_enable      (cols_enable     ),
    .rows_hbrige      (rows_hbrige     ),
    .cols_hbrige      (cols_hbrige     ),
    .p_select_active  (control_state[5]),
    .cell_invert      (control_state[4]), 
    .enable_sn        (enable_sn       ) 
  );



endmodule
