#!/bin/sh
# Purpose: Generating and plotting stacked cross-sectioning bathymetric profiles
# Area: along the track of the Hikurangi trench
# Profiles info: 400 km long, spaced 20 km, sampled every 2km
# # GMT modules: grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, psxy, grdtrack, convert, pstext, logo, psconvert
# Unix progs: echo, rm, cat
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
# Step-4. Extract a subset of GEBCO for the Hikurangi trench
grdcut GEBCO_2019.nc -R172/182/-44.5/-34 -Gh_relief.nc
#grdcut ETOPO1_Ice_g_gmt4.grd -R172/182/-44.5/-34 -Gh_relief.nc
# Step-5. Make color palette
gmt makecpt -Crelief -V -T-8000/1000 > ocean.cpt
#gmt makecpt -Celevation -V -T-3487/2971 > myoceanMAK.cpt

# START
# Step-1. Generate a file
ps=HcrossPG.ps
# Step-6. Make raster image
gmt grdimage h_relief.nc -Cocean.cpt -R172/182/-44.5/-34 -JM15c \
    -P -I+a15+ne0.75 -Xc -K > $ps
# Step-7. Add color legend
gmt psscale -Dg169.7/-44.5+w20.0c/0.4c+v+o0.3/0i+ml \
    -Rh_relief.nc -J -Cocean.cpt \
	--FONT_LABEL=11p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=10p,Helvetica,black \
    --MAP_ANNOT_OFFSET=0.1c \
    -Baf+l"Elevations (m). CPT 'relief': Wessel/Martinez colors for topography [R=-8000/+8000, H=0, C=RGB]" \
	-I0.2 -By+lm -O -K >> $ps
# Step-8. Add shorelines
gmt grdcontour h_relief.nc -R -J -C500 \
    -B+t"Hikurangi Trench: cross-sectional profiles" \
    --FONT_TITLE=16p,Helvetica,black \
    -W0.1p -O -K >> $ps
# Step-9. Add grid
# -Lx11.0c/1.2c+c50+w300k+l"Mercator Projection. Scale (km)"+f
gmt psbasemap -R -J \
	-Bpxg2f1a2 -Bpyg4f2a1 -Bsxg2 -Bsyg2 \
    --FONT_TITLE=15p,Helvetica,black \
    --FONT_LABEL=10p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=10p,Helvetica,black -O -K >> $ps
# SEGMENT
cat << EOF > trenchHis.txt
177.0 -41.7
174.2 -42.6
EOF
gmt psxy -Rh_relief.nc -J -W2p,darkslateblue trenchHis.txt -O -K >> $ps # my line
gmt psxy -R -J -Sc0.15i trenchHis.txt -Gdarkslateblue -Wdarkslateblue -O -K >> $ps # points
# Step-13. Cross-track profiles 400 km long, spaced 20 km, sampled every 2km
gmt grdtrack trenchHis.txt -Gh_relief.nc -C400k/2k/20k+v -Sm+sstackHis.txt > tableHis.txt
gmt psxy -R -J -Wthin,darkslateblue tableHis.txt -O -K >> $ps
# Step-15. Show upper/lower values encountered as an envelope
gmt convert stackHis.txt -o0,5 > envHis.txt
gmt convert stackHis.txt -o0,6 -I -T >> envHis.txt
#
# GRAPH
gmt psxy -R-200/200/-5000/1000 -JX15.2c/5c -Y-6.2c envHis.txt \
    -Bpxag100f10+l"Distance from trench (km)"\
    -Bpya1000gf+l"Depth (m)" \
    -Bsxg50 -Bsyg1000 \
    --FONT_ANNOT_PRIMARY=11p,Palatino-Roman,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    --FONT_LABEL=12p,Palatino-Roman,dimgray -BWeSn \
    -UBL/-5p/-35p -Glightgray -W0.5p -O -K >> $ps
gmt psxy -R -J -W1.0p -Ey+p0.2p stackHis.txt -O -K >> $ps
gmt psxy -R -J -W1.0p,red stackHis.txt -O -K >> $ps
# Step-17. Add test annotations
echo "110 -4000 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jBL+f11p,brown -O -K >> $ps
echo "-40 500 Hikurangi Trench" | gmt pstext -R -J -Gwhite -F+jBL+f11p,navyblue -O -K >> $ps
echo "-190 -4500 Cross-section transect" | gmt pstext -R -J -F+jBL+f12p,black -Gfloralwhite -W0.5p -O -K >> $ps
# Step-17. Arrow
gmt psxy -R -J -Sv0.15i+bc+ea -Gyellow -W0.5p -O -K << EOF >> $ps
0 0 270 1.7c
EOF
# Step-18. Add GMT logo
gmt logo -Dx6.5/-2.3+w2c -O -K >> $ps
# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y20.2c -N -O \
    -F+f12p,Helvetica,black+jLB >> $ps << EOF
1.5 11.3 GEBCO DEM Global Relief Model 15 arc sec resolution grid
EOF
# Step-20. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert HcrossPG.ps -A6.0c -E720 -Tj -P -Z
