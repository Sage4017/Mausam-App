import re

# 1. Clean app_models.dart
with open("mausam_app/lib/models/app_models.dart", "r", encoding="utf-8") as f:
    content = f.read()
content = content.replace("?? 28.6139", "?? 0.0").replace("?? 77.2090", "?? 0.0")
with open("mausam_app/lib/models/app_models.dart", "w", encoding="utf-8") as f:
    f.write(content)

# 2. Clean splash_screen.dart
with open("mausam_app/lib/screens/splash_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()
content = re.sub(r"final lat = state.weatherSummary\?.latitude \?\? 28.6139;\s*", "", content)
content = re.sub(r"final lon = state.weatherSummary\?.longitude \?\? 77.2090;\s*", "", content)
with open("mausam_app/lib/screens/splash_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)

# 3. Clean location_permission_screen.dart
with open("mausam_app/lib/screens/location_permission_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()
content = re.sub(r"final lat = state.weatherSummary\?.latitude \?\? 28.6139;\s*", "", content)
content = re.sub(r"final lon = state.weatherSummary\?.longitude \?\? 77.2090;\s*", "", content)

# Remove the Location block in LocationPermissionScreen if it exists, since it has the same card!
pattern = r"// Direct Live Microclimate Region Access on First Screen.*?FrostedGlassCard\(.*?\),\s*const SizedBox\(height: 32\),"
content = re.sub(pattern, "", content, flags=re.DOTALL)

with open("mausam_app/lib/screens/location_permission_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)

print("Cleaned hardcoded locations")
