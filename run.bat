vlog adder_tree.v
vlog tb.v
vsim -batch -voptargs=+acc work.adder_tb -do "run -all; quit" 
python convertor.py