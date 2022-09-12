vsim -voptargs=+acc work.testALU
view structure wave signals

do wave.do

log -r *
run -all

