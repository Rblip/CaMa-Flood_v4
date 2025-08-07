# German Flood Simulation Documentation

## Overview
This directory contains the implementation for generating daily gridded flood-inundation dataset (FLD) for Germany for January 2020 using CaMa-Flood v4.

## Implementation Features

### Build Modifications
- **Inundation flags**: Added `-DINUND -DOUTFLD` compilation flags to enable inundation modeling and daily flood output
- **OpenMP support**: Built with OpenMP for parallel execution
- **Custom Makefile**: Created `Mkinclude_ger_flood` for German simulation configuration

### Daily Flood Output Feature
- **New functionality**: Implemented daily flood file output when `DOUTFLD` flag is enabled
- **File format**: Creates separate binary files named `outfldYYYYMMDD.bin` for each day
- **Target output**: 31 files for January 2020 (20200101 to 20200131)

### Source Code Changes
- **Modified**: `src/cmf_ctrl_output_mod.F90`
  - Added conditional compilation for daily flood files (`#ifdef DOUTFLD`)
  - New subroutine `WRTE_DAILY_FLD` for daily file output
  - Modified file initialization to skip standard file opening for flood depth when daily mode enabled

### Configuration Files
- **Run script**: `gosh/run_ger_202001.sh` - Complete German simulation setup
- **Time period**: 2020-01-01 → 2020-01-31 (31 days)
- **Output frequency**: Daily (24-hour intervals)
- **Variable**: `flddph` (flood depth)

## File Structure Created
```
data/GER_202001/          # Target directory for final outputs
docs/                     # Documentation
out/ger_202001/          # Simulation runtime directory  
adm/Mkinclude_ger_flood  # Custom build configuration
gosh/run_ger_202001.sh   # German simulation script
```

## Next Steps Required
1. **Data Preparation**: 
   - Clip 6-arcmin DEM to Germany domain
   - Create German river map with `mk_map` tools
   - Generate bankfull heights & flood tables via `mk_fldtbl`

2. **Input Data Setup**:
   - Obtain EFAS 3-hourly runoff data (`EFAS_3h_GER_2020.nc`)
   - Create dimension info and input matrix files
   - Set up proper map directory structure

3. **Execution & Post-processing**:
   - Run simulation with `OMP_NUM_THREADS=8`
   - Convert binary outputs to NetCDF
   - Generate GeoTIFF visualizations
   - Quality assurance checks

## Technical Notes
- The `DINUND` and `DOUTFLD` flags are now implemented as custom extensions to CaMa-Flood
- Daily flood files use direct access binary format with single record per file
- Compatible with existing CaMa-Flood infrastructure and post-processing tools