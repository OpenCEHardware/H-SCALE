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
