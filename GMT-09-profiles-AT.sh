#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Aleutian Trench
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=cross2AT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=0.5c \
    MAP_ANNOT_OFFSET=0.2c \
    MAP_TICK_PEN_PRIMARY=thinnest,dimgray \
    MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    FONT_LABEL=10p,Palatino-Roman,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of ETOPO1m for the Aleutian Trench area
grdcut earth_relief_01m.grd -R154/220/44/64 -Gat_relief.nc
# Step-5. Make color palette
gmt makecpt -Cterra -V -T-8200/7000 > myoceanAT.cpt
# Step-6. Make raster image
gmt grdimage at_relief.nc -CmyoceanAT.cpt -R154/220/44/64 -JM6i \
    -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg142/44+w8.2c/0.4c+v+o0.3/0i+ml -Rat_relief.nc -J -CmyoceanAT.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
	-Baf+l"Color scale legend: depth and height elevations (m)" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour at_relief.nc -R -J -C1000 \
    -B+t"Cross-sectional profiles of the Aleutian Trench on the selected segment" \
    -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
	-Lx5.3i/-0.5i+c50+w1000k+l"Mercator projection. Scale (km)"+f \
	-Bxg4f4a8 -Byg4f2a4 \
    --FONT=7p,Palatino-Roman,dimgray \
	-UBL/-15p/-35p -O -K >> $ps
# Step-10. Add directional rose
gmt psbasemap -R -J \
    --FONT=7p,Palatino-Roman,white \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx13.5c/1.0c+w0.3i+f2+l+o0.15i -O -K >> $ps
# Step-11. Select two points along the Aleutian Trench
cat << EOF > trenchA2.txt
180.0 49.9
188.0 51.0
EOF
# Step-12. Plot trench segment and end points
gmt psxy -Rat_relief.nc -J -W2p,red trenchA2.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred trenchA2.txt -O -K >> $ps # points
# Step-13. Generate cross-track profiles 400 km long, spaced 20 km, sampled every 2km
# and stack these using the mean, write stacked profile
#gmt grdtrack trenchA2.txt -Gat_relief.nc -C400k/2k/20k+v -Sa+sstackA2.txt > tableA2.txt
gmt grdtrack trenchA2.txt -Gat_relief.nc -C400k/2k/20k+v -Sm+sstackA2.txt > tableA2.txt
gmt psxy -R -J -W0.2p,yellow tableA2.txt -O -K >> $ps
# Step-14. Add text annotation
gmt pstext -R -J -F+f10,Palatino-Roman,white -O -K >> $ps << END
192 47.5 profiles 400 km long, 20 km spaced
192 46.5 samples every 2 km along each profile
180 57 Bering Sea
END
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackA2.txt -o0,5 > envA2.txt
gmt convert stackA2.txt -o0,6 -I -T >> envA2.txt
# Step-16. Plot graph (statistical mean for the profiles)
gmt psxy -R-200/200/-8800/2000 -JX15.2c/5c -Y11.0c envA2.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya2000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
	-Glightgray -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackA2.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackA2.txt -O -K >> $ps
# Step-17. Add test annotations
echo "150 -3000 Aleutian Islands" | gmt pstext -R -J -Gwhite -F+jTC+f9p -O -K >> $ps
echo "0 -300 Median stacked profile with error bars" | gmt pstext -R -J -Gwhite -F+jTC+f10p,red -O -K >> $ps
echo "0 -8000 Aleutian Trench" | gmt pstext -R -J -Gwhite -F+jTC+f9p -O -K >> $ps
echo "50 -2000 Submarine terraces" | gmt pstext -R -J -Gwhite -F+jTC+f9p -O -K >> $ps
echo "-150 -7000 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jTC+f9p -O -K >> $ps
# Step-18. Add GMT logo
gmt logo -Dx6.2/-13.0+o0.1i/0.1i+w2c -O >> $ps
# Step-19. Clean up
#rm -f z.cpt trenchA2.txt tableA2.txt envA2.txt stackA2.txt
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert cross2AT.ps -A0.2c -E720 -Tj -P -Z
