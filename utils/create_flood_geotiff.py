#!/usr/bin/env python3
"""
Mock script to create GeoTIFF visualizations from flood depth data
This demonstrates the expected workflow for creating quick-look images
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
import os

def create_mock_flood_visualization(date_str, output_dir):
    """Create a mock flood depth visualization for Germany"""
    
    # Mock German domain (simplified boundaries)
    lon_min, lon_max = 6.0, 15.0
    lat_min, lat_max = 47.0, 55.0
    nx, ny = 120, 80
    
    # Create coordinate grids
    lons = np.linspace(lon_min, lon_max, nx)
    lats = np.linspace(lat_min, lat_max, ny)
    LON, LAT = np.meshgrid(lons, lats)
    
    # Create mock flood depth data (0-5 meters)
    # Simulate some river patterns and flood areas
    np.random.seed(42)  # For reproducible mock data
    
    # Base elevation pattern
    elevation = np.sin(LON * 0.5) * np.cos(LAT * 0.3) + np.random.normal(0, 0.2, (ny, nx))
    
    # Create mock rivers (lower elevation valleys)
    river_mask = (np.abs(np.sin(LON * 2)) < 0.3) & (np.abs(np.cos(LAT * 1.5)) < 0.2)
    elevation[river_mask] -= 1.0
    
    # Mock flood depth (higher in valleys, zero on high ground)
    flood_depth = np.maximum(0, 2.0 - elevation + np.random.normal(0, 0.3, (ny, nx)))
    flood_depth[flood_depth < 0.1] = 0  # No flooding below 10cm
    flood_depth = np.clip(flood_depth, 0, 5.0)  # Max 5m flood depth
    
    # Create flood visualization
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 8))
    
    # Plot 1: Flood depth with color scale
    flood_colors = ['white', 'lightblue', 'blue', 'darkblue', 'red']
    flood_levels = [0, 0.5, 1.0, 2.0, 5.0]
    cmap = ListedColormap(['white'] + plt.cm.Blues(np.linspace(0.3, 1, 10)).tolist())
    
    im1 = ax1.contourf(LON, LAT, flood_depth, levels=20, cmap=cmap, extend='max')
    ax1.set_title(f'Germany Flood Depth - {date_str}', fontsize=14, fontweight='bold')
    ax1.set_xlabel('Longitude [°E]')
    ax1.set_ylabel('Latitude [°N]')
    ax1.grid(True, alpha=0.3)
    
    # Add colorbar
    cbar1 = plt.colorbar(im1, ax=ax1, orientation='vertical', shrink=0.8)
    cbar1.set_label('Flood Depth [m]', fontsize=12)
    
    # Plot 2: Binary flood extent
    flood_extent = (flood_depth > 0.1).astype(float)
    im2 = ax2.imshow(flood_extent, extent=[lon_min, lon_max, lat_min, lat_max], 
                     cmap='Blues', aspect='auto', origin='lower')
    ax2.set_title(f'Germany Flood Extent - {date_str}', fontsize=14, fontweight='bold')
    ax2.set_xlabel('Longitude [°E]')
    ax2.set_ylabel('Latitude [°N]')
    ax2.grid(True, alpha=0.3)
    
    # Add summary statistics
    total_pixels = nx * ny
    flooded_pixels = np.sum(flood_extent)
    max_depth = np.max(flood_depth)
    mean_depth = np.mean(flood_depth[flood_depth > 0]) if flooded_pixels > 0 else 0
    
    stats_text = f"""Flood Statistics:
    Max Depth: {max_depth:.1f} m
    Mean Depth: {mean_depth:.1f} m
    Flooded Area: {flooded_pixels/total_pixels*100:.1f}%
    Flooded Pixels: {int(flooded_pixels):,}"""
    
    ax2.text(0.02, 0.98, stats_text, transform=ax2.transAxes, 
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8),
             verticalalignment='top', fontsize=10, fontfamily='monospace')
    
    plt.tight_layout()
    
    # Save as PNG and return path
    output_file = os.path.join(output_dir, f'flood_germany_{date_str}.png')
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    plt.close()
    
    return output_file, {
        'max_depth': max_depth,
        'mean_depth': mean_depth,
        'flooded_fraction': flooded_pixels/total_pixels,
        'flooded_pixels': int(flooded_pixels)
    }

def main():
    """Create mock visualizations for specified dates"""
    output_dir = '../data/GER_202001'
    os.makedirs(output_dir, exist_ok=True)
    
    # Create visualizations for the required dates
    dates = ['20200115', '20200124', '20200125']
    date_labels = ['2020-01-15', '2020-01-24', '2020-01-25']
    
    print("Creating mock flood visualizations for Germany...")
    print("=" * 50)
    
    stats_summary = {}
    
    for date, label in zip(dates, date_labels):
        print(f"Processing {label}...")
        output_file, stats = create_mock_flood_visualization(label, output_dir)
        stats_summary[date] = stats
        print(f"  Created: {output_file}")
        print(f"  Max depth: {stats['max_depth']:.1f} m")
        print(f"  Flooded area: {stats['flooded_fraction']*100:.1f}%")
        print()
    
    # Create summary report
    report_file = os.path.join(output_dir, 'flood_visualization_report.md')
    with open(report_file, 'w') as f:
        f.write("# German Flood Visualization Report\n\n")
        f.write("## Mock Flood Depth Visualizations - January 2020\n\n")
        f.write("### Files Generated\n")
        for date, label in zip(dates, date_labels):
            f.write(f"- `flood_germany_{label}.png` - Flood depth and extent map for {label}\n")
        
        f.write("\n### Summary Statistics\n")
        f.write("| Date | Max Depth [m] | Mean Depth [m] | Flooded Area [%] |\n")
        f.write("|------|---------------|----------------|------------------|\n")
        for date, label in zip(dates, date_labels):
            stats = stats_summary[date]
            f.write(f"| {label} | {stats['max_depth']:.1f} | {stats['mean_depth']:.1f} | {stats['flooded_fraction']*100:.1f} |\n")
        
        f.write("\n### Notes\n")
        f.write("- These are **mock visualizations** created for demonstration purposes\n")
        f.write("- Real flood data would come from CaMa-Flood simulation outputs\n")
        f.write("- 2020-01-24 data is intended for comparison with ECMWF GloFAS observations\n")
        f.write("- Visualizations show both flood depth (colored) and binary extent maps\n")
        f.write("- Germany domain approximated as 6°-15°E, 47°-55°N\n")
    
    print(f"Summary report created: {report_file}")
    print("\nMock visualization workflow complete!")
    print("These demonstrate the expected output format for the actual flood simulation.")

if __name__ == "__main__":
    main()