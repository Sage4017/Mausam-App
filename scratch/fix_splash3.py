with open("mausam_app/lib/screens/splash_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("import '../services/app_state.dart';\n", "")

with open("mausam_app/lib/screens/splash_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
