import re
with open("mausam_app/lib/services/app_state.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Empty probingAnswers
pattern = r"final Map<String, dynamic> probingAnswers = \{.*?\};"
content = re.sub(pattern, "final Map<String, dynamic> probingAnswers = {};", content, flags=re.DOTALL)

with open("mausam_app/lib/services/app_state.dart", "w", encoding="utf-8") as f:
    f.write(content)
print("Removed defaults")
