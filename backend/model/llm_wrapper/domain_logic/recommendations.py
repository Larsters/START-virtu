from datetime import datetime, timedelta
from model.llm_wrapper.domain_logic.calculations import calculate_daytime_heat_stress_risk, calculate_frost_stress, calculate_nighttime_heat_stress_risk, get_drought_risk, get_yield_risk
from model.llm_wrapper.services.soil_service import fetch_soil_data

def recommend_products(crop_type, weather_prediction, soil_data=None, latitude=None, longitude=None):
    """
    Recommends products based on crop type, soil data, and weather predictions.

    Args:
        crop_type (str): Type of crop (Soybean, Corn, Cotton)
        weather_prediction (dict): Weather forecast data from predict_future_weather
        soil_data (dict, optional): Soil information. If None, will fetch using coordinates.
        latitude (float, optional): Latitude coordinate for fetching soil data
        longitude (float, optional): Longitude coordinate for fetching soil data
        
    Returns:
        list: Ranked product recommendations with rationale
    """
    product_info = {
        "Stress Buster": {
            "problems": ["Abiotic stress", "Cold stress", "Heat stress", "Drought stress", "Wounding"],
            "crops": ["Soybean", "Corn", "Cotton"],
            "description": "Allows plants to tolerate and quickly overcome stress, preserving yield under Cold, Heat, drought, wounding conditions.",
            "when_to_use": "When stress factors are predicted in the upcoming weather"
        },
        "Nutrient Booster": {
            "problems": ["Nutrient deficiency", "Poor nutrient uptake", "Low soil fertility"],
            "crops": ["Soybean", "Corn"],
            "description": "Increases the efficiency of plant nutrient use.",
            "when_to_use": "When soil tests show nutrient limitations or pH issues"
        },
        "Yield Booster": {
            "problems": ["Suboptimal yield", "Growth limitation", "Productivity issues"],
            "crops": ["Soybean", "Corn", "Cotton"],
            "description": "Guarantees maximum productivity under favorable conditions.",
            "when_to_use": "When conditions are generally favorable but yield needs a boost"
        }
    }

    if soil_data and latitude is not None and longitude is not None:
        try:
            soil_data = fetch_soil_data(latitude, longitude)
        except Exception as e:
            print(f"Error fetching soil data: {e}")
            soil_data = {
                "soil_moisture": 0.5,
                "soil_pH": 6.5,
                "soil_nutrients": 0.05
            }

    calculation_results = {}
    if latitude is not None and longitude is not None:
        try:
            # Calculate stress factors using the scientific formulas
            calculation_results["daytime_heat_stress"] = calculate_daytime_heat_stress_risk(latitude, longitude, crop_type.lower())
            calculation_results["nighttime_heat_stress"] = calculate_nighttime_heat_stress_risk(latitude, longitude, crop_type.lower())
            calculation_results["frost_stress"] = calculate_frost_stress(latitude, longitude, crop_type.lower())
            calculation_results["drought_risk"] = get_drought_risk(latitude, longitude)
            
            # Get date range for yield calculations
            start = datetime.now() - timedelta(days=90)
            end = datetime.now() + timedelta(days=14) 
            calculation_results["yield_risk"] = get_yield_risk(latitude, longitude, start, end, crop_type.lower())
        except Exception as e:
            print(f"Error performing calculations: {e}")
            
    recommendations = []
    identified_problems = identify_problems(crop_type, weather_prediction, soil_data, calculation_results)

    for product_name, info in product_info.items():
        if crop_type not in info["crops"]:
            continue
        
        matching_problems = [p for p in identified_problems if p in info["problems"]]
        if not matching_problems:
            continue
            
        probability = len(matching_problems) / len(identified_problems) if identified_problems else 0.5
        accuracy = calculate_accuracy(matching_problems, weather_prediction, soil_data, calculation_results)

        text = generate_recommendation_text(product_name, crop_type, matching_problems, info["description"], weather_prediction, calculation_results)
 
        recommendations.append({
            "recommended_product": product_name,
            "probability": round(probability, 2),
            "accuracy": min(10, max(1, round(accuracy))),
            "text": text,
            "matching_problems": matching_problems
        })
        
    recommendations.sort(key=lambda x: x["probability"], reverse=True)

    if not recommendations:
        recommendations.append({
            "recommended_product": "None",
            "probability": 0.5,
            "accuracy": 5,
            "text": f"Based on current conditions for your {crop_type}, a standard fertilization program is recommended. No specific issues requiring special products were identified.",
            "matching_problems": ["General maintenance"]
        })

    for rec in recommendations:
        rec.pop("matching_problems", None)

    return recommendations

def _identify_problems(crop_type, weather_prediction, soil_data, calculation_results=None):
    """
    Identify potential problems based on weather, soil, and calculation results
    
    Args:
        crop_type (str): Type of crop
        weather_prediction (dict): Weather forecast data
        soil_data (dict): Soil information
        calculation_results (dict): Results from scientific calculations
        
    Returns:
        list: Identified problems that need to be addressed
    """
    problems = []
    
    # Extract weather data
    forecast = weather_prediction.get("forecast", {})
    temperature = forecast.get("temperature", 25)
    precipitation = forecast.get("precipitation", 0)
    
    # Use scientific calculations when available
    if calculation_results:
        # Heat stress
        if calculation_results.get("daytime_heat_stress", 0) > 5:
            problems.append("Heat stress")
        
        # Cold/frost stress
        if calculation_results.get("frost_stress", 0) > 4:
            problems.append("Cold stress")
        
        # Drought stress
        drought_index = calculation_results.get("drought_risk")
        if drought_index is not None:
            if drought_index < 0:
                problems.append("Drought stress")
        
        # Yield risk assessment
        yield_risk = calculation_results.get("yield_risk")
        if yield_risk is not None:
            if yield_risk > 1000:
                problems.append("Suboptimal yield")
    
    # Fall back to simpler checks if calculations aren't available
    else:
        # Check for temperature stress
        if temperature > 35:
            problems.append("Heat stress")
        elif temperature < 10:
            problems.append("Cold stress")
        
        # Check for water stress
        if precipitation < 1:
            problems.append("Drought stress")
    
    # Check soil conditions if available
    if soil_data:
        # Check soil moisture
        soil_moisture = soil_data.get("soil_moisture", 0.5)
        if soil_moisture < 0.3:
            problems.append("Drought stress")
        
        # Check pH
        soil_ph = soil_data.get("soil_ph", 6.5)
        if soil_ph < 5.5 or soil_ph > 7.5:
            problems.append("Nutrient deficiency")
        
        # Check nitrogen
        nitrogen = soil_data.get("soil_nitrogen_content", 0.05)
        if nitrogen < 0.03:
            problems.append("Nutrient deficiency")
    
    # If no specific problems found, add general productivity concern
    if not problems:
        problems.append("Suboptimal yield")
    
    return problems

def calculate_accuracy(matching_problems, weather_prediction, soil_data, calculation_results=None):
    """
    Calculate accuracy score (1-10) for the recommendation based on data quality and calculations
    
    Args:
        matching_problems (list): Problems the product addresses
        weather_prediction (dict): Weather forecast data
        soil_data (dict): Soil information
        calculation_results (dict): Results from scientific calculations
        
    Returns:
        float: Accuracy score between 1-10
    """
    # Base accuracy
    accuracy = 5
    
    # More problems matched = higher accuracy
    accuracy += min(3, len(matching_problems))
    
    # Weather confidence affects accuracy
    if "temperature_confidence" in weather_prediction.get("forecast", {}):
        temp_conf = weather_prediction["forecast"]["temperature_confidence"] / 100
        accuracy += temp_conf * 2
    
    # Scientific calculations increase accuracy
    if calculation_results:
        # Count how many calculations were performed successfully
        valid_calculations = sum(1 for v in calculation_results.values() if v is not None)
        # Add 0.5 points for each valid calculation, max 2 points
        accuracy += min(2, valid_calculations * 0.5)
    
    # Soil data present increases accuracy
    if soil_data and all(k in soil_data for k in ["soil_moisture", "soil_ph", "soil_nitrogen_content"]):
        accuracy += 1
    
    return accuracy

def generate_recommendation_text(product_name, crop_type, problems, description, weather_prediction, calculation_results=None):
    """
    Generate recommendation text including scientific rationale
    
    Args:
        product_name (str): Name of the product
        crop_type (str): Type of crop
        problems (list): Problems the product addresses
        description (str): Product description
        weather_prediction (dict): Weather forecast data
        calculation_results (dict): Results from scientific calculations
        
    Returns:
        str: Detailed recommendation text
    """
    # Format the date
    target_date = weather_prediction.get("target_date", datetime.now().strftime("%d/%m/%Y"))
    
    # Introduction
    text = f"For your {crop_type} crop, {product_name} is recommended to address "
    
    # List problems
    if len(problems) > 1:
        text += ", ".join(problems[:-1]) + f" and {problems[-1]}. "
    else:
        text += f"{problems[0]}. "
    
    # Add product description
    text += description + " "
    
    # Add scientific rationale based on calculations
    if calculation_results:
        text += "\n\nBased on scientific analysis: "
        
        if "daytime_heat_stress" in calculation_results:
            text += f"Daytime heat stress index: {round(calculation_results['daytime_heat_stress'], 1)}/9. "
        
        if "nighttime_heat_stress" in calculation_results:
            text += f"Nighttime heat stress index: {round(calculation_results['nighttime_heat_stress'], 1)}/9. "
        
        if "frost_stress" in calculation_results:
            text += f"Frost stress index: {round(calculation_results['frost_stress'], 1)}/9. "
        
        if "drought_risk" in calculation_results:
            drought_index = calculation_results["drought_risk"]
            risk_level = "High" if drought_index < -10 else "Medium" if drought_index < 0 else "Low"
            text += f"Drought risk: {risk_level} (index: {round(drought_index, 1)}). "
        
        if "yield_risk" in calculation_results:
            yield_risk = calculation_results["yield_risk"]
            text += f"Yield risk assessment: {round(yield_risk, 1)}. "
    
    # Add weather context
    forecast = weather_prediction.get("forecast", {})
    if "temperature" in forecast:
        text += f"\n\nWith forecasted temperatures of {forecast['temperature']}°C "
        
        if "precipitation" in forecast:
            if forecast["precipitation"] < 1:
                text += "and dry conditions, "
            else:
                text += f"and {forecast['precipitation']}mm of precipitation, "
    
    # Add application advice
    text += f"application of {product_name} is expected to significantly improve crop performance."
    
    return text

def recommend_fertilizer(crop_type, yield_risk, pH, N_Actual):
    """
    Recommend fertilizer based on yield risk and soil parameters
    
    Args:
        crop_type (str): Type of crop
        yield_risk (float): Calculated yield risk
        pH (float): Soil pH
        N_Actual (float): Nitrogen content
        
    Returns:
        dict: Fertilizer recommendation
    """
    # Determine product based on yield risk
    if yield_risk > 1000:
        product = "Stress Buster"  # High risk, need stress protection
        application_rate = "High"
        timing = "As soon as possible"
    elif yield_risk > 500:
        product = "Nutrient Booster"  # Medium risk, boost nutrients
        application_rate = "Medium"
        timing = "Within 7 days"
    else:
        product = "Yield Booster"  # Low risk, focus on maximizing yield
        application_rate = "Standard"
        timing = "At next scheduled application"
    
    # Adjust for soil pH
    if pH < 5.5:
        notes = "Consider lime application to raise soil pH"
    elif pH > 7.5:
        notes = "Consider sulfur application to lower soil pH"
    else:
        notes = "Soil pH is optimal for nutrient uptake"
    
    # Check nitrogen levels
    if N_Actual < 0.03:
        nitrogen_note = "Increase nitrogen application rate by 20%"
    elif N_Actual > 0.1:
        nitrogen_note = "Decrease nitrogen application rate by 10%"
    else:
        nitrogen_note = "Nitrogen levels are adequate"
    
    return {
        "product": product,
        "application_rate": application_rate,
        "application_timing": timing,
        "soil_notes": notes,
        "nitrogen_recommendation": nitrogen_note
    }

