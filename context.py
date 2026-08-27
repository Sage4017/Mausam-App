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

def calculate_context_score(interest,context):
    score = 0
    if interest == "Outdoor Fitness":

        if 6 <= context["hour"] <= 9:
            score += 20

        if context["temperature"] < 30:
            score += 10

        if context["rain_probability"] < 30:
            score += 10

    if interest == "Travel":

        if context["upcoming_trip"]:
            score += 40

    if interest == "Commuter":

        if context["commuting"]:
            score += 30

    return min(score, 100)


def calculate_weather_impact(widget, context):

    score = 0

    if widget == "Outdoor Fitness":

        if context["uv_index"] >= 8:
            score += 30

        if context["temperature"] >= 35:
            score += 30

        if context["rain_probability"] >= 70:
            score += 30

    if widget == "Commuter":

        if context["rain_probability"] >= 70:
            score += 30

        if context["visibility"] < 5:
            score += 40

    if widget == "Health":

        if context["uv_index"] >= 8:
            score += 20

    return min(score, 100)
