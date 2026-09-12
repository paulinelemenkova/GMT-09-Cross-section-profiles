# GMT Cross-Section Profiles — Bathymetric Trench Profiling Scripts

A collection of over 40 GMT (Generic Mapping Tools) shell scripts for generating and plotting stacked cross-sectional bathymetric profiles across ocean trenches. Serial cross-track profiles are sampled from a relief grid along a trench axis, stacked statistically, and plotted with error envelopes alongside a shaded-relief map of the profiling swath. The scripts have been used to generate figures across the author's marine-geomorphological and cartographic publications.

## What the scripts do

Each script builds a complete profile figure, typically chaining:

- grid clipping and subsetting (grdcut) over the trench area
- colour palette generation (makecpt) for the relief
- shaded-relief basemap rendering (grdimage) with contours (grdcontour), scale bar and rose (psbasemap)
- definition of a trench-axis line and plotting of its segment and end points (psxy)
- extraction of cross-track profiles of set length, spacing and sampling interval, with statistical stacking by mean or median (grdtrack -C ... -Sa / -Sm)
- plotting of the individual and stacked profiles with an upper/lower envelope and error bars (psxy, gmt convert)
- geological and tectonic annotations of plates, forearc and trench features (pstext)
- GMT logo (logo) and export to raster (psconvert) at high resolution

Typical profile geometry: profiles a few hundred km long, spaced ~10-20 km, sampled every ~2 km along track.

## Data source

Global relief / bathymetry: ETOPO1 (1 arc-minute), via GMT earth_relief tiles.

## File naming

Scripts follow GMT-09-...-XX.sh, where XX is an ocean-trench tag (e.g. MAT = Middle America Trench, KKT = Kuril-Kamchatka Trench, JT = Japan Trench, IBT = Izu-Bonin Trench, NBT, YPT, RT, MnT, NER = Ninetyeast Ridge). Suffixes _profiles, _graphs and _profiles+graphs indicate whether the script produces the map swath, the stacked-profile plot, or both; other suffixes mark segment (north/south) or styling variants.

## Requirements

- GMT 6.x (Generic Mapping Tools): https://www.generic-mapping-tools.org
- A POSIX shell (bash/sh)
- The relevant relief grid (ETOPO1 / earth_relief) available locally

## Usage

Place the required relief grid in the working directory, adjust the -R region and the trench-axis coordinates at the top of the chosen script, then run:

    bash GMT-09-profiles-MAT.sh

The script writes a PostScript file and converts it to a raster image (JPG/PNG) via psconvert.

## Author and citation

Polina Lemenkova
ORCID: https://orcid.org/0000-0002-5759-1089

These scripts accompany figures in the author's marine-geomorphological and cartographic papers; please cite the specific article a given figure appears in. The full publication list is available via the ORCID record above.

## License

See the LICENSE file in this repository.
