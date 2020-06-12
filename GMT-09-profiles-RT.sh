#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Ryukyu Trench
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=crossRT.ps
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
# Step-4. Extract a subset of ETOPO1m for the Ryukyu Trench area
grdcut earth_relief_01m.grd -R120/134/20/33 -Grt_relief.nc
# Step-5. Make color palette
gmt makecpt -Cterra -V -T-7500/1000 > myoceanRT.cpt
# Step-6. Make raster image
gmt grdimage rt_relief.nc -CmyoceanRT.cpt -R120/134/20/33 -JM6i \
    -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg142/44+w8.2c/0.4c+v+o0.3/0i+ml -Rrt_relief.nc -J -CmyoceanRT.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
	-Baf+l"Color scale legend: depth and height elevations (m)" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour rt_relief.nc -R -J -C1000 \
    -B+t"Cross-sectional profiles of the Ryukyu Trench on two selected segments" \
    -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
	-Lx5.3i/-0.5i+c50+w400k+l"Mercator projection. Scale (km)"+f \
	-Bpxg4f2a2 -Bpyg4f4a2 -Bsxg2 -Bsyg2 \
    --FONT=7p,Palatino-Roman,dimgray \
	-UBL/-15p/-35p -O -K >> $ps
# annotation
echo "120.3 32.3 C" | gmt pstext -R -J -F+jBL+f20p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-10. Add directional rose
gmt psbasemap -R -J \
    --FONT=7p,Palatino-Roman,white \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx13.5c/1.0c+w0.3i+f2+l+o0.15i -O -K >> $ps
# NORTHERN segment
# Step-10. Select two points along the Kuril-Kamchatka Trench
cat << EOF > trenchRTn.txt
126.5 23.7
128.1 25.1
EOF
gmt psxy -Rrt_relief.nc -J -W2p,yellow trenchRTn.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gyellow trenchRTn.txt -O -K >> $ps # points
# Step-13. Generate cross-track profiles 400 km long, spaced 20 km, sampled every 2km
# and stack these using the mean, write stacked profile
#gmt grdtrack trenchRT.txt -Grt_relief.nc -C400k/2k/20k+v -Sa+sstackRT.txt > tableRT.txt
gmt grdtrack trenchRTn.txt -Grt_relief.nc -C400k/2k/20k -Sm+sstackRTn.txt > tableRTn.txt
gmt psxy -R -J -Wthin,yellow tableRTn.txt -O -K >> $ps
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackRTn.txt -o0,5 > envRTn.txt
gmt convert stackRTn.txt -o0,6 -I -T >> envRTn.txt
#
# SOUTHERN segment
# Step-11. Plot trench segment and end points
cat << EOF > trenchRTs.txt
124.4 23.2
126.5 23.7
EOF
gmt psxy -Rrt_relief.nc -J -W2p,green trenchRTs.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Ggreen trenchRTs.txt -O -K >> $ps # points
# Step-13. Generate cross-track profiles 400 km long, spaced 20 km, sampled every 2km
# and stack these using the mean, write stacked profile
#gmt grdtrack trenchRT.txt -Grt_relief.nc -C400k/2k/20k+v -Sa+sstackRT.txt > tableRT.txt
gmt grdtrack trenchRTs.txt -Grt_relief.nc -C400k/2k/20k -Sm+sstackRTs.txt > tableRTs.txt
gmt psxy -R -J -Wthin,green tableRTs.txt -O -K >> $ps
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackRTs.txt -o0,5 > envRTs.txt
gmt convert stackRTs.txt -o0,6 -I -T >> envRTs.txt
#
# NORTHERN graph
gmt psxy -R-200/200/-8500/1000 -JX15.2c/5c -Y19.0c envRTn.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya2000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
	-Glightgray -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackRTn.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackRTn.txt -O -K >> $ps
# Step-17. Add test annotations
echo "-150 -3000 Ryukyu Islands" | gmt pstext -R -J -Gwhite -F+jTC+f10p,brown -O -K >> $ps
echo "-50 -100 Median stacked profile with error bars: northern part" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps
echo "-10 -2800 Ryukyu Trench" | gmt pstext -R -J -Gwhite -F+jBL+f10p -O -K >> $ps
echo "-50 -1000 Submarine terraces" | gmt pstext -R -J -Gwhite -F+jBL+f10p -O -K >> $ps
echo "100 -7000 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jTC+f10p,brown -O -K >> $ps
echo "150 -3000 Pacific Ocean" | gmt pstext -R -J -Gwhite -F+jTC+f10p,blue -O -K >> $ps
echo "-190 -7000 B" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
3 -3500 270 1.5c
EOF
#
# SOUTHERN graph
gmt psxy -R-200/200/-8500/1000 -JX15.2c/5c -Y7.0c envRTs.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya2000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
    -Glightgray -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackRTs.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackRTs.txt -O -K >> $ps
# Step-17. Add test annotations
echo "-150 -3000 Ryukyu Islands" | gmt pstext -R -J -Gwhite -F+jTC+f10p,brown -O -K >> $ps
echo "-50 -100 Median stacked profile with error bars: southern part" | gmt pstext -R -J -Gwhite -F+jBL+f10p,red -O -K >> $ps
echo "-10 -2800 Ryukyu Trench" | gmt pstext -R -J -Gwhite -F+jBL+f10p -O -K >> $ps
echo "-30 -1000 Submarine terraces" | gmt pstext -R -J -Gwhite -F+jBL+f10p -O -K >> $ps
echo "150 -7000 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jTC+f10p,brown -O -K >> $ps
echo "150 -3000 Pacific Ocean" | gmt pstext -R -J -Gwhite -F+jTC+f10p,blue -O -K >> $ps
echo "-190 -7000 A" | gmt pstext -R -J -F+jBL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
5 -3500 270 1.3c
EOF
#
# Step-18. Add GMT logo
gmt logo -Dx6.5/-28.0+w2c -O >> $ps
# Step-19. Clean up
#rm -f z.cpt trenchRT.txt tableRT.txt envRT.txt stackRT.txt
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert crossRT.ps -A5.5c -E720 -Tj -P -Z
