#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Sunda Trench (Sumatra segment)
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makeHT, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat

# GMT set up
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
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

# Extract a subset of ETOPO1m
#grdcut ETOPO1_Ice_g_gmt4.grd -R90/107/-8/2 -Gsts_relief.nc
grdcut GEBCO_2019.nc -R90/107/-8/2 -Gsts_relief.nc
gdalinfo sts_relief.nc -stats
# Minimum=-7164.000, Maximum=3403.000

# Make color palette
gmt makecpt -Cglobe -V -T-7164/3403 > myocean.cpt

# Generate a file
ps=crossSTS.ps

#  Make raster image
gmt grdimage sts_relief.nc -Cmyocean.cpt -R90/107/-8/2 -JM6i \
    -P -I+a15+ne0.75 -Xc -K > $ps
    
# Add color legend
gmt psscale -Dg87.5/-8+w9.0c/0.4c+v+o0.3/0i+ml -Rsts_relief.nc -J -Cmyocean.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=7p,Helvetica,black \
	-Baf+l"Colors for global bathymetry/topography relief [R=-7164/3403, H=0, C=RGB]" \
    --MAP_TITLE_OFFSET=0.5c \
	-I0.2 -By+lm -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    -Lx13.0c/-0.5i+c50+w300k+l"Mercator projection. Scale (km)"+f \
    -Bpxg2f1a2 -Bpyg2f1a2 -Bsxg1 -Bsyg1 \
    --FONT=9p,Helvetica,black \
    -UBL/-5p/-35p -O -K >> $ps

# Add shorelines
gmt grdcontour sts_relief.nc -R -J -C1000 \
    -B+t"Cross-sectional profiles of the Sunda Trench, Sumatra segment. DEM: GEBCO" \
    --MAP_TITLE_OFFSET=0.5c \
    -W0.1p -O -K >> $ps

# annotation
echo "90.5 1.0 B" | gmt pstext -R -J -F+jBL+f20p,black -Gfloralwhite -W0.5p -O -K >> $ps
    
# Select two points along the Sunda Trench
cat << EOF > trenchSTS.txt
97.5 -1.1
101.0 -5.5
EOF

# Plot trench segment and end points
gmt psxy -R -J -W2p,red trenchSTS.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred trenchSTS.txt -O -K >> $ps # points

# Generate cross-track profiles 200 km long, sampled every 2km, spaced 10 km
# and stack these using the mean, write stacked profile
gmt grdtrack trenchSTS.txt -Gsts_relief.nc -C500k/2k/10k+v -Sm+sstackSTS.txt > tableSTS.txt
gmt psxy -R -J -W0.5p,yellow tableSTS.txt -O -K >> $ps

# Show upper/lower values encountered as an envelope
gmt convert stackSTS.txt -o0,5 > envSTS.txt
gmt convert stackSTS.txt -o0,6 -I -T >> envSTS.txt

# Plot graph (statistical mean for the profiles)
gmt psxy -R-250/250/-7200/1000 -JX15.2c/5c -Y11.5c envSTS.txt -W0.5p \
    -Bpxa50g100f10+l"Distance from trench (km)"\
    -Bpya1000gf500+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinner,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
	-Glightgray -O -K >> $ps
    
gmt psxy -R -J -W1.0p -Ey+p0.2p stackSTS.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackSTS.txt -O -K >> $ps

# Add test annotations
echo "-230 -3000 Median stacked profile with error bars" | gmt pstext -R -J -Gwhite -F+jBL+f10p,Helvetica,red -O -K >> $ps
echo "110 -6500 Eurasian Plate " | gmt pstext -R -J -F+jBL+f12p,Helvetica,orangered4 -Gwhite -O -K >> $ps
echo "-220 -6500 Australian Plate " | gmt pstext -R -J -F+jBL+f12p,Helvetica,orangered4 -Gwhite -O -K >> $ps
echo "-50 -200 Sunda Trench" | gmt pstext -R -J -F+f12p,Helvetica,orangered4+jBL -Gwhite -O -K >> $ps
echo "-230 -500 A" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps

# Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 -1000 270 1.7c
EOF

# Add GMT logo
gmt logo -Dx6.4/-13.2+0.25c/1.5c+w2c -O >> $ps

# Clean up
#rm -f z.HT trenchA2.txt tableA2.txt envA2.txt stackA2.txt
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert crossSTS.ps -A0.2c -E720 -Tj -P -Z
