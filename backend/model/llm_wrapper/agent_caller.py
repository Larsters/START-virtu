from datetime import datetime, timedelta
import json
import os
import argparse
from pathlib import Path
from langchain_openai import ChatOpenAI
from dotenv import load_dotenv
import numpy as np
from services.current_weather_service import get_current_weather, get_historical_weather_year_ago, get_historical_weather_two_year_ago
# from services.soil_service import fetch_soil_data
# from domain_logic.calculations import calculate_gdd, calculate_yield_risk
# from domain_logic.recommendations import recommend_fertilizer


class LLMAgent:
    def __init__(self):
        load_dotenv()
        api_key = os.getenv('OPENAI_API_KEY')
        if not api_key:
            raise ValueError("No API key found in environment variables")
        try:
            self.llm = ChatOpenAI(api_key=api_key, model="gpt-3.5-turbo-16k", temperature=0)
            self.functions = self._load_functions()
        except Exception as e:
            raise Exception(f"Failed to initialize LLM: {str(e)}")
    
    def _load_functions(self):
        current_dir = Path(__file__).parent
        functions_path = current_dir / "functions.json"
        
        if not functions_path.exists():
            raise FileNotFoundError(f"Functions file not found at: {functions_path}")
        
        with open(functions_path) as f:
            function_data = json.load(f)
            return [function_data] if not isinstance(function_data, list) else function_data
    
    def invoke_function(self, message):
        messages = [{"role": "user", "content": message}]
        response = self.llm.invoke(messages, functions=self.functions)
        
        if function_call := response.additional_kwargs.get("function_call"):
            function_name = function_call["name"]
            args = json.loads(function_call["arguments"])
            
            # Handle parameter mismatch for specific functions
            if function_name == "calculate_heat_stress":
                # Extract only the parameters our function accepts
                filtered_args = {}
                if "TMAX" in args:
                    filtered_args["TMAX"] = args["TMAX"]
                if "TMIN" in args:
                    filtered_args["TMIN"] = args["TMIN"]
                if "crop_type" in args:
                    filtered_args["crop_type"] = args["crop_type"]
                
                # Call the actual function with filtered arguments
                result = self.calculate_heat_stress(**filtered_args)
            else:
                # For other functions, try direct call
                if hasattr(self, function_name) and callable(getattr(self, function_name)):
                    result = getattr(self, function_name)(**args)
                else:
                    return {
                        "name": function_name,
                        "arguments": function_call["arguments"],
                        "error": f"Function {function_name} not implemented"
                    }
            
            return {
                "name": function_name,
                "arguments": function_call["arguments"],
                "result": result
            }
        return None
    
 
    def calculate_heat_stress(self, TMAX, TMIN=None, crop_type=None):
        # Default values based on crop type if provided
        crop_values = {
            "Soybean": {"TMaxOptimum": 30, "TMaxLimit": 40},
            "Corn": {"TMaxOptimum": 32, "TMaxLimit": 42},
            "Cotton": {"TMaxOptimum": 35, "TMaxLimit": 45}
        }
        
        TMaxOptimum = crop_values.get(crop_type, {}).get("TMaxOptimum", 30)
        TMaxLimit = crop_values.get(crop_type, {}).get("TMaxLimit", 40)
        
        if TMAX <= TMaxOptimum:
            return 0
        elif TMAX >= TMaxLimit:
            return 9
        else:
            return round(9 * ((TMAX - TMaxOptimum) / (TMaxLimit - TMaxOptimum)), 2)

    def calculate_drought_index(self, Precipitation, Evapotranspiration, SoilMoisture, TAVG):
        DI = (Precipitation - Evapotranspiration + SoilMoisture) / TAVG
        if DI > 1:
            risk = "No risk"
        elif DI == 1:
            risk = "Medium risk"
        else:
            risk = "High risk"
        return {"DI": round(DI, 2), "Risk": risk}

    def calculate_yield_risk(self, crop_type, GDD, Precipitation, pH, N_Actual):
        # Optimal values for each crop type
        crop_optimal_values = {
            "Soybean": {"GDD_opt": 2700, "P_opt": 575, "pH_opt": 6.4, "N_opt": 0.013},
            "Corn": {"GDD_opt": 2900, "P_opt": 650, "pH_opt": 6.4, "N_opt": 0.115},
            "Cotton": {"GDD_opt": 2400, "P_opt": 1000, "pH_opt": 6.3, "N_opt": 0.072},
        }
        w1, w2, w3, w4 = 0.3, 0.3, 0.2, 0.2
        opt = crop_optimal_values[crop_type]

        yield_risk = (w1 * (GDD - opt["GDD_opt"])**2 +
                    w2 * (Precipitation - opt["P_opt"])**2 +
                    w3 * (pH - opt["pH_opt"])**2 +
                    w4 * (N_Actual - opt["N_opt"])**2)

        return round(yield_risk, 2)
    
    def test_function(self, function_name, args):
        """Test a function directly with provided arguments"""
        if hasattr(self, function_name) and callable(getattr(self, function_name)):
            return getattr(self, function_name)(**args)
        raise ValueError(f"Function {function_name} not found")
    
    def predict_future_weather(self, latitude, longitude, days_ahead):
        """
        Predicts weather for a future date based on historical patterns.
        
        Args:
            latitude (float): Latitude coordinate
            longitude (float): Longitude coordinate
            days_ahead (int): Number of days in the future to predict
            
        Returns:
            dict: Predicted weather data including temperature, humidity, etc.
        """
        # Get current weather
        current_data = get_current_weather(latitude, longitude)
        
        # Get weather from same date last year
        one_year_ago = get_historical_weather_year_ago(latitude, longitude)
        
        # Get weather from same date two years ago
        two_years_ago = get_historical_weather_two_year_ago(latitude, longitude)
        
        # Determine the target date (days_ahead from now)
        target_date = (datetime.now() + timedelta(days=days_ahead)).strftime("%Y-%m-%d")
        
        # Initialize prediction result
        prediction = {
            "latitude": latitude,
            "longitude": longitude,
            "target_date": target_date,
            "prediction_created": datetime.now().isoformat(),
            "forecast": {}
        }
        
        # List of weather parameters to predict
        params = ["temperature", "humidity", "wind_speed", "wind_direction", "precipitation"]
        
        # Check which parameters are available in all three datasets
        available_params = []
        for param in params:
            if (param in current_data and 
                param in one_year_ago and 
                param in two_years_ago):
                available_params.append(param)
        
        # Simple weighted average prediction model
        # Weight current conditions more heavily than historical
        weights = [0.5, 0.3, 0.2]  # Current, 1yr ago, 2yrs ago
        
        for param in available_params:
            try:
                # Get values, converting to numeric
                current_value = float(current_data.get(param, 0))
                yr1_value = float(one_year_ago.get(param, 0))
                yr2_value = float(two_years_ago.get(param, 0))
                
                # Calculate weighted average
                predicted_value = (
                    weights[0] * current_value +
                    weights[1] * yr1_value +
                    weights[2] * yr2_value
                )
                
                # Add seasonal trend adjustment (simple linear)
                seasonal_trend = (yr1_value - yr2_value) / 365 * days_ahead
                predicted_value += seasonal_trend
                
                # Round to 2 decimal places for readability
                prediction["forecast"][param] = round(predicted_value, 2)
                
                # Add confidence level based on variance
                values = [current_value, yr1_value, yr2_value]
                variance = np.var(values)
                # Higher variance = lower confidence
                max_variance = max(values) * 0.5  # Arbitrary threshold
                confidence = max(0, min(100, 100 * (1 - variance/max_variance)))
                prediction["forecast"][f"{param}_confidence"] = round(confidence)
                
            except (ValueError, TypeError) as e:
                # Skip parameters that can't be converted to numeric
                print(f"Error processing {param}: {e}")
        
        # Add a narrative summary
        prediction["summary"] = self._generate_weather_narrative(prediction["forecast"], target_date)
        
        return prediction
    
    def _generate_weather_narrative(self, forecast, target_date):
        """Generate a human-readable narrative of the weather prediction"""
        
        # Basic template for the narrative
        narrative = f"Weather prediction for {target_date}: "
        
        if "temperature" in forecast:
            temp = forecast["temperature"]
            conf = forecast.get("temperature_confidence", 0)
            
            temp_desc = "hot" if temp > 30 else "warm" if temp > 20 else "mild" if temp > 10 else "cool" if temp > 0 else "cold"
            conf_desc = "high" if conf > 70 else "moderate" if conf > 40 else "low"
            
            narrative += f"Expect {temp_desc} conditions with temperatures around {temp}°C (confidence: {conf_desc}). "
        
        if "precipitation" in forecast and forecast["precipitation"] > 0:
            precip = forecast["precipitation"]
            if precip < 1:
                narrative += "Light chance of precipitation. "
            elif precip < 5:
                narrative += "Moderate chance of rain. "
            else:
                narrative += "High chance of significant rainfall. "
        
        if "humidity" in forecast:
            humidity = forecast["humidity"]
            if humidity > 80:
                narrative += "Expect humid conditions. "
            elif humidity < 30:
                narrative += "Expect dry conditions. "
        
        if "wind_speed" in forecast:
            wind = forecast["wind_speed"]
            if wind > 30:
                narrative += "Strong winds expected. "
            elif wind > 15:
                narrative += "Moderate winds expected. "
        
        return narrative



def main():
    parser = argparse.ArgumentParser(description='LLM Function Caller')
    parser.add_argument('--message', help='Message to invoke function call', 
                        default="Calculate heat stress for soybean with maximum temp of 38°C and minimum temp of 25°C.")
    parser.add_argument('--test', help='Test function directly', 
                       choices=['heat_stress', 'drought_index', 'yield_risk', 'predict_weather'])
    parser.add_argument('--args', help='JSON string of arguments for direct test')
    args = parser.parse_args()
    
    try:
        agent = LLMAgent()
        
        if args.test:
            if args.test == 'predict_weather':
                # Default args for weather prediction 
                if not args.args:
                    test_args = {
                        "latitude": 47.3769, 
                        "longitude": 8.5417,
                        "days_ahead": 7
                    }
                else:
                    test_args = json.loads(args.args)
                
                result = agent.predict_future_weather(**test_args)
                print(f"Weather prediction for {result['target_date']}:")
                print(f"Location: {result['latitude']}, {result['longitude']}")
                print("\nForecast:")
                for param, value in result['forecast'].items():
                    if not param.endswith('_confidence'):
                        confidence = result['forecast'].get(f"{param}_confidence", "N/A")
                        print(f"  {param}: {value} (confidence: {confidence}%)")
                
                print(f"\nSummary: {result['summary']}")
            
            else:
                # Handle other test functions
                args_dict = json.loads(args.args) if args.args else {}
                result = agent.test_function(args.test, args_dict)
                print(f"Result: {result}")
        else:
            result = agent.invoke_function(args.message)
            print(f"Result: {result}")
            
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()