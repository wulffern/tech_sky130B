
cell:
	cicsim simcell  ${LIB} ${CELL} ../tech/cicsim/simcell_template.yaml

netlist:
#- TODO: Should I add the view here? Either xsch or lpe??
	test -d ../../work/xsch || mkdir ../../work/xsch
	cd ../../work && xschem -q -x -b -s -n ../design/${LIB}/${CELL}.sch
	perl -pi -e "s/\*\*\.subckt/\.subckt/ig;s/\*\*\.ends/\.ends/ig;s/,/ /ig;" ../../work/xsch/${CELL}.spice
