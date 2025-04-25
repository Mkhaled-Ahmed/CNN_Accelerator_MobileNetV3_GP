add wave -position insertpoint  \
sim:/hs_segment/output_data
add wave -position insertpoint  \
sim:/hs_segment/output_data \
sim:/hs_segment/stage1_out \
sim:/hs_segment/stage2_out \
sim:/hs_segment/stage3_out \
sim:/hs_segment/stage4_out
add wave -position end  sim:/hs_segment/rst
force -freeze sim:/hs_segment/rst 1'h0 0
add wave -position insertpoint  \
sim:/hs_segment/clk
force -freeze sim:/hs_segment/clk 1 0, 0 {50 ns} -r 100
force -freeze sim:/hs_segment/rst 1'h0 0
run
force -freeze sim:/hs_segment/rst 1'h1 0
add wave -position insertpoint  \
sim:/hs_segment/en
force -freeze sim:/hs_segment/en 1'h1 0
force -freeze sim:/hs_segment/rst 1'h1 0
add wave -position end  sim:/hs_segment/input_data
force -freeze sim:/hs_segment/input_data -32'd222 0
run
run
run
run
run
run