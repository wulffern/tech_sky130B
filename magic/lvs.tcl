set VDD AVDD
set GND AVSS
set SUB BULKN
load {PATH}/{CELL}.mag
#writeall force
extract
ext2spice lvs
ext2spice -o lvs/{CELL}.spi
quit
