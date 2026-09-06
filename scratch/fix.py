import os

def insert_import(filepath, imp):
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()
    if imp not in content:
        content = imp + "\n" + content
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(content)

insert_import("mausam_app/lib/screens/persona_question_screen.dart", "import '../models/app_models.dart';\nimport '../widgets/frosted_glass_card.dart';")
insert_import("mausam_app/lib/screens/persona_selection_screen.dart", "import '../models/app_models.dart';")
insert_import("mausam_app/lib/screens/relevance_sliders_screen.dart", "import '../widgets/frosted_glass_card.dart';\nimport 'home_screen.dart';\nimport 'explore_screen.dart';\nimport 'alerts_screen.dart';\nimport 'profile_screen.dart';")
insert_import("mausam_app/lib/widgets/imd_widgets.dart", "import 'package:google_fonts/google_fonts.dart';")

# Fix RelevanceSlidersScreen having MainShellScreen appended to it
with open("mausam_app/lib/screens/relevance_sliders_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()
import re
match = re.search(r"(class RelevanceSlidersScreen .*?)(class MainShellScreen .*?)$", content, re.DOTALL)
if match:
    with open("mausam_app/lib/screens/relevance_sliders_screen.dart", "w", encoding="utf-8") as f:
        f.write(match.group(1))
    print("Fixed RelevanceSlidersScreen")

