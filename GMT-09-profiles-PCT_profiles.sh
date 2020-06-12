#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Peru-Chile Trench
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=crossPCT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=0.5c \
    MAP_ANNOT_OFFSET=0.2c \
    MAP_TICK_PEN_PRIMARY=thinnest,dimgray \
    MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    FONT_LABEL=10p,Palatino-Roman,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of ETOPO1m for the Peru-Chile Trench area
grdcut earth_relief_01m.grd -R276/292/-30/-6 -Gpct_relief.nc
# Step-5. Make color palette
gmt makecpt -Cglobe -V -T-8500/7000 > myoceanPCT.cpt
# Step-6. Make raster image
gmt grdimage pct_relief.nc -CmyoceanPCT.cpt -R276/292/-30/-6 -JM4.5i \
    -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg263.0/-55+w9.7i/0.4c+v+o0.3/0i+ml -Rpct_relief.nc -J -CmyoceanPCT.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
	-Baf+l"Color scale legend: depth and height elevations (m)" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour pct_relief.nc -R -J -C1000 \
    -B+t"Cross-sectional profiles of the Peru-Chile Trench on two selected segments" \
    -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
	-Lx9c/-1.2c+c50+w600k+l"Mercator Cylindrical Projection. Scale (km)"+f \
	-Bpxg8f4a8 -Bpyg10f4a4 -Bsxg4 -Bsyg4 \
    --FONT=8p,Palatino-Roman,dimgray \
	-UBL/-10p/-35p -O -K >> $ps
#
# PERU segment
# Step-10. Select two points along the Peru segment
cat << EOF > trenchPCTn.txt
279.1 -9.0
282.4 -14.0
EOF
gmt psxy -Rpct_relief.nc -J -W2p,yellow trenchPCTn.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gyellow trenchPCTn.txt -O -K >> $ps # points
# Step-13. Generate cross-track profiles 400 km long, spaced 20 km, sampled every 2km
#gmt grdtrack trenchRT.txt -Gpct_relief.nc -C400k/2k/20k+v -Sa+sstackPCTn.txt > tablePCTn.txt
gmt grdtrack trenchPCTn.txt -Gpct_relief.nc -C400k/2k/20k+v -Sm+sstackPCTn.txt > tablePCTn.txt
gmt psxy -R -J -Wthin,yellow tablePCTn.txt -O -K >> $ps
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackPCTn.txt -o0,5 > envPCTn.txt
gmt convert stackPCTn.txt -o0,6 -I -T >> envPCTn.txt
#
# CHILE segment
# Step-11. Select two points along the Chile segment
cat << EOF > trenchPCTs.txt
288.85 -21.0
288.45 -26.5
EOF
gmt psxy -Rpct_relief.nc -J -W2p,red trenchPCTs.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred trenchPCTs.txt -O -K >> $ps # points
# Step-13. Generate cross-track profiles 400 km long, spaced 20 km, sampled every 2km
#gmt grdtrack trenchRT.txt -Grt_relief.nc -C400k/2k/20k+v -Sa+sstackRT.txt > tableRT.txt
gmt grdtrack trenchPCTs.txt -Gpct_relief.nc -C400k/2k/20k+v -Sm+sstackPCTs.txt > tablePCTs.txt
gmt psxy -R -J -Wthin,red tablePCTs.txt -O -K >> $ps
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackPCTs.txt -o0,5 > envPCTs.txt
gmt convert stackPCTs.txt -o0,6 -I -T >> envPCTs.txt
#
# Step-18. Add GMT logo
gmt logo -Dx5.0/-2.8+w2c -O >> $ps
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert crossPCT.ps -A0.5c -E720 -Tj -P -Z
