# CaMa-Flood v4 Run Configurations

This document tracks the run configurations and simulations performed with CaMa-Flood v4.

## German January 2020 Flood Simulation

### Configuration Summary
- **Run ID**: ger_202001
- **Domain**: Germany  
- **Time Period**: 2020-01-01 → 2020-01-31 (31 days)
- **Resolution**: 6-arcmin (to be implemented)
- **Forcing**: EFAS 3-hourly runoff data
- **Output**: Daily flood inundation depth (`outfldYYYYMMDD.bin`)

### Model Setup
- **Compilation Flags**: `-DINUND -DOUTFLD` (inundation + daily flood output)
- **OpenMP Threads**: 8
- **Time Step**: 3600 seconds (1 hour)
- **Output Frequency**: 24 hours (daily)

### Expected Outputs
- 31 daily binary files: `outfld20200101.bin` to `outfld20200131.bin`
- Each file contains 2D flood depth grid for Germany domain
- File format: Direct access binary, single precision (4 bytes per value)

### Post-Processing Pipeline
1. Binary to NetCDF conversion → `fld_ger_daily_202001.nc`
2. GeoTIFF generation for visualization (days 15 and 25)
3. Quality assurance against GloFAS observations (day 24)

### Validation Targets
- **Reference Date**: 2020-01-24 (comparison with ECMWF GloFAS)
- **Checksum**: TBD after simulation completion
- **Max Flooded Area**: TBD

### File Checksums
*To be populated after simulation completion*

| File | Size | MD5 | Notes |
|------|------|-----|-------|
| `outfld20200115.bin` | TBD | TBD | Mid-month sample |
| `outfld20200124.bin` | TBD | TBD | GloFAS validation |
| `outfld20200125.bin` | TBD | TBD | GeoTIFF sample |
| `fld_ger_daily_202001.nc` | TBD | TBD | Final NetCDF |

---

*Last Updated*: Initial setup - Implementation phase completed
*Status*: Ready for data preparation and execution