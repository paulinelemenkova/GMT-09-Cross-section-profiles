#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Hellenic Trench
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
#grdcut ETOPO1_Ice_g_gmt4.grd -R21/28/33/37 -Ght_relief1.nc
grdcut GEBCO_2019.nc -R21/28/33/37 -Ght_relief1.nc
gdalinfo ht_relief1.nc -stats
# -5120.85009765625,2359.875

# Make color palette
gmt makecpt -Cterra -V -T-5121/2360 > myoceanHT.cpt

# Generate a file
ps=crossHT.ps

#  Make raster image
gmt grdimage ht_relief1.nc -CmyoceanHT.cpt -R21/28/33/37 -JM6i \
    -P -I+a15+ne0.75 -Xc -K > $ps
    
# Add color legend
gmt psscale -Dg19.7/33+w11.3c/0.4c+v+o0.3/0i+ml -Rht_relief1.nc -J -CmyoceanHT.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=7p,Helvetica,black \
	-Baf+l"Colors for global bathymetry/topography relief [R=-7000/7000, H=0, C=RGB]" \
    --MAP_TITLE_OFFSET=0.5c \
	-I0.2 -By+lm -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    -Lx13.0c/-0.5i+c50+w100k+l"Mercator projection. Scale (km)"+f \
    -Bpxg2f1a1 -Bpyg2f1a1 -Bsxg0.5 -Bsyg0.5 \
    --FONT=9p,Helvetica,black \
    -UBL/-15p/-35p -O -K >> $ps

# Add shorelines
gmt grdcontour ht_relief1.nc -R -J -C1000 \
    -B+t"Cross-sectional profiles of the Hellenic Trench, Mediterranean Sea. DEM: GEBCO" \
    --MAP_TITLE_OFFSET=0.5c \
    -W0.1p -O -K >> $ps

# annotation
echo "21.3 33.3 B" | gmt pstext -R -J -F+jBL+f20p,black -Gfloralwhite -W0.5p -O -K >> $ps
    
# Select two points along the Hellenic Trench
cat << EOF > trenchHT.txt
22.2 35.9
23.2 35.3
EOF

# Step-12. Plot trench segment and end points
gmt psxy -R -J -W2p,red trenchHT.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred trenchHT.txt -O -K >> $ps # points

# Generate cross-track profiles 200 km long, sampled every 2km, spaced 10 km
# and stack these using the mean, write stacked profile
gmt grdtrack trenchHT.txt -Ght_relief1.nc -C200k/2k/10k+v -Sm+sstackHT.txt > tableHT.txt
gmt psxy -R -J -W0.5p,white tableHT.txt -O -K >> $ps

# Show upper/lower values encountered as an envelope
gmt convert stackHT.txt -o0,5 > envHT.txt
gmt convert stackHT.txt -o0,6 -I -T >> envHT.txt

# Plot graph (statistical mean for the profiles)
gmt psxy -R-100/100/-6000/1500 -JX15.2c/5c -Y13.0c envHT.txt -W0.5p \
    -Bpxa20g100f10+l"Distance from trench (km)"\
    -Bpya1000gf500+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinner,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
	-Glightgray -O -K >> $ps
    
gmt psxy -R -J -W1.0p -Ey+p0.2p stackHT.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackHT.txt -O -K >> $ps

# Add test annotations
echo "-90 -1900 Median stacked profile with error bars" | gmt pstext -R -J -Gwhite -F+jBL+f10p,Helvetica,red -O -K >> $ps
echo "51 -4700 Aegean Sea Plate " | gmt pstext -R -J -F+jBL+f12p,Helvetica,orangered4 -Gwhite -O -K >> $ps
echo "-80 -4800 African Plate " | gmt pstext -R -J -F+jBL+f12p,Helvetica,orangered4 -Gwhite -O -K >> $ps
echo "-15 500 Hellenic Trench" | gmt pstext -R -J -F+f12p,Helvetica,orangered4+jBL -Gwhite -O -K >> $ps
echo "75 1000 Kythira" | gmt pstext -R -J -F+jBL+f10p,orangered4 -Gwhite -O -K >> $ps
echo "78 450 Island" | gmt pstext -R -J -F+jBL+f10p,orangered4 -Gwhite -O -K >> $ps
echo "-95 -5000 A" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps

# Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 0 270 1.5c
EOF

# Step-18. Add GMT logo
gmt logo -Dx6.4/-15.0+0.25c/1.5c+w2c -O >> $ps

# Step-19. Clean up
#rm -f z.HT trenchA2.txt tableA2.txt envA2.txt stackA2.txt
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert crossHT.ps -A0.2c -E720 -Tj -P -Z
