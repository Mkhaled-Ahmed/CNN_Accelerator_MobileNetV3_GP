cls
vlog fixed_point_multiplier.v
vlog tp_multi.v
vsim -batch -voptargs=+acc work.tp_multi -do "run -all; quit" 
python convertor.py
cmd /k