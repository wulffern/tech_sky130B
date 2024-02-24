set VDD AVDD
set GND AVSS
set SUB BULKN
load {PATH}/{CELL}.mag
extract all
ext2spice lvs
ext2spice hierarchy off
ext2spice subcircuits off
ext2spice -o lvs/{CELL}.spi
quit
