import os
import re

def extract_block(text, keyword, name):
    pattern = re.compile(rf"{keyword}\s+{name}(?:[^{{]*)?{{", re.MULTILINE)
    match = pattern.search(text)
    if not match:
        return None, text
    
    start_idx = match.start()
    brace_idx = text.find("{", start_idx)
    
    count = 1
    i = brace_idx + 1
    while count > 0 and i < len(text):
        if text[i] == '{':
            count += 1
        elif text[i] == '}':
            count -= 1
        i += 1
        
    end_idx = i
    block_str = text[start_idx:end_idx]
    
    new_text = text[:start_idx] + text[end_idx:]
    return block_str, new_text

with open('mausam_app/lib/main.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# Define extractions
widgets_config = {
    'frosted_glass_card': [('class', 'FrostedGlassCard')],
    'pill_button': [('class', 'PillButton')],
}

screens_config = {
    'splash_screen': [('class', 'SplashScreen')],
    'location_permission_screen': [('class', 'LocationPermissionScreen')],
    'persona_selection_screen': [('class', 'PersonaSelectionScreen')],
    'persona_question_screen': [('class', 'PersonaQuestionScreen'), ('class', '_PersonaQuestionScreenState')],
    'relevance_sliders_screen': [('class', 'RelevanceSlidersScreen')],
    'main_shell_screen': [('class', 'MainShellScreen')],
    'home_screen': [('class', 'HomeScreen')],
    'weather_detail_screen': [('class', 'WeatherDetailScreen'), ('class', '_MetricCard')],
    'aqi_detail_screen': [('class', 'AqiDetailScreen')],
    'explore_screen': [('class', 'ExploreScreen')],
    'mausam_ai_screen': [('class', 'MausamAIScreen'), ('class', '_MausamAIScreenState')],
    'alerts_screen': [('class', 'AlertsScreen')],
    'profile_screen': [('class', 'ProfileScreen')],
}

os.makedirs('mausam_app/lib/widgets', exist_ok=True)
os.makedirs('mausam_app/lib/screens', exist_ok=True)

standard_imports = """import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/frosted_glass_card.dart';
import '../widgets/pill_button.dart';
"""

# Extract and write widgets
for filename, classes in widgets_config.items():
    extracted = []
    for type_, name in classes:
        blk, code = extract_block(code, type_, name)
        if blk: extracted.append(blk)
    
    if extracted:
        with open(f'mausam_app/lib/widgets/{filename}.dart', 'w', encoding='utf-8') as f:
            f.write("import 'package:flutter/material.dart';\n")
            f.write("import '../core/app_theme.dart';\n\n")
            f.write("\n\n".join(extracted))

# Extract and write screens
for filename, classes in screens_config.items():
    extracted = []
    for type_, name in classes:
        blk, code = extract_block(code, type_, name)
        if blk: extracted.append(blk)
    
    if extracted:
        with open(f'mausam_app/lib/screens/{filename}.dart', 'w', encoding='utf-8') as f:
            f.write(standard_imports + "\n\n")
            if filename == 'main_shell_screen':
                # Needs imports for the screens it displays
                f.write("import 'home_screen.dart';\n")
                f.write("import 'explore_screen.dart';\n")
                f.write("import 'alerts_screen.dart';\n")
                f.write("import 'profile_screen.dart';\n\n")
            if filename == 'home_screen':
                f.write("import 'weather_detail_screen.dart';\n")
                f.write("import 'aqi_detail_screen.dart';\n")
                f.write("import 'mausam_ai_screen.dart';\n\n")
            if filename == 'splash_screen':
                f.write("import 'location_permission_screen.dart';\n\n")
            if filename == 'location_permission_screen':
                f.write("import 'persona_selection_screen.dart';\n\n")
            if filename == 'persona_selection_screen':
                f.write("import 'persona_question_screen.dart';\n")
                f.write("import 'relevance_sliders_screen.dart';\n\n")
            if filename == 'persona_question_screen':
                f.write("import 'relevance_sliders_screen.dart';\n\n")
            if filename == 'relevance_sliders_screen':
                f.write("import 'main_shell_screen.dart';\n\n")

            f.write("\n\n".join(extracted))

# Add new imports to main.dart
new_imports = """import 'widgets/frosted_glass_card.dart';
import 'widgets/pill_button.dart';
import 'screens/splash_screen.dart';
"""

lines = code.split('\n')
last_import = 0
for i, line in enumerate(lines):
    if line.startswith('import '):
        last_import = i

lines.insert(last_import + 1, new_imports)
code = '\n'.join(lines)

with open('mausam_app/lib/main.dart', 'w', encoding='utf-8') as f:
    f.write(code)

print("Screens extraction complete!")
