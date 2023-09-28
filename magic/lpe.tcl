#set VDD AVDD
#set GND AVSS
#set SUB 0

load {PATH}/{CELL}.mag
writeall force

select top cell
#- Tim does not trust hierarchy extract, but port order gets screwed up with flat
# needed to add a script to fix it.
# Also seen for the SUN_PLL that the flat fails simulation, but the hierarcichal is ok.
# The question is, does the circuit actually fail, or is it the flat lpe that is funky?
# For now, don't do flat this way
#flatten {CELL}_flat
#load {CELL}_flat

extract all

ext2sim labels on
ext2sim

ext2spice lvs
ext2spice format ngspice
ext2spice resistor off
#ext2spice hierarchy off
#ext2spice subcircuits off
#ext2spice merge conservative
ext2spice cthresh 0.1
ext2spice -o lpe/{CELL}_lpe.spi
quit
