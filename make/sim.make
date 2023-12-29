
cell:
	cicsim simcell  ${LIB} ${CELL} ../tech/cicsim/simcell_template.yaml

netlist:
#- I've seen port ordering change between xschem version, so I also
# generate a xdut.spi file that always has the right port ordering.
#- TODO: Should I add the view here? Either xsch or lpe??
	test -d ../../work/xsch || mkdir ../../work/xsch
	cd ../../work && xschem -q -x -b -s -n ../design/${LIB}/${CELL}.sch
	cp ../../work/xsch/${CELL}.spice ../../work/xsch/${CELL}.spice.bak
	cat ../../work/xsch/${CELL}.spice.bak | perl ../../tech/script/fixsubckt > ../../work/xsch/${CELL}.spice
	perl ../../tech/script/genxdut ../../work/xsch/${CELL}.spice ${CELL}
	-rm ../../work/xsch/${CELL}.spice.bak
