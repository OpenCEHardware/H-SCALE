from mk import *

simulator = VerilatedPackage('simulator')

hs_npu   = find_package('hs_npu')
hsv_core = find_package('hsv_core')
wb2axip  = find_package('wb2axip')
ncursesw = find_pkgconfig('ncursesw')

simulator.requires   (hs_npu)
simulator.requires   (hsv_core)
simulator.requires   (ncursesw)
simulator.requires   (wb2axip)
simulator.requires   (find_files(['*.hpp', '*.hxx']))
simulator.main       (find_files('*.cpp'))
simulator.rtl        (find_files('*.sv'))
simulator.top        ('hosted_top_flat')
simulator.executable ('simulator')
simulator.trace_args (lambda file: [f'--trace={file}'])
