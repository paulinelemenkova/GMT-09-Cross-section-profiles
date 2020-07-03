#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Puysegur and Hjort trenches
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat

# GMT set up
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
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

# Extract a subset of SRTM for the Puysegur and Hjort trenches
grdcut GEBCO_2019.nc -R154/168/-60/-46 -Ghpt_relief.nc
#grdcut ETOPO1_Ice_g_gmt4.grd -R154/168/-60/-46 -Ghpt_relief.nc

# Make color palette
gmt makecpt -Crelief -V -T-8000/1000 > ocean.cpt

# Generate a file
ps=HPTcross.ps

# Make raster image
gmt grdimage hpt_relief.nc -Cocean.cpt -R154/168/-60/-46 -JM12c \
    -P -I+a15+ne0.75 -Xc -K > $ps

# Add color legend
gmt psscale -Dg150.2/-60+w20.0c/0.4c+v+o0.3/0i+ml \
    -Rhpt_relief.nc -J -Cocean.cpt \
	--FONT_LABEL=11p,Helvetica,black \
	--FONT_ANNOT_PRIMARY=10p,Helvetica,black \
    --MAP_ANNOT_OFFSET=0.1c \
    -Baf+l"Elevations (m). CPT 'relief': Wessel/Martinez colors for topography [R=-6482/1135, H=0, C=RGB]" \
	-I0.2 -By+lm -O -K >> $ps
    
# Add shorelines
gmt grdcontour hpt_relief.nc -R -J -C1000 \
    -B+t"Puysegur and Hjort trenches: cross-sectional profiles" \
    --FONT_TITLE=16p,Helvetica,black \
    --MAP_TITLE_OFFSET=0.9c \
    -W0.1p -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
	-Lx9.5c/-1.4c+c50+w400k+l"Mercator Projection. Scale (km)"+f \
	-Bpxg4f2a2 -Bpyg4f2a1 -Bsxg4 -Bsyg2 \
    --FONT_TITLE=15p,Helvetica,black \
    --FONT_LABEL=10p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=10p,Helvetica,black \
	-UBL/-5p/-35p -O -K >> $ps
#
# HJORT segment (south)
cat << EOF > trenchH.txt
157.5 -57.8
157.8 -58.7
EOF
gmt psxy -Rhpt_relief.nc -J -W2p,magenta trenchH.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i trenchH.txt -Gmagenta -Wmagenta -O -K >> $ps # points

# Generate cross-track profiles 400 km long, spaced 20 km, sampled every 2km
gmt grdtrack trenchH.txt -Ghpt_relief.nc -C400k/2k/20k -Sm+sstackH.txt > tableH.txt
gmt psxy -R -J -Wthin,magenta tableH.txt -O -K >> $ps

# Show upper/lower values encountered as an envelope
gmt convert stackH.txt -o0,5 > envH.txt
gmt convert stackH.txt -o0,6 -I -T >> envH.txt

# PUYSEGUR segment (north)
# Select two points
cat << EOF > trenchP.txt
164.75 -47.2
164.2 -48.8
EOF
gmt psxy -Rhpt_relief.nc -J -W2p,red trenchP.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred -Wred trenchP.txt -O -K >> $ps # points

# Generate cross-track profiles 400 km long, spaced 20 km, sampled every 2km
gmt grdtrack trenchP.txt -Ghpt_relief.nc -C400k/2k/20k+v -Sm+sstackP.txt > tableP.txt
gmt psxy -R -J -Wthin,red tableP.txt -O -K >> $ps

# Show upper/lower values encountered as an envelope
gmt convert stackP.txt -o0,5 > envP.txt
gmt convert stackP.txt -o0,6 -I -T >> envP.txt

# Add GMT logo
gmt logo -Dx4.8/-2.2+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y13.8c -N -O \
    -F+f12p,Helvetica,black+jLB >> $ps << EOF
0.0 10.8 GEBCO DEM Global Relief Model 15 arc sec resolution grid
EOF
# Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert HPTcross.ps -A1.0c -E720 -Tj -P -Z
