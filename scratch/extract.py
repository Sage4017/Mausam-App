import re

with open("scratch/teammate_main.dart", "r", encoding="utf-16") as f:
    content = f.read()

def extract_and_write(class_name, next_class, file_path, imports):
    pattern = rf"(class {class_name} .*?(?=class {next_class}))"
    match = re.search(pattern, content, re.DOTALL)
    if match:
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(imports + "\n\n" + match.group(1).strip())
        print(f"Updated {file_path}")
    else:
        print(f"Failed to extract {class_name}")

imports_splash = "import 'package:flutter/material.dart';\nimport '../core/app_theme.dart';\nimport '../services/app_state.dart';\nimport '../widgets/frosted_glass_card.dart';\nimport '../widgets/pill_button.dart';\nimport '../widgets/imd_widgets.dart';\nimport 'location_permission_screen.dart';"
extract_and_write("SplashScreen", "LocationPermissionScreen", "mausam_app/lib/screens/splash_screen.dart", imports_splash)

imports_loc = "import 'package:flutter/material.dart';\nimport '../core/app_theme.dart';\nimport '../services/app_state.dart';\nimport '../widgets/pill_button.dart';\nimport '../widgets/imd_widgets.dart';\nimport 'onboarding/onboarding_screen.dart';\nimport 'package:geolocator/geolocator.dart';"
extract_and_write("LocationPermissionScreen", "MainShellScreen", "mausam_app/lib/screens/location_permission_screen.dart", imports_loc)

imports_psel = "import 'package:flutter/material.dart';\nimport '../core/app_theme.dart';\nimport '../services/app_state.dart';\nimport '../widgets/frosted_glass_card.dart';\nimport '../widgets/pill_button.dart';\nimport 'persona_question_screen.dart';"
extract_and_write("PersonaSelectionScreen", "PersonaQuestionScreen", "mausam_app/lib/screens/persona_selection_screen.dart", imports_psel)

# PersonaQuestionScreen also needs _OptionItem which is before RelevanceSlidersScreen
pattern_pques = r"(class PersonaQuestionScreen .*?(?=class RelevanceSlidersScreen))"
match_pques = re.search(pattern_pques, content, re.DOTALL)
if match_pques:
    imports_pques = "import 'package:flutter/material.dart';\nimport '../core/app_theme.dart';\nimport '../services/app_state.dart';\nimport '../widgets/pill_button.dart';\nimport 'relevance_sliders_screen.dart';"
    with open("mausam_app/lib/screens/persona_question_screen.dart", "w", encoding="utf-8") as f:
        f.write(imports_pques + "\n\n" + match_pques.group(1).strip())
    print("Updated mausam_app/lib/screens/persona_question_screen.dart")

imports_rel = "import 'package:flutter/material.dart';\nimport '../core/app_theme.dart';\nimport '../services/app_state.dart';\nimport '../widgets/pill_button.dart';\nimport 'main_shell_screen.dart';"
extract_and_write("RelevanceSlidersScreen", "HomeScreen", "mausam_app/lib/screens/relevance_sliders_screen.dart", imports_rel)

