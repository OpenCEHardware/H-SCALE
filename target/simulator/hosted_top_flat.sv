module hosted_top_flat (
    input logic clk,
    input logic rst_n,

    input  logic        sys_awready,
    output logic        sys_awvalid,
    output logic [ 7:0] sys_awid,
    output logic [ 7:0] sys_awlen,
    output logic [ 2:0] sys_awsize,
    output logic [ 1:0] sys_awburst,
    output logic [ 2:0] sys_awprot,
    output logic [31:0] sys_awaddr,

    input  logic        sys_wready,
    output logic        sys_wvalid,
    output logic [31:0] sys_wdata,
    output logic        sys_wlast,
    output logic [ 3:0] sys_wstrb,

    output logic       sys_bready,
    input  logic       sys_bvalid,
    input  logic [7:0] sys_bid,
    input  logic [1:0] sys_bresp,

    input  logic        sys_arready,
    output logic        sys_arvalid,
    output logic [ 7:0] sys_arid,
    output logic [ 7:0] sys_arlen,
    output logic [ 2:0] sys_arsize,
    output logic [ 1:0] sys_arburst,
    output logic [ 2:0] sys_arprot,
    output logic [31:0] sys_araddr,

    output logic        sys_rready,
    input  logic        sys_rvalid,
    input  logic [ 7:0] sys_rid,
    input  logic [31:0] sys_rdata,
    input  logic [ 1:0] sys_rresp,
    input  logic        sys_rlast
);

  axib_if sys_mem ();

  assign sys_arid = sys_mem.s.arid;
  assign sys_arlen = sys_mem.s.arlen;
  assign sys_arsize = sys_mem.s.arsize;
  assign sys_araddr = sys_mem.s.araddr;
  assign sys_arprot = 3'b010;
  assign sys_arburst = sys_mem.s.arburst;
  assign sys_arvalid = sys_mem.s.arvalid;
  assign sys_mem.s.arready = sys_arready;

  assign sys_awid = sys_mem.s.awid;
  assign sys_awlen = sys_mem.s.awlen;
  assign sys_awsize = sys_mem.s.awsize;
  assign sys_awaddr = sys_mem.s.awaddr;
  assign sys_awprot = 3'b010;
  assign sys_awburst = sys_mem.s.awburst;
  assign sys_awvalid = sys_mem.s.awvalid;
  assign sys_mem.s.awready = sys_awready;

  assign sys_wdata = sys_mem.s.wdata;
  assign sys_wlast = sys_mem.s.wlast;
  assign sys_wstrb = sys_mem.s.wstrb;
  assign sys_wvalid = sys_mem.s.wvalid;
  assign sys_mem.s.wready = sys_wready;

  assign sys_rready = sys_mem.s.rready;
  assign sys_mem.s.rid = sys_rid;
  assign sys_mem.s.rdata = sys_rdata;
  assign sys_mem.s.rlast = sys_rlast;
  assign sys_mem.s.rresp = sys_rresp;
  assign sys_mem.s.rvalid = sys_rvalid;

  assign sys_bready = sys_mem.s.bready;
  assign sys_mem.s.bid = sys_bid;
  assign sys_mem.s.bresp = sys_bresp;
  assign sys_mem.s.bvalid = sys_bvalid;

  hosted_top top (
      .clk,
      .rst_n,

      .sys_mem(sys_mem.m)
  );

endmodule
