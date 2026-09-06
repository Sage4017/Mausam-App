with open("mausam_app/lib/screens/persona_selection_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()
if "relevance_sliders_screen.dart" not in content:
    content = "import 'relevance_sliders_screen.dart';\n" + content
    with open("mausam_app/lib/screens/persona_selection_screen.dart", "w", encoding="utf-8") as f:
        f.write(content)
        print("Fixed PersonaSelectionScreen")
