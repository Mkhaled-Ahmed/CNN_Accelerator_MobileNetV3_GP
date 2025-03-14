cls
vlog module/hs_segment.v
vlog test/tb_hs.v
vsim -batch -voptargs=+acc work.tb_hs -do "run -all; quit" 
python python/convertor.py
cmd /k