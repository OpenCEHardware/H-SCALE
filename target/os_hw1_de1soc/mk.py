from mk import *

os_hw1_de1soc = QuartusProjectPackage('os_hw1_de1soc')

hs_npu_altera_ip   = find_package('hs_npu_altera_ip')
hsv_core_altera_ip = find_package('hsv_core_altera_ip')
hsv_host_sw        = find_package('hsv_host_sw')

os_hw1_de1soc.requires      (hs_npu_altera_ip)
os_hw1_de1soc.requires      (hsv_core_altera_ip)
os_hw1_de1soc.requires      (hsv_host_sw, outputs=['hsv_host_sw.hex'])
os_hw1_de1soc.altera_device ('5CSEMA5F31C6') # DE1-SoC
os_hw1_de1soc.altera_family ('Cyclone V')
os_hw1_de1soc.sdc           (['timing.sdc'])
os_hw1_de1soc.qsf           (['pins.tcl', 'rom.tcl'])
os_hw1_de1soc.qsys_platform ('cpu.qsys')
os_hw1_de1soc.rtl           (['cpu_inst.v'])
os_hw1_de1soc.top           ('cpu_inst')
