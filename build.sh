#!/bin/bash
# ============================================================================
# Cloudflare Pages Build Script for Architectus
# ============================================================================
# Builds the architectus-docs Antora site for public deployment.
#
# Environment Variables (set in Cloudflare Pages > Settings > Environment Variables):
#   CF_ANTORA_GIT_TOKEN     - GitHub PAT with read access to architectus-* repos (optional)
#
# Usage:
#   Build command: ./build.sh
#   Output directory: build/site
# ============================================================================

set -e

echo "=== Architectus Documentation Build ==="
echo "Node version: $(node --version)"
echo "NPM version: $(npm --version)"

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm ci --prefer-offline
fi

# If GitHub token is provided, inject it for private spoke repos
if [ -n "$CF_ANTORA_GIT_TOKEN" ]; then
    echo "Injecting GitHub credentials..."
    sed -i "s|https://github.com/EvanusModestus/|https://${CF_ANTORA_GIT_TOKEN}@github.com/EvanusModestus/|g" antora-playbook.yml
fi

# Run Antora build
echo "Building Antora site..."
npx antora --quiet antora-playbook.yml

echo "=== Build Complete ==="
echo "Output: build/site/index.html"
ls -la build/site/
