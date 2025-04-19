@REM cls
vlog -f module/list.list
vsim  -voptargs=+acc work.tb_conv2d -do "add wave *;run -all" 
@REM python python/convertor.py
@REM cmd /k