#!/bin/bash
# make_deb_autotag.sh — release builder for watcher-monitoring

REPO_OWNER="egk10"
REPO_NAME="watcher-monitoring"
REPO_PATH="../${REPO_NAME}"
README="$REPO_PATH/README.md"
BUILD_ROOT=~/deb-build
CONTROL_PATH="../watcher-release-tools/control-template/control"


cd "$REPO_PATH"

# Version bump logic — patch only v1.x series
BASE="v1."
LATEST_TAG=$(git tag | grep "^${BASE}" | sort -V | tail -n1)

if [[ "$LATEST_TAG" == "$BASE" ]]; then
  DEB_VERSION="1.0.1"
else
  IFS='.' read -r major minor patch <<< "${LATEST_TAG/v/}"
  NEW_PATCH=$((patch + 1))
  DEB_VERSION="${major}.${minor}.${NEW_PATCH}"
fi

FINAL_NAME="${REPO_NAME}-v${DEB_VERSION}.deb"

echo "🚀 Releasing: v${DEB_VERSION} → $FINAL_NAME"

CHANGELOG=$(git log -n 3 --pretty=format:"- %s")

BUILD_DIR="$BUILD_ROOT/${REPO_NAME}_${DEB_VERSION}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/usr/local/bin" "$BUILD_DIR/DEBIAN"

cp "$CONTROL_PATH" "$BUILD_DIR/DEBIAN/control"
sed -i "s/Version: .*/Version: ${DEB_VERSION}/" "$BUILD_DIR/DEBIAN/control"

cp "$REPO_PATH"/*.sh "$BUILD_DIR/usr/local/bin/"
chmod +x "$BUILD_DIR/usr/local/bin/"*.sh

cd "$BUILD_ROOT"
dpkg-deb --build "${REPO_NAME}_${DEB_VERSION}"
mv "${REPO_NAME}_${DEB_VERSION}.deb" "$FINAL_NAME"
echo "✅ Built: $FINAL_NAME"

cd "$REPO_PATH"
git add .
git commit -m "Release v${DEB_VERSION}"
git tag "v${DEB_VERSION}"
git push origin main --tags

gh release create "v${DEB_VERSION}" "$BUILD_ROOT/$FINAL_NAME" \
  --repo "${REPO_OWNER}/${REPO_NAME}" \
  --title "${REPO_NAME} v${DEB_VERSION}" \
  --notes "$CHANGELOG"

BADGE="[![Deb Version](https://img.shields.io/badge/deb-v${DEB_VERSION}-blue)](https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/tag/v${DEB_VERSION})"
INSTALL_CMD="wget https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/v${DEB_VERSION}/${FINAL_NAME} && sudo dpkg -i ${FINAL_NAME}"

# Patch README

sed -i "/^

\[!

\[Deb Version\]

/c\\${BADGE}" "$README"


sed -i "/^wget https:\/\/github.com\/egk10\/watcher-monitoring\/releases\/download\/v.*\.deb/c\\${INSTALL_CMD}" "$README"

echo "📘 README patched"
