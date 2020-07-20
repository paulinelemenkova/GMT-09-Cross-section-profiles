#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Makran Trench
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
#grdcut ETOPO1_Ice_g_gmt4.grd -R56/67/21/28 -Gmak_relief.nc
grdcut GEBCO_2019.nc -R56/67/21/28 -Gmak_relief.nc
gdalinfo mak_relief.nc -stats
# Make color palette
gmt makecpt -Cglobe -V -T-4000/3000 > myoceanMAK.cpt

# Generate a file
ps=crossMakT.ps

# Make raster image
gmt grdimage mak_relief.nc -CmyoceanMAK.cpt -R56/67/21/28 -JM6i \
    -P -I+a15+ne0.75 -Xc -K > $ps
    
# Add color legend
gmt psscale -Dg54.5/21+w10.3c/0.4c+v+o0.3/0i+ml -Rmak_relief.nc -J -CmyoceanMAK.cpt \
	--FONT_LABEL=8p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
	-Baf+l"Color scale 'globe': global bathymetry/topography relief [R=-4000/3000, H=0, C=RGB]" \
    --MAP_TITLE_OFFSET=0.5c \
	-I0.2 -By+lm -O -K >> $ps
    
# annotation
echo "56.5 27.5 B" | gmt pstext -R -J -F+jTL+f20p,black -Gfloralwhite -W0.5p -O -K >> $ps

# Add shorelines
gmt grdcontour mak_relief.nc -R -J -C500 \
    -B+t"Cross-sectional profiles of the Makran Trench on the selected segment. DEM: GEBCO" \
    --MAP_TITLE_OFFSET=0.5c \
    -W0.1p -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
	-Lx13.0c/-0.5i+c50+w300k+l"Mercator projection. Scale (km)"+f \
	-Bpxg4f1a2 -Bpyg6f1a1 -Bsxg2 -Bsyg2 -BwESN \
    --FONT=9p,Helvetica,black \
	-UBL/-15p/-35p -O -K >> $ps
    
# Add directional rose
gmt psbasemap -R -J \
    --FONT=7p,Helvetica,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx1.0c/0.7c+w0.3i+f2+l+o0.15i -O -K >> $ps
    
# Select two points along the Makron Trench
cat << EOF > trenchMAK.txt
61.3 24.1
63.7 24.2
EOF

# Plot trench segment and end points
gmt psxy -Rmak_relief.nc -J -W2p,red trenchMAK.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred trenchMAK.txt -O -K >> $ps # points

# Generate cross-track profiles 400 km long, spaced 10 km, sampled every 2km
# and stack these using the mean, write stacked profile
gmt grdtrack trenchMAK.txt -Gmak_relief.nc -C300k/2k/20k+v -Sm+sstackMAK.txt > tableMAK.txt
gmt psxy -R -J -W0.5p,yellow tableMAK.txt -O -K >> $ps

# Show upper/lower values encountered as an envelope
gmt convert stackMAK.txt -o0,5 > envMAK.txt
gmt convert stackMAK.txt -o0,6 -I -T >> envMAK.txt

# Plot graph (statistical mean for the profiles)
gmt psxy -R-150/150/-4500/700 -JX15.2c/5c -Y13.0c envMAK.txt -W0.5p \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya1000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinner,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
	-Glightgray -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackMAK.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackMAK.txt -O -K >> $ps

# Add test annotations
echo "25 -3000 Median stacked profile with error bars" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps
echo "-70 -4000 Arabian Plate " | gmt pstext -R -J -F+jBL+f10p,orangered4 -Gwhite -O -K >> $ps
echo "-40 200 Makran Trench" | gmt pstext -R -J -F+f10p,orangered4+jBL -Gwhite -O -K >> $ps
echo "50 -4000 Eurasian Plate" | gmt pstext -R -J -F+jBL+f10p,orangered4 -Gwhite -O -K >> $ps
echo "-140 500 A" | gmt pstext -R -J -F+jTL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps

# Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 0 270 2.0c
EOF

#  Add GMT logo
gmt logo -Dx6.2/-14.7+0.25c/1.5c+w2c -O >> $ps
# Clean up
#rm -f z.cpt trenchA2.txt tableA2.txt envA2.txt stackA2.txt
# Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert crossMakT.ps -A0.2c -E720 -Tj -P -Z
