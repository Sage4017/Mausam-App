# Relevance Matrix: Maps Widget Category -> {User Interest: Relevance Score (0.0 - 1.0)}
# Rows represent Widgets, Columns represent User Interests.

relevance_matrix = {
    "Health": {
        "Health": 1.0, "Outdoor Fitness": 0.8, "Beach & Surf": 0.2, "Travel": 0.3,
        "Family": 0.7, "Agriculture": 0.3, "Commuter": 0.5, "Events": 0.3
    },
    "Outdoor Fitness": {
        "Health": 0.7, "Outdoor Fitness": 1.0, "Beach & Surf": 0.5, "Travel": 0.3,
        "Family": 0.2, "Agriculture": 0.1, "Commuter": 0.3, "Events": 0.2
    },
    "Beach & Surf": {
        "Health": 0.2, "Outdoor Fitness": 0.5, "Beach & Surf": 1.0, "Travel": 0.5,
        "Family": 0.3, "Agriculture": 0.1, "Commuter": 0.1, "Events": 0.4
    },
    "Travel": {
        "Health": 0.4, "Outdoor Fitness": 0.4, "Beach & Surf": 0.5, "Travel": 1.0,
        "Family": 0.6, "Agriculture": 0.1, "Commuter": 0.8, "Events": 0.7
    },
    "Family": {
        "Health": 0.7, "Outdoor Fitness": 0.2, "Beach & Surf": 0.3, "Travel": 0.6,
        "Family": 1.0, "Agriculture": 0.2, "Commuter": 0.7, "Events": 0.4
    },
    "Agriculture": {
        "Health": 0.3, "Outdoor Fitness": 0.1, "Beach & Surf": 0.1, "Travel": 0.1,
        "Family": 0.2, "Agriculture": 1.0, "Commuter": 0.1, "Events": 0.1
    },
    "Commuter": {
        "Health": 0.6, "Outdoor Fitness": 0.3, "Beach & Surf": 0.1, "Travel": 0.8,
        "Family": 0.8, "Agriculture": 0.1, "Commuter": 1.0, "Events": 0.3
    },
    "Events": {
        "Health": 0.3, "Outdoor Fitness": 0.2, "Beach & Surf": 0.4, "Travel": 0.7,
        "Family": 0.4, "Agriculture": 0.1, "Commuter": 0.3, "Events": 1.0
    }
}

# Alias for backwards compatibility
MyScore_data = relevance_matrix