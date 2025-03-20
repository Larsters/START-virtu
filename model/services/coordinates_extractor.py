import pandas as pd
import requests
import json
from pathlib import Path
import time
from datetime import datetime, timedelta
import logging

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("historical_data_collection.log"),
        logging.StreamHandler()
    ]
)

# Get project root directory
PROJECT_ROOT = Path(__file__).parent.parent.parent
DATA_DIR = PROJECT_ROOT / "model" / "data"
POINTS_FILE = DATA_DIR / "state_random_points.csv"  # Using direct path to the csv file
OUTPUT_DIR = DATA_DIR / "historical_weather"

# Create necessary directories if they don't exist
DATA_DIR.mkdir(parents=True, exist_ok=True)
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Meteoblue API configuration
API_KEY = "7b29a207a0de"  # Replace with your actual API key
BASE_URL = f"http://my.meteoblue.com/dataset/query?apikey={API_KEY}"

# Updated Weather variables to collect (using only documented codes)
WEATHER_CODES = [
    {"code": 11, "level": "2 m above gnd", "aggregation": "mean"},   # Temperature
    {"code": 52, "level": "2 m above gnd", "aggregation": "sum"},    # Precipitation
    {"code": 157, "level": "180-0 mb above gnd", "aggregation": "sum"}  # Evapotranspiration
]

def get_historical_data(coordinates, location_name, start_date, end_date):
    """
    Fetch historical weather data for a specific location and time period
    
    Args:
        coordinates: [longitude, latitude] for the location
        location_name: Name of the location (for reference)
        start_date: Start date in YYYY-MM-DD format
        end_date: End date in YYYY-MM-DD format
        
    Returns:
        Dictionary with the API response data
    """
    payload = {
        "units": {
            "temperature": "C",
            "velocity": "km/h",
            "length": "metric",
            "energy": "watts"
        },
        "geometry": {
            "type": "Point",
            "coordinates": coordinates,
            "locationNames": [location_name]
        },
        "format": "json",
        "timeIntervals": [
            f"{start_date}T+00:00/{end_date}T+00:00"
        ],
        "queries": [{
            "domain": "ERA5T",
            "gapFillDomain": "NEMSGLOBAL",
            "timeResolution": "daily",
            "codes": WEATHER_CODES
        }]
    }
    
    try:
        response = requests.post(
            BASE_URL,
            headers={"Content-Type": "application/json"},
            data=json.dumps(payload)
        )
        
        if response.status_code == 200:
            return response.json()
        else:
            logging.error(f"Error for {location_name}: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        logging.error(f"Exception for {location_name}: {str(e)}")
        return None

def process_response(response_data, state, state_code, coordinates):
    """
    Process the API response and convert to DataFrame rows
    
    Args:
        response_data: API response JSON
        state: State name
        state_code: State code
        coordinates: [longitude, latitude]
        
    Returns:
        DataFrame with processed weather data
    """
    if not response_data or 'error' in response_data:
        logging.error(f"Invalid response for {state}: {response_data}")
        return pd.DataFrame()
    
    try:
        # Extract data series from response
        data_series = response_data.get('data', {}).get('series', [])
        
        if not data_series:
            logging.warning(f"No data series for {state}")
            return pd.DataFrame()
        
        # Extract time points
        timepoints = response_data.get('data', {}).get('timepoints', [])
        if not timepoints:
            logging.warning(f"No timepoints for {state}")
            return pd.DataFrame()
        
        # Create a dataframe with dates
        df = pd.DataFrame({'date': timepoints})
        
        # Add location information
        df['state'] = state
        df['state_code'] = state_code
        df['longitude'] = coordinates[0]
        df['latitude'] = coordinates[1]
        
        # Process each data series (weather variable)
        for series in data_series:
            variable_name = series.get('metadata', {}).get('name', 'unknown')
            code = series.get('metadata', {}).get('code', 'unknown')
            level = series.get('metadata', {}).get('level', 'unknown')
            aggregation = series.get('metadata', {}).get('aggregation', 'unknown')
            
            # Create column name from variable details
            column_name = f"{variable_name}_{code}_{aggregation}"
            
            # Add data values to dataframe
            df[column_name] = series.get('data', [])
        
        return df
    
    except Exception as e:
        logging.error(f"Error processing response for {state}: {str(e)}")
        return pd.DataFrame()

def collect_historical_data(output_dir, days=10, specific_year=2023):
    """
    Collect historical weather data for Brazil's major cities
    
    Args:
        output_dir: Directory to save output files
        days: Number of days to collect data for
        specific_year: Year to collect data from
        
    Returns:
        Path to the output CSV file
    """
    # Create sample points for Brazil's most important cities
    # Format: [state, state_code, city, longitude, latitude]
    sample_points = [
        ["São Paulo", "SP", "São Paulo", -46.6333, -23.5505],
        ["Rio de Janeiro", "RJ", "Rio de Janeiro", -43.1729, -22.9068],
        ["Brasília", "DF", "Brasília", -47.9292, -15.7801],
        ["Salvador", "BA", "Salvador", -38.5011, -12.9716],
        ["Fortaleza", "CE", "Fortaleza", -38.5434, -3.7172],
        ["Belo Horizonte", "MG", "Belo Horizonte", -43.9266, -19.9208],
        ["Manaus", "AM", "Manaus", -60.0207, -3.1133],
        ["Curitiba", "PR", "Curitiba", -49.2699, -25.4297],
        ["Recife", "PE", "Recife", -34.8811, -8.0539],
        ["Porto Alegre", "RS", "Porto Alegre", -51.2305, -30.0330],
    ]
    
    # Setup date range for the specified year
    start_date = datetime(specific_year, 1, 1)
    end_date = start_date + timedelta(days=days-1)
    
    start_date_str = start_date.strftime('%Y-%m-%d')
    end_date_str = end_date.strftime('%Y-%m-%d')
    
    logging.info(f"Collecting data from {start_date_str} to {end_date_str}")
    
    # Create empty list to store all data
    all_data = []
    
    # Process each point
    for point in sample_points:
        state, state_code, city, longitude, latitude = point
        
        logging.info(f"Processing point for {city}, {state} ({state_code})")
        
        # Get historical data
        response_data = get_historical_data(
            [longitude, latitude],
            city,
            start_date_str,
            end_date_str
        )
        
        if response_data:
            # Process response
            processed_df = process_response(
                response_data,
                state,
                state_code,
                [longitude, latitude]
            )
            
            if not processed_df.empty:
                # Add city column
                processed_df['city'] = city
                all_data.append(processed_df)
            
            # Add delay to avoid rate limiting
            time.sleep(1)
    
    # Combine all data
    if all_data:
        combined_df = pd.concat(all_data, ignore_index=True)
        
        # Save to CSV
        timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
        output_file = output_dir / f"historical_weather_data_{specific_year}_{timestamp}.csv"
        combined_df.to_csv(output_file, index=False)
        
        logging.info(f"Data collection complete. Saved to {output_file}")
        return output_file
    else:
        logging.error("No data collected!")
        return None

if __name__ == "__main__":
    # Use a specific year (2023) and collect 10 days of data
    output_file = collect_historical_data(OUTPUT_DIR, days=10, specific_year=2023)
    
    if output_file:
        print(f"\nData collection complete. Final dataset saved to: {output_file}")
        
        # Load and show summary stats of the collected data
        final_df = pd.read_csv(output_file)
        print(f"\nDataset summary:")
        print(f"Total records: {len(final_df)}")
        print(f"Cities covered: {final_df['city'].nunique()}")
        print(f"States covered: {final_df['state'].nunique()}")
        print(f"Date range: {final_df['date'].min()} to {final_df['date'].max()}")
        print(f"Variables collected: {len(final_df.columns) - 6}")  # Excluding date and location columns
    else:
        print("Data collection failed. Check logs for details.")