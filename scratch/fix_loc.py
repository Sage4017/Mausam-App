with open("mausam_app/lib/screens/location_permission_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

import re
content = re.sub(r"Text\('Lat: \$\{lat\.toStringAsFixed\(3\)\}, Lon: \$\{lon\.toStringAsFixed\(3\)\}'.*?\),", "", content)

with open("mausam_app/lib/screens/location_permission_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
