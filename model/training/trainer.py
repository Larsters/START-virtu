import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from catboost import CatBoostRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, r2_score, root_mean_squared_error
import os
from pathlib import Path

# Load your dataset
data_path = "/Users/vasiliyklyosov/Documents/dev/hackatons/START/model/data/dataexport_20250320T024152.csv"

# Check if file exists
if not os.path.exists(data_path):
    print(f"Error: File not found at {data_path}")
    # List files in the directory to help find the correct file
    data_dir = os.path.dirname(data_path)
    if os.path.exists(data_dir):
        print(f"Files in {data_dir}:")
        for file in os.listdir(data_dir):
            print(f"  - {file}")
    exit(1)

# Load the dataset
df = pd.read_csv(data_path, dtype=str, low_memory=False)

# Check if required columns exist
required_columns = ['lat', 'lon', 'asl']
missing_columns = [col for col in required_columns if col not in df.columns]
if missing_columns:
    print(f"Error: Missing required columns: {missing_columns}")
    print(f"Available columns: {df.columns.tolist()}")
    exit(1)

# Filter and convert numeric columns
if 'lat' in df.columns:
    # Filter out header rows if they got duplicated
    df = df[df["lat"] != "lat"]  
    df["lat"] = pd.to_numeric(df["lat"], errors='coerce')
    df["lon"] = pd.to_numeric(df["lon"], errors='coerce')
    df["asl"] = pd.to_numeric(df["asl"], errors='coerce')

print("Dataset successfully loaded")
print(f"Dataset shape: {df.shape}")
print("First few rows:")
print(df.head())

# Identify date columns (columns that start with digits)
date_columns = [col for col in df.columns if isinstance(col, str) and col[0].isdigit()]
print(f"Found {len(date_columns)} date columns")

if not date_columns:
    print("Warning: No date columns found.")
    print("Column names sample:", df.columns[:10])
    exit(1)

# Reshape the data
df_long = pd.melt(
    df, 
    id_vars=['location', 'lat', 'lon', 'asl', 'variable', 'unit', 'level', 'timeResolution', 'aggregation'],
    value_vars=date_columns,
    var_name='date',
    value_name='value'
)

# Convert values to numeric - more robust handling
print("Converting values to numeric...")
# Replace any commas with periods first
df_long['value'] = df_long['value'].str.replace(',', '.', regex=False)
# Replace empty strings with NaN
df_long['value'] = df_long['value'].replace('', np.nan)
# Convert to numeric and handle errors
df_long['value'] = pd.to_numeric(df_long['value'], errors='coerce')
# Check for any remaining non-numeric values
non_numeric_count = df_long['value'].isna().sum()
print(f"Non-numeric values after conversion: {non_numeric_count}")

# Convert date string to datetime
df_long['date'] = pd.to_datetime(df_long['date'], format='%Y%m%dT%H%M')

print("Reshaped dataset first few rows:")
print(df_long.head())

# Process by variable type instead of pivoting all at once
print("Processing temperature data...")
# Filter only temperature data
temp_data = df_long[df_long['variable'].str.contains('temperature', case=False, na=False)]

# Create a simpler pivot table just for temperature
df_temp = temp_data.pivot_table(
    index=['location', 'lat', 'lon', 'date'],
    columns='variable',
    values='value',
    aggfunc='mean'  # Use mean if there are duplicates
).reset_index()

print("Temperature pivot table first few rows:")
print(df_temp.head())

# Extract date features
df_temp['month'] = df_temp['date'].dt.month
df_temp['day_of_year'] = df_temp['date'].dt.dayofyear
df_temp['day_of_month'] = df_temp['date'].dt.day

# Identify temperature columns
temp_columns = [col for col in df_temp.columns if 'temperature' in str(col).lower()]
print(f"Temperature columns: {temp_columns}")

if not temp_columns:
    print("No temperature columns found after pivoting. Check variable names.")
    exit(1)

# Create target variables (next day's temperature)
for temp_col in temp_columns:
    # Group by location and create shifted values
    df_temp[f'{temp_col}_next_day'] = df_temp.groupby(['location'])[temp_col].shift(-1)

# Choose first temperature column as target
target_column = f"{temp_columns[0]}_next_day"
print(f"Using target column: {target_column}")

# Drop rows with NaN in target
df_temp.dropna(subset=[target_column], inplace=True)

# Select features
features = []
# Add geographical features
features.extend(['lat', 'lon'])
# Add time features
features.extend(['month', 'day_of_year', 'day_of_month'])
# Add temperature column as a feature
features.append(temp_columns[0])

print(f"Using features: {features}")

# Prepare data for modeling
X = df_temp[features]
y = df_temp[target_column]

# Split into train, validation, and test sets (60/20/20)
X_train, X_temp, y_train, y_temp = train_test_split(X, y, test_size=0.4, random_state=42)
X_val, X_test, y_val, y_test = train_test_split(X_temp, y_temp, test_size=0.5, random_state=42)

print(f"Train set: {X_train.shape[0]} samples")
print(f"Validation set: {X_val.shape[0]} samples")
print(f"Test set: {X_test.shape[0]} samples")

# Create directory for saved models if it doesn't exist
model_dir = "/Users/vasiliyklyosov/Documents/dev/hackatons/START/model/saved_models"
os.makedirs(model_dir, exist_ok=True)

# Train CatBoost model
model = CatBoostRegressor(
    iterations=100,
    learning_rate=0.05,
    depth=6,
    loss_function='RMSE',
    eval_metric='RMSE',
    early_stopping_rounds=50,
    verbose=100
)

# Train with validation set
model.fit(
    X_train, y_train,
    eval_set=(X_val, y_val),
    use_best_model=True
)

# Evaluate on test set
y_pred = model.predict(X_test)

# Calculate metrics using correct functions
rmse = root_mean_squared_error(y_test, y_pred)
mae = mean_absolute_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)

print(f"Temperature Prediction RMSE: {rmse:.3f}")
print(f"Temperature Prediction MAE: {mae:.3f}")
print(f"Temperature Prediction R²: {r2:.3f}")

# Feature importance
feature_importance = model.get_feature_importance()
feature_names = np.array(features)
sorted_idx = np.argsort(feature_importance)
plt.figure(figsize=(10, 6))
plt.barh(range(len(sorted_idx)), feature_importance[sorted_idx])
plt.yticks(range(len(sorted_idx)), feature_names[sorted_idx])
plt.title('Feature Importance')
plt.tight_layout()
plt.savefig('feature_importance.png')

# Scatter plot of predictions vs actual
plt.figure(figsize=(8, 8))
plt.scatter(y_test, y_pred, alpha=0.5)
plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--')
plt.xlabel('Actual Temperature')
plt.ylabel('Predicted Temperature')
plt.title('Predicted vs Actual Temperature')
plt.tight_layout()
plt.savefig('prediction_vs_actual.png')

# Save model
model_path = os.path.join(model_dir, "catboost_temp_forecast.cbm")
model.save_model(model_path)
print(f"Model saved as '{model_path}'")

# Create a simple prediction function to demonstrate usage
def predict_next_day_temp(model, location_lat, location_lon, current_temp, current_date):
    """
    Make a prediction for tomorrow's temperature
    
    Args:
        model: Trained CatBoost model
        location_lat: Latitude
        location_lon: Longitude
        current_temp: Current temperature
        current_date: Current date (datetime object)
    
    Returns:
        Predicted temperature for the next day
    """
    # Create a DataFrame with the feature values
    data = {
        'lat': [location_lat],
        'lon': [location_lon],
        'month': [current_date.month],
        'day_of_year': [current_date.timetuple().tm_yday],
        'day_of_month': [current_date.day],
        temp_columns[0]: [current_temp]
    }
    
    # Create a DataFrame
    pred_df = pd.DataFrame(data)
    
    # Make prediction
    return model.predict(pred_df[features])[0]

# Example usage
from datetime import datetime
print("\nExample prediction:")
predicted_temp = predict_next_day_temp(
    model, 
    location_lat=-23.55, 
    location_lon=-46.63, 
    current_temp=25.0, 
    current_date=datetime.now()
)
print(f"Predicted tomorrow's temperature: {predicted_temp:.2f}°C")