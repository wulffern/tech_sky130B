#set VDD AVDD
#set GND AVSS
#set SUB 0

load {PATH}/{CELL}.mag


select top cell

extract all

flatten {CELL}_flat
load {CELL}_flat

extract path extfiles
extract all

ext2sim labels on
ext2sim
extresist tolerance 10
extresist
ext2spice lvs
ext2spice format ngspice
ext2spice extresist on
#ext2spice hierarchy off
#ext2spice subcircuits off
#ext2spice merge conservative
ext2spice cthresh 0.1
ext2spice -p extfiles -o lpe/{CELL}_lper.spi
quit
