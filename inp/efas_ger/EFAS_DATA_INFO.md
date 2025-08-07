# EFAS Data Requirements

## Required File
- **Filename**: `EFAS_3h_GER_2020.nc`
- **Format**: NetCDF
- **Temporal Resolution**: 3-hourly
- **Period**: 2020-01-01 00:00 to 2020-01-31 21:00 (248 time steps)
- **Variables**: Surface runoff [mm/3h]
- **Domain**: Germany (coordinates matching German map domain)

## EFAS Information
- **Source**: European Flood Awareness System
- **Provider**: ECMWF (European Centre for Medium-Range Weather Forecasts)
- **Grid**: Typically 5km European grid
- **Website**: https://www.efas.eu/

## Processing Notes
- Data needs interpolation to CaMa-Flood 6-arcmin German grid
- Unit conversion: mm/3h → m/s (factor: 0.001/10800 ≈ 9.26e-8)
- Requires input matrix (`inpmat_efas_ger.bin`) for spatial interpolation
