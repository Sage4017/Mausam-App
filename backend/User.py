# User preferences configuration and helper parser

# Rating keyword to numerical weight mapping
PREFERENCE_SCALE = {
    "vimp": 1.0,
    "very important": 1.0,
    "high": 1.0,
    "imp": 0.8,
    "important": 0.8,
    "normal": 0.5,
    "medium": 0.5,
    "low": 0.2,
    "not imp": 0.0,
    "not important": 0.0,
    "none": 0.0,
    "doesnt matter": 0.0,
}

def parse_user_preferences(raw_prefs: dict) -> dict:
    """
    Parses user preferences that might contain string keywords (e.g. 'vimp', 'normal')
    or raw numeric weights (0.0 to 1.0), returning normalized float values.
    """
    parsed = {}
    for interest, val in raw_prefs.items():
        if isinstance(val, (int, float)):
            parsed[interest] = float(val)
        elif isinstance(val, str):
            clean_val = val.strip().lower()
            parsed[interest] = PREFERENCE_SCALE.get(clean_val, 0.5)
        else:
            parsed[interest] = 0.0
    return parsed

# Sample default user preferences
user = {
    "Health": 0.8,
    "Outdoor Fitness": 0.1,
    "Beach & Surf": 0.5,
    "Travel": 0.2,
    "Family": 0.5,
    "Agriculture": 0.0,
    "Commuter": 0.4,
    "Events": 0.0
}
