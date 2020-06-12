#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Kermadec and Tonga trenches
# GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix prog: cat
# Step-1. Generate a file
ps=crossTKT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=ddd \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1.7c \
    MAP_ANNOT_OFFSET=0.2c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinnest,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=16p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=10p,Palatino-Roman,dimgray \
    FONT_LABEL=10p,Palatino-Roman,black \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of ETOPO1m for the Kermadec and Tonga trenches area
grdcut earth_relief_01m.grd -R177/193/-37/-13.5 -Gtkt_relief.nc
# Step-5. Make color palette
gmt makecpt -Cgeo -V -T-11000/1000 > myocean.cpt
# Step-6. Make raster image
gmt grdimage tkt_relief.nc -Cmyocean.cpt -R177/193/-37/-13.5 -JM6i \
    -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg174/-37+w24.5c/0.4c+v+o0.3/0i+ml \
    -Rtkt_relief.nc -J -Cmyocean.cpt \
	--FONT_LABEL=10p,Helvetica,black \
	--FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    --MAP_ANNOT_OFFSET=0.1c \
	-Baf+l"Color scale legend: depth and height elevations (m)" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour tkt_relief.nc -R -J -C1000 \
-B+t"Bathymetry of the Kermadec and Tonga trenches and transect profiles" \
    -W0.1,black -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
	-Lx13.4c/-1.3c+c50+w400k+l"Mercator projection. Scale (km)"+f \
	-Bxg4f2a4 -Byg4f2a4 \
    --MAP_TITLE_OFFSET=0.3c \
    --MAP_ANNOT_OFFSET=0.2c \
    --MAP_LABEL_OFFSET=0.2c \
    --FONT=10p,Palatino-Roman,black \
	-UBL/-15p/-35p -O -K >> $ps
#
# KERMADEC
# Step-10. Select two points
cat << EOF > trenchK.txt
181.7 -35
184.0 -28.5
EOF
# Step-11. Plot northern trench segment and end points
gmt psxy -Rtkt_relief.nc -J -W2p,red trenchK.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred trenchK.txt -O -K >> $ps # points
# Step-12. Generate cross-track profiles 400 km long, spaced 10 km, sampled every 2km
gmt grdtrack trenchK.txt -Gtkt_relief.nc -C400k/2k/10k+v -Sm+sstackK.txt > tableK.txt
# Step-13. write stacked profile into table
gmt psxy -R -J -W0.5p tableK.txt -O -K >> $ps
# Step-14. Show upper/lower values encountered as an envelope
gmt convert stackK.txt -o0,5 > envK.txt
gmt convert stackK.txt -o0,6 -I -T >> envK.txt
#
# TONGA
# Step-15. Select two points
cat << EOF > trenchT.txt
185.7 -23.0
187.8 -17.5
EOF
# Step-16. Plot southern trench segment and end points
gmt psxy -Rtkt_relief.nc -J -W2p,green trenchT.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Ggreen trenchT.txt -O -K >> $ps # points
# Step-17. Generate cross-track profiles 400 km long, spaced 10 km, sampled every 2km
gmt grdtrack trenchT.txt -Gtkt_relief.nc -C400k/2k/10k -Sm+sstackT.txt > tableT.txt
gmt psxy -R -J -W0.5p,black tableT.txt -O -K >> $ps
# Step-18. Show upper/lower values encountered as an envelope
gmt convert stackT.txt -o0,5 > envT.txt
gmt convert stackT.txt -o0,6 -I -T >> envT.txt
#
# Step-21. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y17.0c -N -O -K \
-F+f12p,Palatino-Roman,black+jLB >> $ps << EOF
0.0 14.6 Track segments: Kermadec (red) and Tonga (green).
0.0 14.0 Cross-sectional profiles: 400 km long, spaced 10 km, sampled every 2 km.
0.0 13.4 Bathymetric map: ETOPO1 Global Relief Model 1 arc min resolution
EOF
# Step-22. Add GMT logo
gmt logo -Dx6.2/-15.0+o0.2c/-4.0c+w2c -O >> $ps
# Step-23. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert crossTKT.ps -A0.7c -E720 -Tj -P -Z
