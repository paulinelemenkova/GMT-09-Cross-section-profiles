#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Puerto Rico Trench
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
#grdcut ETOPO1_Ice_g_gmt4.grd -R290/305/15/25 -Gprt_relief.nc
grdcut GEBCO_2019.nc -R290/305/15/25 -Gprt_relief.nc
gdalinfo prt_relief.nc -stats
# Minimum=-8497.000, Maximum=1229.000

# Generate a file
ps=crossPRT.ps

# Make color palette
gmt makecpt -Celevation -V -T-8497/1229 > myoceanPRT.cpt

# Make raster image
gmt grdimage prt_relief.nc -CmyoceanPRT.cpt -R290/305/15/25 -JM6i \
    -P -I+a15+ne0.75 -Xc -K > $ps
    
# Add color legend
gmt psscale -Dg288/15+w10.7c/0.4c+v+o0.3/0i+ml -Rprt_relief.nc -J -CmyoceanPRT.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=6p,Helvetica,dimgray \
	-Baf+l"Color scale: Washed-out colors for topography [R=-8497/1229, C=RGB]" \
    --MAP_TITLE_OFFSET=0.5c \
	-I0.2 -By+lm -O -K >> $ps

# Add shorelines
gmt grdcontour prt_relief.nc -R -J -C500 \
    -B+t"Puerto Rico Trench: cross-sectional profiles on the selected segment. DEM: GEBCO" \
    --MAP_TITLE_OFFSET=0.5c \
    -W0.1p -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
	-Lx13.0c/-0.5i+c50+w300k+l"Mercator projection. Scale (km)"+f \
	-Bpxg4f1a2 -Bpyg6f1a2 -Bsxg2 -Bsyg2 \
    --FONT=8p,Palatino-Roman,dimgray \
	-UBL/-15p/-35p -O -K >> $ps

# annotation
echo "304.0 24.5 B" | gmt pstext -R -J -F+jTL+f20p,black -Gfloralwhite -W0.5p -O -K >> $ps
    
# Add directional rose
gmt psbasemap -R -J \
    --FONT=7p,Helvetica,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx0.7c/0.7c+w0.3i+f2+l+o0.15i -O -K >> $ps
    
# Select two points along the Puerto Rico Trench
cat << EOF > trenchPRT.txt
292.5 19.9
#295.5 19.85
#295.5 19.84
#295.9 19.83
295.9 19.82
EOF

# Plot trench segment and end points
gmt psxy -Rprt_relief.nc -J -W2p,red trenchPRT.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred trenchPRT.txt -O -K >> $ps # points

# Generate cross-track profiles 400 km long, spaced 10 km, sampled every 2km
# and stack these using the mean, write stacked profile
gmt grdtrack trenchPRT.txt -Gprt_relief.nc -C300k/2k/20k+v -Sm+sstackPRT.txt > tablePRT.txt
gmt psxy -R -J -W0.5p,blue tablePRT.txt -O -K >> $ps

# Show upper/lower values encountered as an envelope
gmt convert stackPRT.txt -o0,5 > envPRT.txt
gmt convert stackPRT.txt -o0,6 -I -T >> envPRT.txt

# Plot graph (statistical mean for the profiles)
gmt psxy -R-150/150/-10000/1000 -JX15.2c/5c -Y13.0c envPRT.txt -W0.5p \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya1000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinner,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
	-Glightgray -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackPRT.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackPRT.txt -O -K >> $ps

# Add test annotations
echo "25 -3000 Median stacked profile with error bars" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps
echo "60 -7500 North American Plate " | gmt pstext -R -J -F+jBL+f10p,orangered4 -Gwhite -O -K >> $ps
echo "-40 200 Puerto Rico Trench" | gmt pstext -R -J -F+f10p,orangered4+jBL -Gwhite -O -K >> $ps
echo "5 -800 segment coordinates" | gmt pstext -R -J -F+f10p,orangered4+jBL -Gwhite -O -K >> $ps
echo "5 -1800 67.5\232W 19.9\232N to 64.1\232W,19.82\232N" | gmt pstext -R -J -F+f10p,orangered4+jBL -Gwhite -O -K >> $ps
echo "-140 -7500 Caribbean" | gmt pstext -R -J -F+jBL+f10p,orangered4 -Gwhite -O -K >> $ps
echo "-140 -8200 Plate" | gmt pstext -R -J -F+jBL+f10p,orangered4 -Gwhite -O -K >> $ps
echo "130 500 A" | gmt pstext -R -J -F+jTL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps

# Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 -500 270 2.0c
EOF
# Step-18. Add GMT logo
gmt logo -Dx6.2/-14.7+0.25c/1.5c+w2c -O >> $ps
# Step-19. Clean up
#rm -f z.cpt trenchA2.txt tableA2.txt envA2.txt stackA2.txt
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert crossPRT.ps -A0.2c -E720 -Tj -P -Z
