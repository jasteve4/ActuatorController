module sync_n(
  input wire signal_n,
  output wire signal_sn,
  input wire clock
);
  reg [3:0] signal_state;

  always@(posedge clock)
  begin
    if(signal_n)
    begin
      signal_state <= 3'b111;
    end
    else
    begin
      signal_state <= {signal_state[2:0],signal_n};
    end
  end

  assign signal_sn = signal_state == 3'b000 ? 1'b0:1'b1;


endmodule
/*
module sync(
  input wire signal,
  output wire signal,
  input wire clock
);
  reg [3:0] signal_state;

  always@(posedge clock)
  begin
    if(signal)
    begin
      signal_state <= {signal_state[2:0],signal_n};
    end
    else
    begin
      signal_state <= 3'b000;
    end
  end

  assign signal_sn = signal_state == 3'b111 ? 1'b1:1'b0;


endmodule
*/
