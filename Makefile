
techsync:
	cd ../; rsync -av --exclude=.git tech_sky130B/ tech_sky130A
	cd ../tech_sky130A; egrep -R "sky130B"|awk -F: '{print $1}'|sort|uniq|egrep -v "^\.git" > sky130B.txt
	cd ../tech_sky130A; cat sky130B.txt |xargs perl -pi -e "s/sky130B/sky130A/ig;"
