#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Vanuatu and Vityaz trenches
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=VVTcross.ps
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
grdcut GEBCO_2019.nc -R162.5/-24/181.5/-6.0r -Gvvt_relief.nc
#grdcut earth_relief_01m.grd -R162.5/-24/181.5/-6.0r -Gvvt_relief.nc
# earth_relief_01m.grd
# Step-5. Make color palette
gmt makecpt -Crelief.cpt -V -T-11000/1000 > VVocean.cpt
# Step-6. Make raster image
gmt grdimage vvt_relief.nc -CVVocean.cpt -R162.5/-24/181.5/-6.0r -JM16c \
    -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg159.0/-24+w16.0c/0.4c+v+o0.3/0i+ml \
    -Rvvt_relief.nc -J -CVVocean.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --MAP_ANNOT_OFFSET=0.1c \
-Baf+l"Elevations (m). CPT 'relief': Wessel/Martinez colors for topography [R=-8000/+8000, H=0, C=RGB]" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour vvt_relief.nc -R -J -C1000 \
    -B+t"Vanuatu and Vityaz trenches: cross-sectional profiles" \
    -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
	-Lx13c/-1.2c+c50+w500k+l"Mercator Projection. Scale (km)"+f \
	-Bpxg4f2.5a5 -Bpyg4f2.5a5 -Bsxg2.5 -Bsyg5 \
    --FONT=9p,Palatino-Roman,black \
	-UBL/-5p/-35p -O -K >> $ps
# texts
gmt pstext -R -J -N -O -K \
-F+f12p,Helvetica−Bold,blue+jLB+a-32 -Gwhite@30>> $ps << EOF
171.5 -10.4 Vityaz Trench
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Helvetica−Bold,blue+jLB+a-76 -Gwhite@41 >> $ps << EOF
166.4 -11.5 Vanuatu (New Hebrides) Trench
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
177.8 -17.3 FIJI
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Helvetica−Bold,black+jLB -Gwhite@30 >> $ps << EOF
171.5 -16.0 NORTH FIJI
172.0 -16.6 BASIN
180 -18.0 Lau
180 -18.5 Basin
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Helvetica−Bold,black+jLB -Gwhite@30 >> $ps << EOF
165 -17.2 North
165 -17.6 Loyalty
165 -18.1 Basin
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Helvetica−Bold,black+jLB -Gwhite@30 >> $ps << EOF
162.8 -13.4 West
162.8 -13.8 Torres
162.8 -14.2 Massif
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Helvetica−Bold,black+jLB+a-41 -Gwhite@35 >> $ps << EOF
163 -20.5 New Caledonia
164.5 -19.5 Loyalty Ridge
EOF
#
# VANUATU segment (south)
# Step-10.
cat << EOF > trenchVTs.txt
167.8 -19.4
169.2 -21.5
EOF
gmt psxy -Rvvt_relief.nc -J -W2p,magenta trenchVTs.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i trenchVTs.txt -Gmagenta -Wmagenta -O -K >> $ps # points
# Step-13. Generate cross-track profiles 400 km long, spaced 20 km, sampled every 2km
#gmt grdtrack trenchRT.txt -Gpct_relief.nc -C400k/2k/20k+v -Sa+sstackPCTn.txt > tablePCTn.txt
gmt grdtrack trenchVTs.txt -Gvvt_relief.nc -C400k/2k/20k -Sm+sstackVTs.txt > tableVTs.txt
gmt psxy -R -J -Wthin,magenta tableVTs.txt -O -K >> $ps
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackVTs.txt -o0,5 > envVTs.txt
gmt convert stackVTs.txt -o0,6 -I -T >> envVTs.txt
#
# VITYAZ segment (north)
# Step-11. Select two points
#cat << EOF > trenchVTn.txt
#168.2 -8.8
#171.8 -11.0
#EOF
cat << EOF > trenchVTn.txt
168.2 -8.7
170.8 -10.5
EOF
gmt psxy -Rvvt_relief.nc -J -W2p,red trenchVTn.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred -Wred trenchVTn.txt -O -K >> $ps # points
# Step-13. Generate cross-track profiles 400 km long, spaced 20 km, sampled every 2km
#gmt grdtrack trenchRT.txt -Grt_relief.nc -C400k/2k/20k+v -Sa+sstackRT.txt > tableRT.txt
gmt grdtrack trenchVTn.txt -Gvvt_relief.nc -C400k/2k/20k+v -Sm+sstackVTn.txt > tableVTn.txt
gmt psxy -R -J -Wthin,red tableVTn.txt -O -K >> $ps
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackVTn.txt -o0,5 > envVTn.txt
gmt convert stackVTn.txt -o0,6 -I -T >> envVTn.txt
#
# Step-18. Add GMT logo
gmt logo -Dx6.5/-1.8+w2c -O -K >> $ps
# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y9.5c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 11.0 GEBCO DEM Global Relief Model 15 arc sec resolution grid
EOF
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert VVTcross.ps -A0.5c -E720 -Tj -P -Z
#143.8 37.8
