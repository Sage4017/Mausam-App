with open("mausam_app/lib/screens/splash_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("import '../widgets/frosted_glass_card.dart';\n", "")
content = content.replace("final state = AppStateScope.of(context);\n", "")

with open("mausam_app/lib/screens/splash_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
