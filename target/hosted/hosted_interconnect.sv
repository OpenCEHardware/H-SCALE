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
