# German Flood Visualization Report

## Mock Flood Depth Visualizations - January 2020

### Overview
This report documents the expected output format for flood visualizations from the German flood simulation. The actual visualizations would be generated from the `outfldYYYYMMDD.bin` files produced by CaMa-Flood.

### Required Visualizations

#### 1. Quick-look GeoTIFF for 2020-01-15
- **File**: `flood_germany_2020-01-15.tif`
- **Purpose**: Mid-month sample visualization
- **Content**: 2D flood depth map with color scale (0-5+ meters)
- **Format**: GeoTIFF with proper German coordinate system
- **Resolution**: 6-arcmin (~10 km at this latitude)

#### 2. Validation Map for 2020-01-24  
- **File**: `flood_germany_2020-01-24.tif`
- **Purpose**: Comparison with ECMWF GloFAS observations
- **Content**: Flood extent and depth for QA validation
- **Special**: This date chosen for available reference flood data

#### 3. Quick-look GeoTIFF for 2020-01-25
- **File**: `flood_germany_2020-01-25.tif`  
- **Purpose**: Additional sample visualization
- **Content**: Similar to 2020-01-15 but different flood conditions

### Processing Workflow

#### Step 1: Binary to Array Conversion
```bash
# Read daily flood file (example for Jan 15)
python3 utils/read_flood_binary.py out/ger_202001/outfld20200115.bin
```

#### Step 2: GeoTIFF Creation
```bash
# Convert to georeferenced raster
gdal_translate -of GTiff -a_srs EPSG:4326 \
  -a_ullr 6.0 55.0 15.0 47.0 \
  raw_flood_data.bin flood_germany_2020-01-15.tif
```

#### Step 3: Visualization Enhancement
- Apply color ramps (blue scale for flood depth)
- Add contour lines for major depth levels (0.5m, 1m, 2m, 5m)
- Include legend, coordinate grid, and metadata

### Expected Statistics (Placeholder)
| Date | Max Depth [m] | Mean Depth [m] | Flooded Area [km²] | Comments |
|------|---------------|----------------|--------------------|----------|
| 2020-01-15 | TBD | TBD | TBD | Mid-month conditions |
| 2020-01-24 | TBD | TBD | TBD | **GloFAS validation date** |
| 2020-01-25 | TBD | TBD | TBD | Late month sample |

### Quality Assurance Notes

#### GloFAS Comparison (2020-01-24)
- Compare max flooded area extent with ECMWF GloFAS flood observations
- Validate spatial patterns of major flooding events
- Check timing alignment between model and observations
- Document any significant discrepancies

#### Technical Specifications
- **Coordinate System**: WGS84 Geographic (EPSG:4326)
- **Data Type**: 32-bit floating point
- **Units**: Meters above ground surface
- **NoData Value**: -999.0
- **Compression**: LZW or DEFLATE for file size optimization

### File Locations
- **Source Data**: `out/ger_202001/outfld*.bin` (31 daily files)
- **GeoTIFF Output**: `data/GER_202001/*.tif`
- **Visualization PNG**: `data/GER_202001/*.png` (for web display)
- **Metadata**: `data/GER_202001/flood_metadata.xml`

### Tools Required
- **GDAL**: For raster processing and format conversion
- **Python**: NumPy, matplotlib for data processing and plotting  
- **QGIS/ArcGIS**: Optional for advanced visualization and analysis

---

*Note: This is a template report. Actual statistics and maps will be populated after running the CaMa-Flood simulation with real German data and EFAS forcing.*