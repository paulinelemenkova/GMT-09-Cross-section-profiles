#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Japan trench
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=JTgraphs.ps
#
# SOUTH graph
gmt psxy -R-200/200/-9000/1000 -JX15.2c/5c envJTs.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya2000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
	-UBL/-5p/-35p -Glightgray -W0.5p -K > $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackJTs.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackJTs.txt -O -K >> $ps
# Step-17. Add test annotations
echo "110 -7500 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-160 -5500 North American Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-70 0 SOUTHERN segment: median stacked profile with error bars" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps
echo "-5 -1000 Japan Trench" | gmt pstext -R -J -Gwhite -F+jBL+f10p,navyblue -O -K >> $ps
echo "-190 300 Honshu Island" | gmt pstext -R -J -Gwhite -F+jBL+f10p,darkbrown -O -K >> $ps
echo "-45 -7000 Slope" | gmt pstext -R -J -F+jBL+f10p,darkbrown+a-40 -Gwhite -O -K >> $ps
echo "-190 -7000 B" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 -1500 270 2.3c
EOF
#
# NORTH graph
gmt psxy -R-200/200/-9000/1000 -JX15.2c/5c -Y6.5c envJTn.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya2000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
    -Glightgray -W0.5p -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackJTn.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackJTn.txt -O -K >> $ps
# Step-17. Add test annotations
echo "110 -7000 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-160 -5500 North American Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-70 0 NORTHERN segment: median stacked profile with error bars" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps
echo "-190 300 Honshu Island" | gmt pstext -R -J -Gwhite -F+jBL+f10p,darkbrown -O -K >> $ps
echo "-5 -1000 Japan Trench" | gmt pstext -R -J -Gwhite -F+jBL+f10p,navyblue -O -K >> $ps
echo "-70 -1300 Submarine" | gmt pstext -R -J -Gwhite -F+jBL+f9p,darkbrown -O -K >> $ps
echo "-40 -2300 Terraces" | gmt pstext -R -J -Gwhite -F+jBL+f9p,darkbrown -O -K >> $ps
echo "-50 -6500 Slope" | gmt pstext -R -J -F+jBL+f10p,darkbrown+a-50 -Gwhite -O -K >> $ps
echo "-190 -7000 A" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 -1500 270 2.3c
EOF
#
# Step-18. Add GMT logo
gmt logo -Dx6.5/-8.7+w2c -O >> $ps
# Step-19. Clean up
#rm -f z.cpt trenchRT.txt tableRT.txt envRT.txt stackRT.txt
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert JTgraphs.ps -A0.5c -E720 -Tj -P -Z
