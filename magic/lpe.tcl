load {PATH}/{CELL}.mag
select top cell
flatten {CELL}_flat
load {CELL}_flat
extract all
ext2sim labels on
ext2sim
extresist tolerance 10
extresist
ext2spice lvs
ext2spice cthresh 0
ext2spice extresist on
ext2spice -o lpe/{CELL}_lpe.spi
quit
