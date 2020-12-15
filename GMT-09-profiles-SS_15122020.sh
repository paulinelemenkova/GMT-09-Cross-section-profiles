#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the South Sandwich Trench
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
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
#gmt grdcut ETOPO1_Ice_g_gmt4.grd -R320/340/-63/-53 -Gsst_relief.nc
gmt grdcut GEBCO_2019.nc -R320/340/-63/-53 -Gsst_relief.nc
gdalinfo sst_relief.nc -stats

# Generate a file
ps=crossSST.ps

# Make color palette
gmt makecpt -Celevation -V -T-8239/2565 > myoceanSST.cpt

#  Make raster image
gmt grdimage sst_relief.nc -CmyoceanSST.cpt -R320/340/-63/-53 -JM6i \
    -P -I+a15+ne0.75 -Xc -K > $ps
    
# Add color legend
#gmt psscale -Dg317/-63+w14.3c/0.4c+v+o0.3/0i+ml -Rsst_relief.nc -J -CmyoceanSST.cpt \
	--FONT_LABEL=9p,Helvetica,black \
	--FONT_ANNOT_PRIMARY=8p,Helvetica,black \
	-Baf \
    --MAP_TITLE_OFFSET=0.5c \
    --MAP_FRAME_AXES=WESN \
	-I0.2 -By+lm -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    -Lx13.0c/-0.5i+c50+w400k+l"Mercator projection. Scale (km)"+f \
    -Bpxg4f1a4 -Bpyg6f1a2 -Bsxg2 -Bsyg2 \
    --FONT=10p,Helvetica,black \
    -O -K >> $ps
    
# annotation
echo "338.7 -53.5 B" | gmt pstext -R -J -F+jTL+f20p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour sst_relief.nc -R -J -C1000 \
    -B+t"Cross-sectional profiles of the South Sandwich Trench (GEBCO Compilation Group, 2020)" \
    --MAP_TITLE_OFFSET=0.5c \
    -W0.1p -O -K >> $ps
    
# Select two points along the South Sandwich Trench
cat << EOF > trenchSST.txt
335.0 -56.0
336.5 -58.2
EOF

# Step-12. Plot trench segment and end points
#gmt psxy -Rsst_relief.nc -J -W2p,red trenchSST.txt -O -K >> $ps # my line
#gmt psxy -R -J -Sc0.15i -Gred trenchSST.txt -O -K >> $ps # points

# Generate cross-track profiles 400 km long, spaced 10 km, sampled every 2km
# and stack these using the mean, write stacked profile
#gmt grdtrack trenchSST.txt -Gsst_relief.nc -C400k/2k/10k+v -Sa+sstackSST.txt > tableSST.txt
# and stack these using the median, write stacked profile
gmt grdtrack trenchSST.txt -Gsst_relief.nc -C300k/2k/20k+v -Sm+sstackSST.txt > tableSST.txt
gmt psxy -R -J -W0.7p,red tableSST.txt -O -K >> $ps

# Show upper/lower values encountered as an envelope
gmt convert stackSST.txt -o0,5 > envSST.txt
gmt convert stackSST.txt -o0,6 -I -T >> envSST.txt

# Plot graph (statistical mean for the profiles)
gmt psxy -R-150/150/-8500/0 -JX15.2c/5c -Y17.0c envSST.txt -W0.5p \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya1000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --MAP_FRAME_AXES=wESN \
    --FONT_ANNOT_PRIMARY=9p,Helvetica,black \
    --MAP_ANNOT_OFFSET=0.1c \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinner,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Helvetica,black -BWeSn \
	-Glightgray -O -K >> $ps
    
gmt psxy -R -J -W1.0p -Ey+p0.2p stackSST.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackSST.txt -O -K >> $ps

# Add test annotations
echo "10 -550 Median stacked profile: red line" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps
echo "10 -1550 Error bars: grey vertical lines" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps
echo "10 -2550 Upper/lower values: max/min envelope" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps

echo "-130 -7000 South Sandwich Plate " | gmt pstext -R -J -F+jBL+f11p,orangered4 -Gwhite -O -K >> $ps
echo "-80 -750 South Sandwich Trench" | gmt pstext -R -J -F+f11p,orangered4+jBL -Gwhite -O -K >> $ps
echo "50 -7000 South American Plate" | gmt pstext -R -J -F+jBL+f11p,orangered4 -Gwhite -O -K >> $ps
echo "130 -500 A" | gmt pstext -R -J -F+jTL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps

# Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O << EOF >> $ps
0 -1000 270 2.0c
EOF

# Step-19. Clean up
#rm -f z.cpt trenchA2.txt tableA2.txt envA2.txt stackA2.txt
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert crossSST.ps -A0.2c -E720 -Tj -P -Z
