vlog adder_tree.v
vlog tp_multi.v
vsim -batch -voptargs=+acc work.tp_multi -do "run -all; quit" 