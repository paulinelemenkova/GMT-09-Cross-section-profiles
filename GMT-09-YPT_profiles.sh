#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Yap and Palau trenches
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=YPTcross.ps
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
# Step-4. Extract a subset of SRTM for the Yap and Palau trenches
grdcut topo15.grd -R132/140/4/12 -Gypts_relief.nc
# Step-5. Make color palette
gmt makecpt -Cglobe -V -T-11000/2000 > myocean.cpt
# Step-6. Make raster image
gmt grdimage ypts_relief.nc -Cmyocean.cpt -R132/140/4/12 -JM16c \
    -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg130.5/4+w15.8c/0.4c+v+o0.3/0i+ml \
    -R132/140/4/12 -J -Cmyocean.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --MAP_ANNOT_OFFSET=0.1c \
	-Baf+l"Color scale legend: depth and height elevations (m). Color palette: 'globe'" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour ypts_relief.nc -R -J -C1000 \
-B+t"Cross-sectional profiles of two trench segments: Yap (yellow) and Palau (red)" \
    -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
	-Lx13c/-1.2c+c50+w200k+l"Mercator Projection. Scale (km)"+f \
	-Bpxg4f2a1 -Bpyg4f2a1 -Bsxg2 -Bsyg1 \
    --FONT=9p,Palatino-Roman,black \
	-UBL/-5p/-35p -O -K >> $ps
# texts
gmt pstext -R -J -N -O -K \
-F+f12p,Times-Roman,black+jLB -Gwhite@20 -Wthinnest,darkbrown >> $ps << EOF
138.0 8.0 Yap Trench
133.8 6.0 Palau Trench
EOF
#
# YAP
# Step-10. Select two points along the Yap Trench
cat << EOF > trenchYT.txt
136.9 7.3
137.7 7.9
EOF
gmt psxy -Rypts_relief.nc -J -W2p,yellow trenchYT.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gyellow trenchYT.txt -O -K >> $ps # points
# Step-13. Generate cross-track profiles 400 km long, spaced 20 km, sampled every 2km
#gmt grdtrack trenchRT.txt -Gpct_relief.nc -C400k/2k/20k+v -Sa+sstackPCTn.txt > tablePCTn.txt
gmt grdtrack trenchYT.txt -Gypts_relief.nc -C400k/2k/20k -Sm+sstackYT.txt > tableYT.txt
gmt psxy -R -J -Wthin,yellow tableYT.txt -O -K >> $ps
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackYT.txt -o0,5 > envYT.txt
gmt convert stackYT.txt -o0,6 -I -T >> envYT.txt
#
# PALAU
# Step-11. Select two points along the Palau Trench
cat << EOF > trenchPT.txt
134.4 6.6
135.0 7.3
EOF
gmt psxy -Rypts_relief.nc -J -W2p,red trenchPT.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred trenchPT.txt -O -K >> $ps # points
# Step-13. Generate cross-track profiles 400 km long, spaced 20 km, sampled every 2km
#gmt grdtrack trenchRT.txt -Grt_relief.nc -C400k/2k/20k+v -Sa+sstackRT.txt > tableRT.txt
gmt grdtrack trenchPT.txt -Gypts_relief.nc -C400k/2k/20k -Sm+sstackPT.txt > tablePT.txt
gmt psxy -R -J -Wthin,red tablePT.txt -O -K >> $ps
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackPT.txt -o0,5 > envPT.txt
gmt convert stackPT.txt -o0,6 -I -T >> envPT.txt
#
# Step-18. Add GMT logo
gmt logo -Dx6.5/-1.8+w2c -O -K >> $ps
# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y9.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 11.0 SRTM DEM Global Relief Model 15 arc sec resolution grid
EOF
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert YPTcross.ps -A1.0c -E720 -Tj -P -Z
