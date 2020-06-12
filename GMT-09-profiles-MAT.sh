#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Guatemala Trench
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=crossMAT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=0.5c \
    MAP_ANNOT_OFFSET=0.2c \
    MAP_TICK_PEN_PRIMARY=thinnest,dimgray \
    MAP_GRID_PEN_PRIMARY=thinnest,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    FONT_LABEL=10p,Palatino-Roman,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of ETOPO1m for the Middle America Trench area
grdcut earth_relief_01m.grd -R263/278/7/17 -Gmat_relief.nc
# Step-5. Make color palette
gmt makecpt -Cterra -V -T-6500/2500 > myoceanMAT.cpt
# Step-6. Make raster image
gmt grdimage mat_relief.nc -CmyoceanMAT.cpt -R263/278/7/17 -JM6i \
    -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg260/7+w10.3c/0.4c+v+o0.3/0i+ml -Rmat_relief.nc -J -CmyoceanMAT.cpt \
	--FONT_LABEL=8p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
	-Baf+l"Color scale legend: depth and height elevations (m)" \
	-I0.2 -By+lm -O -K >> $ps
# annotation
echo "263.3 16.7 B" | gmt pstext -R -J -F+jTL+f20p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour mat_relief.nc -R -J -C500 \
    -B+t"Cross-sectional profiles of the Guatemala Trench on the selected segment" \
    -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
	-Lx13.0c/-0.5i+c50+w400k+l"Mercator projection. Scale (km)"+f \
	-Bpxg4f2a2 -Bpyg6f2a2 -Bsxg2 -Bsyg2 \
    --FONT=8p,Palatino-Roman,dimgray \
	-UBL/-15p/-35p -O -K >> $ps
# Step-10. Add directional rose
gmt psbasemap -R -J \
    --FONT=7p,Palatino-Roman,white \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx1.0c/1.0c+w0.3i+f2+l+o0.15i -O -K >> $ps
# Step-11. Select two points along the Middle America Trench
cat << EOF > trenchMAT.txt
268.4 13.0
271.9 11.6
EOF
# Step-12. Plot trench segment and end points
gmt psxy -Rmat_relief.nc -J -W2p,red trenchMAT.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred trenchMAT.txt -O -K >> $ps # points
# Step-13. Generate cross-track profiles 400 km long, spaced 10 km, sampled every 2km
# and stack these using the mean, write stacked profile
gmt grdtrack trenchMAT.txt -Gmat_relief.nc -C400k/2k/10k+v -Sa+sstackMAT.txt > tableMAT.txt
# and stack these using the median, write stacked profile
# gmt grdtrack trenchMAT.txt -Gmat_relief.nc -C400k/2k/20k+v -Sm+sstackMAT.txt > tableMAT.txt
gmt psxy -R -J -W0.5p,yellow tableMAT.txt -O -K >> $ps
# Step-14. Add text annotation
gmt pstext -R -J -F+f10,Palatino-Roman,white -O -K >> $ps << END
192 47.5 profiles 400 km long, 20 km spaced
192 46.5 samples every 2 km along each profile
180 57 Pacific Ocean
END
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackMAT.txt -o0,5 > envMAT.txt
gmt convert stackMAT.txt -o0,6 -I -T >> envMAT.txt
# Step-16. Plot graph (statistical mean for the profiles)
gmt psxy -R-200/200/-7000/2000 -JX15.2c/5c -Y13.0c envMAT.txt -W0.5p \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya2000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinner,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
	-Glightgray -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackMAT.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackMAT.txt -O -K >> $ps
# Step-17. Add test annotations
echo "0 1500 Mean stacked profile with error bars" | gmt pstext -R -J -Gwhite -F+jTC+f10p,red -O -K >> $ps
echo "120 -3000 Carribean Plate " | gmt pstext -R -J -F+jTC+f10p,orangered4 -Gwhite -O -K >> $ps
echo "-10 0 Guatemala Trench" | gmt pstext -R -J -F+f10p,orangered4+jTC -Gwhite -O -K >> $ps
echo "-100 -5000 Cocos Plate" | gmt pstext -R -J -F+jTC+f10p,orangered4 -Gwhite -O -K >> $ps
echo "140 -1000 Chortis block" | gmt pstext -R -J -F+jTL+f10p,darkbrown -Gwhite -O -K >> $ps
echo "15 -5500 Oceanward Forearc" | gmt pstext -R -J -F+jTL+f10p,darkbrown+a-310 -Gwhite -O -K >> $ps
echo "-190 1500 A" | gmt pstext -R -J -F+jTL+f18p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
-3 -1000 270 2.2c
EOF
# Step-18. Add GMT logo
gmt logo -Dx6.2/-14.7+0.25c/1.5c+w2c -O >> $ps
# Step-19. Clean up
#rm -f z.cpt trenchA2.txt tableA2.txt envA2.txt stackA2.txt
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert crossMAT.ps -A0.2c -E720 -Tj -P -Z
