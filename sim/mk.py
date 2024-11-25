from mk import *

bench_cpu_vs_npu = VerilatedRunPackage('bench_cpu_vs_npu')

hosted      = find_package('hosted')
hsv_host_sw = find_package('hsv_host_sw')

bench_cpu_vs_npu.requires (hsv_host_sw, outputs=['hsv_host_sw'])
bench_cpu_vs_npu.runner   (hosted)
bench_cpu_vs_npu.args     (['--timeout=60', '--ram-size=0x20000', 'hsv_host_sw'])
