#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Izu-Bonin trench
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=IBTcross.ps
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
 grdcut GEBCO_2019.nc -R138/148/26/35 -Gib_relief.nc
# grdcut earth_relief_01m.grd -R138/148/26/35 -Gib_relief.nc
# earth_relief_01m.grd
# Step-5. Make color palette
gmt makecpt -Ctopo.cpt -V -T-9000/0 > myocean.cpt
# Step-6. Make raster image
gmt grdimage ib_relief.nc -Cmyocean.cpt -R138/148/26/35 -JM16c \
    -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg136.2/26+w16.5c/0.4c+v+o0.3/0i+ml \
    -Rib_relief.nc -J -Cmyocean.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --MAP_ANNOT_OFFSET=0.1c \
-Baf+l"Color scale legend, elevations (m); CPT: 'topo', Sandwell/Anderson colors for topography [R=-7000/+7000, H=0, C=HSV]" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour ib_relief.nc -R -J -C1000 \
    -B+t"Izu-Bonin Trench: cross-sectional profiles in two segments" \
    -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
	-Lx13c/-1.2c+c50+w200k+l"Mercator Projection. Scale (km)"+f \
	-Bpxg4f2a1 -Bpyg4f2a1 -Bsxg2 -Bsyg1 \
    --FONT=9p,Palatino-Roman,black \
	-UBL/-5p/-35p -O -K >> $ps
#
# SOUTHERN segment
# Step-10.
cat << EOF > trenchIBTs.txt
143.1 28.5
142.3 30.5
EOF
gmt psxy -Rib_relief.nc -J -W2p,darkmagenta trenchIBTs.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i trenchIBTs.txt -Gyellow -Wdarkmagenta -O -K >> $ps # points
# Step-13. Generate cross-track profiles 400 km long, spaced 20 km, sampled every 2km
#gmt grdtrack trenchRT.txt -Gpct_relief.nc -C400k/2k/20k+v -Sa+sstackPCTn.txt > tablePCTn.txt
gmt grdtrack trenchIBTs.txt -Gib_relief.nc -C400k/2k/20k -Sm+sstackIBTs.txt > tableIBTs.txt
gmt psxy -R -J -Wthin,darkmagenta tableIBTs.txt -O -K >> $ps
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackIBTs.txt -o0,5 > envIBTs.txt
gmt convert stackIBTs.txt -o0,6 -I -T >> envIBTs.txt
#
# NORTHERN segment
# Step-11. Select two points
cat << EOF > trenchIBTn.txt
142.2 31.3
142.0 33.8
EOF
gmt psxy -Rib_relief.nc -J -W2p,red trenchIBTn.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gyellow -Wred trenchIBTn.txt -O -K >> $ps # points
# Step-13. Generate cross-track profiles 400 km long, spaced 20 km, sampled every 2km
#gmt grdtrack trenchRT.txt -Grt_relief.nc -C400k/2k/20k+v -Sa+sstackRT.txt > tableRT.txt
gmt grdtrack trenchIBTn.txt -Gib_relief.nc -C400k/2k/20k -Sm+sstackIBTn.txt > tableIBTn.txt
gmt psxy -R -J -Wthin,red tableIBTn.txt -O -K >> $ps
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackIBTn.txt -o0,5 > envIBTn.txt
gmt convert stackIBTn.txt -o0,6 -I -T >> envIBTn.txt
#
# Step-18. Add GMT logo
gmt logo -Dx6.5/-1.8+w2c -O -K >> $ps
# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y10.3c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 11.0 GEBCO DEM Global Relief Model 15 arc sec resolution grid
EOF
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert IBTcross.ps -A0.5c -E720 -Tj -P -Z
#143.8 37.8
