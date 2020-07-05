#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Cayman Trough
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
#grdcut ETOPO1_Ice_g_gmt4.grd -R270/287/15/25 -Gcmt_relief.nc
# -R270/305/7/25
grdcut GEBCO_2019.nc -R270/287/15/25 -Gcmt_relief.nc
gdalinfo cmt_relief.nc -stats
#  Minimum=-8239.000, Maximum=2789.000

# Generate a file
ps=crossCMT.ps

# Make color palette
#gmt makecpt -Celevation -V -T-8239/2789 > myoceanCMT.cpt
gmt makecpt -Crelief -V -T-8239/2789 > myoceanCMT.cpt

# Make raster image
gmt grdimage cmt_relief.nc -CmyoceanCMT.cpt -R270/287/15/25 -JM6i \
    -P -I+a15+ne0.75 -Xc -K > $ps
    
# Add color legend
gmt psscale -Dg268/15+w9.5c/0.4c+v+o0.3/0i+ml -Rcmt_relief.nc -J -CmyoceanCMT.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=6p,Helvetica,dimgray \
	-Baf+l"Scale: 'relief', Wessel/Martinez colors for topography [R=-8239/2789, H=0, C=RGB]" \
    --MAP_TITLE_OFFSET=0.5c \
	-I0.2 -By+lm -O -K >> $ps

# Add shorelines
gmt grdcontour cmt_relief.nc -R -J -C500 \
    -B+t"Cayman Trough: cross-sectional profiles on the selected segment. DEM: GEBCO" \
    --MAP_TITLE_OFFSET=0.5c \
    -W0.1p -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
	-Lx13.0c/-0.5i+c50+w300k+l"Mercator projection. Scale (km)"+f \
	-Bpxg4f1a2 -Bpyg6f1a2 -Bsxg2 -Bsyg2 \
    --FONT=8p,Palatino-Roman,dimgray \
	-UBL/-15p/-35p -O -K >> $ps

# annotation
echo "286.0 24.0 B" | gmt pstext -R -J -F+jTL+f20p,black -Gfloralwhite -W0.5p -O -K >> $ps
    
# Add directional rose
gmt psbasemap -R -J \
    --FONT=7p,Helvetica,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx0.7c/0.7c+w0.3i+f2+l+o0.15i -O -K >> $ps
    
# Select two points along the Cayman Trough
# 270/287/15/25
cat << EOF > trenchCMT.txt
275 17.7
281.5 19.5
EOF

# Plot trench segment and end points
gmt psxy -Rcmt_relief.nc -J -W2p,red trenchCMT.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred trenchCMT.txt -O -K >> $ps # points

# Generate cross-track profiles 400 km long, spaced 10 km, sampled every 2km
# and stack these using the mean, write stacked profile
gmt grdtrack trenchCMT.txt -Gcmt_relief.nc -C300k/2k/20k+v -Sm+sstackCMT.txt > tableCMT.txt
gmt psxy -R -J -W0.5p,red tableCMT.txt -O -K >> $ps

# Show upper/lower values encountered as an envelope
gmt convert stackCMT.txt -o0,5 > envCMT.txt
gmt convert stackCMT.txt -o0,6 -I -T >> envCMT.txt

# Plot graph (statistical mean for the profiles)
gmt psxy -R-150/150/-8000/1500 -JX15.2c/5c -Y12.0c envCMT.txt -W0.5p \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya1000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinner,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
	-Glightgray -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackCMT.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackCMT.txt -O -K >> $ps

# Add test annotations
echo "-145 500 Median stacked profile with error bars" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps
echo "60 -6500 North American Plate " | gmt pstext -R -J -F+jBL+f10p,orangered4 -Gwhite -O -K >> $ps
echo "-40 -500 Cayman Trough" | gmt pstext -R -J -F+f10p,orangered4+jBL -Gwhite -O -K >> $ps
echo "-50 -2200 (segment coordinates)" | gmt pstext -R -J -F+f10p,orangered4+jBL -Gwhite -O -K >> $ps
echo "-65 -1500 85.0\232W 17.7\232N to 78.5\232W,19.5\232N" | gmt pstext -R -J -F+f10p,orangered4+jBL -Gwhite -O -K >> $ps
echo "-140 -6500 Caribbean" | gmt pstext -R -J -F+jBL+f10p,orangered4 -Gwhite -O -K >> $ps
echo "-140 -7200 Plate" | gmt pstext -R -J -F+jBL+f10p,orangered4 -Gwhite -O -K >> $ps
echo "130 500 A" | gmt pstext -R -J -F+jTL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps

# 281.5 19.5
# Arrow
#gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
#0 -500 270 2.0c
#EOF

# Add GMT logo
gmt logo -Dx6.2/-14.0+0.25c/1.5c+w2c -O >> $ps
# Clean up
#rm -f z.cpt trenchA2.txt tableA2.txt envA2.txt stackA2.txt

# Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert crossCMT.ps -A0.2c -E720 -Tj -P -Z
