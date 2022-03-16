module memory_controller
(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
  input wire          clock,
  //input wire reset_sn,
  input wire          memory_enable_n,
  input wire          memory_write_n,
  input wire          memory_read_n,
  input wire  [7:0]   memory_address,
  input wire  [15:0]  memory_data_in,
  output wire [15:0]  memory_data_out,
  output wire [15:0]  cell_state,
//  output wire [15:0]  control_state,
  output wire [31:0]  ccr0,
  output wire [31:0]  ccr1,
  output wire [31:0]  ccr2,
  output wire [31:0]  ccr3
);
  localparam NUM_OF_MEM_ELEMENTS = 10;
  reg [15:0] memory [0:9]; 
  wire [3:0] row_sel;
  reg [15:0] memory_data_reg;

  //assign row_sel = system_data_in[$clog2(NUM_OF_MEM_ELEMENTS)+16-1:16];
  assign row_sel = memory_address[3:0];
/*
  genvar mem_row;
  generate
    for(mem_row=0;mem_row<NUM_OF_MEM_ELEMENTS;mem_row=mem_row+1)
    begin
      always@(posedge clock)
      begin
        if(reset_sn)
        begin
        end
          if(row_sel==mem_row)
          begin
            memory[mem_row] <= memory_enable_n ? memory[mem_row] : memory_write_n ? memory[mem_row] : system_data_in[15:0];
          end
        else
        begin
          memory[mem_row] <= 16'b0; 
        end
      end
    end
  endgenerate
*/
  genvar mem_row;
  generate 
    for(mem_row=0;mem_row<NUM_OF_MEM_ELEMENTS;mem_row=mem_row+1)
    begin : reg_memroy_file
      always@(posedge clock)
      begin
        if(row_sel==mem_row)
        begin
          case({memory_enable_n,memory_write_n})
            2'b00: memory[mem_row] <= memory_data_in[15:0];
            default: memory[mem_row] <= memory[mem_row];
          endcase
        end
      end
    end
  endgenerate

  always@(posedge clock)
  begin
    memory_data_reg = memory_enable_n | memory_read_n ? 16'b0 : memory[row_sel];
  end
  
  assign cell_state = memory[0];
  //assign control_state = memory[1];
  assign ccr0 = {memory[3],memory[2]};
  assign ccr1 = {memory[5],memory[4]};
  assign ccr2 = {memory[7],memory[6]};
  assign ccr3 = {memory[9],memory[8]};
  assign memory_data_out = memory_data_reg;

endmodule
