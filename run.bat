cls
vlog fifo_segment.v
vlog fifo_image_input.v
vlog fifo_seg_tb.v
vsim -batch -voptargs=+acc work.fifo_seg_tb -do "run -all; quit" 
::python convertor.py
cmd /k