module hosted_interconnect (
    input logic clk,
    srst_n,

    axib_if.s host_dmem,
    host_imem,
    npu_mem,

    axib_if.m sys_mem,

    axil_if.m npu_csr
);

  axib_if host_to_sys ();
  axil_if mmio_axi ();

  hosted_interconnect_sys sys_xbar (
      .clk,
      .srst_n,
      .npu_mem,
      .sys_mem,
      .host_dmem(host_to_sys.s),
      .host_imem
  );

  hosted_interconnect_host_dmem host_dmem_xbar (
      .clk,
      .srst_n,
      .mmio(npu_csr),
      //.mmio(mmio_axi.m),
      .sys_mem(host_to_sys.m),
      .host_dmem
  );

  /*hosted_interconnect_host_mmio host_mmio_xbar
    (
        .clk,
        .srst_n,
        .host(mmio_axi.s),
        .npu_csr
    );*/

endmodule

module hosted_interconnect_sys (
    input logic clk,
    srst_n,

    axib_if.s npu_mem,
    host_dmem,
    host_imem,

    axib_if.m sys_mem
);

  //FIXME: Lower-numbered masters (last in {..., ...}) always win

  axixbar #(
      .NM            (3),
      .NS            (1),
      .OPT_LOWPOWER  (0),
      .SLAVE_ADDR    ('0),
      .SLAVE_MASK    ('0),
      .C_AXI_ID_WIDTH(8)
  ) xbar (
      .S_AXI_ACLK(clk),
      .S_AXI_ARESETN(srst_n),

      .S_AXI_AWVALID({npu_mem.awvalid, host_dmem.awvalid, host_imem.awvalid}),
      .S_AXI_AWREADY({npu_mem.awready, host_dmem.awready, host_imem.awready}),
      .S_AXI_AWID({npu_mem.awid, host_dmem.awid, host_imem.awid}),
      .S_AXI_AWADDR({npu_mem.awaddr, host_dmem.awaddr, host_imem.awaddr}),
      .S_AXI_AWLEN({npu_mem.awlen, host_dmem.awlen, host_imem.awlen}),
      .S_AXI_AWSIZE({npu_mem.awsize, host_dmem.awsize, host_imem.awsize}),
      .S_AXI_AWBURST({npu_mem.awburst, host_dmem.awburst, host_imem.awburst}),
      .S_AXI_AWLOCK('0),
      .S_AXI_AWCACHE('0),
      .S_AXI_AWPROT('0),
      .S_AXI_AWQOS('0),

      .S_AXI_WVALID({npu_mem.wvalid, host_dmem.wvalid, host_imem.wvalid}),
      .S_AXI_WREADY({npu_mem.wready, host_dmem.wready, host_imem.wready}),
      .S_AXI_WDATA ({npu_mem.wdata, host_dmem.wdata, host_imem.wdata}),
      .S_AXI_WSTRB ({npu_mem.wstrb, host_dmem.wstrb, host_imem.wstrb}),
      .S_AXI_WLAST ({npu_mem.wlast, host_dmem.wlast, host_imem.wlast}),

      .S_AXI_BVALID({npu_mem.bvalid, host_dmem.bvalid, host_imem.bvalid}),
      .S_AXI_BREADY({npu_mem.bready, host_dmem.bready, host_imem.bready}),
      .S_AXI_BID({npu_mem.bid, host_dmem.bid, host_imem.bid}),
      .S_AXI_BRESP({npu_mem.bresp, host_dmem.bresp, host_imem.bresp}),

      .S_AXI_ARVALID({npu_mem.arvalid, host_dmem.arvalid, host_imem.arvalid}),
      .S_AXI_ARREADY({npu_mem.arready, host_dmem.arready, host_imem.arready}),
      .S_AXI_ARID({npu_mem.arid, host_dmem.arid, host_imem.arid}),
      .S_AXI_ARADDR({npu_mem.araddr, host_dmem.araddr, host_imem.araddr}),
      .S_AXI_ARLEN({npu_mem.arlen, host_dmem.arlen, host_imem.arlen}),
      .S_AXI_ARSIZE({npu_mem.arsize, host_dmem.arsize, host_imem.arsize}),
      .S_AXI_ARBURST({npu_mem.arburst, host_dmem.arburst, host_imem.arburst}),
      .S_AXI_ARLOCK('0),
      .S_AXI_ARCACHE('0),
      .S_AXI_ARPROT('0),
      .S_AXI_ARQOS('0),

      .S_AXI_RVALID({npu_mem.rvalid, host_dmem.rvalid, host_imem.rvalid}),
      .S_AXI_RREADY({npu_mem.rready, host_dmem.rready, host_imem.rready}),
      .S_AXI_RID({npu_mem.rid, host_dmem.rid, host_imem.rid}),
      .S_AXI_RDATA({npu_mem.rdata, host_dmem.rdata, host_imem.rdata}),
      .S_AXI_RRESP({npu_mem.rresp, host_dmem.rresp, host_imem.rresp}),
      .S_AXI_RLAST({npu_mem.rlast, host_dmem.rlast, host_imem.rlast}),

      .M_AXI_AWVALID(sys_mem.awvalid),
      .M_AXI_AWREADY(sys_mem.awready),
      .M_AXI_AWID(sys_mem.awid),
      .M_AXI_AWADDR(sys_mem.awaddr),
      .M_AXI_AWLEN(sys_mem.awlen),
      .M_AXI_AWSIZE(sys_mem.awsize),
      .M_AXI_AWBURST(sys_mem.awburst),
      .M_AXI_AWLOCK(),
      .M_AXI_AWCACHE(),
      .M_AXI_AWPROT(),
      .M_AXI_AWQOS(),

      .M_AXI_WVALID(sys_mem.wvalid),
      .M_AXI_WREADY(sys_mem.wready),
      .M_AXI_WDATA (sys_mem.wdata),
      .M_AXI_WSTRB (sys_mem.wstrb),
      .M_AXI_WLAST (sys_mem.wlast),

      .M_AXI_BVALID(sys_mem.bvalid),
      .M_AXI_BREADY(sys_mem.bready),
      .M_AXI_BID(sys_mem.bid),
      .M_AXI_BRESP(sys_mem.bresp),

      .M_AXI_ARVALID(sys_mem.arvalid),
      .M_AXI_ARREADY(sys_mem.arready),
      .M_AXI_ARID(sys_mem.arid),
      .M_AXI_ARADDR(sys_mem.araddr),
      .M_AXI_ARLEN(sys_mem.arlen),
      .M_AXI_ARSIZE(sys_mem.arsize),
      .M_AXI_ARBURST(sys_mem.arburst),
      .M_AXI_ARLOCK(),
      .M_AXI_ARCACHE(),
      .M_AXI_ARPROT(),
      .M_AXI_ARQOS(),

      .M_AXI_RVALID(sys_mem.rvalid),
      .M_AXI_RREADY(sys_mem.rready),
      .M_AXI_RID(sys_mem.rid),
      .M_AXI_RDATA(sys_mem.rdata),
      .M_AXI_RRESP(sys_mem.rresp),
      .M_AXI_RLAST(sys_mem.rlast)
  );

endmodule

module hosted_interconnect_host_dmem (
    input logic clk,
    srst_n,

    axib_if.s host_dmem,

    axib_if.m sys_mem,
    axil_if.m mmio
);

  localparam logic[31:0]
        SysBase  = 32'h0000_0000,
        SysMask  = 32'h6000_0000,
        MmioBase = 32'hc000_0000,
        MmioMask = 32'hf000_0000;

  axib_if mmio_full ();

  assign host_dmem.bid = '0;
  assign host_dmem.rid = '0;

  assign sys_mem.arid = '0;
  assign sys_mem.awid = '0;

  assign mmio_full.s.bid = '0;
  assign mmio_full.s.rid = '0;
  assign mmio_full.m.arid = '0;
  assign mmio_full.m.awid = '0;

  axixbar #(
      .NM(1),
      .NS(2),
      .OPT_LOWPOWER(0),
      .SLAVE_ADDR({MmioBase, SysBase}),
      .SLAVE_MASK({MmioMask, SysMask})
  ) xbar (
      .S_AXI_ACLK(clk),
      .S_AXI_ARESETN(srst_n),

      .S_AXI_AWVALID(host_dmem.awvalid),
      .S_AXI_AWREADY(host_dmem.awready),
      .S_AXI_AWID('0),
      .S_AXI_AWADDR(host_dmem.awaddr),
      .S_AXI_AWLEN(host_dmem.awlen),
      .S_AXI_AWSIZE(host_dmem.awsize),
      .S_AXI_AWBURST(host_dmem.awburst),
      .S_AXI_AWLOCK('0),
      .S_AXI_AWCACHE('0),
      .S_AXI_AWPROT('0),
      .S_AXI_AWQOS('0),

      .S_AXI_WVALID(host_dmem.wvalid),
      .S_AXI_WREADY(host_dmem.wready),
      .S_AXI_WDATA (host_dmem.wdata),
      .S_AXI_WSTRB (host_dmem.wstrb),
      .S_AXI_WLAST (host_dmem.wlast),

      .S_AXI_BVALID(host_dmem.bvalid),
      .S_AXI_BREADY(host_dmem.bready),
      .S_AXI_BID(),
      .S_AXI_BRESP(host_dmem.bresp),

      .S_AXI_ARVALID(host_dmem.arvalid),
      .S_AXI_ARREADY(host_dmem.arready),
      .S_AXI_ARID('0),
      .S_AXI_ARADDR(host_dmem.araddr),
      .S_AXI_ARLEN(host_dmem.arlen),
      .S_AXI_ARSIZE(host_dmem.arsize),
      .S_AXI_ARBURST(host_dmem.arburst),
      .S_AXI_ARLOCK('0),
      .S_AXI_ARCACHE('0),
      .S_AXI_ARPROT('0),
      .S_AXI_ARQOS('0),

      .S_AXI_RVALID(host_dmem.rvalid),
      .S_AXI_RREADY(host_dmem.rready),
      .S_AXI_RID(),
      .S_AXI_RDATA(host_dmem.rdata),
      .S_AXI_RRESP(host_dmem.rresp),
      .S_AXI_RLAST(host_dmem.rlast),

      .M_AXI_AWVALID({mmio_full.m.awvalid, sys_mem.awvalid}),
      .M_AXI_AWREADY({mmio_full.m.awready, sys_mem.awready}),
      .M_AXI_AWID(),
      .M_AXI_AWADDR({mmio_full.m.awaddr, sys_mem.awaddr}),
      .M_AXI_AWLEN({mmio_full.m.awlen, sys_mem.awlen}),
      .M_AXI_AWSIZE({mmio_full.m.awsize, sys_mem.awsize}),
      .M_AXI_AWBURST({mmio_full.m.awburst, sys_mem.awburst}),
      .M_AXI_AWLOCK(),
      .M_AXI_AWCACHE(),
      .M_AXI_AWPROT(),
      .M_AXI_AWQOS(),

      .M_AXI_WVALID({mmio_full.m.wvalid, sys_mem.wvalid}),
      .M_AXI_WREADY({mmio_full.m.wready, sys_mem.wready}),
      .M_AXI_WDATA ({mmio_full.m.wdata, sys_mem.wdata}),
      .M_AXI_WSTRB ({mmio_full.m.wstrb, sys_mem.wstrb}),
      .M_AXI_WLAST ({mmio_full.m.wlast, sys_mem.wlast}),

      .M_AXI_BVALID({mmio_full.m.bvalid, sys_mem.bvalid}),
      .M_AXI_BREADY({mmio_full.m.bready, sys_mem.bready}),
      .M_AXI_BID('0),
      .M_AXI_BRESP({mmio_full.m.bresp, sys_mem.bresp}),

      .M_AXI_ARVALID({mmio_full.m.arvalid, sys_mem.arvalid}),
      .M_AXI_ARREADY({mmio_full.m.arready, sys_mem.arready}),
      .M_AXI_ARID(),
      .M_AXI_ARADDR({mmio_full.m.araddr, sys_mem.araddr}),
      .M_AXI_ARLEN({mmio_full.m.arlen, sys_mem.arlen}),
      .M_AXI_ARSIZE({mmio_full.m.arsize, sys_mem.arsize}),
      .M_AXI_ARBURST({mmio_full.m.arburst, sys_mem.arburst}),
      .M_AXI_ARLOCK(),
      .M_AXI_ARCACHE(),
      .M_AXI_ARPROT(),
      .M_AXI_ARQOS(),

      .M_AXI_RVALID({mmio_full.m.rvalid, sys_mem.rvalid}),
      .M_AXI_RREADY({mmio_full.m.rready, sys_mem.rready}),
      .M_AXI_RID('0),
      .M_AXI_RDATA({mmio_full.m.rdata, sys_mem.rdata}),
      .M_AXI_RRESP({mmio_full.m.rresp, sys_mem.rresp}),
      .M_AXI_RLAST({mmio_full.m.rlast, sys_mem.rlast})
  );

  axi2axilite #(
      .C_AXI_ADDR_WIDTH(32)
  ) mmio_full2lite (
      .S_AXI_ACLK(clk),
      .S_AXI_ARESETN(srst_n),

      .S_AXI_AWVALID(mmio_full.s.awvalid),
      .S_AXI_AWREADY(mmio_full.s.awready),
      .S_AXI_AWID('0),
      .S_AXI_AWADDR(mmio_full.s.awaddr),
      .S_AXI_AWLEN(mmio_full.s.awlen),
      .S_AXI_AWSIZE(mmio_full.s.awsize),
      .S_AXI_AWBURST(mmio_full.s.awburst),
      .S_AXI_AWLOCK('0),
      .S_AXI_AWCACHE('0),
      .S_AXI_AWPROT('0),
      .S_AXI_AWQOS('0),

      .S_AXI_WVALID(mmio_full.s.wvalid),
      .S_AXI_WREADY(mmio_full.s.wready),
      .S_AXI_WDATA (mmio_full.s.wdata),
      .S_AXI_WSTRB (mmio_full.s.wstrb),
      .S_AXI_WLAST (mmio_full.s.wlast),

      .S_AXI_BVALID(mmio_full.s.bvalid),
      .S_AXI_BREADY(mmio_full.s.bready),
      .S_AXI_BID(),
      .S_AXI_BRESP(mmio_full.s.bresp),

      .S_AXI_ARVALID(mmio_full.s.arvalid),
      .S_AXI_ARREADY(mmio_full.s.arready),
      .S_AXI_ARID('0),
      .S_AXI_ARADDR(mmio_full.s.araddr),
      .S_AXI_ARLEN(mmio_full.s.arlen),
      .S_AXI_ARSIZE(mmio_full.s.arsize),
      .S_AXI_ARBURST(mmio_full.s.arburst),
      .S_AXI_ARLOCK('0),
      .S_AXI_ARCACHE('0),
      .S_AXI_ARPROT('0),
      .S_AXI_ARQOS('0),

      .S_AXI_RVALID(mmio_full.s.rvalid),
      .S_AXI_RREADY(mmio_full.s.rready),
      .S_AXI_RID(),
      .S_AXI_RDATA(mmio_full.s.rdata),
      .S_AXI_RRESP(mmio_full.s.rresp),
      .S_AXI_RLAST(mmio_full.s.rlast),

      .M_AXI_AWADDR (mmio.awaddr),
      .M_AXI_AWPROT (),
      .M_AXI_AWVALID(mmio.awvalid),
      .M_AXI_AWREADY(mmio.awready),

      .M_AXI_WDATA (mmio.wdata),
      .M_AXI_WSTRB (),
      .M_AXI_WVALID(mmio.wvalid),
      .M_AXI_WREADY(mmio.wready),

      .M_AXI_BRESP ('0),
      .M_AXI_BVALID(mmio.bvalid),
      .M_AXI_BREADY(mmio.bready),

      .M_AXI_ARADDR (mmio.araddr),
      .M_AXI_ARPROT (),
      .M_AXI_ARVALID(mmio.arvalid),
      .M_AXI_ARREADY(mmio.arready),

      .M_AXI_RDATA (mmio.rdata),
      .M_AXI_RRESP ('0),
      .M_AXI_RVALID(mmio.rvalid),
      .M_AXI_RREADY(mmio.rready)
  );

endmodule

module hosted_interconnect_host_mmio (
    input logic clk,
    srst_n,

    axil_if.s host,

    axil_if.m npu_csr
);

  localparam logic [31:0] NpuCsrBase = 32'hc000_0000, NpuCsrMask = 32'hffff_0000;

  axilxbar #(
      .NM(1),
      .NS(1),
      .OPT_LOWPOWER(0),
      .SLAVE_ADDR({NpuCsrBase}),
      .SLAVE_MASK({NpuCsrMask})
  ) xbar (
      .S_AXI_ACLK(clk),
      .S_AXI_ARESETN(srst_n),

      .S_AXI_AWVALID(host.awvalid),
      .S_AXI_AWREADY(host.awready),
      .S_AXI_AWADDR (host.awaddr),
      .S_AXI_AWPROT ('0),

      .S_AXI_WVALID(host.wvalid),
      .S_AXI_WREADY(host.wready),
      .S_AXI_WDATA (host.wdata),
      .S_AXI_WSTRB ('1),

      .S_AXI_BVALID(host.bvalid),
      .S_AXI_BREADY(host.bready),
      .S_AXI_BRESP (),

      .S_AXI_ARVALID(host.arvalid),
      .S_AXI_ARREADY(host.arready),
      .S_AXI_ARADDR (host.araddr),
      .S_AXI_ARPROT ('0),

      .S_AXI_RVALID(host.rvalid),
      .S_AXI_RREADY(host.rready),
      .S_AXI_RDATA (host.rdata),
      .S_AXI_RRESP (),

      .M_AXI_AWADDR ({npu_csr.awaddr}),
      .M_AXI_AWPROT (),
      .M_AXI_AWVALID({npu_csr.awvalid}),
      .M_AXI_AWREADY({npu_csr.awready}),

      .M_AXI_WDATA ({npu_csr.wdata}),
      .M_AXI_WSTRB (),
      .M_AXI_WVALID({npu_csr.wvalid}),
      .M_AXI_WREADY({npu_csr.wready}),

      .M_AXI_BRESP ({npu_csr.bresp}),
      .M_AXI_BVALID({npu_csr.bvalid}),
      .M_AXI_BREADY({npu_csr.bready}),

      .M_AXI_ARADDR ({npu_csr.araddr}),
      .M_AXI_ARPROT (),
      .M_AXI_ARVALID({npu_csr.arvalid}),
      .M_AXI_ARREADY({npu_csr.arready}),

      .M_AXI_RDATA ({npu_csr.rdata}),
      .M_AXI_RRESP ({npu_csr.rresp}),
      .M_AXI_RVALID({npu_csr.rvalid}),
      .M_AXI_RREADY({npu_csr.rready})
  );

endmodule
