#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Hikurangi trench
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=HTgraphs.ps
#
# SOUTHERN graph (south)
gmt psxy -R-200/200/-5000/1000 -JX15.2c/5c envHis.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya1000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
	-UBL/-5p/-35p -Glightgray -W0.5p -K > $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackHis.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackHis.txt -O -K >> $ps
# Step-17. Add test annotations
echo "110 -6000 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-40 500 Hikurangi Trench" | gmt pstext -R -J -Gwhite -F+jBL+f10p,navyblue -O -K >> $ps
echo "-195 -2500 North Island" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-190 -4500 B (Southern transect)" | gmt pstext -R -J -F+jBL+f12p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 0 270 1.7c
EOF
#
# CENTRAL graph (north)
gmt psxy -R-200/200/-5000/1000 -JX15.2c/5c -Y6.5c envHic.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya1000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
    -Glightgray -W0.5p -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackHic.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackHic.txt -O -K >> $ps
# Step-17. Add test annotations
echo "60 200 Modelled median stacked profiles" | gmt pstext -R -J \
-Gwhite -F+jBL+f10p,Times-Roman,red -O -K >> $ps
echo "60 -300 with error bars" | gmt pstext -R -J \
-Gwhite -F+jBL+f10p,Times-Roman,red -O -K >> $ps
echo "110 -6000 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-180 -1500 North Island" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-20 0 Hikurangi Trench" | gmt pstext -R -J -Gwhite -F+jBL+f10p,navyblue -O -K >> $ps
echo "-190 -4000 A (Northern transect)" | gmt pstext -R -J -F+jBL+f12p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 -500 270 1.7c
EOF
#
# Step-18. Add GMT logo
gmt logo -Dx6.5/-8.6+w2c -O >> $ps
# Step-19. Clean up
#rm -f z.cpt trenchRT.txt tableRT.txt envRT.txt stackRT.txt
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert HTgraphs.ps -A1.0c -E720 -Tj -P -Z
