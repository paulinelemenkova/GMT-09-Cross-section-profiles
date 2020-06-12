#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Izu-Bonin Trench
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=IBTgraphs.ps
#
# SOUTH graph
gmt psxy -R-200/200/-11000/1000 -JX15.2c/5c envIBTs.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya2000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
	-UBL/-5p/-35p -Glightgray -W0.5p -K > $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackIBTs.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackIBTs.txt -O -K >> $ps
# Step-17. Add test annotations
echo "110 -7500 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-160 -7000 Philippine Sea Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-70 0 SOUTHERN segment: median stacked profile with error bars" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps
echo "-5 -1500 Izu-Bonin Trench" | gmt pstext -R -J -Gwhite -F+jBL+f10p,navyblue -O -K >> $ps
echo "-140 0 Bonin Ridge" | gmt pstext -R -J -Gwhite -F+jBL+f10p,darkbrown -O -K >> $ps
echo "-60 -7000 Slope" | gmt pstext -R -J -F+jBL+f10p,darkbrown+a-40 -Gwhite -O -K >> $ps
echo "-190 -7000 B" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 -2000 270 2.0c
EOF
#
# NORTH graph
gmt psxy -R-200/200/-11000/1000 -JX15.2c/5c -Y6.5c envIBTn.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya2000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
    -Glightgray -W0.5p -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackIBTn.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackIBTn.txt -O -K >> $ps
# Step-17. Add test annotations
echo "110 -7500 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-160 -7000 Philippine Sea Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-70 0 NORTHERN segment: median stacked profile with error bars" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps
echo "-160 0 Izu-Bonin Arc" | gmt pstext -R -J -Gwhite -F+jBL+f10p,darkbrown -O -K >> $ps
echo "-5 -1500 Izu-Bonin Trench" | gmt pstext -R -J -Gwhite -F+jBL+f10p,navyblue -O -K >> $ps
echo "-60 -6500 Slope" | gmt pstext -R -J -F+jBL+f10p,darkbrown+a-50 -Gwhite -O -K >> $ps
echo "40 -5800 Seamounts" | gmt pstext -R -J -F+jBL+f10p,darkbrown+a-340 -Gwhite -O -K >> $ps
echo "-190 -7000 A" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 -2000 270 2.0c
EOF
#
# Step-18. Add GMT logo
gmt logo -Dx6.5/-8.6+w2c -O >> $ps
# Step-19. Clean up
#rm -f z.cpt trenchRT.txt tableRT.txt envRT.txt stackRT.txt
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert IBTgraphs.ps -A1.0c -E720 -Tj -P -Z
