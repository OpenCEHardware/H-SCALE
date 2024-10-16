cores := axixbar

define core/axixbar
  $(this)/rtl_top := axixbar
  $(this)/rtl_files := \
    addrdecode.v \
    axi_addr.v \
    axi2axilite.v \
    axilxbar.v \
    axixbar.v \
    sfifo.v \
    skidbuffer.v
endef
