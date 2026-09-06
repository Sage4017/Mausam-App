import re
with open("scratch/teammate_main.dart", "r", encoding="utf-16") as f:
    content = f.read()

pattern = r"(class SplashScreen .*?(?=class PersonaSelectionScreen))"
match = re.search(pattern, content, re.DOTALL)
if match:
    imports_splash = "import 'package:flutter/material.dart';\nimport '../core/app_theme.dart';\nimport '../services/app_state.dart';\nimport '../widgets/frosted_glass_card.dart';\nimport '../widgets/pill_button.dart';\nimport '../widgets/imd_widgets.dart';\nimport 'persona_selection_screen.dart';"
    with open("mausam_app/lib/screens/splash_screen.dart", "w", encoding="utf-8") as f:
        f.write(imports_splash + "\n\n" + match.group(1).strip())
    print("Updated SplashScreen")
