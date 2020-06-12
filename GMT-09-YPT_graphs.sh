#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the New Britain and San Cristobal trenches
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=YPTgraphs.ps
#
# YAP TRENCH graph
gmt psxy -R-200/200/-9000/3000 -JX15.2c/5c envYT.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya2000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
	-UBL/-5p/-35p -Glightgray -W0.5p -K > $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackYT.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackYT.txt -O -K >> $ps
# Step-17. Add test annotations
echo "-170 -7000 Philippine Sea Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "10 -500 Median stacked profile with error bars" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps
echo "-60 2000 Yap Islands" | gmt pstext -R -J -Gwhite -F+jBL+f10p,darkbrown -O -K >> $ps
echo "-5 1500 Yap Trench" | gmt pstext -R -J -Gwhite -F+jBL+f10p,navyblue -O -K >> $ps
echo "-100 500 Ridges" | gmt pstext -R -J -Gwhite -F+jTC+f10p,brown -O -K >> $ps
echo "10 -4500 Horst" | gmt pstext -R -J -Gwhite -F+jBL+f9p,darkbrown+a-310 -O -K >> $ps
echo "30 -3000 Graben" | gmt pstext -R -J -Gwhite -F+jBL+f9p,darkbrown+a-310 -O -K >> $ps
echo "-40 -6000 Slope" | gmt pstext -R -J -F+jBL+f10p,darkbrown+a-50 -Gwhite -O -K >> $ps
echo "-190 1000 B" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 1000 270 2.3c
EOF
#
# PALAU graph
gmt psxy -R-200/200/-9000/3000 -JX15.2c/5c -Y6.5c envPT.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya2000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
    -Glightgray -W0.5p -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackPT.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackPT.txt -O -K >> $ps
# Step-17. Add test annotations
echo "-140 -7000 Philippine Sea Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "30 -500 Median stacked profile with error bars" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps
echo "-5 1000 Palau Trench" | gmt pstext -R -J -Gwhite -F+jBL+f10p,navyblue -O -K >> $ps
echo "-100 -500 Ridges" | gmt pstext -R -J -Gwhite -F+jTC+f10p,brown -O -K >> $ps
echo "30 -1500 Abyssal hill" | gmt pstext -R -J -Gwhite -F+jTC+f10p,darkbrown -O -K >> $ps
echo "-50 1500 Palau Islands" | gmt pstext -R -J -Gwhite -F+jTC+f10p,darkbrown -O -K >> $ps
echo "-40 -6000 Slope" | gmt pstext -R -J -F+jBL+f10p,darkbrown+a-50 -Gwhite -O -K >> $ps
echo "-190 1000 A" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps
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
gmt psconvert YPTgraphs.ps -A0.5c -E720 -Tj -P -Z
