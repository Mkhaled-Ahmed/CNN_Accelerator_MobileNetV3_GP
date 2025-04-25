@REM cls
vlog -f module/list.list
vsim  -voptargs=+acc -batch work.tb_conv2d
@REM python python/convertor.py
@REM cmd /k~