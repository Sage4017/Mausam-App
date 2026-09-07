import re
with open("mausam_app/lib/services/app_state.dart", "r", encoding="utf-8") as f:
    content = f.read()

pattern = r"return await Geolocator\.getCurrentPosition\(\s*desiredAccuracy: LocationAccuracy\.low,\s*timeLimit: const Duration\(seconds: 2\),\s*\);"
replacement = """return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );"""

content = re.sub(pattern, replacement, content)

with open("mausam_app/lib/services/app_state.dart", "w", encoding="utf-8") as f:
    f.write(content)
print("Fixed Geolocator properly")
