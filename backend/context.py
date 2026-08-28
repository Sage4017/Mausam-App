"""
Context and Weather Evaluation Engine for Mausam Mobile App
Calculates live contextual suitability, regional climate calibration,
dynamic reason badges, and smart packing micro-tips.
"""

from typing import Dict, Any, Tuple, Callable
from Widgets import WIDGETS

# Regional Climate Thresholds Calibration
# Adjusts what temperatures count as 'Extreme Heat', 'Chilly', or 'Ideal'
CLIMATE_THRESHOLDS = {
    "temperate": {  # Default: Europe, North America, East Asia
        "heat_extreme": 32.0,
        "heat_warm": 27.0,
        "cold_chill": 8.0,
        "frost": 2.0,
        "beach_min": 22.0,
        "fitness_ideal": (14.0, 22.0),
    },
    "tropical": {   # India, Southeast Asia, Caribbean, Central America
        "heat_extreme": 38.0,
        "heat_warm": 33.0,
        "cold_chill": 16.0,
        "frost": 6.0,
        "beach_min": 25.0,
        "fitness_ideal": (18.0, 27.0),
    },
    "arid": {       # Middle East, North Africa, Desert regions
        "heat_extreme": 42.0,
        "heat_warm": 36.0,
        "cold_chill": 12.0,
        "frost": 3.0,
        "beach_min": 26.0,
        "fitness_ideal": (16.0, 26.0),
    },
    "cold": {       # Canada, Nordic countries, Russia, High altitude
        "heat_extreme": 28.0,
        "heat_warm": 23.0,
        "cold_chill": 0.0,
        "frost": -5.0,
        "beach_min": 20.0,
        "fitness_ideal": (10.0, 18.0),
    }
}

# Sample contextual test payload (Lean standard API fields)
context = {
    # Region calibration (tropical, temperate, arid, cold)
    "climate_zone": "tropical",

    # Temporal
    "hour": 7,                  # Current local hour (0-23)

    # Standard weather metrics
    "temperature": 25,          # °C
    "humidity": 65,             # %
    "rain_probability": 20,     # %
    "wind_speed": 8,            # km/h
    "uv_index": 10,             # 0-12
    "visibility": 10,           # km
    "aqi": 45,                  # 0-500 Air Quality Index (optional)
    "pollen_level": "low",      # low, medium, high (optional)

    # Situational user flags
    "upcoming_trip": False,     # Scheduled flight/trip booked
    "commuting": True,          # User active commute window
    "outdoor_activity": True    # User scheduled outdoor workout
}


def get_climate_config(ctx: Dict[str, Any]) -> Dict[str, Any]:
    """Retrieves regional temperature thresholds based on the context's climate_zone."""
    zone = ctx.get("climate_zone", "tropical").lower()
    return CLIMATE_THRESHOLDS.get(zone, CLIMATE_THRESHOLDS["tropical"])


def generate_packing_tip(ctx: Dict[str, Any]) -> str:
    """
    Generates actionable packing suggestions based on trip conditions or weather disparities.
    """
    temp = ctx.get("temperature", 20)
    rain = ctx.get("rain_probability", 0)
    uv = ctx.get("uv_index", 3)
    wind = ctx.get("wind_speed", 0)

    tips = []
    if rain >= 50:
        tips.append("Compact umbrella & rain jacket")
    if temp <= 12:
        tips.append("Thermal layers & warm jacket")
    elif temp <= 19:
        tips.append("Light hoodie / windbreaker")
    elif temp >= 33:
        tips.append("Breathable cottons & hydration pack")

    if uv >= 8:
        tips.append("SPF 50+ sunscreen & shades")
    if wind >= 30:
        tips.append("Windproof outer shell")

    if not tips:
        return "Standard comfortable clothing & essentials"
    return " + ".join(tips[:2])


def evaluate_outdoor_fitness(ctx: Dict[str, Any]) -> float:
    """Evaluates suitability and timing for outdoor workouts, running, cycling."""
    score = 0.0
    hour = ctx.get("hour", 12)
    temp = ctx.get("temperature", 20)
    humidity = ctx.get("humidity", 50)
    rain = ctx.get("rain_probability", 0)
    uv = ctx.get("uv_index", 3)
    wind = ctx.get("wind_speed", 5)
    vis = ctx.get("visibility", 10)
    outdoor_activity = ctx.get("outdoor_activity", False)
    climate = get_climate_config(ctx)

    # Active user intent
    if outdoor_activity:
        score += 25.0

    # Optimal workout time
    if 6 <= hour <= 9:
        score += 20.0
    elif 17 <= hour <= 20:
        score += 15.0
    elif 10 <= hour <= 16:
        score += 10.0

    # Regional temperature calibration
    fit_min, fit_max = climate["fitness_ideal"]
    if fit_min <= temp <= fit_max:
        score += 20.0
    elif (fit_min - 6 <= temp < fit_min) or (fit_max < temp <= fit_max + 5):
        score += 12.0
    elif temp <= climate["heat_extreme"]:
        score += 5.0

    # Rain suitability
    if rain < 20:
        score += 20.0
    elif rain <= 40:
        score += 10.0
    elif rain <= 60:
        score += 5.0

    # UV Index
    if uv <= 3:
        score += 10.0
    elif uv <= 6:
        score += 7.0
    elif uv <= 8:
        score += 3.0

    # Humidity & Wind
    if 35 <= humidity <= 65:
        score += 5.0
    if wind <= 15:
        score += 10.0
    elif wind <= 25:
        score += 5.0

    if vis >= 8:
        score += 5.0

    return min(score, 100.0)


def evaluate_travel(ctx: Dict[str, Any]) -> float:
    """Evaluates relevance for travel planning, flight/road disruptions, and smart packing."""
    score = 0.0
    upcoming_trip = ctx.get("upcoming_trip", False)
    rain = ctx.get("rain_probability", 0)
    vis = ctx.get("visibility", 10)
    wind = ctx.get("wind_speed", 0)
    temp = ctx.get("temperature", 20)
    climate = get_climate_config(ctx)

    # Explicit trip intent
    if upcoming_trip:
        score += 40.0
    else:
        score += 10.0

    # Weather disruptions requiring travel prep & smart packing
    if rain >= 60:
        score += 20.0
    elif rain >= 30:
        score += 10.0

    if vis < 3:
        score += 20.0
    elif vis < 6:
        score += 10.0

    if wind >= 35:
        score += 15.0
    elif wind >= 20:
        score += 8.0

    # Extreme packing temperature sensitivity (Regional calibrated)
    if temp >= climate["heat_extreme"] or temp <= climate["cold_chill"]:
        score += 15.0

    return min(score, 100.0)


def evaluate_commuter(ctx: Dict[str, Any]) -> float:
    """Evaluates commute urgency, traffic risk, road hazards, and transit conditions."""
    score = 0.0
    commuting = ctx.get("commuting", False)
    hour = ctx.get("hour", 12)
    rain = ctx.get("rain_probability", 0)
    vis = ctx.get("visibility", 10)
    wind = ctx.get("wind_speed", 0)
    temp = ctx.get("temperature", 20)
    climate = get_climate_config(ctx)

    # Commute status & rush hours
    if commuting:
        score += 30.0

    if (7 <= hour <= 10) or (16 <= hour <= 20):
        score += 25.0
    elif 11 <= hour <= 15:
        score += 10.0

    # Weather hazards affecting transit
    if rain >= 60:
        score += 20.0
    elif rain >= 30:
        score += 10.0

    if vis < 3:
        score += 15.0
    elif vis < 6:
        score += 8.0

    if wind >= 30 or temp <= climate["frost"]:
        score += 10.0

    return min(score, 100.0)


def evaluate_beach_surf(ctx: Dict[str, Any]) -> float:
    """Evaluates beach weather, surf swell conditions, and coastal recreation."""
    score = 0.0
    temp = ctx.get("temperature", 20)
    rain = ctx.get("rain_probability", 0)
    wind = ctx.get("wind_speed", 0)
    hour = ctx.get("hour", 12)
    vis = ctx.get("visibility", 10)
    uv = ctx.get("uv_index", 3)
    climate = get_climate_config(ctx)

    # Regional beach temperature threshold
    b_min = climate["beach_min"]
    if b_min <= temp <= b_min + 8:
        score += 25.0
    elif (b_min - 4 <= temp < b_min) or (temp > b_min + 8 and temp <= climate["heat_extreme"]):
        score += 15.0
    elif temp > climate["heat_extreme"]:
        score += 5.0

    # Dry weather
    if rain < 15:
        score += 20.0
    elif rain <= 35:
        score += 10.0

    # Coastal breeze / surf wind
    if 12 <= wind <= 28:
        score += 20.0
    elif wind < 12:
        score += 12.0
    elif wind <= 38:
        score += 5.0

    # Daylight hours
    if 9 <= hour <= 17:
        score += 15.0
    elif (6 <= hour < 9) or (18 <= hour <= 20):
        score += 8.0

    # Visibility & Sun
    if vis >= 8:
        score += 10.0
    elif vis >= 5:
        score += 5.0

    if 3 <= uv <= 7:
        score += 10.0
    elif uv > 7:
        score += 5.0

    return min(score, 100.0)


def evaluate_health(ctx: Dict[str, Any]) -> float:
    """Evaluates environmental health: daily UV awareness, air quality, hydration, heat/cold stress, pollen."""
    score = 20.0  # Baseline wellness utility

    uv = ctx.get("uv_index", 0)
    temp = ctx.get("temperature", 20)
    humidity = ctx.get("humidity", 50)
    vis = ctx.get("visibility", 10)
    rain = ctx.get("rain_probability", 0)
    aqi = ctx.get("aqi")
    pollen = ctx.get("pollen_level", "low")
    climate = get_climate_config(ctx)

    # UV Radiation
    if uv >= 11:
        score += 30.0
    elif uv >= 8:
        score += 25.0
    elif uv >= 6:
        score += 15.0
    elif uv >= 3:
        score += 8.0

    # Temperature extremes (Regional calibrated)
    if temp >= climate["heat_extreme"] or temp <= climate["frost"]:
        score += 25.0
    elif temp >= climate["heat_warm"] or temp <= climate["cold_chill"]:
        score += 15.0

    if humidity >= 80 and temp >= climate["heat_warm"]:
        score += 10.0  # Muggy / Heat index stress

    # Air Quality Index (AQI)
    if aqi is not None:
        if aqi >= 200:
            score += 30.0
        elif aqi >= 100:
            score += 20.0
        elif aqi >= 50:
            score += 10.0
    elif vis < 3:
        score += 20.0
    elif vis < 6:
        score += 10.0

    # Allergy / Pollen
    if pollen in ["high", "extreme"]:
        score += 15.0
    elif pollen == "medium":
        score += 8.0

    if rain >= 80:
        score += 10.0

    return min(score, 100.0)


def evaluate_family(ctx: Dict[str, Any]) -> float:
    """Evaluates outdoor family activity suitability and child weather precautions."""
    score = 0.0
    hour = ctx.get("hour", 12)
    rain = ctx.get("rain_probability", 0)
    temp = ctx.get("temperature", 20)
    vis = ctx.get("visibility", 10)
    uv = ctx.get("uv_index", 3)
    climate = get_climate_config(ctx)

    # School & family routine hours
    if (7 <= hour <= 9) or (16 <= hour <= 19):
        score += 20.0
    elif 10 <= hour <= 15:
        score += 15.0

    # Rain
    if rain < 20:
        score += 25.0
    elif rain >= 60:
        score += 20.0
    else:
        score += 10.0

    # Temperature (Regional calibrated)
    if 18 <= temp <= 27:
        score += 25.0
    elif temp >= climate["heat_extreme"] or temp <= climate["cold_chill"]:
        score += 20.0
    else:
        score += 12.0

    if vis < 5:
        score += 15.0
    if uv >= 8:
        score += 15.0

    return min(score, 100.0)


def evaluate_agriculture(ctx: Dict[str, Any]) -> float:
    """Evaluates farming, gardening, irrigation planning, frost, and harvest conditions."""
    score = 0.0
    rain = ctx.get("rain_probability", 0)
    temp = ctx.get("temperature", 20)
    wind = ctx.get("wind_speed", 0)
    uv = ctx.get("uv_index", 3)
    climate = get_climate_config(ctx)

    # Irrigation planning
    if 30 <= rain <= 70:
        score += 30.0
    elif rain > 70:
        score += 20.0
    elif rain > 10:
        score += 10.0

    # Temperature (Regional calibrated)
    if temp <= climate["frost"]:
        score += 25.0  # Frost danger
    elif temp >= climate["heat_warm"]:
        score += 25.0  # Crop heat stress
    elif 16 <= temp <= 28:
        score += 25.0
    else:
        score += 12.0

    if wind >= 30:
        score += 25.0
    elif wind >= 18:
        score += 15.0

    if uv >= 8:
        score += 15.0
    elif uv >= 5:
        score += 8.0

    return min(score, 100.0)


def evaluate_events(ctx: Dict[str, Any]) -> float:
    """Evaluates conditions for outdoor festivals, matches, concerts, and public events."""
    score = 0.0
    rain = ctx.get("rain_probability", 0)
    temp = ctx.get("temperature", 20)
    humidity = ctx.get("humidity", 50)
    wind = ctx.get("wind_speed", 0)
    hour = ctx.get("hour", 12)
    vis = ctx.get("visibility", 10)
    climate = get_climate_config(ctx)

    # Rain impact
    if rain >= 60:
        score += 30.0
    elif rain < 20:
        score += 25.0
    else:
        score += 15.0

    # Temperature and humidity comfort
    if 18 <= temp <= 27:
        score += 25.0
        if 40 <= humidity <= 65:
            score += 5.0
    elif temp >= climate["heat_extreme"] or temp <= climate["cold_chill"]:
        score += 20.0
    else:
        score += 10.0

    # Wind (marquee safety)
    if wind >= 28:
        score += 20.0
    elif wind >= 18:
        score += 10.0

    if 10 <= hour <= 22:
        score += 15.0
    if vis < 5:
        score += 10.0

    return min(score, 100.0)


# Strategy registry mapping widget category to its evaluator
CONTEXT_EVALUATORS: Dict[str, Callable[[Dict[str, Any]], float]] = {
    "Outdoor Fitness": evaluate_outdoor_fitness,
    "Travel": evaluate_travel,
    "Commuter": evaluate_commuter,
    "Beach & Surf": evaluate_beach_surf,
    "Health": evaluate_health,
    "Family": evaluate_family,
    "Agriculture": evaluate_agriculture,
    "Events": evaluate_events,
}


def calculate_context_score(widget: str, ctx: Dict[str, Any]) -> float:
    """Computes the contextual relevance score (0 - 100) for a given widget."""
    evaluator = CONTEXT_EVALUATORS.get(widget)
    if evaluator:
        return float(evaluator(ctx))
    return 0.0


def generate_widget_badge(widget: str, ctx: Dict[str, Any]) -> str:
    """
    Generates a concise, human-readable badge/subtitle (e.g. 'High UV Alert (10)')
    explaining why this widget is relevant on the mobile app homepage.
    """
    uv = ctx.get("uv_index", 0)
    aqi = ctx.get("aqi")
    rain = ctx.get("rain_probability", 0)
    temp = ctx.get("temperature", 20)
    vis = ctx.get("visibility", 10)
    wind = ctx.get("wind_speed", 0)
    hour = ctx.get("hour", 12)
    climate = get_climate_config(ctx)

    if widget == "Health":
        if uv >= 8:
            return f"High UV Alert ({uv})"
        if aqi and aqi >= 100:
            return f"Poor Air Quality (AQI {aqi})"
        if temp >= climate["heat_extreme"]:
            return "Extreme Heatwave Alert"
        if temp <= climate["frost"]:
            return "Freezing Temperature Alert"
        return "Daily UV & Wellness"

    elif widget == "Outdoor Fitness":
        if rain >= 60:
            return "Rain / Shift Indoors"
        if 6 <= hour <= 9 and temp <= climate["fitness_ideal"][1]:
            return "Prime Morning Running Hours"
        if 17 <= hour <= 20 and temp <= climate["fitness_ideal"][1]:
            return "Great Evening Workout Weather"
        if temp >= climate["heat_warm"]:
            return "High Heat / Reduce Exertion"
        return "Optimal Outdoor Conditions"

    elif widget == "Beach & Surf":
        if temp >= climate["beach_min"] and rain < 20:
            return "Perfect Beach Day"
        if 15 <= wind <= 28:
            return "Great Coastal Surf Breeze"
        if rain >= 50:
            return "Rain Over Coast"
        return "Coastal Conditions"

    elif widget == "Travel":
        if ctx.get("upcoming_trip"):
            return f"Packing: {generate_packing_tip(ctx)}"
        if rain >= 60 or vis < 4 or wind >= 35:
            return "Transit & Flight Delay Risk"
        return "Clear Travel Conditions"

    elif widget == "Commuter":
        if rain >= 60:
            return "Heavy Rain Traffic Delays"
        if vis < 4:
            return "Dense Fog Road Caution"
        if 7 <= hour <= 10 or 16 <= hour <= 20:
            return "Rush Hour Transit Route"
        return "Smooth Commute Conditions"

    elif widget == "Family":
        if rain >= 60:
            return "Rain Alert for School Run"
        if 18 <= temp <= 27 and rain < 20:
            return "Ideal Playground Weather"
        if uv >= 8:
            return "Sun Protection for Kids"
        return "Family Routine Planning"

    elif widget == "Agriculture":
        if temp <= climate["frost"]:
            return "Crop Frost Warning"
        if 30 <= rain <= 70:
            return "Rain Forecast / Skip Watering"
        if wind >= 28:
            return "High Spray Drift Wind"
        return "Optimal Growing Weather"

    elif widget == "Events":
        if rain >= 60:
            return "Rain Disruption Risk"
        if wind >= 28:
            return "Wind Caution for Marquees"
        if 18 <= temp <= 27 and rain < 20:
            return "Ideal Outdoor Event Weather"
        return "Event Weather Window"

    return "Live Weather Update"


def get_card_highlights(widget: str, ctx: Dict[str, Any]) -> Dict[str, str]:
    """
    Returns 3-4 essential weather & environmental metrics tailored specifically
    for this widget card on the mobile UI (e.g. UV level, air quality, packing tips).
    """
    uv = ctx.get("uv_index", 0)
    aqi = ctx.get("aqi")
    rain = ctx.get("rain_probability", 0)
    temp = ctx.get("temperature", 20)
    humidity = ctx.get("humidity", 50)
    vis = ctx.get("visibility", 10)
    wind = ctx.get("wind_speed", 0)
    pollen = ctx.get("pollen_level", "low").title()

    uv_desc = "Extreme" if uv >= 11 else "Very High" if uv >= 8 else "High" if uv >= 6 else "Moderate" if uv >= 3 else "Low"
    aqi_desc = f"AQI {aqi} (Unhealthy)" if aqi and aqi >= 150 else f"AQI {aqi} (Moderate)" if aqi and aqi >= 50 else f"AQI {aqi} (Good)" if aqi else "Good"

    if widget == "Health":
        return {
            "UV Index": f"{uv} ({uv_desc})",
            "Air Quality": aqi_desc,
            "Temperature": f"{temp}C ({humidity}% Humidity)",
            "Allergy / Pollen": f"{pollen} Pollen Level"
        }

    elif widget == "Outdoor Fitness":
        return {
            "Best Running Hours": "6:00 AM - 9:00 AM" if 6 <= ctx.get("hour", 12) <= 12 else "5:00 PM - 8:00 PM",
            "Temperature": f"{temp}C",
            "Rain Probability": f"{rain}%",
            "Running Comfort": f"Wind {wind} km/h | UV {uv}"
        }

    elif widget == "Beach & Surf":
        return {
            "Coastal Temp": f"{temp}C (Warm & Sunny)",
            "Surf Breeze": f"{wind} km/h",
            "Sun & UV": f"{uv} ({uv_desc})",
            "Precipitation": f"{rain}% Rain"
        }

    elif widget == "Travel":
        return {
            "Trip Status": "Upcoming Trip Scheduled" if ctx.get("upcoming_trip") else "Local Transit Clear",
            "Route Weather": f"{temp}C | {rain}% Rain Risk",
            "Flight / Road Delay": "High Delay Risk" if rain >= 60 or vis < 4 or wind >= 35 else "Clear Routes",
            "Smart Packing": generate_packing_tip(ctx)
        }

    elif widget == "Family":
        return {
            "School Commute": "Drop-off Hours (7-9 AM)" if 7 <= ctx.get("hour", 12) <= 10 else "After-School Routine",
            "Playground Weather": f"{temp}C (Pleasant)" if 18 <= temp <= 27 else f"{temp}C",
            "Child Sun Protection": f"UV {uv} ({'Apply SPF 50+' if uv >= 8 else 'Low Risk'})",
            "Rain Alert": f"{rain}% Rain Expected"
        }

    elif widget == "Commuter":
        return {
            "Transit Status": "Rush Hour Active" if (7 <= ctx.get("hour", 12) <= 10 or 16 <= ctx.get("hour", 12) <= 20) else "Standard Traffic",
            "Road Visibility": f"{vis} km ({'Dense Fog Caution' if vis < 4 else 'Clear Visibility'})",
            "Road Weather": f"{temp}C | {rain}% Rain",
            "Wind Conditions": f"{wind} km/h"
        }

    elif widget == "Agriculture":
        return {
            "Rain & Watering": f"{rain}% Rain | {'Skip Irrigation' if 30 <= rain <= 70 else 'Watering Needed'}",
            "Crop Temperature": f"{temp}C | {'Frost Danger' if temp <= 4 else 'Optimal Growth' if 16 <= temp <= 28 else 'Heat Stress' if temp >= 33 else 'Moderate'}",
            "Spray Drift Window": f"{wind} km/h ({'Safe for Spraying' if wind <= 15 else 'High Drift Risk'})",
            "Solar Sunlight": f"UV {uv} ({uv_desc})"
        }

    elif widget == "Events":
        return {
            "Crowd Comfort": f"{temp}C ({humidity}% Humidity)",
            "Rain Disruption Risk": f"{rain}% ({'Disruption Likely' if rain >= 60 else 'Clear Skies'})",
            "Tent & Marquee Wind": f"{wind} km/h ({'Marquee Hazard' if wind >= 28 else 'Safe for Structures'})",
            "Event Hours": "10:00 AM - 10:00 PM"
        }

    return {
        "Temperature": f"{temp}C",
        "Rain Probability": f"{rain}%",
        "Wind": f"{wind} km/h"
    }

