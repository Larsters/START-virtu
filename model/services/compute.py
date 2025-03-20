import pandas as pd

df = pd.read_csv("extracted_data.csv")

# Compute GDD
df["GDD"] = (df["TMAX"] + df["TMIN"]) / 2 - 10  # Tbase = 10°C

# Compute Heat Stress
df["HeatStress"] = 9 * ((df["TMAX"] - 30) / (40 - 30))  # Crop-specific thresholds

# Compute Drought Index
df["DroughtIndex"] = (df["Precipitation"] - df["Evapotranspiration"] + df["SoilMoisture"]) / df["TAVG"]

df.to_csv("final_dataset.csv", index=False)

