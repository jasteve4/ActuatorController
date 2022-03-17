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
 * cell_contorller
 *
 *
 *-------------------------------------------------------------
 */
module cells_controller
(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
  input wire clock,
  input wire [15:0] cells_state,
  input wire system_enable_n,
  input wire [31:0] ccr0,
  input wire [31:0] ccr1,
  output reg update_done,
  output wire [4:0] rows,
  output wire [1:0] cols,
  output reg [4:0] rows_enable,
  output reg [1:0] cols_enable,
  output wire [9:0] rows_hbrige,
  output wire [3:0] cols_hbrige,
  input wire p_select_active,
  input wire cell_invert, 
  input wire enable_sn 
);
  reg [31:0] count;
  reg [10:0] cell_pos;
  wire line_enable_n;
  wire [9:0] cell_output_state;
  wire [9:0] adj_cell_output_state;
  reg [4:0] rows_output;
  reg [1:0] cols_output;

  reg  [1:0] pcell_mem [9:0] ;
  wire  [9:0] cells_state_diff   ;
  wire [9:0] cell_enable;
  genvar cell_p;
  

 // 4 9 | 8 9 
 // 3 8 | 6 7 
 // 2 7 | 2 5 
 // 1 6 | 1 4 
 // 0 5 | 0 3   

 // 00_0000_0001 0 
 // 00_0000_0010 1
 // 00_0000_0100 2
 // 00_0010_0000 3
 // 00_0100_0000 4
 // 00_1000_0000 5
 // 00_0000_1000 6
 // 01_0000_0000 7
 // 00_0001_0000 8
 // 10_0000_0000 9

  always@(posedge clock)
  begin
    case({system_enable_n,(ccr1==count)})
      2'b00: count <= count+1'b1;
      default: count <= 32'b0;
    endcase
  end



  always@(posedge clock)
  begin
    case({system_enable_n,(ccr1 == count)})
      3'b00: cell_pos <= cell_pos;
      3'b01: cell_pos <= {cell_pos[9:0],cell_pos[10]};
      default: cell_pos <= 11'h001;
    endcase
  end


  assign line_enable_n = (count <= ccr0) ? system_enable_n : 1'b1;

  assign {
  cell_output_state[9], 
  cell_output_state[4],
  cell_output_state[8], 
  cell_output_state[3], 
  cell_output_state[7], 
  cell_output_state[6], 
  cell_output_state[5], 
  cell_output_state[2], 
  cell_output_state[1], 
  cell_output_state[0] 
  } =  cells_state[9:0];  // 10


  always@(posedge clock)
  begin
    case({line_enable_n,cell_pos[9:0]})
      11'b000_0000_0001: rows_output[0] <=  (cell_output_state[0]) ; 
      11'b000_0010_0000: rows_output[0] <=  (cell_output_state[5]) ; 
      default: rows_output[0] <= 1'b0;
    endcase
  end

  always@(posedge clock)
  begin
    case({line_enable_n,cell_pos[9:0]})
      11'b000_0000_0010: rows_output[1] <= (cell_output_state[1]); 
      11'b000_0100_0000: rows_output[1] <= (cell_output_state[6]); 
      default: rows_output[1] <= 1'b0;
    endcase
  end

  always@(posedge clock)
  begin
    case({line_enable_n,cell_pos[9:0]})
      11'b000_0000_0100: rows_output[2] <= (cell_output_state[2]); 
      11'b000_1000_0000: rows_output[2] <= (cell_output_state[7]); 
      default: rows_output[2] <= 1'b0;
    endcase
  end

  always@(posedge clock)
  begin
    case({line_enable_n,cell_pos[9:0]})
      11'b000_0000_1000: rows_output[3] <= (cell_output_state[3]); 
      11'b001_0000_0000: rows_output[3] <= (cell_output_state[8]); 
      default: rows_output[3] <= 1'b0;
    endcase
  end

  always@(posedge clock)
  begin
    case({line_enable_n,cell_pos[9:0]})
      11'b000_0001_0000: rows_output[4] <= (cell_output_state[4]) ; 
      11'b010_0000_0000: rows_output[4] <= (cell_output_state[9]) ; 
      default: rows_output[4] <= 1'b0;
    endcase
  end

  always@(posedge clock)
  begin
    case({line_enable_n,cell_pos[9:0]})
      11'b000_0000_0001: cols_output[0] <= ~(cell_output_state[0]); 
      11'b000_0000_0010: cols_output[0] <= ~(cell_output_state[1]); 
      11'b000_0000_0100: cols_output[0] <= ~(cell_output_state[2]); 
      11'b000_0000_1000: cols_output[0] <= ~(cell_output_state[3]); 
      11'b000_0001_0000: cols_output[0] <= ~(cell_output_state[4]); 
      default: cols_output[0] <= 1'b0;     
    endcase
  end

  always@(posedge clock)
  begin
    case({line_enable_n,cell_pos[9:0]})
      11'b0_00_0010_0000: cols_output[1] <= ~(cell_output_state[5]); 
      11'b0_00_0100_0000: cols_output[1] <= ~(cell_output_state[6]); 
      11'b0_00_1000_0000: cols_output[1] <= ~(cell_output_state[7]); 
      11'b0_01_0000_0000: cols_output[1] <= ~(cell_output_state[8]); 
      11'b0_10_0000_0000: cols_output[1] <= ~(cell_output_state[9]); 
      default: cols_output[1] <= 1'b0;
    endcase
  end

  generate
    for(cell_p=0;cell_p<2;cell_p=cell_p+1)
    begin : cols_invert_block
      assign cols[cell_p] = cell_invert ? ~cols_output[cell_p] : cols_output[cell_p];
    end
    for(cell_p=0;cell_p<5;cell_p=cell_p+1)
    begin : rows_invert_block
      assign rows[cell_p] = cell_invert ? ~rows_output[cell_p] : rows_output[cell_p];
    end
  endgenerate


  generate
    for(cell_p=0;cell_p<10;cell_p=cell_p+1)
    begin : past_state_logic
      assign adj_cell_output_state[cell_p] = cell_invert ? ~cell_output_state[cell_p] : cell_output_state[cell_p];
      always@(posedge clock)
      begin
        case({enable_sn,update_done})
          2'b00: pcell_mem[cell_p] <= pcell_mem[cell_p]; 
          2'b01: pcell_mem[cell_p] <= adj_cell_output_state[cell_p] ? 2'b11 : 2'b00; 
          2'b10: pcell_mem[cell_p] <= 2'b01; 
          2'b11: pcell_mem[cell_p] <= 2'b01; 
        endcase
      end

      assign cells_state_diff[cell_p] = |(pcell_mem[cell_p] ^ {adj_cell_output_state[cell_p],adj_cell_output_state[cell_p]});
      assign cell_enable[cell_p] = cells_state_diff[cell_p]  | ~p_select_active;
    end
  endgenerate


  always@(posedge clock)
  begin
    case({line_enable_n,cell_pos[9:0]})
      11'b000_0000_0001: rows_enable[0] <= cell_enable[0]; 
      11'b000_0010_0000: rows_enable[0] <= cell_enable[5]; 
      default: rows_enable[0] <= 1'b0;
    endcase
  end

  always@(posedge clock)
  begin
    case({line_enable_n,cell_pos[9:0]})
      11'b000_0000_0010: rows_enable[1] <= cell_enable[1]; 
      11'b000_0100_0000: rows_enable[1] <= cell_enable[6]; 
      default: rows_enable[1] <= 1'b0;
    endcase
  end

  always@(posedge clock)
  begin
    case({line_enable_n,cell_pos[9:0]})
      11'b000_0000_0100: rows_enable[2] <= cell_enable[2]; 
      11'b000_1000_0000: rows_enable[2] <= cell_enable[7]; 
      default: rows_enable[2] <= 1'b0;
    endcase
  end

  always@(posedge clock)
  begin
    case({line_enable_n,cell_pos[9:0]})
      11'b000_0000_1000: rows_enable[3] <= cell_enable[3]; 
      11'b001_0000_0000: rows_enable[3] <= cell_enable[8]; 
      default: rows_enable[3] <= 1'b0;
    endcase
  end

  always@(posedge clock)
  begin
    case({line_enable_n,cell_pos[9:0]})
      11'b000_0001_0000: rows_enable[4] <= cell_enable[4]; 
      11'b010_0000_0000: rows_enable[4] <= cell_enable[9]; 
      default: rows_enable[4] <= 1'b0;
    endcase
  end

  always@(posedge clock)
  begin
    case({line_enable_n,cell_pos[9:0]})
      11'b000_0000_0001: cols_enable[0] <= cell_enable[0]; 
      11'b000_0000_0010: cols_enable[0] <= cell_enable[1]; 
      11'b000_0000_0100: cols_enable[0] <= cell_enable[2]; 
      11'b000_0000_1000: cols_enable[0] <= cell_enable[3]; 
      11'b000_0001_0000: cols_enable[0] <= cell_enable[4]; 
      default: cols_enable[0] <= 1'b0;
    endcase
  end

  always@(posedge clock)
  begin
    case({line_enable_n,cell_pos[9:0]})
      11'b0_00_0010_0000: cols_enable[1] <= cell_enable[5]; 
      11'b0_00_0100_0000: cols_enable[1] <= cell_enable[6]; 
      11'b0_00_1000_0000: cols_enable[1] <= cell_enable[7]; 
      11'b0_01_0000_0000: cols_enable[1] <= cell_enable[8]; 
      11'b0_10_0000_0000: cols_enable[1] <= cell_enable[9]; 
      default: cols_enable[1] <= 1'b0;
    endcase
  end

  generate
    for(cell_p=0;cell_p<2;cell_p=cell_p+1)
    begin : cols_hbrige_logic
      assign cols_hbrige[cell_p*2+1:cell_p*2] = cols_enable[cell_p] ? ~cols[cell_p] ? 2'b00 : 2'b11 : 2'b10;
    end
    for(cell_p=0;cell_p<5;cell_p=cell_p+1)
    begin : rows_hbrige_logic
      assign rows_hbrige[cell_p*2+1:cell_p*2] = rows_enable[cell_p] ? ~rows[cell_p] ? 2'b00 : 2'b11 : 2'b10;
    end
  endgenerate

  always@(posedge clock)
  begin
  if((cell_pos[10] == 1'b1))
  begin
    update_done <= 1'b1;
  end
  else
  begin
    update_done <= 1'b0;
  end
  end
endmodule
