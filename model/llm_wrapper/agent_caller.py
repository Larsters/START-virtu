import json
import os
import argparse
from pathlib import Path
from langchain_openai import ChatOpenAI
from dotenv import load_dotenv

class LLMAgent:
    def __init__(self):
        load_dotenv()
        self.llm = ChatOpenAI(model="gpt-3.5-turbo-16k", temperature=0)
        self.functions = self._load_functions()
    
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

def main():
    parser = argparse.ArgumentParser(description='LLM Function Caller')
    parser.add_argument('--message', help='Message to invoke function call', 
                        default="Calculate heat stress for soybean with maximum temp of 38°C and minimum temp of 25°C.")
    parser.add_argument('--test', help='Test function directly (heat_stress, drought_index, yield_risk)', choices=['heat_stress', 'drought_index', 'yield_risk'])
    parser.add_argument('--args', help='JSON string of arguments for direct test')
    args = parser.parse_args()
    
    try:
        agent = LLMAgent()
        
        # Direct function testing
        if args.test:
            function_map = {
                'heat_stress': 'calculate_heat_stress',
                'drought_index': 'calculate_drought_index',
                'yield_risk': 'calculate_yield_risk'
            }
            
            function_name = function_map[args.test]
            test_args = json.loads(args.args) if args.args else {}
            
            result = agent.test_function(function_name, test_args)
            print(f"Test Result: {result}")
        
        # LLM function invocation
        else:
            result = agent.invoke_function(args.message)
            
            if result:
                print(f"Function called: {result['name']}")
                print(f"With arguments: {result['arguments']}")
                if 'result' in result:
                    print(f"Result: {result['result']}")
                if 'error' in result:
                    print(f"Error: {result['error']}")
            else:
                print("No function was called")
            
    except Exception as e:
        print(f"Error: {str(e)}")

if __name__ == "__main__":
    main()