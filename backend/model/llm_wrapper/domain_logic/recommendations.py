from backend.model.llm_wrapper.services.soil_service import fetch_soil_data

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
    recommendations = []
    identified_problems = _identify_problems(crop_type, weather_prediction, soil_data)

    for product_name, info in product_info.items():
        if crop_type not in info["crops"]:
            continue
        
        matching_problems = [p for p in identified_problems if p in info["problems"]]
        if not matching_problems:
            continue
            
        probability = len(matching_problems) / len(identified_problems) if identified_problems else 0.5
        accuracy = _calculate_accuracy(matching_problems, weather_prediction, soil_data)

        text =_generate_recommendation_text(product_name, crop_type, matching_problems, info["description"], weather_prediction)

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

def _identify_problems():
    pass

def calculate_accuracy():
    """Calculate accuracy score (1-10) for the recommendation"""
    pass

def _generate_recommendation_text():
    """Generate recommendation text based on product, crop, problems, weather, soil, calculations"""
    pass

def recommend_fertilizer():
    """Recommend fertilizer based on soil data, crop type, and weather predictions, calculations"""
    pass

