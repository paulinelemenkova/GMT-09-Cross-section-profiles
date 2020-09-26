#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Cascadia Trench
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
#grdcut ETOPO1_Ice_g_gmt4.grd -R228/238/47/52 -Gct1_relief.nc
grdcut GEBCO_2019.nc -R228/238/47/52 -Gct1_relief.nc
gdalinfo ct1_relief.nc -stats
# Minimum=-3489.000, Maximum=3243.000

# Make color palette
gmt makecpt -Cterra -V -T-3489/3243 > myoceanCT.cpt

# Generate a file
ps=crossCT.ps

#  Make raster image
gmt grdimage ct1_relief.nc -CmyoceanCT.cpt -R228/238/47/52 -JM6i \
    -P -I+a15+ne0.75 -Xc -K > $ps
    
# Add color legend
gmt psscale -Dg316.6/-63+w14.3c/0.4c+v+o0.3/0i+ml -Rct1_relief.nc -J -CmyoceanCT.cpt \
	--FONT_LABEL=8p,Helvetica,black \
	--FONT_ANNOT_PRIMARY=8p,Helvetica,black \
	-Baf+l"Color scale: elevation. Washed-out colors for topography [R=-8239/2565, C=RGB]" \
    --MAP_TITLE_OFFSET=0.5c \
	-I0.2 -By+lm -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    -Lx13.0c/-0.5i+c50+w300k+l"Mercator projection. Scale (km)"+f \
    -Bpxg4f1a2 -Bpyg6f1a1 -Bsxg2 -Bsyg1 \
    --FONT=8p,Helvetica,black \
    -UBL/-15p/-35p -O -K >> $ps
    
# annotation
echo "228.5 51.5 B" | gmt pstext -R -J -F+jTL+f20p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour ct1_relief.nc -R -J -C1000 \
    -B+t"Cross-sectional profiles of the Cascadia Trench, Pacific Ocean. DEM: GEBCO" \
    --MAP_TITLE_OFFSET=0.5c \
    -W0.1p -O -K >> $ps
    
# Select two points
cat << EOF > trenchCT.txt
231.2 50.4
233.0 48.3
EOF

# Step-12. Plot trench segment and end points
gmt psxy -R -J -W2p,red trenchCT.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred trenchCT.txt -O -K >> $ps # points

# Generate cross-track profiles 400 km long, spaced 10 km, sampled every 2km
# and stack these using the mean, write stacked profile
#gmt grdtrack trenchSST.txt -Gsst_relief.nc -C400k/2k/10k+v -Sa+sstackSST.txt > tableSST.txt
# and stack these using the median, write stacked profile
gmt grdtrack trenchCT.txt -Gct1_relief.nc -C300k/2k/20k+v -Sm+sstackCT.txt > tableCT.txt
gmt psxy -R -J -W0.5p,white tableCT.txt -O -K >> $ps

# Show upper/lower values encountered as an envelope
gmt convert stackCT.txt -o0,5 > envCT.txt
gmt convert stackCT.txt -o0,6 -I -T >> envCT.txt

# Plot graph (statistical mean for the profiles)
gmt psxy -R-150/150/-3500/2500 -JX15.2c/5c -Y14.5c envCT.txt -W0.5p \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya1000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinner,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Helvetica,black -BWeSn \
	-Glightgray -O -K >> $ps
    
gmt psxy -R -J -W1.0p -Ey+p0.2p stackCT.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackCT.txt -O -K >> $ps

# Add test annotations
echo "27 -3000 Median stacked profile with error bars" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps
echo "-100 -1500 Pacific Plate " | gmt pstext -R -J -F+jBL+f10p,orangered4 -Gwhite -O -K >> $ps
echo "-50 1500 Cascadia Subduction Zone" | gmt pstext -R -J -F+f10p,orangered4+jBL -Gwhite -O -K >> $ps
echo "70 -1500 Vancouver Island" | gmt pstext -R -J -F+jBL+f10p,orangered4 -Gwhite -O -K >> $ps
echo "-140 1100 A" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps

# Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 1000 270 1.5c
EOF

# Step-18. Add GMT logo
gmt logo -Dx6.4/-16.2+0.25c/1.5c+w2c -O >> $ps

# Step-19. Clean up
#rm -f z.cpt trenchA2.txt tableA2.txt envA2.txt stackA2.txt
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert crossCT.ps -A0.2c -E720 -Tj -P -Z
#rm -f ct1_relief.nc
