#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Kuril-Kamchatka Trench
# Profiles info: 400 km long, spaced 10 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=cross2KKTU.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=ddd \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=0.7c \
    MAP_ANNOT_OFFSET=0.2c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinnest,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=24p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=10p,Palatino-Roman,black \
    FONT_LABEL=12p,Palatino-Roman,black \
# Step-3. Overwrite defaults of GMT
#gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of ETOPO1m for the Kuril-Kamchatka Trench area
grdcut earth_relief_01m.grd -R140/170/40/60 -Gkkt_relief.nc
# Step-5. Make color palette
#gmt makecpt -Cglobe.cpt -V -T-10000/1000 > myocean.cpt
gmt makecpt -Cgeo -V -T-10000/1000 > myocean.cpt
# Step-6. Make raster image
gmt grdimage kkt_relief.nc -Cmyocean.cpt -R140/170/40/60 -JM6i \
    -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg133.8/40+w6.5i/0.15i+v+o0.3/0i+ml \
    -Rkkt_relief.nc -J -Cmyocean.cpt \
	--FONT_LABEL=10p,Helvetica,black \
	--FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    --MAP_ANNOT_OFFSET=0.1c \
	-Baf+l"Color scale legend: depth and height elevations (m)" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour kkt_relief.nc -R -J -C1000 \
-B+t"Kuril-Kamchatka Trench area" \
    -W0.1,black -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
	-Lx13.4c/-1.3c+c50+w500k+l"Mercator projection. Scale (km)"+f \
	-Bxg4f2a8 -Byg4f2a8 \
    --MAP_TITLE_OFFSET=0.3c \
    --MAP_ANNOT_OFFSET=0.2c \
    --MAP_LABEL_OFFSET=0.2c \
    --FONT=13p,Palatino-Roman,black \
    -Tdx1.0c/13.5c+w0.3i+f2+l+o0.15i \
	-UBL/-15p/-35p -O -K >> $ps
# Step-10. Select two points along the Kuril-Kamchatka Trench
cat << EOF > trench2.txt
153.5 45.5
158.5 50.0
EOF
#
gmt pstext -R -J -N -O -K \
-F+jTL+f18p,Times-Roman,yellow+jLB >> $ps << EOF
161.0 48.3 Kuril-Kamchatka
161.0 47.5 Trench
EOF
# 2. вектор: стрелки тонкие с желтым кружком в начале и острием в конце.
# kwargs: координаты, угол наклона, длина
gmt psxy -R -J -Sv0.15i+ea -Gyellow -W0.5p,yellow -O -K >> $ps << EOF
161.5 48.5 120 1.5c
EOF
# Step-11. Plot north trench segment and end points
gmt psxy -Rkkt_relief.nc -J -W3p,red trench2.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred trench2.txt -O -K >> $ps # points
# Step-12. Generate cross-track profiles 400 km long, spaced 10 km, sampled every 2km
# and stack these using the median, write stacked profile
gmt grdtrack trench2.txt -Gkkt_relief.nc -C400k/2k/10k+v -Sm+sstack2.txt > table2.txt
# Step-12. Generate cross-track profiles 400 km long, spaced 10 km, sampled every 2km
# and stack these using the mean, write stacked profile
#gmt grdtrack trench2.txt -Gkkt_relief.nc -C400k/2k/10k+v -Sa+sstack2.txt > table2.txt
gmt psxy -R -J -W0.5p table2.txt -O -K >> $ps
# Step-14. Show upper/lower values encountered as an envelope
gmt convert stack2.txt -o0,5 > env2.txt
gmt convert stack2.txt -o0,6 -I -T >> env2.txt
# 2nd segment
# Step-10. Select two points along the Kuril-Kamchatka Trench
cat << EOF > trench1.txt
148.0 43.0
153.5 45.5
EOF
#
# Step-11. Plot south trench segment and end points
gmt psxy -Rkkt_relief.nc -J -W3p,green trench1.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Ggreen trench1.txt -O -K >> $ps # points
# Step-12. Generate cross-track profiles 400 km long, spaced 10 km, sampled every 2km
# and stack these using the median, write stacked profile
gmt grdtrack trench1.txt -Gkkt_relief.nc -C400k/2k/10k -Sm+sstack1.txt > table1.txt
gmt psxy -R -J -W0.5p,black table1.txt -O -K >> $ps
# Step-14. Show upper/lower values encountered as an envelope
gmt convert stack1.txt -o0,5 > env1.txt
gmt convert stack1.txt -o0,6 -I -T >> env1.txt
#
# Step-10. Select two points of the whole trench
cat << EOF > trenchS.txt
144.2 41.0
153.5 45.5
EOF
cat << EOF > trenchC.txt
153.5 45.5
158.5 50.0
EOF
cat << EOF > trenchN.txt
158.5 50.0
163.1 53.5
EOF
gmt psxy -Rkkt_relief.nc -J -W1p,yellow trenchS.txt -O -K >> $ps # my line
gmt psxy -Rkkt_relief.nc -J -W1p,yellow trenchC.txt -O -K >> $ps # my line
gmt psxy -Rkkt_relief.nc -J -W1p,yellow trenchN.txt -O -K >> $ps # my line
#
# Step-7. Add texts
gmt pstext -R -J -N -O -K \
-F+jTL+f18p,Times-Roman,blue+jLB -Gwhite >> $ps << EOF
148.0 53.0 Sea of Okhotsk
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Times-Roman,black+jLB+a-75 -Gwhite -Wthinnest >> $ps << EOF
145.0 54.5 Deryugin Basin
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Times-Roman,black+jLB -Gwhite -Wthinnest >> $ps << EOF
146.0 55.5 Barite Mts.
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Times-Roman,black+jLB+a-326 -Gwhite -Wthinnest >> $ps << EOF
147.7 48.3 Academy of Sciences Rise
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Times-Roman,black+jLB+a-295 -Gwhite -Wthinnest >> $ps << EOF
158.0 54.0 Kamchatka Peninsula
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Times-Roman,black+jLB+a-270 -Gwhite -Wthinnest >> $ps << EOF
143.0 49.0 Sakhalin Island
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Times-Roman,black+jLB -Gwhite -Wthinnest >> $ps << EOF
141.5 43.2 Hokkaido
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Times-Roman,black+jRB -Gwhite@30 -Wthinnest >> $ps << EOF
146.0 44.7 Kunashir
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f22p,Times-Roman,white+jLB >> $ps << EOF
160.0 46.0 Pacific Ocean
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
-F+jTL+f14p,Times-Roman,blue=0.2p,black+jLB+a-329 -Gwhite >> $ps << EOF
147.1 45.2 G r e a t e r  .
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
-F+jTL+f14p,Times-Roman,blue=0.2p,black+jLB+a-307 -Gwhite >> $ps << EOF
151.4 47.0 K u r i l  C h a i n
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
-F+jTL+f15p,Times-Roman,blue+jLB -Gwhite >> $ps << EOF
165.2 58.5 Bering Sea
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
-F+jTL+f14p,Times-Roman,black+jLB+a-40 -Gwhite -Wthinnest >> $ps << EOF
163.8 58.0 Commandor Basin
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
-F+jTL+f14p,Times-Roman,black+jLB -Gwhite -Wthinnest >> $ps << EOF
156.2 43.2 Bussol Strait
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
-F+jTL+f14p,Times-Roman,black+jLB -Gwhite -Wthinnest >> $ps << EOF
154.0 41.0 Northwest Pacific Abyssal Plain
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
-F+jTL+f14p,Times-Roman,black+jLB -Gwhite -Wthinnest >> $ps << EOF
164.1 43.0 Shatsky Ridge
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
-F+jTL+f14p,Times-Roman,black+jLB+a-330 -Gwhite -Wthinnest>> $ps << EOF
146.0 46.0 Kuril Basin
EOF
# 2. вектор: стрелки тонкие с желтым кружком в начале и острием в конце.
# kwargs: координаты, угол наклона, длина
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p,yellow -O -K >> $ps << EOF
155.9 43.8 135 1.5c
EOF
# Step-17. Add GMT logo
gmt logo -Dx6.2/-2.0+o0.1i/0.1i+w2c -O >> $ps
#gmt psxy -R -J -O -T >> $ps
# Step-18. Clean up (not necessary in this case)
#rm -f z.cpt ridge.txt table.txt env.txt stack.txt
# Step-19. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert cross2KKTU.ps -A0.5c -E720 -Tj -P -Z
