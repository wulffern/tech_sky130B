######################################################################
##        Copyright (c) 2022 Carsten Wulff Software, Norway
## ###################################################################
## Created       : wulff at 2022-4-27
## ###################################################################
##  The MIT License (MIT)
##
##  Permission is hereby granted, free of charge, to any person obtaining a copy
##  of this software and associated documentation files (the "Software"), to deal
##  in the Software without restriction, including without limitation the rights
##  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
##  copies of the Software, and to permit persons to whom the Software is
##  furnished to do so, subject to the following conditions:
##
##  The above copyright notice and this permission notice shall be included in all
##  copies or substantial portions of the Software.
##
##  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
##  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
##  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
##  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
##  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
##  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
##  SOFTWARE.
##
######################################################################


PRCELL = ${PREFIX}${CELL}

PDKPATH=${PDK_ROOT}/sky130B

.PHONY: drc lvs lpe gds cdl xsch


#----------------------------------------------------------------------------
# Figure out what where running on
#----------------------------------------------------------------------------
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
ECHO=echo
endif

ifeq ($(UNAME_S),Linux)

#- Seems to be a difference between centos and ubuntu here. Ubuntu does not like echo -e
ifeq ($(shell lsb_release -si),Ubuntu)
ECHO=echo
else
ECHO=echo -e
endif
endif

#----------------------------------------------------------------------------
# VERIFICATION
#----------------------------------------------------------------------------
LMAG=../design/${LIB}
NCELL=${LMAG}/${PRCELL}
MCELL=${NCELL}.mag

#- Options
OPT=

SUB=BULKN

BUILD=../design/


CICEXCLUDE?=""

#- Cicpy
CICPY=cicpy

#- Ciccreator
CICDIR=../../ciccreator
ifneq "$(wildcard $(CICDIR) )" ""
CIC=${CICDIR}/bin/cic
CICGUI=${CICDIR}/bin/cic-gui
else
CIC=cic
CICGUI=cic-gui
endif

CICVIEWS =  --spice --verilog --xschem --magic

RDIR=2>&1


define TECH_HELP
*****************************************************************
                 Technology make system
******************************************************************
I know I will forget, so I write everything down in a Makefile

The command 'make' reads a Makefile, and runs the first command.

You can specify the commands by adding them after 'make'
, for example 'make help' prints this text

Most commands in this Makefile use two parameters, LIB, and CELL.
For example:

	make xsch LIB=RPLY_EX0_SKY130NM CELL=RPLY_EX0

generates a netlist from schematic in xsch/RPLY_EX0.spice

To see what a make command does, add a '-n' option
For example:
	make xsch LIB=RPLY_EX0_SKY130NM CELL=RPLY_EX0 -n

Outputs:
	test -d xsch || mkdir xsch
	xschem -q -x -b -s -n ../design/RPLY_EX0_SKY130NM/RPLY_EX0.sch

Commands:
   gds    Generate GDSII from layout
   xsch   Generate spice netlist from schematic
   xlvs   Run Layout Versus Schematic
   drc    Run Design Rule Checks
   doc    Use pandoc to convert README.md into README.html
   xview  Start Xschem
endef

export TECH_HELP

help:
	@echo "$${TECH_HELP}"



ip:
	-test -f ../cic/ip.py && python3 ../cic/ip.py
	cd ${BUILD};${CIC}  --I ../cic ../cic/ip.json  ../cic/sky130.tech ${LIB} ${CICOPT}
	cd ${BUILD}; ${CICPY}  transpile ${LIB}.cic ../cic/sky130.tech ${LIB}  ${CICVIEWS} --smash "(P|N)CHIOA" --exclude ${CICEXCLUDE}

view:
	@cd ${BUILD}; ${CICGUI} ${LIB}.cic ../cic/sky130.tech

gds:
	test -d gds || mkdir gds
	${ECHO} "load ${NCELL}.mag\ncalma write gds/${PRCELL}.gds \nquit" > gds/${PRCELL}.tcl
	magic -noconsole -dnull gds/${PRCELL}.tcl > gds/${PRCELL}.log  ${RDIR}


xsch:
	@test -d xsch || mkdir xsch
	xschem -q -x -b -s -n ../design/${LIB}/${CELL}.sch
	cp xsch/${CELL}.spice xsch/${CELL}.spice.bak
	cat xsch/${CELL}.spice.bak | perl ../tech/script/fixsubckt > xsch/${CELL}.spice
	-rm xsch/${CELL}.spice.bak


cdl:
	@test -d cdl || mkdir cdl
	xschem -q -x -b -s --tcl "set lvs_netlist 1; set netlist_dir ${PWD}/cdl/; set bus_replacement_char {[]};" -n ../design/${LIB}/${CELL}.sch


#--------------------------------------------------------------------------------------
#- LVS commands
#--------------------------------------------------------------------------------------

xlvs: cdl
	test -d lvs || mkdir lvs
	cat ../tech/magic/lvs.tcl|perl -pe 's#{PATH}#${LMAG}#ig;s#{CELL}#${PRCELL}#ig;' > lvs/${PRCELL}_spi.tcl
	magic -noconsole -dnull lvs/${PRCELL}_spi.tcl > lvs/${PRCELL}_spi.log ${RDIR}
	netgen -batch lvs "lvs/${PRCELL}.spi ${PRCELL}"  "cdl/${PRCELL}.spice ${PRCELL}" ${PDKPATH}/libs.tech/netgen/sky130B_setup.tcl lvs/${PRCELL}_lvs.log > lvs/${PRCELL}_netgen_lvs.log
	cat lvs/${PRCELL}_lvs.log | ../tech/script/checklvs ${PRCELL}

xflvs: cdl
	@test -d lvs || mkdir lvs
	cat ../tech/magic/lvsf.tcl|perl -pe 's#{PATH}#${LMAG}#ig;s#{CELL}#${PRCELL}#ig;' > lvs/${PRCELL}_spi.tcl
	magic -noconsole -dnull lvs/${PRCELL}_spi.tcl > lvs/${PRCELL}_spi.log ${RDIR}
	netgen -batch lvs "lvs/${PRCELL}.spi ${PRCELL}"  "cdl/${PRCELL}.spice ${PRCELL}" ${PDKPATH}/libs.tech/netgen/sky130B_setup.tcl lvs/${PRCELL}_lvs.log > lvs/${PRCELL}_netgen_lvs.log
	cat lvs/${PRCELL}_lvs.log | ../tech/script/checklvs ${PRCELL}

lvs:
	test -d lvs || mkdir lvs
	cat ../tech/magic/lvs.tcl|perl -pe 's#{PATH}#${LMAG}#ig;s#{CELL}#${PRCELL}#ig;' > lvs/${PRCELL}_spi.tcl
	magic -noconsole -dnull lvs/${PRCELL}_spi.tcl > lvs/${PRCELL}_spi.log ${RDIR}
	netgen -batch lvs "lvs/${PRCELL}.spi ${PRCELL}"  "${BUILD}/${LIB}.spi ${PRCELL}" ${PDKPATH}/libs.tech/netgen/sky130B_setup.tcl lvs/${PRCELL}_lvs.log > lvs/${PRCELL}_netgen.log
	cat lvs/${PRCELL}_lvs.log | ../tech/script/checklvs ${PRCELL} ${OPT}

#--------------------------------------------------------------------------------------
#- Run DRC
#--------------------------------------------------------------------------------------
drc:
	@test -d drc || mkdir drc
	@${ECHO} "load ${NCELL}.mag\nlogcommands drc/${PRCELL}_drc.log\nset b [view bbox]\nbox values [lindex \$$b 0] [lindex \$$b 1] [lindex \$$b 2] [lindex \$$b 3]\ndrc catchup\ndrc why\ndrc count total\nquit\n" > drc/${PRCELL}_drc.tcl
	@magic -noconsole -dnull drc/${PRCELL}_drc.tcl > drc/${PRCELL}_drc.log ${RDIR}
	@tail -n 1 drc/${PRCELL}_drc.log| perl -ne "\$$exit = 0;use Term::ANSIColor;print(sprintf(\"%-40s\t[ \",${PRCELL}));if(m/:\s+0\n/ig){print(color('green').'DRC OK  '.color('reset'));}else{print(color('red').'DRC FAIL'.color('reset'));\$$exit = 1;};print(\" ]\n\");exit \$$exit;" || tail -n 10 drc/${PRCELL}_drc.log

kdrc:
	klayout -b -r ${PDK_ROOT}/sky130B/libs.tech/klayout/drc/sky130B_mr.drc  -rd input=gds/${PRCELL}.gds -rd topcell=${PRCELL} -rd report=../drc/${PRCELL}_drc.xml -rd thr=8 -rd feol=true -rd beol=true -rd offgrid=true  >& drc/${PRCELL}_kdrc.log


#--------------------------------------------------------------------------------------
#- Run parasitic extraction
#--------------------------------------------------------------------------------------
lpe: xsch
	test -d lpe || mkdir lpe
	-rm lpe/${PRCELL}_lpe.spi
	cat ../tech/magic/lpe.tcl |perl -pe 's#{PATH}#${LMAG}#ig;s#{CELL}#${PRCELL}#ig;'  > lpe/${PRCELL}_lpe.tcl
	magic -noconsole -dnull lpe/${PRCELL}_lpe.tcl ${RDIR} | tee lpe/${PRCELL}_magic_lpe.log
	perl -pi -e "s/_flat//ig;" lpe/${PRCELL}_lpe.spi
	../tech/script/fixlpe lpe/${PRCELL}_lpe.spi xsch/${PRCELL}.spice ${PRCELL}

lper: xsch
	test -d lpe || mkdir lpe
	-rm lpe/${PRCELL}_lper.spi
	cat ../tech/magic/lper.tcl |perl -pe 's#{PATH}#${LMAG}#ig;s#{CELL}#${PRCELL}#ig;'  > lpe/${PRCELL}_lper.tcl
	magic -noconsole -dnull lpe/${PRCELL}_lper.tcl ${RDIR} | tee lpe/${PRCELL}_magic_lper.log
	perl -pi -e "s/_flat//ig;" lpe/${PRCELL}_lper.spi
	../tech/script/fixlpe lpe/${PRCELL}_lper.spi xsch/${PRCELL}.spice ${PRCELL}

lpeh: xsch
	test -d lpe || mkdir lpe
	cat ../tech/magic/lpeh.tcl |perl -pe 's#{PATH}#${LMAG}#ig;s#{CELL}#${PRCELL}#ig;'  > lpe/${PRCELL}_lpe.tcl
	magic -noconsole -dnull lpe/${PRCELL}_lpe.tcl ${RDIR} | tee lpe/${PRCELL}_magic_lpe.log
	perl -pi -e "s/_flat//ig;" lpe/${PRCELL}_lpe.spi
	../tech/script/fixlpe lpe/${PRCELL}_lpe.spi xsch/${PRCELL}.spice ${PRCELL}

lvsall:
	@${foreach b, ${CELLS}, ${MAKE} -s cdl lvs CELL=$b;}

xlvsall:
	@${foreach b, ${CELLS}, ${MAKE} -s xlvs CELL=$b;}

xflvsall:
	@${foreach b, ${CELLS}, ${MAKE} -s xflvs CELL=$b;}

lpeall:
	@${foreach b, ${CELLS}, ${MAKE} -s lpe CELL=$b;}

drcall:
	@${foreach  b, ${CELLS}, ${MAKE} -s drc CELL=$b;}

doc: svg dclone
	pandoc -s ../README.md -o ../README.html

clean:
	-rm -rf lvs drc lpe cdl gds *.ext *.sim *.nodes

spi:
	test -d xsch || mkdir xsch
	xschem -q -x -b -s -n ../design/${LIB}/${CELL}.sch
	cat xsch/${CELL}.spice| ../tech/script/fixspi > ../cic/${CELL}.spi

xview:
	xschem -b  ../design/${LIB}/${CELL}.sch &

SCHS := $(wildcard ../design/${LIB}/*.sch)
BINS := $(SCHS:%.sch=%)
SVGP =${<:%.sch=%}.svg
MDP =${<:%.sch=%}.md
SVG = ${subst ../design/,,${SVGP}}

svg:
	test -d ../documents/ || mkdir ../documents
	@echo "---\nlayout: page\ntitle: Schematic\npermalink: sch\n---\n" > ../documents/schematic.md

	${foreach l, ${SVGLIBS}, ${MAKE} svgf LIB=${l};}
	pandoc -s ../documents/schematic.md -o ../documents/schematic.html

svgf: ${BINS}

%: %.sch
	xschem --preinit "set dark_colorscheme 0" -x -q -p --svg $<
	echo "## ${SVG}\n\n" >> ../documents/schematic.md
	echo "\n\n![${SVG}](${SVG})\n\n" >> ../documents/schematic.md
	-test -f ${MDP} && cat ${MDP} >> ../documents/schematic.md
	test -d  ../documents/${LIB} || mkdir ../documents/${LIB}
	cp plot.svg ../documents/${SVG}


LINKLIBS = ${shell find ../design -d 1 -type l}
fmdclone = ../install.md
dclone:
	echo "# Clone ${CELL}\n\n" > ${fmdclone}
	echo "To use this library you need the following libraries\n\n" >> ${fmdclone}
	echo "\`\`\`bash\n" >> ${fmdclone}
	git  remote -v |grep fetch|awk '{print "git clone "$$2}' >> ${fmdclone}
	${foreach l, ${LINKLIBS}, git -C ${l} remote -v |grep fetch|awk '{print "git clone "$$2}' >> ${fmdclone} ;}
	git -C ../tech remote -v |grep fetch|awk '{print "git clone "$$2}' >> ${fmdclone}
	git -C ../../cpdk remote -v |grep fetch|awk '{print "git clone "$$2}' >> ${fmdclone}
	echo "\`\`\`\n\n" >> ${fmdclone}
