#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Kermadec and Tonga trenches
# Profiles info: 400 km long, spaced 10 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=crossTKTprofiles.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
MAP_FRAME_PEN=dimgray \
MAP_FRAME_WIDTH=0.1c \
MAP_TITLE_OFFSET=0.5c \
MAP_ANNOT_OFFSET=0.2c \
MAP_TICK_PEN_PRIMARY=thinner,dimgray \
MAP_GRID_PEN_PRIMARY=thin,dimgray \
MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
FONT_TITLE=12p,Palatino-Roman,black \
FONT_ANNOT_PRIMARY=10p,Palatino-Roman,dimgray \
FONT_LABEL=10p,Palatino-Roman,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
#
# KERMADEC graph
# Step-15. Plot graph
gmt psxy -R-200/200/-11000/2000 -JX15.2c/5c \
    -Bxag100f50+l"Distance from trench (km)" \
    -Byag2000f1000a2000+l"Depth (m)" \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_GRID_PEN_PRIMARY=thinner,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
    -Glightgray -W0.5p envK.txt -UBL/-2p/-45p -K > $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackK.txt -O -K >> $ps
gmt psxy -R -J -W1p,red stackK.txt -O -K >> $ps
# Step-16. Add test annotations
echo "-70 1000 Kermadec segment: median stacked profile with error bars" | gmt pstext -R -J \
-Gwhite -F+jBL+f12p,Times-Roman,red -O -K >> $ps
echo "-70 -100 Profiles 400 km long, spaced 20 km, sampled 2km" | gmt pstext -R -J -Gwhite -F+jBL+f12p,red -O -K >> $ps
echo "-150 -4500 Kermadec Ridge" | gmt pstext -R -J -Gwhite -F+jTC+f11p,darkbrown -O -K >> $ps
echo "150 -7000 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jTC+f12p,darkbrown -O -K >> $ps
echo "150 -3000 Pacific Ocean" | gmt pstext -R -J -Gwhite -F+jTC+f12p,darkblue -O -K >> $ps
echo "-120 -6500 Oceanward Forearc" | gmt pstext -R -J -F+jBL+f11p,darkbrown+a-27 -Gwhite -O -K >> $ps
echo "-25 -1500 Kermadec Trench" | gmt pstext -R -J -F+f11p,orangered4+jBL -Gwhite -O -K >> $ps
echo "-190 -9000 B" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps
 >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 -2000 270 1.6c
EOF
#
# TONGA graph
# Step-14. Plot graph
gmt psxy -R-200/200/-11000/2000 -JX15.2c/5c -Y6.5c \
    -Bxag100f50+l"Distance from trench (km)" \
    -Byag2000f1000a2000+l"Depth (m)" \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_GRID_PEN_PRIMARY=thinner,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
    -Glightgray -W0.5p envT.txt -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackT.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackT.txt -O -K >> $ps
# Step-15. Add test annotations
echo "-80 600 Tonga segment: median stacked profile with error bars" | gmt pstext -R -J \
-Gwhite -F+jBL+f12p,Times-Roman,red -O -K >> $ps
echo "-80 -500 Profiles 400 km long, spaced 20 km, sampled 2km" | gmt pstext -R -J -Gwhite -F+jBL+f12p,red -O -K >> $ps
echo "-150 -3500 Tonga Ridge" | gmt pstext -R -J -Gwhite -F+jTC+f11p,darkbrown -O -K >> $ps
echo "150 -7000 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jTC+f12p,darkbrown -O -K >> $ps
echo "150 -3000 Pacific Ocean" | gmt pstext -R -J -Gwhite -F+jTC+f12p,darkblue -O -K >> $ps
echo "-100 -4500 Oceanward Forearc" | gmt pstext -R -J -F+jTL+f11p,darkbrown+a-35 -Gwhite -O -K >> $ps
echo "-25 -2000 Tonga Trench" | gmt pstext -R -J -F+f11p,orangered4+jBL -Gwhite -O -K >> $ps
echo "-190 -9000 A" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 -2800 270 1.6c
EOF
#
# Add GMT logo
gmt logo -Dx6.5/-8.7+w2c -O >> $ps
# Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert crossTKTprofiles.ps -A0.5c -E720 -Tj -P -Z
