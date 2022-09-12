vsim -voptargs=+acc work.test_mux2_1
view structure wave signals

do wave.do

log -r *
run -all

