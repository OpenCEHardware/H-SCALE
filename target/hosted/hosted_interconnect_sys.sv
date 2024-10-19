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
