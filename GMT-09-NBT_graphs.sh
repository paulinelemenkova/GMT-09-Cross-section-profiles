#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the New Britain and San Cristobal trenches
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=NBTgraphs.ps
#
# NEW BRITAIN TRENCH graph
gmt psxy -R-200/200/-8500/3000 -JX15.2c/5c envNBT.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya2000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
	-UBL/-5p/-35p -Glightgray -W0.5p -K > $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackNBT.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackNBT.txt -O -K >> $ps
# Step-17. Add test annotations
echo "-150 -2000 New Britain Island" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "10 -500 Median stacked profile with error bars" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps
echo "-5 1500 New Britain Trench" | gmt pstext -R -J -Gwhite -F+jBL+f10p,navyblue -O -K >> $ps
echo "70 -6500 Solomon Sea Plate" | gmt pstext -R -J -Gwhite -F+jTC+f10p,brown -O -K >> $ps
echo "100 -1500 Solomon Sea" | gmt pstext -R -J -Gwhite -F+jTC+f10p,blue -O -K >> $ps
echo "-90 -3000 Continental slope" | gmt pstext -R -J -F+jBL+f11p,darkbrown+a-45 -Gwhite -O -K >> $ps
echo "-190 -8000 B" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 1000 270 2.3c
EOF
#
# SAN CRISTOBAL graph
gmt psxy -R-200/200/-11000/3000 -JX15.2c/5c -Y6.5c envSCT.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya2000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
    -Glightgray -W0.5p -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackSCT.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackSCT.txt -O -K >> $ps
# Step-17. Add test annotations
echo "-140 -2500 Solomon Islands" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "30 -500 Median stacked profile with error bars" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps
echo "-5 1000 San Cristobal Trench" | gmt pstext -R -J -Gwhite -F+jBL+f10p,navyblue -O -K >> $ps
echo "150 -6000 Solomon Sea Plate" | gmt pstext -R -J -Gwhite -F+jTC+f10p,brown -O -K >> $ps
echo "150 -2000 Solomon Sea" | gmt pstext -R -J -Gwhite -F+jTC+f10p,blue -O -K >> $ps
echo "-85 -3500 Continental slope" | gmt pstext -R -J -F+jBL+f11p,darkbrown+a-50 -Gwhite -O -K >> $ps
echo "-190 -10000 A" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 0 270 1.8c
EOF
#
# Step-18. Add GMT logo
gmt logo -Dx6.5/-8.7+w2c -O >> $ps
# Step-19. Clean up
#rm -f z.cpt trenchRT.txt tableRT.txt envRT.txt stackRT.txt
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert NBTgraphs.ps -A0.5c -E720 -Tj -P -Z
