#!/bin/bash
#==========================================================
# Mock data preparation script for German flood simulation
# Creates placeholder structures for the German domain setup
#==========================================================

echo "Setting up German flood simulation data structure..."

BASE_DIR="/home/runner/work/CaMa-Flood_v4/CaMa-Flood_v4"
GER_MAP_DIR="$BASE_DIR/map/ger_6min"
GER_INP_DIR="$BASE_DIR/inp/efas_ger"
GER_OUT_DIR="$BASE_DIR/out/ger_202001"

# Create directory structure
mkdir -p "$GER_MAP_DIR"
mkdir -p "$GER_INP_DIR" 
mkdir -p "$GER_OUT_DIR"
mkdir -p "$BASE_DIR/data/GER_202001"

echo "Created directory structure:"
echo "- Map data: $GER_MAP_DIR"
echo "- Input forcing: $GER_INP_DIR"
echo "- Output: $GER_OUT_DIR"
echo "- Final data: $BASE_DIR/data/GER_202001"

# Create placeholder dimension info file
cat > "$GER_MAP_DIR/diminfo_efas_ger.txt" << EOF
# Dimension information for EFAS Germany domain
# Placeholder - needs real German coordinates
NX    120    # Number of longitude points (example)
NY    80     # Number of latitude points (example) 
WEST  6.0    # Western boundary (degrees)
EAST  15.0   # Eastern boundary (degrees)
SOUTH 47.0   # Southern boundary (degrees)
NORTH 55.0   # Northern boundary (degrees)
INPN2XY 0    # Input order: 0=WE->SN, 1=SN->WE
EOF

# Create placeholder README for data requirements
cat > "$GER_MAP_DIR/README_DATA_NEEDED.md" << EOF
# Data Required for German Flood Simulation

## River Network Maps (Binary Format)
- \`nextxy.bin\` - Downstream connectivity (2-byte integers)
- \`ctmare.bin\` - Catchment area per pixel (4-byte floats) [m²]
- \`elevtn.bin\` - Channel elevation (4-byte floats) [m]
- \`nxtdst.bin\` - Distance to downstream pixel (4-byte floats) [m]
- \`rivlen.bin\` - River channel length (4-byte floats) [m]
- \`fldhgt.bin\` - Floodplain height profile (4-byte floats) [m]

## Channel Parameters
- \`rivwth.bin\` - Channel width (4-byte floats) [m]
- \`rivhgt.bin\` - Channel depth (4-byte floats) [m]  
- \`rivman.bin\` - Manning coefficient (4-byte floats)

## Input Processing
- \`inpmat_efas_ger.bin\` - Input interpolation matrix for EFAS→CaMa grid
- \`bifprm.txt\` - Bifurcation parameters (text file)

## Tools Needed
1. **\`mk_map\`** - Generate river network from 6-arcmin DEM clipped to Germany
2. **\`mk_fldtbl\`** - Generate bankfull heights and flood tables
3. **DEM clipping** - Extract German domain from global datasets

## Data Sources
- **DEM**: MERIT DEM or similar 6-arcmin global dataset
- **Runoff**: EFAS 3-hourly data for 2020-01 (\`EFAS_3h_GER_2020.nc\`)
- **Domain**: Germany political boundaries
EOF

echo "Created placeholder files:"
echo "- $GER_MAP_DIR/diminfo_efas_ger.txt"
echo "- $GER_MAP_DIR/README_DATA_NEEDED.md"

# Create placeholder for EFAS data info
cat > "$GER_INP_DIR/EFAS_DATA_INFO.md" << EOF
# EFAS Data Requirements

## Required File
- **Filename**: \`EFAS_3h_GER_2020.nc\`
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
- Requires input matrix (\`inpmat_efas_ger.bin\`) for spatial interpolation
EOF

echo "Created EFAS data requirements: $GER_INP_DIR/EFAS_DATA_INFO.md"

# Create mock post-processing scripts
cat > "$BASE_DIR/utils/convert_fld_to_netcdf.py" << 'EOF'
#!/usr/bin/env python3
"""
Mock post-processing script to convert daily flood binary files to NetCDF
This is a placeholder - would need real implementation with proper dimensions
"""

import numpy as np
import netCDF4 as nc
from datetime import datetime, timedelta
import os
import glob

def convert_daily_fld_to_netcdf(input_dir, output_file, nx=120, ny=80):
    """
    Convert daily outfldYYYYMMDD.bin files to single NetCDF file
    """
    print(f"Converting daily flood files to {output_file}")
    
    # Find all daily flood files
    fld_files = sorted(glob.glob(os.path.join(input_dir, "outfld*.bin")))
    
    if not fld_files:
        print("No outfldYYYYMMDD.bin files found!")
        return
    
    print(f"Found {len(fld_files)} daily flood files")
    
    # Create output NetCDF file (mock structure)
    with nc.Dataset(output_file, 'w', format='NETCDF4') as ncout:
        # Define dimensions
        ncout.createDimension('time', len(fld_files))
        ncout.createDimension('lat', ny)
        ncout.createDimension('lon', nx)
        
        # Define variables
        times = ncout.createVariable('time', 'f8', ('time',))
        lats = ncout.createVariable('lat', 'f4', ('lat',))
        lons = ncout.createVariable('lon', 'f4', ('lon',))
        flddph = ncout.createVariable('flddph', 'f4', ('time', 'lat', 'lon'), 
                                      fill_value=-999.0)
        
        # Add attributes
        ncout.title = "Daily Flood Depth - Germany January 2020"
        ncout.source = "CaMa-Flood v4 with daily inundation output"
        ncout.description = "Daily flood inundation depth for Germany domain"
        
        times.units = "days since 2020-01-01 00:00:00"
        times.calendar = "gregorian"
        lats.units = "degrees_north"
        lons.units = "degrees_east"
        flddph.units = "m"
        flddph.long_name = "flood inundation depth"
        
        # Mock coordinate data (would need real German domain coordinates)
        lons[:] = np.linspace(6.0, 15.0, nx)  # Placeholder German longitudes
        lats[:] = np.linspace(47.0, 55.0, ny)  # Placeholder German latitudes
        
        # Time values
        base_time = datetime(2020, 1, 1)
        for i in range(len(fld_files)):
            times[i] = i  # Days since start
            
        print(f"NetCDF structure created: {nx}x{ny} grid, {len(fld_files)} time steps")

if __name__ == "__main__":
    # Example usage
    input_dir = "../out/ger_202001"
    output_file = "../data/GER_202001/fld_ger_daily_202001.nc"
    
    print("Mock NetCDF conversion script")
    print("This would convert binary outfldYYYYMMDD.bin files to NetCDF")
    print(f"Input: {input_dir}/outfld*.bin")
    print(f"Output: {output_file}")
    print("Note: Requires actual binary files to process")
EOF

chmod +x "$BASE_DIR/utils/convert_fld_to_netcdf.py"

echo "Created post-processing script: $BASE_DIR/utils/convert_fld_to_netcdf.py"

echo ""
echo "German flood simulation framework setup complete!"
echo ""
echo "Next steps:"
echo "1. Obtain real German DEM and river network data"
echo "2. Clip and process data using mk_map and mk_fldtbl tools"
echo "3. Obtain EFAS 3-hourly runoff data for January 2020"
echo "4. Run simulation: cd out/ger_202001 && ../../gosh/run_ger_202001.sh"
echo "5. Post-process results to NetCDF and GeoTIFF formats"