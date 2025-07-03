#!/bin/bash
# readme_cleaner.sh — sync README badge and install line with latest release

REPO_OWNER="egk10"
REPO_NAME="watcher-monitoring"
README_PATH="../watcher-monitoring/README.md"  # Adjust if target is elsewhere

LATEST_TAG=$(git tag | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1)
FINAL_NAME="${REPO_NAME}-${LATEST_TAG}.deb"

BADGE="[![Deb Version](https://img.shields.io/badge/deb-${LATEST_TAG}-blue)](https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/tag/${LATEST_TAG})"
INSTALL_CMD="wget https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${LATEST_TAG}/${FINAL_NAME} && sudo dpkg -i ${FINAL_NAME}"

# Replace badge line
sed -i "/^

\[!

\[Deb Version\]

/c\\${BADGE}" "$README_PATH"

# Replace install command line
sed -i "/^wget https:\/\/github.com\/${REPO_OWNER}\/${REPO_NAME}\/releases\/download\/v.*\.deb && sudo dpkg -i ${REPO_NAME}-v.*\.deb/c\\${INSTALL_CMD}" "$README_PATH"

echo "✅ README patched with ${LATEST_TAG}"

