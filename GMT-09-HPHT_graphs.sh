#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Puysegur and Hjort trenches
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=HPHTgraphs.ps
#
# HJORT graph
gmt psxy -R-200/200/-7000/0 -JX15.2c/5 envH.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya2000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
	-UBL/-5p/-35p -Glightgray -W0.5p -K > $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackH.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackH.txt -O -K >> $ps
# Step-17. Add test annotations
echo "110 -5000 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-10 -1000 Hjort Trench" | gmt pstext -R -J -Gwhite -F+jBL+f10p,navyblue -O -K >> $ps
echo "90 -5000 Modelled median stacked" | gmt pstext -R -J \
-Gwhite -F+jBL+f10p,Times-Roman,red -O -K >> $ps
echo "90 -5700 cross-section profiles" | gmt pstext -R -J \
-Gwhite -F+jBL+f10p,Times-Roman,red -O -K >> $ps
echo "90 -6400 with error bars" | gmt pstext -R -J \
-Gwhite -F+jBL+f10p,Times-Roman,red -O -K >> $ps
echo "-190 -6200 C" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 -1500 270 1.7c
EOF
#
# PUYSEGUR graph
gmt psxy -R-200/200/-7000/1000 -JX15.2c/5 -Y6.5c envP.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya2000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
    -Glightgray -W0.5p -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackP.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackP.txt -O -K >> $ps
# Step-17. Add test annotations
echo "-190 -1000 Modelled median stacked" | gmt pstext -R -J \
-Gwhite -F+jBL+f10p,Times-Roman,red -O -K >> $ps
echo "-190 -1700 cross-section profiles" | gmt pstext -R -J \
-Gwhite -F+jBL+f10p,Times-Roman,red -O -K >> $ps
echo "-190 -2400 with error bars" | gmt pstext -R -J \
-Gwhite -F+jBL+f10p,Times-Roman,red -O -K >> $ps
echo "110 -6000 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "60 -500 Puysegur Ridge" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-50 0 Puysegur Trench" | gmt pstext -R -J -Gwhite -F+jBL+f10p,navyblue -O -K >> $ps
echo "-190 -6200 B" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 -500 270 1.7c
EOF
#
# HIKURANGI graph
gmt psxy -R-200/200/-4500/1000 -JX15.2c/5 -Y6.5c envHis.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya1000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
    -Glightgray -W0.5p -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackHis.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackHis.txt -O -K >> $ps
# Step-17. Add test annotations
echo "90 -3000 Modelled median stacked " | gmt pstext -R -J \
-Gwhite -F+jBL+f10p,Times-Roman,red -O -K >> $ps
echo "90 -3500 cross-section profiles" | gmt pstext -R -J \
-Gwhite -F+jBL+f10p,Times-Roman,red -O -K >> $ps
echo "90 -4000 with error bars" | gmt pstext -R -J \
-Gwhite -F+jBL+f10p,Times-Roman,red -O -K >> $ps
echo "110 -6000 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "100 -1000 North Island" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-20 500 Hikurangi Trench" | gmt pstext -R -J -Gwhite -F+jBL+f10p,navyblue -O -K >> $ps
echo "-190 -3800 A" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 0 270 1.7c
EOF
#
# Step-18. Add GMT logo
gmt logo -Dx6.5/-15.3+w2c -O >> $ps
# Step-19. Clean up
#rm -f z.cpt trenchRT.txt tableRT.txt envRT.txt stackRT.txt
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert HPHTgraphs.ps -A1.0c -E720 -Tj -P -Z
