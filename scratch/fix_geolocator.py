import re
with open("mausam_app/lib/services/app_state.dart", "r", encoding="utf-8") as f:
    content = f.read()

old = """        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 2),
        );"""

new = """        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 5),
          ),
        );"""

content = content.replace(old, new)
with open("mausam_app/lib/services/app_state.dart", "w", encoding="utf-8") as f:
    f.write(content)

print("Fixed Geolocator")
