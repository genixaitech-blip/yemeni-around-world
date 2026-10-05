"""Apply foreground-only location permissions to generated Flutter platforms."""
from pathlib import Path
import plistlib
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parent.parent
ANDROID = "http://schemas.android.com/apk/res/android"
ET.register_namespace("android", ANDROID)
manifest = ROOT / "android/app/src/main/AndroidManifest.xml"
if manifest.exists():
    tree = ET.parse(manifest)
    root = tree.getroot()
    names = {node.get(f"{{{ANDROID}}}name") for node in root.findall("uses-permission")}
    for name in ("android.permission.ACCESS_COARSE_LOCATION", "android.permission.ACCESS_FINE_LOCATION", "android.permission.INTERNET"):
        if name not in names:
            root.insert(0, ET.Element("uses-permission", {f"{{{ANDROID}}}name": name}))
    tree.write(manifest, encoding="utf-8", xml_declaration=True)

info = ROOT / "ios/Runner/Info.plist"
if info.exists():
    with info.open("rb") as stream:
        data = plistlib.load(stream)
    data["NSLocationWhenInUseUsageDescription"] = "نستخدم موقعك عند طلبك للعثور على خدمات قريبة، ولا نحفظه في حسابك."
    with info.open("wb") as stream:
        plistlib.dump(data, stream, sort_keys=False)

podfile = ROOT / "ios/Podfile"
if podfile.exists():
    source = podfile.read_text(encoding="utf-8")
    marker = "flutter_additional_ios_build_settings(target)"
    if "BYPASS_PERMISSION_LOCATION_ALWAYS=1" not in source and marker in source:
        source = source.replace(marker, marker + "\n    target.build_configurations.each do |config|\n      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']\n      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'BYPASS_PERMISSION_LOCATION_ALWAYS=1'\n    end")
        podfile.write_text(source, encoding="utf-8")
