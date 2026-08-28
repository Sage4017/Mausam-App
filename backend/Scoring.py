"""
Widget Scoring and Ranking Engine for Mausam Mobile App
Combines personalized user affinities, direct preference weighting,
live real-time contextual conditions, climate zones, and essential card highlights.
"""

from typing import Dict, List, Tuple, Any, Optional
from Widgets import WIDGETS
from Relevance_matrix import relevance_matrix
from User import user, parse_user_preferences
from context import calculate_context_score, generate_widget_badge, get_card_highlights, context


# Human-friendly UI titles for mobile display
WIDGET_DISPLAY_TITLES: Dict[str, str] = {
    "Health": "Health & Air Quality",
    "Outdoor Fitness": "Outdoor Fitness",
    "Beach & Surf": "Beach & Surf",
    "Travel": "Travel & Trip Prep",
    "Family": "Family & Kids Routine",
    "Agriculture": "Gardening & Agriculture",
    "Commuter": "Commute & Traffic",
    "Events": "Outdoor Events & Gatherings",
}

# Safety-critical widget triggers mapped to alert types
SAFETY_WIDGETS: Dict[str, List[str]] = {
    "storm": ["Commuter", "Family", "Travel"],
    "extreme_heat": ["Health", "Outdoor Fitness"],
    "flood": ["Commuter", "Family", "Travel"],
    "air_quality": ["Health", "Outdoor Fitness", "Family"],
}


def calculate_personal_score(
    widget: str,
    user_prefs: Dict[str, float],
    matrix: Optional[Dict[str, Dict[str, float]]] = None,
    direct_weight: float = 0.70,
    cross_weight: float = 0.30
) -> float:
    """
    Calculates a balanced personal preference score (0 - 100).
    - Direct Component (70%): User's explicit rating for this category.
    - Cross Component (30%): Spillover relevance from related categories.
    """
    if matrix is None:
        matrix = relevance_matrix

    total_preference = sum(user_prefs.values())
    if total_preference <= 0:
        return 0.0

    direct_score = user_prefs.get(widget, 0.0) * 100.0

    widget_relevance = matrix.get(widget, {})
    raw_cross = sum(
        widget_relevance.get(interest, 0.0) * pref
        for interest, pref in user_prefs.items()
    )
    cross_score = (raw_cross / total_preference) * 100.0

    combined_score = (direct_score * direct_weight) + (cross_score * cross_weight)
    return min(max(combined_score, 0.0), 100.0)


def calculate_final_score(
    personal: float,
    contextual: float,
    mode: str = "multiplicative",
    personal_weight: float = 0.70,
    context_weight: float = 0.30,
    min_multiplier: float = 0.35
) -> float:
    """
    Computes a composite final score (0 - 100).
    - 'multiplicative' (Recommended): Weather scales user interest dynamically.
    - 'additive': Linear combination (Personal * 0.7 + Context * 0.3).
    """
    if mode == "multiplicative":
        scaling_factor = min_multiplier + (1.0 - min_multiplier) * (contextual / 100.0)
        return min(personal * scaling_factor, 100.0)
    else:
        return (personal * personal_weight) + (contextual * context_weight)


def apply_safety_override(
    scores: Dict[str, float],
    alerts: Optional[List[Dict[str, Any]]] = None,
    override_score: float = 95.0
) -> Dict[str, float]:
    """Elevates scores of safety widgets when severe weather alerts are active."""
    if not alerts:
        return scores

    updated_scores = dict(scores)
    for alert in alerts:
        alert_type = alert.get("type", "").lower()
        affected_widgets = SAFETY_WIDGETS.get(alert_type, [])

        for widget in affected_widgets:
            if widget in updated_scores:
                updated_scores[widget] = max(updated_scores[widget], override_score)

    return updated_scores


def rank_widgets(
    user_prefs: Dict[str, Any],
    ctx: Dict[str, Any],
    alerts: Optional[List[Dict[str, Any]]] = None,
    mode: str = "multiplicative",
    direct_weight: float = 0.70,
    cross_weight: float = 0.30
) -> List[Tuple[str, float]]:
    """Ranks all widgets in descending order by final score."""
    parsed_prefs = parse_user_preferences(user_prefs)
    scores: Dict[str, float] = {}

    for widget in WIDGETS:
        personal = calculate_personal_score(
            widget=widget,
            user_prefs=parsed_prefs,
            direct_weight=direct_weight,
            cross_weight=cross_weight
        )
        contextual = calculate_context_score(widget, ctx)
        final = calculate_final_score(personal=personal, contextual=contextual, mode=mode)
        scores[widget] = final

    if alerts:
        scores = apply_safety_override(scores, alerts)

    return sorted(scores.items(), key=lambda item: item[1], reverse=True)


def get_home_feed(
    user_prefs: Dict[str, Any],
    ctx: Dict[str, Any],
    alerts: Optional[List[Dict[str, Any]]] = None,
    hero_count: int = 3,
    mode: str = "multiplicative"
) -> Dict[str, List[Dict[str, Any]]]:
    """
    Primary API function for the Mausam Mobile App Feed.
    Returns both 'primary_widgets' (Top 3 for Hero screen without scrolling)
    and 'secondary_widgets' (Remaining 5 for the scroll view), populated with
    actionable subtitles and essential weather highlights for that specific card.
    """
    parsed_prefs = parse_user_preferences(user_prefs)
    ranked_tuples = rank_widgets(parsed_prefs, ctx, alerts=alerts, mode=mode)

    all_cards = []
    for rank, (widget_name, score) in enumerate(ranked_tuples, start=1):
        badge = generate_widget_badge(widget_name, ctx)

        if alerts:
            for alert in alerts:
                if widget_name in SAFETY_WIDGETS.get(alert.get("type", "").lower(), []):
                    badge = f"[ALERT] Severe {alert.get('type', '').title()} Warning"

        highlights = get_card_highlights(widget_name, ctx)

        all_cards.append({
            "rank": rank,
            "widget_id": widget_name.lower().replace(" & ", "_").replace(" ", "_"),
            "category": widget_name,
            "title": WIDGET_DISPLAY_TITLES.get(widget_name, widget_name),
            "badge": badge,
            "highlights": highlights
        })

    return {
        "primary_widgets": all_cards[:hero_count],
        "secondary_widgets": all_cards[hero_count:]
    }


def get_top_homepage_widgets(
    user_prefs: Dict[str, Any],
    ctx: Dict[str, Any],
    alerts: Optional[List[Dict[str, Any]]] = None,
    top_k: int = 3,
    mode: str = "multiplicative"
) -> List[Dict[str, Any]]:
    """Backward-compatible helper returning the top K widgets."""
    feed = get_home_feed(user_prefs, ctx, alerts=alerts, hero_count=top_k, mode=mode)
    return feed["primary_widgets"]


if __name__ == "__main__":
    print("=" * 80)
    print(" MAUSAM APP - HYPER-PERSONALIZED HOMEPAGE FEED (CONSUMER VIEW)")
    print("=" * 80)

    # Standard Home Feed: Primary (Top 3) & Secondary (Scrollable 5)
    feed = get_home_feed(user, context, hero_count=3)

    print("\n" + "=" * 80)
    print(" [1] HERO VIEW - TOP 3 CARDS (Seen Immediately On App Open):")
    print("=" * 80)
    for card in feed["primary_widgets"]:
        print(f"\n [Card #{card['rank']}] {card['title'].upper()}")
        print(f"   |-- Status Badge : {card['badge']}")
        print("   +-- Key Highlights:")
        for metric, val in card["highlights"].items():
            print(f"       * {metric:<22}: {val}")

    print("\n" + "=" * 80)
    print(" [2] SCROLL VIEW - REMAINING 5 CARDS (Seen Upon Scrolling Down):")
    print("=" * 80)
    for card in feed["secondary_widgets"]:
        print(f"\n [Card #{card['rank']}] {card['title'].upper()} ({card['badge']})")
        for metric, val in list(card["highlights"].items())[:2]:
            print(f"   * {metric:<22}: {val}")

    # Upcoming Trip Scenario: Smart Packing Micro-tip demonstration
    print("\n" + "=" * 80)
    print(" [3] TRIP PREPARATION DEMO (Adverse Weather Packing Triggered):")
    print("=" * 80)
    trip_ctx = dict(context)
    trip_ctx["upcoming_trip"] = True
    trip_ctx["rain_probability"] = 75
    trip_ctx["temperature"] = 11  # Chilly rainy destination

    trip_feed = get_home_feed(user, trip_ctx, hero_count=3)
    for card in trip_feed["primary_widgets"]:
        print(f"\n [Card #{card['rank']}] {card['title'].upper()}")
        print(f"   |-- Status Badge : {card['badge']}")
        print("   +-- Key Highlights:")
        for metric, val in card["highlights"].items():
            print(f"       * {metric:<22}: {val}")
