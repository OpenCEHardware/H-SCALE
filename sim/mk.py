from mk import *

bench_bogomips   = VerilatedRunPackage('bench_bogomips')
bench_cpu_vs_npu = VerilatedRunPackage('bench_cpu_vs_npu')

simulator        = find_package('simulator')
hsv_rom_iris     = find_package('hsv_rom_iris')
hsv_rom_bogomips = find_package('hsv_rom_bogomips')

bench_bogomips.requires (hsv_rom_bogomips)
bench_bogomips.runner   (simulator)
bench_bogomips.args     (['--timeout=600', '--ram-size=0x20000', 'hsv_rom_bogomips'])

bench_cpu_vs_npu.requires (hsv_rom_iris)
bench_cpu_vs_npu.runner   (simulator)
bench_cpu_vs_npu.args     (['--timeout=60', '--ram-size=0x20000', 'hsv_rom_iris'])
