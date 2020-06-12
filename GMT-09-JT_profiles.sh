#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Japan trench
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=JTcross.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1.0c \
    MAP_ANNOT_OFFSET=0.2c \
    MAP_TICK_PEN_PRIMARY=thinnest,dimgray \
    MAP_GRID_PEN_PRIMARY=thinnest,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    FONT_LABEL=10p,Palatino-Roman,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of SRTM for the Japan trenches
grdcut GEBCO_2019.nc -R138/149/33/42 -Gjts_relief.nc
# earth_relief_01m.grd
# Step-5. Make color palette
gmt makecpt -Cglobe.cpt -V -T-9000/2000 > myocean.cpt
# Step-6. Make raster image
gmt grdimage jts_relief.nc -Cmyocean.cpt -R138/149/33/42 -JM16c \
    -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg136.0/33+w16.0c/0.4c+v+o0.3/0i+ml \
    -Rjts_relief.nc -J -Cmyocean.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --MAP_ANNOT_OFFSET=0.1c \
    -Baf+l"Color scale legend: depth and height elevations (m); color palette: 'globe'" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour jts_relief.nc -R -J -C1000 \
    -B+t"Japan Trench: cross-sectional profiles on two segments: southern (red) and northern (green)" \
    -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
	-Lx13c/-1.2c+c50+w200k+l"Mercator Projection. Scale (km)"+f \
	-Bpxg4f2a1 -Bpyg4f2a1 -Bsxg2 -Bsyg1 \
    --FONT=9p,Palatino-Roman,black \
	-UBL/-5p/-35p -O -K >> $ps
#
# NORTH
# Step-10. Select two points along the New Britain segment
cat << EOF > trenchJTn.txt
144.1 38.1
144.3 40.4
EOF
gmt psxy -Rjts_relief.nc -J -W2p,green trenchJTn.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Ggreen trenchJTn.txt -O -K >> $ps # points
# Step-13. Generate cross-track profiles 400 km long, spaced 20 km, sampled every 2km
#gmt grdtrack trenchRT.txt -Gpct_relief.nc -C400k/2k/20k+v -Sa+sstackPCTn.txt > tablePCTn.txt
gmt grdtrack trenchJTn.txt -Gjts_relief.nc -C400k/2k/20k -Sm+sstackJTn.txt > tableJTn.txt
gmt psxy -R -J -Wthin,green tableJTn.txt -O -K >> $ps
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackJTn.txt -o0,5 > envJTn.txt
gmt convert stackJTn.txt -o0,6 -I -T >> envJTn.txt
#
# SOUTH
# Step-11. Select two points along the San Cristobal segment
cat << EOF > trenchJTs.txt
143.1 36.3
144.1 38.1
EOF
gmt psxy -Rjts_relief.nc -J -W2p,red trenchJTs.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred trenchJTs.txt -O -K >> $ps # points
# Step-13. Generate cross-track profiles 400 km long, spaced 20 km, sampled every 2km
#gmt grdtrack trenchRT.txt -Grt_relief.nc -C400k/2k/20k+v -Sa+sstackRT.txt > tableRT.txt
gmt grdtrack trenchJTs.txt -Gjts_relief.nc -C400k/2k/20k -Sm+sstackJTs.txt > tableJTs.txt
gmt psxy -R -J -Wthin,red tableJTs.txt -O -K >> $ps
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackJTs.txt -o0,5 > envJTs.txt
gmt convert stackJTs.txt -o0,6 -I -T >> envJTs.txt
#
# Step-18. Add GMT logo
gmt logo -Dx6.5/-1.8+w2c -O -K >> $ps
# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y10.0c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 11.0 GEBCO DEM Global Relief Model 15 arc sec resolution grid
EOF
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert JTcross.ps -A0.5c -E720 -Tj -P -Z
#143.8 37.8
