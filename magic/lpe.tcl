
load {PATH}/{CELL}.mag

select top cell
#- Tim does not trust hierarchy extract, but port order gets screwed up with flat
#flatten {CELL}_flat
#load {CELL}_flat

extract all
set VDD AVDD
set GND AVSS
set SUB AVSS

ext2sim labels on
ext2sim

ext2spice lvs
ext2spice format ngspice
ext2spice resistor off
ext2spice hierarchy off
ext2spice subcircuits off
#ext2spice merge conservative
ext2spice cthresh 0.1
ext2spice -o lpe/{CELL}_lpe.spi
quit
