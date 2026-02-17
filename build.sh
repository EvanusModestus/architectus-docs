#!/bin/bash
# ============================================================================
# Cloudflare Pages Build Script
# ============================================================================
# Builds the architectus-docs Antora site with:
#   1. Fetches UI bundle from ui.domusdigitalis.dev (Cloudflare Access)
#   2. Injects GitHub token into playbook URLs for private repo access
#   3. Runs Antora build
#
# Environment Variables (set in Cloudflare Pages > Settings > Environment Variables):
#   CF_ANTORA_GIT_TOKEN     - GitHub PAT with read access to architectus-* repos
#   CF_ACCESS_CLIENT_ID     - Cloudflare Access service token ID (for UI bundle)
#   CF_ACCESS_CLIENT_SECRET - Cloudflare Access service token secret
#
# Cloudflare Access Setup:
#   Zero Trust > Access > Applications > antora-ui-bundle
#   Zero Trust > Service Credentials > Service Tokens > antora-ui-bundle
#
# Usage:
#   Build command: ./build.sh
#   Output directory: build/site
# ============================================================================

set -e

# Check for required tokens
if [ -z "$CF_ANTORA_GIT_TOKEN" ]; then
    echo "ERROR: CF_ANTORA_GIT_TOKEN environment variable not set"
    echo "Add it in Cloudflare Pages > Settings > Environment Variables"
    exit 1
fi

if [ -z "$CF_ACCESS_CLIENT_ID" ] || [ -z "$CF_ACCESS_CLIENT_SECRET" ]; then
    echo "ERROR: CF_ACCESS_CLIENT_ID and CF_ACCESS_CLIENT_SECRET required"
    echo "Add them in Cloudflare Pages > Settings > Environment Variables"
    exit 1
fi

# Fetch UI bundle with Cloudflare Access auth
echo "Fetching UI bundle from ui.domusdigitalis.dev..."
curl -sfo ui-bundle.zip \
    -H "CF-Access-Client-Id: $CF_ACCESS_CLIENT_ID" \
    -H "CF-Access-Client-Secret: $CF_ACCESS_CLIENT_SECRET" \
    -H "Cache-Control: no-cache" \
    "https://ui.domusdigitalis.dev/ui-bundle.zip?v=$(date +%s)"

if [ ! -f ui-bundle.zip ]; then
    echo "ERROR: Failed to fetch UI bundle"
    exit 1
fi

# Validate bundle is a valid zip
if ! unzip -t ui-bundle.zip > /dev/null 2>&1; then
    echo "ERROR: UI bundle is not a valid ZIP file"
    echo "Content received:"
    head -c 500 ui-bundle.zip
    exit 1
fi

# Verify bundle contains theme CSS
if ! unzip -p ui-bundle.zip css/site.css | grep -q "data-theme"; then
    echo "ERROR: UI bundle missing theme CSS"
    exit 1
fi

echo "UI bundle downloaded and validated ($(stat -c%s ui-bundle.zip) bytes)"

# Inject token into playbook URLs
echo "Injecting credentials into playbook..."
sed -i "s|https://github.com/EvanusModestus/|https://${CF_ANTORA_GIT_TOKEN}@github.com/EvanusModestus/|g" antora-playbook.yml

# Run Antora build (--quiet suppresses URL logging to avoid token exposure)
echo "Building Antora site..."
npx antora --quiet antora-playbook.yml

echo "Build complete: build/site/index.html"
