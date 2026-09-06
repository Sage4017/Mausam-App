import re
with open("scratch/teammate_main.dart", "r", encoding="utf-16") as f:
    content = f.read()

match = re.search(r"class SplashScreen extends StatelessWidget \{.*?(?=class LocationPermissionScreen)", content, re.DOTALL)
if match:
    with open("mausam_app/lib/screens/splash_screen.dart", "w", encoding="utf-8") as f:
        f.write("import 'package:flutter/material.dart';\nimport '../core/app_theme.dart';\nimport '../widgets/imd_widgets.dart';\nimport 'location_permission_screen.dart';\n\n")
        f.write(match.group(0))
    print("Extracted SplashScreen")
