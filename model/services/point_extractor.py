import geopandas as gpd
import pandas as pd
import numpy as np
import random
from shapely.geometry import Point
import matplotlib.pyplot as plt
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent.parent

# Define relative paths
DATA_DIR = PROJECT_ROOT / "model" / "data"
GEOJSON_PATH = DATA_DIR / "brazil-states.geojson"
OUTPUT_PATH = DATA_DIR / "processed" / "state_random_points.csv"

(DATA_DIR / "processed").mkdir(parents=True, exist_ok=True)

def extract_random_points_per_state(geojson_path, points_per_state=20):
    """
    Extract random points from each state's boundary
    
    Args:
        geojson_path: Path to GeoJSON with state boundaries
        points_per_state: Number of random points to extract per state
        
    Returns:
        DataFrame with sampled points and their state info
    """
    states = gpd.read_file(geojson_path)
    
    all_points = []
    
    for idx, state in states.iterrows():
        state_name = state['name']
        state_code = state['sigla']
        state_geometry = state['geometry']
        
        minx, miny, maxx, maxy = state_geometry.bounds
        
        # Generate random points inside the state boundary
        state_points = []
        attempts = 0
        
        # Keep trying until we get enough points or too many attempts
        while len(state_points) < points_per_state and attempts < 1000:
            # Generate a random point within the bounding box
            x = random.uniform(minx, maxx)
            y = random.uniform(miny, maxy)
            point = Point(x, y)
            
            # Check if the point is inside the state boundary
            if state_geometry.contains(point):
                state_points.append({
                    'state': state_name,
                    'state_code': state_code,
                    'longitude': x,
                    'latitude': y
                })
            
            attempts += 1
        
        all_points.extend(state_points)
    
    # Convert to DataFrame
    points_df = pd.DataFrame(all_points)
    
    return points_df

def visualize_points(geojson_path, points_df):
    """Visualize the sampled points on a map of Brazil"""
    states = gpd.read_file(geojson_path)
    
    fig, ax = plt.subplots(figsize=(12, 20))
    states.plot(ax=ax, color='lightgrey', edgecolor='black')
    
    # Plot points
    for state_code, group in points_df.groupby('state_code'):
        ax.scatter(group['longitude'], group['latitude'], 
                  label=state_code, s=20, alpha=0.7)
    
    plt.title('Random Points from Brazilian States')
    plt.tight_layout()
    
    # Handle the legend - if there are many states, position it outside
    if len(points_df['state_code'].unique()) > 20:
        plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
    else:
        plt.legend()
        
    plt.savefig('random_state_points.png', bbox_inches='tight')
    plt.show()

# Example usage
if __name__ == "__main__":
    # Use the defined paths
    points_df = extract_random_points_per_state(GEOJSON_PATH, points_per_state=20)
    
    # Save points to CSV using relative path
    points_df.to_csv(OUTPUT_PATH, index=False)
    
    # Visualize points
    visualize_points(GEOJSON_PATH, points_df)
    
    print(f"Extracted {len(points_df)} points from {points_df['state'].nunique()} states")
    print(f"States with fewer than 20 points: {points_df.groupby('state').size()[points_df.groupby('state').size() < 20]}")