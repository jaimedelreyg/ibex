//DUMMY MODULE ACCELERATOR FOR BITWISE OR
//
//
module dummy #(
) (
  input                 clk_i,
  input                 rst_ni,

  input                 dummy_req_i,   //instruction request control
  input                 dummy_we_i,    //write enable signal
  input [3:0]           dummy_be_i,    //byte enable signal
  input [31:0]          dummy_addr_i,
  input [31:0]          dummy_wdata_i,
  output logic          dummy_rvalid_o,
  output logic [31:0]   dummy_rdata_o
);
  localparam bit [9:0] OP_A = 0;
  localparam bit [9:0] OP_B = 8;
  localparam bit [9:0] OP_C = 16;

  logic [31:0] a_q;
  logic [31:0] a_d;
  logic [31:0] b_d;
  logic [31:0] b_q;
  logic [31:0] rdata_d, rdata_q;
  logic        rvalid_d, rvalid_q;
  logic        a_we, b_we;

  assign dummy_we = dummy_req_i & dummy_we_i;

  //Data Based on memory
  assign a_we = dummy_we & (dummy_addr_i[4:0] == OP_A);
  assign b_we = dummy_we & (dummy_addr_i[4:0] == OP_B);

  assign a_d = (a_we? dummy_wdata_i: a_q);
  assign b_d = (b_we? dummy_wdata_i: b_q);

  //Registers
  always_ff @(posedge clk_i or negedge rst_ni) begin
          if(~rst_ni) begin
                  a_q <= 'b0;
          end else begin
                 a_q <= a_d;
          end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
          if(~rst_ni) begin
                  b_q <= 'b0;
          end else begin
                  b_q <= b_d;
          end
  end

  always_comb begin
        if(dummy_req_i) begin
          unique case (dummy_addr_i[4:0])
                OP_A: rdata_d = a_q;
                OP_B: rdata_d = b_q;
                OP_C: rdata_d = (a_q | b_q);
                default:begin
                        rdata_d = 'b0;
                end
          endcase
        end
  end

  always_ff @(posedge clk_i) begin
          if(dummy_req_i) begin
                rdata_q <= rdata_d;
          end
  end

  assign dummy_rdata_o = rdata_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin
          if(!rst_ni) begin
                  rvalid_q <= 1'b0;
          end else begin
                  rvalid_q <= dummy_req_i;
          end
  end

  assign dummy_rvalid_o = rvalid_q;

endmodule



