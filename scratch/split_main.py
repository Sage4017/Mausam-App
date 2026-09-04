import os
import re

def extract_block(text, keyword, name):
    # Regex allows optional 'extends' or 'implements' before the open brace
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

# First, restore main.dart from git so we have the original 3000 lines back.
os.system("git restore mausam_app/lib/main.dart")

with open('mausam_app/lib/main.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# 1. Models and Enums
models = [('enum', 'PersonaType'), ('class', 'WeatherSummaryModel'), ('class', 'WidgetCardModel'), ('class', 'HourlyForecastItem'), ('class', 'DailyForecastItem'), ('class', 'PollutantDetail'), ('class', 'ChatMessageModel')]
extracted_models = []
for type_, name in models:
    blk, code = extract_block(code, type_, name)
    if blk:
        extracted_models.append(blk)

# 2. Theme
themes = [('class', 'MausamColors'), ('class', 'MausamTheme')]
extracted_themes = []
for type_, name in themes:
    blk, code = extract_block(code, type_, name)
    if blk:
        extracted_themes.append(blk)

# 3. State
states = [('class', 'AppState'), ('class', 'AppStateScope')]
extracted_state = []
for type_, name in states:
    blk, code = extract_block(code, type_, name)
    if blk:
        extracted_state.append(blk)

# Ensure directories exist
os.makedirs('mausam_app/lib/models', exist_ok=True)
os.makedirs('mausam_app/lib/core', exist_ok=True)
os.makedirs('mausam_app/lib/services', exist_ok=True)

# Write Models
with open('mausam_app/lib/models/app_models.dart', 'w', encoding='utf-8') as f:
    f.write("import 'package:flutter/material.dart';\n")
    f.write("import '../core/app_theme.dart';\n\n")
    f.write("\n\n".join(extracted_models))

# Write Theme
with open('mausam_app/lib/core/app_theme.dart', 'w', encoding='utf-8') as f:
    f.write("import 'package:flutter/material.dart';\n\n")
    f.write("\n\n".join(extracted_themes))

# Write State
with open('mausam_app/lib/services/app_state.dart', 'w', encoding='utf-8') as f:
    f.write("import 'package:flutter/material.dart';\n")
    f.write("import '../models/app_models.dart';\n")
    f.write("import '../core/app_theme.dart';\n")
    f.write("import 'api_client.dart';\n\n")
    f.write("\n\n".join(extracted_state))

# Add imports back to main.dart AT THE TOP
import_statements = """import 'models/app_models.dart';
import 'core/app_theme.dart';
import 'services/app_state.dart';
"""

# Insert imports after existing imports. Find the last import line.
lines = code.split('\n')
last_import = 0
for i, line in enumerate(lines):
    if line.startswith('import '):
        last_import = i

lines.insert(last_import + 1, import_statements)
code = '\n'.join(lines)

with open('mausam_app/lib/main.dart', 'w', encoding='utf-8') as f:
    f.write(code)

print("Extraction complete!")
