import re
with open("mausam_app/lib/screens/splash_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Remove the entire FrostedGlassCard block
pattern = r"// Direct Live Microclimate Region Access on First Screen.*?FrostedGlassCard\(.*?\),\s*const SizedBox\(height: 32\),"
content = re.sub(pattern, "", content, flags=re.DOTALL)

with open("mausam_app/lib/screens/splash_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
print("Removed FrostedGlassCard from Splash")
