
cell:
	cicsim simcell  ${LIB} ${CELL} ../tech/cicsim/simcell_template.yaml

netlist:
#- TODO: Should I add the view here? Either xsch or lpe??
	test -d ../../work/xsch || mkdir ../../work/xsch
	cd ../../work && xschem -q -x -b -s -n ../design/${LIB}/${CELL}.sch
	cp ../../work/xsch/${CELL}.spice ../../work/xsch/${CELL}.spice.bak
	cat ../../work/xsch/${CELL}.spice.bak | perl ../../tech/script/fixsubckt > ../../work/xsch/${CELL}.spice
	-rm ../../work/xsch/${CELL}.spice.bak
