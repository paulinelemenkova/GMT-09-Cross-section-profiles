#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Peru-Chile Trench
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=crossPCTg.ps
#
# PERU graph
gmt psxy -R-200/200/-7000/2000 -JX15.2c/5c envPCTn.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya2000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
	-UBL/-5p/-35p -Glightgray -W0.5p -K > $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackPCTn.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackPCTn.txt -O -K >> $ps
# Step-17. Add test annotations
echo "130 -1500 Central Andes" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-150 1000 Peruvian part: Median stacked profile with error bars" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps
echo "-50 -1000 Peru-Chile Trench" | gmt pstext -R -J -Gwhite -F+jBL+f10p -O -K >> $ps
echo "-150 -5500 Nazca Plate" | gmt pstext -R -J -Gwhite -F+jTC+f10p,brown -O -K >> $ps
echo "-150 -3000 Pacific Ocean" | gmt pstext -R -J -Gwhite -F+jTC+f10p,blue -O -K >> $ps
echo "40 -5100 Continental slope" | gmt pstext -R -J -F+jBL+f11p,darkbrown+a-325 -Gwhite -O -K >> $ps
echo "-190 500 B" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 -1500 270 1.8c
EOF
#
# CHILE graph
gmt psxy -R-200/200/-8500/3000 -JX15.2c/5c -Y6.5c envPCTs.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya2000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
    -Glightgray -W0.5p -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackPCTs.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackPCTs.txt -O -K >> $ps
# Step-17. Add test annotations
echo "130 -1000 Central Andes" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-150 1000 Chilean part: Median stacked profile with error bars" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps
echo "-50 -1000 Peru-Chile Trench" | gmt pstext -R -J -Gwhite -F+jBL+f10p -O -K >> $ps
echo "-150 -6000 Nazca Plate" | gmt pstext -R -J -Gwhite -F+jTC+f10p,brown -O -K >> $ps
echo "-150 -2000 Pacific Ocean" | gmt pstext -R -J -Gwhite -F+jTC+f10p,blue -O -K >> $ps
echo "50 -5100 Continental slope" | gmt pstext -R -J -F+jBL+f11p,darkbrown+a-325 -Gwhite -O -K >> $ps
echo "-190 1000 A" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 -1500 270 1.8c
EOF
#
# Step-18. Add GMT logo
gmt logo -Dx6.5/-8.7+w2c -O >> $ps
# Step-19. Clean up
#rm -f z.cpt trenchRT.txt tableRT.txt envRT.txt stackRT.txt
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert crossPCTg.ps -A0.5c -E720 -Tj -P -Z
