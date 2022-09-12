onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TOP LEVEL INPUTS}

add wave -noupdate -format Literal -radix unsigned /test_mux2_1/mux_in_1
add wave -noupdate -format Literal -radix unsigned /test_mux2_1/mux_in_2
add wave -noupdate -format Logic /test_mux2_1/sel
add wave -noupdate -format Literal -radix unsigned /test_mux2_1/mux_out

#add wave -noupdate -format Literal -radix unsigned  /test_FileName/test_Signal
# -radix後接型態 十進位 decimal, 1bit logic, 十六進位 hex, 二進位 binary, 正整數 unsigned

