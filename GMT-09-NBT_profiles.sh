#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the New Britain - San Cristobal trenches
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=crossNBT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=0.5c \
    MAP_ANNOT_OFFSET=0.2c \
    MAP_TICK_PEN_PRIMARY=thinnest,dimgray \
    MAP_GRID_PEN_PRIMARY=thinnest,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    FONT_LABEL=10p,Palatino-Roman,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of SRTM for the New Britain and San Cristobal trenches
grdcut topo15.grd -R149.0/161.0/-10.5/-2.0 -Gnbts_relief.nc
# Step-5. Make color palette
gmt makecpt -Cglobe -V -T-10000/2000 > myoceanPCT.cpt
# Step-6. Make raster image
gmt grdimage nbts_relief.nc -CmyoceanPCT.cpt -R149.0/161.0/-10.5/-2.0 -JM16c \
    -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg147.0/-10.5+w11.0c/0.4c+v+o0.3/0i+ml -Rnbts_relief.nc -J -CmyoceanPCT.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --MAP_ANNOT_OFFSET=0.1c \
	-Baf+l"Color scale legend: depth and height elevations (m)" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour nbts_relief.nc -R -J -C1000 \
-B+t"Cross-sectional profiles on two selected segments of trenches: New Britain (yellow) and San Cristobal (red)" \
    -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
	-Lx13c/-1.2c+c50+w300k+l"Mercator Projection. Scale (km)"+f \
	-Bpxg4f2a1 -Bpyg4f2a1 -Bsxg2 -Bsyg1 \
    --FONT=9p,Palatino-Roman,black \
	-UBL/-5p/-35p -O -K >> $ps
#
# New Britain segment
# Step-10. Select two points along the New Britain segment
cat << EOF > trenchNBT.txt
150.1 -7.0
152.3 -6.0
EOF
gmt psxy -Rnbts_relief.nc -J -W2p,yellow trenchNBT.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gyellow trenchNBT.txt -O -K >> $ps # points
# Step-13. Generate cross-track profiles 400 km long, spaced 20 km, sampled every 2km
#gmt grdtrack trenchRT.txt -Gpct_relief.nc -C400k/2k/20k+v -Sa+sstackPCTn.txt > tablePCTn.txt
gmt grdtrack trenchNBT.txt -Gnbts_relief.nc -C400k/2k/20k -Sm+sstackNBT.txt > tableNBT.txt
gmt psxy -R -J -Wthin,yellow tableNBT.txt -O -K >> $ps
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackNBT.txt -o0,5 > envNBT.txt
gmt convert stackNBT.txt -o0,6 -I -T >> envNBT.txt
#
# San Cristobal segment
# Step-11. Select two points along the San Cristobal segment
cat << EOF > trenchSCT.txt
153.5 -6.1
155.0 -7.4
EOF
#cat << EOF > trenchSCT.txt
#153.8 -6.3
#155.1 -7.3
#EOF
#
#154.0 -6.5
#155.5 -7.7
#EOF
#cat << EOF > trenchSCT.txt
#155.8 -7.8
#157.8 -9.2
#EOF
gmt psxy -Rnbts_relief.nc -J -W2p,red trenchSCT.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred trenchSCT.txt -O -K >> $ps # points
# Step-13. Generate cross-track profiles 400 km long, spaced 20 km, sampled every 2km
#gmt grdtrack trenchRT.txt -Grt_relief.nc -C400k/2k/20k+v -Sa+sstackRT.txt > tableRT.txt
gmt grdtrack trenchSCT.txt -Gnbts_relief.nc -C400k/2k/20k -Sm+sstackSCT.txt > tableSCT.txt
gmt psxy -R -J -Wthin,red tableSCT.txt -O -K >> $ps
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackSCT.txt -o0,5 > envSCT.txt
gmt convert stackSCT.txt -o0,6 -I -T >> envSCT.txt
#
# Step-18. Add GMT logo
gmt logo -Dx6.5/-1.8+w2c -O >> $ps
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert crossNBT.ps -A0.5c -E720 -Tj -P -Z
