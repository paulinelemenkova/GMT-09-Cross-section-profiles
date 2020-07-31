#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Ninety East Ridge
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
grdcut ETOPO1_Ice_g_gmt4.grd -R82/92/-28/-15 -Gner_relief3.nc
#grdcut GEBCO_2019.nc -R82/92/-28/-15 -Gner_relief3.nc
gdalinfo ner_relief3.nc -stats
# Minimum=-6711.000, Maximum=-206.000

# Make color palette
gmt makecpt -Cturbo -V -T-6711/-206 > myocean.cpt

# Generate a file
ps=crossNER3.ps

# Make raster image
gmt grdimage ner_relief3.nc -Cmyocean.cpt -R82/92/-28/-15 -JM5.5i \
    -P -I+a15+ne0.75 -Xc -K > $ps
    
# Add color legend
gmt psscale -Dg82/-29.0+w13.5c/0.4c+h+o0.3/0i+ml -Rner_relief3.nc -J -Cmyocean.cpt \
	--FONT_LABEL=8p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
	-Baf+l"Color scale 'turbo': Google's Improved Rainbow Colormap for Visualization [C=RGB, -5808/461]" \
    --MAP_TITLE_OFFSET=0.5c \
	-I0.2 -By+lm -O -K >> $ps
    
# annotation
#echo "85.8 9 B" | gmt pstext -R -J -F+jTL+f20p,black -Gfloralwhite -W0.5p -O -K >> $ps

# Add shoreliness
gmt grdcontour ner_relief3.nc -R -J -C300 \
    -B+t"Cross-sectional profiles of the Ninty East Ridge on the southern segment. DEM: GEBCO" \
    --MAP_TITLE_OFFSET=0.5c \
    -Wthinner -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
	-Lx11.5c/-2.8c+c50+w200k+l"Mercator projection. Scale (km)"+f \
	-Bpxg4f1a2 -Bpyg6f1a1 -Bsxg2 -Bsyg2 -BWESN \
    --FONT=9p,Helvetica,black \
	-UBL/-5p/-80p -O -K >> $ps
    
# Add directional rose
gmt psbasemap -R -J \
    --FONT=7p,Helvetica,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx1.0c/0.7c+w0.3i+f2+l+o0.15i -O -K >> $ps
    
# Select two points along the Ninety East Ridge
cat << EOF > NER3.txt
87.9 -17.0
87.5 -27.0
EOF

# Plot ridge segment and end points
gmt psxy -Rner_relief3.nc -J -W2p,red NER3.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred NER3.txt -O -K >> $ps # points

# Generate cross-track profiles 400 km long, spaced 10 km, sampled every 2km
# and stack these using the mean, write stacked profile
gmt grdtrack NER3.txt -Gner_relief3.nc -C400k/2k/20k+v -Sm+sstackNER3.txt > tableNER3.txt
gmt psxy -R -J -W0.5p,red tableNER3.txt -O -K >> $ps

# Show upper/lower values encountered as an envelope
gmt convert stackNER3.txt -o0,5 > envNER3.txt
gmt convert stackNER3.txt -o0,6 -I -T >> envNER3.txt

# Plot graph (statistical mean for the profiles)
gmt psxy -R-200/200/-6800/-500 -JX14.5c/5c -Y22.0c envNER3.txt -W0.5p \
    -Bpxag100f10+l"Distance from ridge (km)"\
    -Bpya1000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinner,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
	-Glightgray -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackNER3.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackNER3.txt -O -K >> $ps

# Add test annotations
echo "-195 -1500 Ninety East Ridge (south)" | gmt pstext -R -J -F+jBL+f10p,orangered4 -Gwhite -O -K >> $ps
echo "-195 -2000 segment" | gmt pstext -R -J -F+jBL+f10p,orangered4 -Gwhite -O -K >> $ps
echo "-195 -2500 87.5\232E-27\232S to 87.9\232E-17\232N" | gmt pstext -R -J -F+jBL+f10p,orangered4 -Gwhite -O -K >> $ps

#  Add GMT logo
gmt logo -Dx6.0/-25.4+0.25c/1.5c+w2c -O >> $ps
# Clean up
#rm -f z.cpt trenchA2.txt tableA2.txt envA2.txt stackA2.txt
# Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert crossNER3.ps -A3.0c -E720 -Tj -P -Z
