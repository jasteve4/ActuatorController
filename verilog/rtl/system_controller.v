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
 * system_controller
 *
 *
 *-------------------------------------------------------------
 */
module system_controller
(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
  input  wire         clock,
  input  wire         enable_sn,
  input  wire         update_done,
  input  wire  [31:0] spi_data,
  input  wire  [31:0] ccr2,
  input  wire  [31:0] ccr3,
  input  wire  [15:0] memory_data_in,
  output wire [15:0]  memory_data_out,
  output wire [15:0]  memory_data,
  output wire         memory_enable_n,
  output wire         memory_write_n,
  output wire         memory_read_n,
  output wire [7:0]   memory_address,
  output wire         system_enable_n,
  //output wire         data_ready_n,
  output wire         data_valid_n,
  output wire         trigger_out_n,
  input  wire         trigger_in_sn,
  input  wire         latch_data_sn,
  output wire [7:0]   control_state

);
  
  reg [1:0] mem_state;
  reg [1:0] system_state;
  reg [1:0] trigger_out_state;
  reg [1:0] latch_data_state;
  wire refresh_n;
  reg [31:0] refresh_count;
  reg [2:0] mem_read_state;
  reg [15:0] memory_data_reg;
  reg [31:0] system_data;
  wire system_control_n;

  

  always@(posedge clock)
  begin
    case({enable_sn,latch_data_state})
      3'b0_00: latch_data_state <= latch_data_sn ? 2'b00 :  2'b01;
      3'b0_01: latch_data_state <= 2'b10;
      3'b0_10: latch_data_state <= 2'b11;
      3'b0_11: latch_data_state <= latch_data_sn ? 2'b00 : 2'b11;
      default latch_data_state <= 2'b00;
    endcase
  end

  assign system_control_n = latch_data_state != 2'b10;

  always@(posedge clock)
  begin
    case({enable_sn,latch_data_state})
      3'b0_00: system_data <= system_data;
      3'b0_01: system_data <= spi_data;
      3'b0_10: system_data <= system_data;
      3'b0_11: system_data <= system_data;
      default: system_data <= 32'b0;
    endcase
  end

  assign control_state = system_data[31:24];
  assign memory_address = system_data[23:16];
  assign memory_data_out = system_data[15:0];


  always@(posedge clock)
  begin
    case({enable_sn,~system_control_n,control_state[1:0],mem_state})
      6'b00_10_00: mem_state <= 2'b10;
      6'b00_10_10: mem_state <= 2'b11;
      6'b00_10_11: mem_state <= 2'b11;

      6'b00_01_00: mem_state <= 2'b01;
      6'b00_01_01: mem_state <= 2'b11;
      6'b00_01_11: mem_state <= 2'b11;
      default:    mem_state <= 2'b00;
    endcase
  end

  assign memory_enable_n = (^mem_state)  ? 1'b0 : 1'b1;
  assign memory_write_n = mem_state == 2'b10 ? 1'b0 : 1'b1;
  assign memory_read_n = mem_state == 2'b01 ? 1'b0 : 1'b1;
  

  always@(posedge clock)
  begin
    case({enable_sn,mem_read_state})
      5'b0_000: mem_read_state <= memory_read_n ? 3'b000 : 3'b001;
      5'b0_001: mem_read_state <= 3'b010;
      5'b0_010: mem_read_state <= 3'b011;
      5'b0_011: mem_read_state <= 3'b000;
      //5'b0_100: mem_read_state <= 3'b000;
      default : mem_read_state <= 3'b000;
    endcase
  end

  assign data_valid_n = (mem_read_state == 3'b011) ? 1'b0 : 1'b1;

  always@(posedge clock)
  begin
    case({enable_sn,mem_read_state})
      4'b0_001: memory_data_reg <= memory_data_in;
      default: memory_data_reg <= memory_data_reg;
    endcase
  end


  assign memory_data  = memory_data_reg;
  //assign data_ready_n = mem_read_state[1] ? 1'b0 : 1'b1;


  always@(posedge clock)
  begin
    case({enable_sn,~system_control_n,control_state[3:2],system_state})
      6'b00_10_00: system_state <= trigger_in_sn ? 2'b00 : 2'b10;
      6'b00_10_10: system_state <= update_done ? 2'b11 : 2'b10;
      6'b00_10_11: system_state <= trigger_in_sn  ? 2'b00 : 2'b11;

      6'b00_01_00: system_state <= 2'b10;
      6'b00_01_10: system_state <= update_done ? 2'b11 : 2'b10;
      6'b00_01_11: system_state <= refresh_n   ? 2'b11 : 2'b10;
      default:    system_state <= 2'b00;
    endcase
  end

  assign system_enable_n = ~^system_state;
  
  always@(posedge clock)
  begin
    case({enable_sn,trigger_out_state})
      3'b0_00: trigger_out_state <= update_done ? 2'b01 : 2'b00;
      3'b0_01: trigger_out_state <= 2'b10;
      3'b0_10: trigger_out_state <= 2'b11;
      default: trigger_out_state <= 2'b00;
    endcase
  end
  
  assign trigger_out_n = ~^trigger_out_state;
  



  always@(posedge clock)
  begin
    if(enable_sn | ~system_control_n)
    begin
      refresh_count <= 32'b0;
    end
    else
    begin
      if((control_state[2]) & (&system_state))
      begin
        if(refresh_count <= ccr3) 
        begin
          refresh_count <= refresh_count+1'b1;
        end
        else
        begin
          refresh_count <= 32'b0;
        end
      end
      else
      begin
        refresh_count <= 32'b0;
      end
    end
  end

  assign refresh_n = (refresh_count != ccr2);



endmodule
