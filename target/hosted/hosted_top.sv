module hosted_top
  import hs_npu_ctrlstatus_regs_pkg::*;
(
    input logic clk,
    input logic rst_n,

    axib_if.m sys_mem
);

  logic irq_core, srst_n;

  axib_if host_dmem (), host_imem (), npu_mem ();
  axil_if npu_csr ();
  axi4lite_intf #(.ADDR_WIDTH(HS_NPU_CTRLSTATUS_REGS_MIN_ADDR_WIDTH)) npu_csr_regblock ();

  hosted_interconnect xbar (
      .clk,
      .srst_n,

      .npu_mem  (npu_mem.s),
      .host_dmem(host_dmem.s),
      .host_imem(host_imem.s),

      .sys_mem,

      .npu_csr(npu_csr.m)
  );

  hsv_core_top cpu (
      .clk_core  (clk),
      .rst_core_n(rst_n),

      .imem(host_imem.m),
      .dmem(host_dmem.m),

      .irq_core
  );

  hs_npu_top npu (
      .clk,
      .rst_n,

      .irq_cpu(irq_core),

      .csr(npu_csr_regblock.slave),
      .mem(npu_mem.m)
  );

  // FIXME: npu should accept axil_if.s instead of axi4lite_intf
  axil2regblock_if npu_csr_axil2regblock (
      .axis(npu_csr.s),
      .axim(npu_csr_regblock.master)
  );

  if_rst_sync rst_sync (
      .clk,
      .rst_n,
      .srst_n
  );

endmodule





