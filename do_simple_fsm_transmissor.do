#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom simple_fsm_transmissor.vhd simple_fsm_transmissor_tb.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -voptargs="+acc" -t ns work.simple_fsm_transmissor_tb

#Mosta forma de onda
view wave

#Adiciona ondas específicas
add wave -radix binary  /clk
add wave -radix binary  /start
add wave -radix binary  /reset
add wave -radix binary  /data
add wave -radix binary  /addr
add wave -radix binary  /sdata
add wave /dut/pr_state
add wave -radix binary  /sel_pr



#Simula até um 100000ns
run 500

wave zoomfull
write wave wave.ps