from interest import index


context = {
    "hour": 7,
    "rain_probability": 20,
    "temperature": 25,
    "uv_index": 10,
    "wind_speed": 8,
    "visibility": 10,

    "upcoming_trip": False,
    "commuting": True,
    "outdoor_activity": True
}

#these will change and will come from api

def calculate_context_score(interest, context):
    score = 0
    if interest == "Outdoor Fitness":

        # Ideal workout time
        if 6 <= context["hour"] <= 9:
            score += 20
        elif 17 <= context["hour"] <= 20:
            score += 15

        # Temperature
        if 16 <= context["temperature"] <= 22:
            score += 20
        elif 23 <= context["temperature"] <= 28:
            score += 15
        elif 29 <= context["temperature"] <= 34:
            score += 8

        # Rain
        if context["rain_probability"] >= 60:
            score += 20
        elif context["rain_probability"]>= 40:
            score += 10

        # UV
        if context["uv_index"] <= 3:
            score += 15
        elif context["uv_index"] <= 6:
            score += 10
        elif context["uv_index"] >= 9:
            score += 5

        # Wind
        if context["wind_speed"] <= 15:
            score += 10
        elif context["wind_speed"] <= 25:
            score += 5

        # Visibility
        if context["visibility"] >= 8:
            score += 5


    # ========================================================
    # TRAVEL
    # ========================================================

    elif interest == "Travel":

        if context.get("upcoming_trip", False):
            score += 40

        if context["rain_probability"] >= 40:
            score += 20
        elif context["rain_probability"] >= 20:
            score += 10

        if context["visibility"] < 3:
            score += 25
        elif context["visibility"] < 5:
            score += 20

        if context["temperature"] >= 35:
            score += 10
        elif context["temperature"] <= 10:
            score += 10

        if context["wind_speed"] >= 30:
            score += 10


    # ========================================================
    # COMMUTER
    # ========================================================

    elif interest == "Commuter":

        # Actual commute
        if context.get("commuting", False):
            score += 30

        # Rush hour
        if 7 <= context["hour"] <= 10:
            score += 15
        elif 16 <= context["hour"] <= 20:
            score += 15

        # Rain
        if context["rain_probability"] >= 70:
            score += 20
        elif context["rain_probability"] >= 40:
            score += 10

        # Visibility
        if context["visibility"] < 3:
            score += 20
        elif context["visibility"] < 6:
            score += 10


    # ========================================================
    # BEACH & SURF
    # ========================================================

    elif interest == "Beach & Surf":

        # Temperature
        if 21 <= context["temperature"] <= 25:
            score += 25
        elif 18 <= context["temperature"] < 21:
            score += 15
        elif 26 <= context["temperature"] <= 30:
            score += 15
        else:
            score += 5

        # Rain
        if context["rain_probability"] < 20:
            score += 15
        elif context["rain_probability"] < 50:
            score += 8

        # Wind
        if 10 <= context["wind_speed"] <= 25:
            score += 25
        elif context["wind_speed"] < 10:
            score += 15
        elif context["wind_speed"] <= 35:
            score += 10

        # UV
        if 3 <= context["uv_index"] <= 6:
            score += 10
        elif context["uv_index"] <= 2:
            score += 8
        elif context["uv_index"] >= 9:
            score += 5

        # Visibility
        if context["visibility"] >= 8:
            score += 15
        elif context["visibility"] >= 5:
            score += 8

        # Daylight
        if 7 <= context["hour"] <= 18:
            score += 10


    # ========================================================
    # HEALTH
    # ========================================================

    elif interest == "Health":

        # UV
        if context["uv_index"] >= 11:
            score += 30
        elif context["uv_index"] >= 8:
            score += 25
        elif context["uv_index"] >= 6:
            score += 15

        # Temperature
        if context["temperature"] >= 35:
            score += 25
        elif context["temperature"] >= 30:
            score += 15
        elif context["temperature"] <= 5:
            score += 20

        # Rain
        if context["rain_probability"] >= 80:
            score += 15
        elif context["rain_probability"] >= 50:
            score += 8

        # Visibility
        if context["visibility"] < 3:
            score += 20
        elif context["visibility"] < 5:
            score += 10


    # ========================================================
    # FAMILY
    # ========================================================

    elif interest == "Family":

        # Morning/evening
        if 7 <= context["hour"] <= 9:
            score += 20
        elif 16 <= context["hour"] <= 19:
            score += 15

        # Rain
        if context["rain_probability"] >= 70:
            score += 30
        elif context["rain_probability"] >= 40:
            score += 15

        # Temperature
        if context["temperature"] >= 35:
            score += 20
        elif context["temperature"] <= 5:
            score += 20

        # Visibility
        if context["visibility"] < 5:
            score += 20


    # ========================================================
    # AGRICULTURE
    # ========================================================

    elif interest == "Agriculture":

        #crops condition, type or crops, time of irrigation

        # Rain
        if 30 <= context["rain_probability"] <= 70:
            score += 30
        elif context["rain_probability"] > 70:
            score += 20
        elif context["rain_probability"] > 10:
            score += 10

        # Temperature
        if 15 <= context["temperature"] <= 30:
            score += 25
        elif context["temperature"] > 35:
            score += 25
        elif context["temperature"] < 5:
            score += 25

        # Wind
        if context["wind_speed"] >= 30:
            score += 20
        elif context["wind_speed"] >= 20:
            score += 10

        # UV
        if context["uv_index"] >= 8:
            score += 10


    # ========================================================
    # EVENTS
    # ========================================================

    elif interest == "Events":

        # Rain
        if context["rain_probability"] >= 70:
            score += 30
        elif context["rain_probability"] >= 40:
            score += 20

        # Temperature
        if 18 <= context["temperature"] <= 28:
            score += 25
        elif context["temperature"] >= 35:
            score += 20
        elif context["temperature"] <= 10:
            score += 20

        # Wind
        if context["wind_speed"] >= 30:
            score += 20
        elif context["wind_speed"] >= 20:
            score += 10

        # Visibility
        if context["visibility"] < 5:
            score += 15

        # Active event hours
        if 10 <= context["hour"] <= 20:
            score += 10


    # ========================================================
    # FINAL CONTEXT SCORE
    # ========================================================

    return min(score, 100)

def calculate_weather_impact(widget, context):

    score = 0

    if widget == "Outdoor Fitness":

        if context["uv_index"] >= 8:
            score += 0

        if context["temperature"] >= 35:
            score += 0

        if context["rain_probability"] >= 70:
            score += 0

    if widget == "Commuter":

        if context["rain_probability"] >= 70:
            score += 0

        if context["visibility"] < 5:
            score += 0

    if widget == "Health":

        if context["uv_index"] >= 8:
            score += 0

    return min(score, 100)
