define core
  $(this)/targets := sim

  $(this)/deps := hsv_core_top_flat hs_npu_top_flat axixbar

  $(this)/rtl_top   := hosted_top_flat
  $(this)/rtl_files := hosted_top.sv hosted_top_flat.sv hosted_interconnect.sv

  $(this)/vl_main  := main.cpp
  $(this)/vl_files := axi.cpp elf_loader.cpp magic_io.cpp simulation.cpp
endef
