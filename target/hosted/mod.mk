define core
  $(this)/targets := sim

  $(this)/deps := hsv_core_top_flat hs_npu_top_flat axixbar

  $(this)/rtl_top   := hosted_top_flat
  $(this)/rtl_files := \
    hosted_interconnect.sv \
    hosted_interconnect_host_dmem.sv \
    hosted_interconnect_host_mmio.sv \
    hosted_interconnect_sys.sv \
    hosted_top.sv \
    hosted_top_flat.sv

  $(this)/vl_main  := main.cpp
  $(this)/vl_files := axi.cpp elf_loader.cpp magic_io.cpp simulation.cpp
endef
