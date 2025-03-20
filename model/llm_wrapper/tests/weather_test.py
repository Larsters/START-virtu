import json
import os
import sys
import logging
from datetime import datetime, timedelta

# Setup logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from agent_caller import LLMAgent

def main():
    agent = LLMAgent()
    
    try:
        # Test direct function call
        print("Testing direct function call:")
        # Use current date for testing
        today = datetime.now()
        weather_data = agent.fetch_weather_daily_data(47.424, 9.370, days=3)  # Reduced to 3 days
        logger.debug(f"Raw weather data: {weather_data}")
        
        if isinstance(weather_data, list) and weather_data:
            print(json.dumps(weather_data[:2], indent=2))
        else:
            logger.error(f"Unexpected weather data format: {type(weather_data)}")
            print("No weather data received")
    
        # Test LLM function invocation with better coordinates
        print("\nTesting LLM function invocation:")
        test_query = "What's the weather forecast for Zurich (lat 47.3769, lon 8.5417) for the next 3 days?"
        result = agent.invoke_function(test_query)
        
        if result and isinstance(result, dict):
            print(f"Function called: {result.get('name')}")
            
            if result.get('result'):
                data = result['result']
                print(f"Result: {len(data)} days of forecast data")
                if data:
                    print(json.dumps(data[0], indent=2))
                else:
                    print("No forecast data available")
            else:
                logger.warning("No result data in response")
                print("No result data received")
        else:
            logger.error(f"Unexpected result format: {type(result)}")
            print("No function was called")
            
    except Exception as e:
        logger.error(f"Error during weather test: {str(e)}")
        raise

if __name__ == "__main__":
    main()