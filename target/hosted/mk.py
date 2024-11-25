from mk import *

hosted = VerilatedPackage('hosted')

hs_npu   = find_package('hs_npu')
hsv_core = find_package('hsv_core')
wb2axip  = find_package('wb2axip')
ncursesw = find_pkgconfig('ncursesw')

hosted.requires   (hs_npu)
hosted.requires   (hsv_core)
hosted.requires   (ncursesw)
hosted.requires   (wb2axip)
hosted.requires   (find_files(['*.hpp', '*.hxx']))
hosted.main       (find_files('*.cpp'))
hosted.rtl        (find_files('*.sv'))
hosted.top        ('hosted_top_flat')
hosted.executable ('simulator')
hosted.trace_args (lambda file: [f'--trace={file}'])
