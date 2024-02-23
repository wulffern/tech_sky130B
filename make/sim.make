
cell:
	cicsim simcell  ${LIB} ${CELL} ../tech/cicsim/simcell_template.yaml

netlist:
#- I've seen port ordering change between xschem version, so I also
# generate a xdut.spi file that always has the right port ordering.
#- TODO: Should I add the view here? Either xsch or lpe??
	test -d ../../work/xsch || mkdir ../../work/xsch
	cd ../../work/ && make xsch
	perl ../../tech/script/genxdut ../../work/xsch/${CELL}.spice ${CELL}
