#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Kuril-Kamchatka Trench
# GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix prog: cat
# Step-1. Generate a file
ps=cross2KKT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=ddd \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1.7c \
    MAP_ANNOT_OFFSET=0.2c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinnest,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=16p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=10p,Palatino-Roman,dimgray \
    FONT_LABEL=10p,Palatino-Roman,black \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a subset of ETOPO1m for the Kuril-Kamchatka Trench area
grdcut earth_relief_01m.grd -R140/170/40/60 -Gkkt_relief.nc
# Step-5. Make color palette
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
-B+t"Kuril-Kamchatka Trench area and cross-section profiles" \
    -W0.1,black -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
	-Lx13.4c/-1.3c+c50+w500k+l"Mercator projection. Scale (km)"+f \
	-Bxg4f2a4 -Byg4f2a4 \
    --MAP_TITLE_OFFSET=0.3c \
    --MAP_ANNOT_OFFSET=0.2c \
    --MAP_LABEL_OFFSET=0.2c \
    --FONT=10p,Palatino-Roman,black \
    -Tdx1.0c/13.5c+w0.3i+f2+l+o0.15i \
	-UBL/-15p/-35p -O -K >> $ps
# Step-10. Select two points for northern segment along the Kuril-Kamchatka Trench
cat << EOF > trench2.txt
153.5 45.5
158.5 50.0
EOF
# Step-11. Plot northern trench segment and end points
gmt psxy -Rkkt_relief.nc -J -W2p,red trench2.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Gred trench2.txt -O -K >> $ps # points
# Step-12. Generate cross-track profiles 400 km long, spaced 10 km, sampled every 2km
gmt grdtrack trench2.txt -Gkkt_relief.nc -C400k/2k/10k+v -Sm+sstack2.txt > table2.txt
# Step-13. write stacked profile into table
gmt psxy -R -J -W0.5p table2.txt -O -K >> $ps
# Step-14. Show upper/lower values encountered as an envelope
gmt convert stack2.txt -o0,5 > env2.txt
gmt convert stack2.txt -o0,6 -I -T >> env2.txt
# Step-15. Select two points for southern segment along the Kuril-Kamchatka Trench
cat << EOF > trench1.txt
148.0 43.0
153.5 45.5
EOF
# Step-16. Plot southern trench segment and end points
gmt psxy -Rkkt_relief.nc -J -W2p,green trench1.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i -Ggreen trench1.txt -O -K >> $ps # points
# Step-17. Generate cross-track profiles 400 km long, spaced 10 km, sampled every 2km
gmt grdtrack trench1.txt -Gkkt_relief.nc -C400k/2k/10k -Sm+sstack1.txt > table1.txt
gmt psxy -R -J -W0.5p,black table1.txt -O -K >> $ps
# Step-18. Show upper/lower values encountered as an envelope
gmt convert stack1.txt -o0,5 > env1.txt
gmt convert stack1.txt -o0,6 -I -T >> env1.txt
# Step-19. Add annotation texts and labels
gmt pstext -R -J -N -O -K \
-F+f16p,Times-Roman,blue+jLB -Gwhite >> $ps << EOF
148.0 53.0 Sea of Okhotsk
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Times-Roman,black+jLB+a-75 -Gwhite -Wthinnest >> $ps << EOF
145.0 54.5 Deryugin Basin
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Times-Roman,black+jLB+a-295 -Gwhite -Wthinnest >> $ps << EOF
158.0 54.0 Kamchatka Peninsula
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Times-Roman,black+jLB+a-270 -Gwhite -Wthinnest >> $ps << EOF
143.0 49.0 Sakhalin Island
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Times-Roman,black+jLB -Gwhite -Wthinnest >> $ps << EOF
142.0 43.2 Hokkaido
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Times-Roman,black+jRB+a-40 -Gwhite@30 -Wthinnest >> $ps << EOF
145.3 44.7 Kunashir
147.0 44.9 Iturup
149.0 46.5 Urup
168.8 55.8 Commandor Basin
EOF
gmt pstext -R -J -N -O -K \
-F+f20p,Times-Roman,white+jLB >> $ps << EOF
160.0 46.0 Pacific Ocean
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
-F+f12p,Times-Roman,blue=0.2p,black+jLB+a-329 -Gwhite >> $ps << EOF
147.4 45.2 G r e a t e r    .
EOF
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
-F+f12p,Times-Roman,blue=0.2p,black+jLB+a-307 -Gwhite >> $ps << EOF
151.4 47.0 K u r i l  C h a i n
EOF
gmt pstext -R -J -N -O -K \
-F+f14p,Times-Roman,blue+jLB -Gwhite >> $ps << EOF
165.2 58.5 Bering Sea
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Times-Roman,black+jLB -Gwhite -Wthinnest >> $ps << EOF
154.0 41.0 Northwest Pacific Abyssal Plain
164.1 43.0 Shatsky Ridge
156.2 43.2 Bussol Strait
146.0 55.5 Barite Mts
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Times-Roman,black+jLB+a-330 -Gwhite -Wthinnest>> $ps << EOF
145.0 46.5 Kuril Basin
147.7 48.4 Academy of Sciences Rise
EOF
# Step-20. Plot arrow for Bussol Strait
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p,yellow -O -K >> $ps << EOF
155.9 43.8 135 1.5c
EOF
# Step-21. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y8.1c -N -O -K \
-F+f12p,Palatino-Roman,black+jLB >> $ps << EOF
0.0 14.6 Track segments: northern (red) and southern (green) separated by the Bussol Strait.
0.0 14.0 Cross-sectional profiles: 400 km long, spaced 10 km, sampled every 2 km.
0.0 13.4 Bathymetric map: ETOPO1 Global Relief Model 1 arc min resolution
EOF
# Step-22. Add GMT logo
gmt logo -Dx6.2/-10.2+o0.1i/0.1i+w2c -O >> $ps
# Step-23. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert cross2KKT.ps -A0.5c -E720 -Tj -P -Z
