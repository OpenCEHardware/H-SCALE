from mk import *

wb2axip = RtlPackage('wb2axip')

rtl = find_files('*.v')

# These modules fail to verilate, we don't need them anyway
rtl.take('axissafety.v')
rtl.take('migsdram.v')

wb2axip.rtl       (rtl)
wb2axip.skip_lint ()
