import re

with open("scratch/teammate_main.dart", "r", encoding="utf-16") as f:
    content = f.read()

def get_class(class_name, end_marker):
    pattern = rf"class {class_name} .*?(?={end_marker})"
    match = re.search(pattern, content, re.DOTALL)
    if not match:
        print(f"Failed to find {class_name}")
        return ""
    return match.group(0)

# Splash Screen
splash = get_class("SplashScreen", "class LocationPermissionScreen")
if splash:
    with open("mausam_app/lib/screens/splash_screen.dart", "w", encoding="utf-8") as f:
        f.write("import 'package:flutter/material.dart';\nimport '../core/app_theme.dart';\nimport '../widgets/imd_widgets.dart';\nimport 'location_permission_screen.dart';\n\n" + splash)

# Location Permission
loc = get_class("LocationPermissionScreen", "class MainShellScreen")
if loc:
    with open("mausam_app/lib/screens/location_permission_screen.dart", "w", encoding="utf-8") as f:
        f.write("import 'package:flutter/material.dart';\nimport '../core/app_theme.dart';\nimport '../services/app_state.dart';\nimport '../widgets/imd_widgets.dart';\nimport 'onboarding/onboarding_screen.dart';\nimport 'package:geolocator/geolocator.dart';\n\n" + loc)

# Persona Selection
psel = get_class("PersonaSelectionScreen", "class PersonaQuestionScreen")
if psel:
    with open("mausam_app/lib/screens/persona_selection_screen.dart", "w", encoding="utf-8") as f:
        f.write("import 'package:flutter/material.dart';\nimport '../core/app_theme.dart';\nimport '../services/app_state.dart';\nimport '../widgets/pill_button.dart';\nimport 'persona_question_screen.dart';\n\n" + psel)

# Persona Question
pques = get_class("PersonaQuestionScreen", "class _OptionItem")
opt = get_class("_OptionItem", "class RelevanceSlidersScreen")
if pques and opt:
    with open("mausam_app/lib/screens/persona_question_screen.dart", "w", encoding="utf-8") as f:
        f.write("import 'package:flutter/material.dart';\nimport '../core/app_theme.dart';\nimport '../services/app_state.dart';\nimport '../widgets/pill_button.dart';\nimport 'relevance_sliders_screen.dart';\n\n" + pques + "\n" + opt)

# Relevance Sliders
rel = get_class("RelevanceSlidersScreen", "class HomeScreen")
if rel:
    with open("mausam_app/lib/screens/relevance_sliders_screen.dart", "w", encoding="utf-8") as f:
        f.write("import 'package:flutter/material.dart';\nimport '../core/app_theme.dart';\nimport '../services/app_state.dart';\nimport '../widgets/pill_button.dart';\nimport 'main_shell_screen.dart';\n\n" + rel)

print("Extraction complete")
