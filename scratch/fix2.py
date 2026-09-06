imports = """import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/pill_button.dart';
import '../widgets/frosted_glass_card.dart';
import 'main_shell_screen.dart';
"""
with open("mausam_app/lib/screens/relevance_sliders_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()
if "package:flutter/material.dart" not in content:
    with open("mausam_app/lib/screens/relevance_sliders_screen.dart", "w", encoding="utf-8") as f:
        f.write(imports + "\n\n" + content)
        print("Restored imports")
