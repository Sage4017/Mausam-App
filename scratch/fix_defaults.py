import re
with open("mausam_app/lib/screens/persona_question_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Replace all ?? 'Time' or ?? 'Location' with ?? ''
pattern = r"\?\? '[^']*'"
content = re.sub(pattern, "?? ''", content)

with open("mausam_app/lib/screens/persona_question_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
print("Removed defaults in UI")
