#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Manila Trench
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=crossMnT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=0.5c \
    MAP_ANNOT_OFFSET=0.2c \
    MAP_TICK_PEN_PRIMARY=thinnest,dimgray \
    MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    FONT_LABEL=10p,Palatino-Roman,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of ETOPO1m for the Manila Trench area
grdcut earth_relief_01m.grd -R105/123/8/24 -Gmnt_relief.nc
# Step-5. Make color palette
gmt makecpt -Cterra -V -T-6200/3500 > myoceanMnT.cpt
# Step-6. Make raster image
gmt grdimage mnt_relief.nc -CmyoceanMnT.cpt -R105/123/8/24 -JM6i \
    -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg102/8+w14.0c/0.4c+v+o0.3/0i+ml -Rmnt_relief.nc -J -CmyoceanRT.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
	-Baf+l"Color scale legend: depth and height elevations (m)" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour mnt_relief.nc -R -J -C1000 \
    -B+t"Cross-sectional profiles of the Manila Trench on two selected segments" \
    -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
	-Lx5.3i/-0.5i+c50+w400k+l"Mercator projection. Scale (km)"+f \
	-Bpxg4f2a2 -Bpyg4f4a2 -Bsxg2 -Bsyg2 \
    --FONT=7p,Palatino-Roman,dimgray \
	-UBL/-15p/-35p -O -K >> $ps
# annotation
echo "122.0 23.0 C" | gmt pstext -R -J -F+jBL+f20p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-10. Add directional rose
# NORTHERN segment
# Step-10. Select two points along the Manila Trench
cat << EOF > trenchMTn.txt
119.2 16.4
119.2 14.0
EOF
gmt psxy -Rmnt_relief.nc -J -W2p,yellow trenchMTn.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gyellow trenchMTn.txt -O -K >> $ps # points
# Step-13. Generate cross-track profiles 400 km long, spaced 20 km, sampled every 2km
# and stack these using the mean, write stacked profile
#gmt grdtrack trenchRT.txt -Gmnt_relief.nc -C400k/2k/20k+v -Sa+sstackMT.txt > tableRT.txt
gmt grdtrack trenchMTn.txt -Gmnt_relief.nc -C400k/2k/20k+v -Sa+sstackMTn.txt > tableMTn.txt
gmt psxy -R -J -Wthin,yellow tableMTn.txt -O -K >> $ps
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackMTn.txt -o0,5 > envMTn.txt
gmt convert stackMTn.txt -o0,6 -I -T >> envMTn.txt
#
# SOUTHERN segment
# Step-11. Plot trench segment and end points
cat << EOF > trenchMTs.txt
119.2 14.0
120.0 13.2
EOF
gmt psxy -Rmnt_relief.nc -J -W2p,green trenchMTs.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Ggreen trenchMTs.txt -O -K >> $ps # points
# Step-13. Generate cross-track profiles 400 km long, spaced 20 km, sampled every 2km
# and stack these using the mean, write stacked profile
#gmt grdtrack trenchRT.txt -Gmnt_relief.nc -C400k/2k/20k+v -Sa+sstackRT.txt > tableRT.txt
gmt grdtrack trenchMTs.txt -Gmnt_relief.nc -C400k/2k/20k+v -Sa+sstackMTs.txt > tableMTs.txt
gmt psxy -R -J -Wthin,green tableMTs.txt -O -K >> $ps
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackMTs.txt -o0,5 > envMTs.txt
gmt convert stackMTs.txt -o0,6 -I -T >> envMTs.txt
#
# NORTHERN graph
gmt psxy -R-200/200/-6500/1000 -JX15.2c/5c -Y17.0c envMTn.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya2000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
	-Glightgray -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackMTn.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackMTn.txt -O -K >> $ps
# Step-17. Add test annotations
echo "-110 -1000 South China Sea" | gmt pstext -R -J -Gwhite -F+jBL+f10p,blue -O -K >> $ps
echo "-200 500 Mean stacked profile with error bars: northern part" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps
echo "-25 -500 Manila Trench" | gmt pstext -R -J -Gwhite -F+jBL+f10p -O -K >> $ps
echo "100 -4000 Philippine Sea Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-130 -6000 Eurasian Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "100 -7000 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jTC+f10p,brown -O -K >> $ps
echo "150 -1000 Luzon Island" | gmt pstext -R -J -Gwhite -F+jTC+f10p,blue -O -K >> $ps
echo "180 -6000 B" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 -1000 270 1.5c
EOF
#
# SOUTHERN graph
gmt psxy -R-200/200/-6500/1000 -JX15.2c/5c -Y7.0c envMTs.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya2000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
    -Glightgray -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackMTs.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackMTs.txt -O -K >> $ps
# Step-17. Add test annotations
echo "-110 -500 South China Sea" | gmt pstext -R -J -Gwhite -F+jBL+f10p,blue -O -K >> $ps
echo "-200 500 Mean stacked profile with error bars: southern part" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps
echo "-25 -1000 Manila Trench" | gmt pstext -R -J -Gwhite -F+jBL+f10p -O -K >> $ps
echo "100 -4000 Philippine Sea Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-130 -6000 Eurasian Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "150 -7000 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jTC+f10p,brown -O -K >> $ps
echo "150 -1000 Luzon Island" | gmt pstext -R -J -Gwhite -F+jTC+f10p,blue -O -K >> $ps
echo "180 -6000 A" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
-10 -1500 270 1.3c
EOF
#
# Step-18. Add GMT logo
gmt logo -Dx6.5/-26.0+w2c -O >> $ps
# Step-19. Clean up
#rm -f z.cpt trenchRT.txt tableRT.txt envRT.txt stackRT.txt
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert crossMnT.ps -A5.0c -E720 -Tj -P -Z
