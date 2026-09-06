import re

with open("scratch/teammate_main.dart", "r", encoding="utf-16") as f:
    content = f.read()

# Extract ImdLogoWidget
match = re.search(r"class ImdLogoWidget extends StatelessWidget \{.*?(?=class ImdBadge)", content, re.DOTALL)
imd_logo = match.group(0) if match else ""

# Extract ImdBadge
match2 = re.search(r"class ImdBadge extends StatelessWidget \{.*?(?=(// ============================================================================|class SplashScreen))", content, re.DOTALL)
imd_badge = match2.group(0) if match2 else ""

with open("mausam_app/lib/widgets/imd_widgets.dart", "w", encoding="utf-8") as f:
    f.write("import 'package:flutter/material.dart';\nimport '../core/app_theme.dart';\n\n")
    f.write(imd_logo + "\n\n" + imd_badge)

print("Extracted IMD widgets length:", len(imd_logo), len(imd_badge))
