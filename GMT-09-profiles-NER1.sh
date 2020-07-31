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
#grdcut ETOPO1_Ice_g_gmt4.grd -R85/95/-8/8 -Gner_relief1.nc
grdcut GEBCO_2019.nc -R85/95/-8/8 -Gner_relief1.nc
gdalinfo ner_relief1.nc -stats
# Minimum=-5671.000, Maximum=461.000
# GEBCO actual_range={-5808.361328125,566.5078125}

# Make color palette
gmt makecpt -Cturbo -V -T-5808/461 > myocean.cpt

# Generate a file
ps=crossNER1.ps

# Make raster image
gmt grdimage ner_relief1.nc -Cmyocean.cpt -R85/95/-8/8 -JM5.5i \
    -P -I+a15+ne0.75 -Xc -K > $ps
    
# Add color legend
gmt psscale -Dg85/-9.2+w13.5c/0.4c+h+o0.3/0i+ml -Rner_relief1.nc -J -Cmyocean.cpt \
	--FONT_LABEL=8p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
	-Baf+l"Color scale 'turbo': Google's Improved Rainbow Colormap for Visualization [C=RGB, -5808/461]" \
    --MAP_TITLE_OFFSET=0.5c \
	-I0.2 -By+lm -O -K >> $ps
    
# annotation
#echo "85.8 9 B" | gmt pstext -R -J -F+jTL+f20p,black -Gfloralwhite -W0.5p -O -K >> $ps

# Add shoreliness
gmt grdcontour ner_relief1.nc -R -J -C300 \
    -B+t"Cross-sectional profiles of the Ninty East Ridge on the northern segment. DEM: GEBCO" \
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
cat << EOF > NER1.txt
#90.5 7.0
90.0 7.0
89.0 -7.0
EOF

# Plot ridge segment and end points
gmt psxy -Rner_relief1.nc -J -W2p,red NER1.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred NER1.txt -O -K >> $ps # points

# Generate cross-track profiles 400 km long, spaced 10 km, sampled every 2km
# and stack these using the mean, write stacked profile
gmt grdtrack NER1.txt -Gner_relief1.nc -C400k/2k/20k+v -Sm+sstackNER1.txt > tableNER1.txt
gmt psxy -R -J -W0.5p,red tableNER1.txt -O -K >> $ps

# Show upper/lower values encountered as an envelope
gmt convert stackNER1.txt -o0,5 > envNER1.txt
gmt convert stackNER1.txt -o0,6 -I -T >> envNER1.txt

# Plot graph (statistical mean for the profiles)
gmt psxy -R-200/200/-6500/-1000 -JX14.5c/5c -Y24.5c envNER1.txt -W0.5p \
    -Bpxag100f10+l"Distance from ridge (km)"\
    -Bpya1000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinner,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
	-Glightgray -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackNER1.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackNER1.txt -O -K >> $ps

# Add test annotations
echo "-180 -1500 Ninety East Ridge (north)" | gmt pstext -R -J -F+jBL+f10p,orangered4 -Gwhite -O -K >> $ps
echo "-180 -2000 segment 89\232E7\232S to 90\232E7\232N" | gmt pstext -R -J -F+jBL+f10p,orangered4 -Gwhite -O -K >> $ps

#  Add GMT logo
gmt logo -Dx6.2/-27.8+0.25c/1.5c+w2c -O >> $ps
# Clean up
#rm -f z.cpt trenchA2.txt tableA2.txt envA2.txt stackA2.txt
# Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert crossNER1.ps -A3.0c -E720 -Tj -P -Z
