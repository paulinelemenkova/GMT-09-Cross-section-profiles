#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Mariana Trench
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
# Step-1. Generate a file
ps=MT2cross.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1.0c \
    MAP_ANNOT_OFFSET=0.2c \
    MAP_TICK_PEN_PRIMARY=thinnest,dimgray \
    MAP_GRID_PEN_PRIMARY=thinner,white \
    MAP_GRID_PEN_SECONDARY=thin,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    FONT_LABEL=10p,Palatino-Roman,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Extract a grid subset for the Philippine trench
grdcut GEBCO_2019.nc -R138.5/150/4/17 -Gmt_relief.nc
#grdcut earth_relief_01m.grd -R138.5/150/4/17 -Gmt_relief.nc
# earth_relief_01m.grd
# Step-5. Make color palette
gmt makecpt -Crainbow.cpt -V -T-12000/1000 > ocean.cpt
# Step-6. Make raster image
gmt grdimage mt_relief.nc -Cocean.cpt -R138.5/150/4/17 -JM12c \
    -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg135.75/4+w13.8c/0.4c+v+o0.3/0i+ml \
    -Rmt_relief.nc -J -Cocean.cpt \
	--FONT_LABEL=7p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    --MAP_ANNOT_OFFSET=0.1c \
    -Baf+l"Elevations (m). Artificial CPT 'rainbow':  magenta-blue-cyan-green-yellow-red [C=HSV]" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour mt_relief.nc -R -J -C1000 \
    -B+t"Mariana Trench: cross-section transect profiles" \
    -W0.1p -O -K >> $ps
# Step-9. Add grid
gmt psbasemap -R -J \
	-Lx10.0c/-1.2c+c50+w300k+l"Mercator Projection. Scale (km)"+f \
	-Bpxg4f2a2 -Bpyg4f2a1 -Bsxg4 -Bsyg2 \
    --FONT=9p,Palatino-Roman,black \
	-UBL/-5p/-35p -O -K >> $ps
#
# Mariana Trench
# Step-10.
cat << EOF > trenchM.txt
141.2 11.0
143.8 11.65
EOF
gmt psxy -Rmt_relief.nc -J -W2p,red trenchM.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.1i trenchM.txt -Gred -Wblack -O -K >> $ps # points
# Step-13. Generate cross-track profiles 400 km long, spaced 20 km, sampled every 2km
#gmt grdtrack trenchRT.txt -Gpct_relief.nc -C400k/2k/20k+v -Sa+sstackPCTn.txt > tablePCTn.txt
gmt grdtrack trenchM.txt -Gmt_relief.nc -C400k/2k/20k -Sm+sstackM.txt > tableM.txt
gmt psxy -R -J -Wthin,red tableM.txt -O -K >> $ps
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackM.txt -o0,5 > envM.txt
gmt convert stackM.txt -o0,6 -I -T >> envM.txt
# Step-12. Add subtitle
gmt pstext -R -J -X0.0c -Y0.0c -N -O -K \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
139.0 18.0 Bathymetry: GEBCO Global Relief Model 15 arc sec resolution grid
EOF
# Step-13. Add GMT logo
gmt logo -Dx4.8/-2.5+o0.1i/0.1i+w2c -O -K >> $ps
#
# PHILIPPINE Trench graph
gmt psxy -R-200/200/-12500/2000 -JX12.0c/5c -Y-7.8c envM.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya1000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=9p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=10p,Palatino-Roman,dimgray -BWeSn \
    -Glightgray -W0.5p -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackM.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackM.txt -O -K >> $ps
# Step-17. Add test annotations
echo "110 -2000 Philippine Sea" | gmt pstext -R -J -Gwhite -F+jBL+f10p,navyblue -O -K >> $ps
echo "100 -8000 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-180 -8000 Philippine Sea Plate" | gmt pstext -R -J -Gwhite -F+jBL+f10p,brown -O -K >> $ps
echo "-40 500 Mariana Trench" | gmt pstext -R -J -Gwhite -F+jBL+f10p,navyblue -O -K >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O << EOF >> $ps
0 0 270 1.7c
EOF
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert MT2cross.ps -A6.8c -E720 -Tj -P -Z
