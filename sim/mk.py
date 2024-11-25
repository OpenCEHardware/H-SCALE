from mk import *

bench_cpu_vs_npu = VerilatedRunPackage('bench_cpu_vs_npu')

simulator   = find_package('simulator')
hsv_host_sw = find_package('hsv_host_sw')

bench_cpu_vs_npu.requires (hsv_host_sw, outputs=['hsv_host_sw'])
bench_cpu_vs_npu.runner   (simulator)
bench_cpu_vs_npu.args     (['--timeout=60', '--ram-size=0x20000', 'hsv_host_sw'])
