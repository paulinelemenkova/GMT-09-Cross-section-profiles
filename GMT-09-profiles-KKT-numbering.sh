#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Kuril-Kamchatka Trench
# GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix prog: cat
# Step-1. Generate a file
ps=crossKKT_num.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=ddd \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=0.5c \
    MAP_ANNOT_OFFSET=0.2c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinnest,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=14p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=10p,Palatino-Roman,dimgray \
    FONT_LABEL=10p,Palatino-Roman,black \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of ETOPO1m for the Kuril-Kamchatka Trench area
#grdcut earth_relief_01m.grd -R146/162/41/51 -Gkkt_relief.nc
grdcut GEBCO_2019.nc -R146/162/41/51 -Gkkt_relief.nc
# Step-5. Make color palette
gmt makecpt -Cgeo -V -T-10000/1000 > myocean.cpt
# Step-6. Make raster image
gmt grdimage kkt_relief.nc -Cmyocean.cpt -R146/162/41/51 -JM6i \
    -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg133.8/40+w6.5i/0.15i+v+o0.3/0i+ml \
    -Rkkt_relief.nc -J -Cmyocean.cpt \
	--FONT_LABEL=10p,Helvetica,black \
	--FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    --MAP_ANNOT_OFFSET=0.1c \
	-Baf+l"Color scale legend: depth and height elevations (m)" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour kkt_relief.nc -R -J -C1000 \
-B+t"Enlarged view of the trench and 2 segments of the cross-section profiles" \
    -W0.1,black -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
	-Lx13.4c/-1.3c+c50+w400k+l"Mercator projection. Scale (km)"+f \
	-Bxg4f2a2 -Byg4f2a2 \
    --MAP_TITLE_OFFSET=0.3c \
    --MAP_ANNOT_OFFSET=0.2c \
    --MAP_LABEL_OFFSET=0.2c \
    --FONT=10p,Palatino-Roman,black \
	-UBL/-15p/-35p -O -K >> $ps
# Step-10. Select two points for northern segment along the Kuril-Kamchatka Trench
cat << EOF > trench2.txt
153.5 45.5
158.5 50.0
EOF
# Step-11. Plot northern trench segment and end points
gmt psxy -Rkkt_relief.nc -J -W2p,red trench2.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred trench2.txt -O -K >> $ps # points
# Step-12. Generate cross-track profiles 400 km long, spaced 10 km, sampled every 2km
gmt grdtrack trench2.txt -Gkkt_relief.nc -C400k/2k/10k+v -Sm+sstack2.txt > table2.txt
# Step-13. write stacked profile into table
gmt psxy -R -J -W0.5p table2.txt -O -K >> $ps
# Step-14. Show upper/lower values encountered as an envelope
gmt convert stack2.txt -o0,5 > env2.txt
gmt convert stack2.txt -o0,6 -I -T >> env2.txt
# Step-15. Select two points for southern segment along the Kuril-Kamchatka Trench
cat << EOF > trench1.txt
148.0 43.0
153.5 45.5
EOF
# Step-16. Plot southern trench segment and end points
gmt psxy -Rkkt_relief.nc -J -W2p,green trench1.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Ggreen trench1.txt -O -K >> $ps # points
# Step-17. Generate cross-track profiles 400 km long, spaced 10 km, sampled every 2km
gmt grdtrack trench1.txt -Gkkt_relief.nc -C400k/2k/10k -Sm+sstack1.txt > table1.txt
gmt psxy -R -J -W0.3p,black table1.txt -O -K >> $ps
# Step-18. Show upper/lower values encountered as an envelope
gmt convert stack1.txt -o0,5 > env1.txt
gmt convert stack1.txt -o0,6 -I -T >> env1.txt
# Step-22. Add GMT logo
gmt logo -Dx6.2/-2.2+o0.1i/0.1i+w2c -O >> $ps
# Step-23. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert crossKKT_num.ps -A0.5c -E720 -Tj -P -Z
