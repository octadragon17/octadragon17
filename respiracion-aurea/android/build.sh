#!/usr/bin/env bash
# Compila Vórtice Áureo como APK sin Gradle ni Android Studio.
# Requisitos (Ubuntu 24.04):
#   sudo apt-get install -y aapt zipalign apksigner android-sdk-platform-23 dalvik-exchange openjdk-17-jdk
# Uso:  ./build.sh            -> build/VorticeAureo.apk
# La llave de firma se crea en ~/.vortice-aureo/release.jks la primera vez. RESPÁLDALA:
# sin ella no podrás instalar actualizaciones encima de la app ya instalada.
set -euo pipefail
cd "$(dirname "$0")"
ANDROID_JAR=${ANDROID_JAR:-/usr/lib/android-sdk/platforms/android-23/android.jar}
KEYSTORE=${KEYSTORE:-$HOME/.vortice-aureo/release.jks}
KS_PASS=${KS_PASS:-vortice-aureo}
OUT=build
rm -rf "$OUT"; mkdir -p "$OUT/gen" "$OUT/classes" "$OUT/assets"

# 1) Web app -> assets (fuentes locales, sin recursos externos)
cp -r ../fonts ../icons ../manifest.webmanifest "$OUT/assets/"
cp ../index.html "$OUT/assets/index.html"
if grep -q 'googleapis' "$OUT/assets/index.html"; then echo "Quedó una referencia externa" >&2; exit 1; fi

# 2) Recursos + R.java
aapt package -f -m -J "$OUT/gen" -M AndroidManifest.xml -S res -I "$ANDROID_JAR"

# 3) Java -> bytecode 8 -> dex
javac -nowarn -Xlint:-options -source 8 -target 8 -bootclasspath "$ANDROID_JAR" \
  -d "$OUT/classes" $(find src "$OUT/gen" -name '*.java')
dalvik-exchange --dex --min-sdk-version=21 --output="$OUT/classes.dex" "$OUT/classes"

# 4) Empaquetar, alinear, firmar
aapt package -f -M AndroidManifest.xml -S res -A "$OUT/assets" -I "$ANDROID_JAR" -F "$OUT/unsigned.apk"
(cd "$OUT" && aapt add -f unsigned.apk classes.dex >/dev/null)
zipalign -f -p 4 "$OUT/unsigned.apk" "$OUT/aligned.apk"
if [ ! -f "$KEYSTORE" ]; then
  mkdir -p "$(dirname "$KEYSTORE")"
  keytool -genkeypair -keystore "$KEYSTORE" -storepass "$KS_PASS" -keypass "$KS_PASS" \
    -alias vortice -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Vortice Aureo, C=MX"
fi
apksigner sign --ks "$KEYSTORE" --ks-pass "pass:$KS_PASS" --ks-key-alias vortice \
  --out "$OUT/VorticeAureo.apk" "$OUT/aligned.apk"
apksigner verify --print-certs "$OUT/VorticeAureo.apk" | head -1
ls -lh "$OUT/VorticeAureo.apk"
