`timescale 1 ns / 1 ps

module write_enable #
(
  parameter integer BRAM_WIDTH = 13
)
(
  input  wire                  start_acq,
  input  wire [BRAM_WIDTH-1:0] address,
  input  wire                  clk,
  output wire [4-1:0]          wen
);

  reg [BRAM_WIDTH-1:0] count1;
  reg count1_running;
  reg [BRAM_WIDTH-1:0] count2;
  reg count2_running;
  reg rst;

  always @(posedge clk) begin
    if (start_acq) begin
      count1 <= {(BRAM_WIDTH){1'b0}};
      count1_running <= 1'b1;
    end
    else begin 
      if (count1 != {(BRAM_WIDTH){1'b1}}) begin
        count1 <= count1 + 1;
      end else begin
        count1_running <= 1'b0;
      end
    end
  end

  always @(posedge clk) begin
    if (count1_running && (address == {(BRAM_WIDTH){1'b0}})) begin
      rst <= 1'b1;
    end else begin 
      rst <= 1'b0;
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      rst <= 1'b1;
      count2 <= {(BRAM_WIDTH){1'b0}};
      count2_running <= 1'b1;
    end else begin 
      if (count_out != {(BRAM_WIDTH){1'b1}}) begin
        count2 <= count2 + 1;
      end else begin
        count2_running <= 1'b0;
      end
    end
  end

  assign wen = {4{count2_running}};

endmodule
