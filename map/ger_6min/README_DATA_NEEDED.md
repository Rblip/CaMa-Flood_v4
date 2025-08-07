# Data Required for German Flood Simulation

## River Network Maps (Binary Format)
- `nextxy.bin` - Downstream connectivity (2-byte integers)
- `ctmare.bin` - Catchment area per pixel (4-byte floats) [m²]
- `elevtn.bin` - Channel elevation (4-byte floats) [m]
- `nxtdst.bin` - Distance to downstream pixel (4-byte floats) [m]
- `rivlen.bin` - River channel length (4-byte floats) [m]
- `fldhgt.bin` - Floodplain height profile (4-byte floats) [m]

## Channel Parameters
- `rivwth.bin` - Channel width (4-byte floats) [m]
- `rivhgt.bin` - Channel depth (4-byte floats) [m]  
- `rivman.bin` - Manning coefficient (4-byte floats)

## Input Processing
- `inpmat_efas_ger.bin` - Input interpolation matrix for EFAS→CaMa grid
- `bifprm.txt` - Bifurcation parameters (text file)

## Tools Needed
1. **`mk_map`** - Generate river network from 6-arcmin DEM clipped to Germany
2. **`mk_fldtbl`** - Generate bankfull heights and flood tables
3. **DEM clipping** - Extract German domain from global datasets

## Data Sources
- **DEM**: MERIT DEM or similar 6-arcmin global dataset
- **Runoff**: EFAS 3-hourly data for 2020-01 (`EFAS_3h_GER_2020.nc`)
- **Domain**: Germany political boundaries
