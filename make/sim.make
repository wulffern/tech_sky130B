
cell:
	cicsim simcell  ${LIB} ${CELL} ../tech/cicsim/simcell_template.yaml

netlist:
	test -d ../../work/xsch || mkdir ../../work/xsch
	cd ../../work && xschem -q -x -b -s -n ../design/${LIB}/${CELL}.sch
	perl -pi -e "s/\*\*\.subckt/\.subckt/ig;s/\*\*\.ends/\.ends/ig;" ../../work/xsch/${CELL}.spice