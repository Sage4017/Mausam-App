import pandas as pd
from Relevance_matrix import MyScore_data
from interest import index
from User import user
from context import calculate_context_score,calculate_weather_impact
from context import context
# Create DataFrame
Myscore_matrix = pd.DataFrame(
    MyScore_data,
    index=index
)  

# Calculate personal score


def calculate_personal_score(Index, user, Myscore_matrix):

    score = 0
    max_score = sum(user.values())

    for interest, preference in user.items():

        relevance = Myscore_matrix.loc[Index, interest]

        score += relevance * preference
    if max_score == 0:
        return 0
    
    normalized_score = (score/max_score)*100

    return normalized_score


def calculate_final_score(
    personal,
    context,
    weather
):

    return (
        personal * 0.6 +
        context * 0.2 +
        weather * 0.2
    )

def rank_widgets(user, context):

    scores = {}

    for widget in index:

        personal = calculate_personal_score(
            user,
            widget,
            MyScore_data
        )

        contextual = calculate_context_score(
            widget,
            context
        )

        weather = calculate_weather_impact(
            widget,
            context
        )

        final = calculate_final_score(
            personal,
            contextual,
            weather
        )

        scores[widget] = final

    return scores

def rank_widgets(user, context):

    scores = {}

    for widget in index:

        personal = calculate_personal_score(
            widget,
            user,
            Myscore_matrix
        )

        contextual = calculate_context_score(
            widget,
            context
        )

        weather = calculate_weather_impact(
            widget,
            context
        )

        weather_score = calculate_weather_impact(
            widget,
            context
        )

        final = calculate_final_score(
            personal,
            contextual,
            weather_score
        )

        scores[widget] = final

    ranked = sorted(
        scores.items(),
        key=lambda x: x[1],
        reverse=True
    )

    return ranked

SAFETY_WIDGETS = {
    "storm": ["commuter", "family", "travel"],
    "extreme_heat": ["health", "fitness"],
    "flood": ["commuter", "family", "travel"],
}
def apply_safety_override(scores, alerts):

    for alert in alerts:

        widgets = SAFETY_WIDGETS.get(
            alert["type"],
            []
        )

        for widget in widgets:
            scores[widget] = max(
                scores[widget],
                95
            )

    return scores

print("\nUSER BEING USED:")
print(user)

print(context)

result = rank_widgets(user, context)

for widget, score in result:
    print(widget, round(score, 2))
