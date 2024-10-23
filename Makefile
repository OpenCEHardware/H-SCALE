top := hsv_core

core_dirs := \
  modules/cpu/rtl   \
  modules/cpu/tb    \
  modules/npu/rtl   \
  modules/npu/tb    \
  modules/sw        \
  rtl               \
  target

.PHONY: all

all: test

include mk/top.mk
