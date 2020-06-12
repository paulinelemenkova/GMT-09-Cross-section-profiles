#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Hikurangi trench
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=Hcross.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1.0c \
    MAP_ANNOT_OFFSET=0.2c \
    MAP_TICK_PEN_PRIMARY=thinnest,dimgray \
    MAP_GRID_PEN_PRIMARY=thinner,white \
    MAP_GRID_PEN_SECONDARY=thin,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    FONT_LABEL=10p,Palatino-Roman,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of GEBCO for the Hikurangi trench
#grdcut GEBCO_2019.nc -R172/182/-44.5/-34 -Gh_relief.nc
grdcut earth_relief_01m.grd -R172/182/-44.5/-34 -Gh_relief.nc
# earth_relief_01m.grd
# Step-5. Make color palette
gmt makecpt -Crainbow.cpt -V -T-8000/1000 > ocean.cpt
# Step-6. Make raster image
gmt grdimage h_relief.nc -Cocean.cpt -R172/182/-44.5/-34 -JM12c \
    -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg169.5/-44.5+w16.5c/0.4c+v+o0.3/0i+ml \
    -Rh_relief.nc -J -Cocean.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --MAP_ANNOT_OFFSET=0.1c \
    -Baf+l"Elevations (m). Artificial CPT 'rainbow':  magenta-blue-cyan-green-yellow-red [C=HSV]" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour h_relief.nc -R -J -C500 \
    -B+t"Hikurangi Trench: cross-sectional profiles" \
    -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
	-Lx10.0c/-1.2c+c50+w300k+l"Mercator Projection. Scale (km)"+f \
	-Bpxg2f1a2 -Bpyg4f2a1 -Bsxg2 -Bsyg2 \
    --FONT=9p,Palatino-Roman,black \
	-UBL/-5p/-35p -O -K >> $ps
#
#NORTH
#cat << EOF > trenchHic.txt
#179.3 -38.4
#178.5 -40.2
#EOF
#gmt psxy -Rh_relief.nc -J -W2p,mediumblue trenchHic.txt -O -K >> $ps # my line
#gmt psxy -R -J -Sc0.15i trenchHic.txt -Gmediumblue -Wmediumblue -O -K >> $ps
# points
# Step-13. Cross-track profiles 400 km long, spaced 20 km, sampled every 2km
#gmt grdtrack trenchHic.txt -Gh_relief.nc -C400k/2k/20k+v \
    #-Sm+sstackHic.txt > tableHic.txt
#gmt psxy -R -J -Wthin,mediumblue tableHic.txt -O -K >> $ps
# Step-15. Show upper/lower values encountered as an envelope
#gmt convert stackHic.txt -o0,5 > envHic.txt
#gmt convert stackHic.txt -o0,6 -I -T >> envHic.txt
#
# SOUTH
#cat << EOF > trenchHis.txt
#177.0 -41.5
#174.2 -42.4
#EOF
cat << EOF > trenchHis.txt
177.0 -41.7
174.2 -42.6
EOF
gmt psxy -Rh_relief.nc -J -W2p,darkslateblue trenchHis.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i trenchHis.txt -Gdarkslateblue -Wdarkslateblue -O -K >> $ps # points
# Step-13. Cross-track profiles 400 km long, spaced 20 km, sampled every 2km
gmt grdtrack trenchHis.txt -Gh_relief.nc -C400k/2k/20k+v -Sm+sstackHis.txt > tableHis.txt
gmt psxy -R -J -Wthin,darkslateblue tableHis.txt -O -K >> $ps
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackHis.txt -o0,5 > envHis.txt
gmt convert stackHis.txt -o0,6 -I -T >> envHis.txt
#
# Step-18. Add GMT logo
gmt logo -Dx4.8/-2.2+w2c -O -K >> $ps
# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y10.0c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
0.8 11.0 GEBCO DEM Global Relief Model 15 arc sec resolution grid
EOF
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert Hcross.ps -A0.5c -E720 -Tj -P -Z
