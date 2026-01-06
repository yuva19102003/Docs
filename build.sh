#!/bin/bash

# Build MkDocs site for GitHub Pages
# This script builds the documentation site using the configuration in docs-site/mkdocs.yml

echo "🔨 Building MkDocs site..."
echo ""

# Change to docs-site directory and build
cd docs-site
mkdocs build --clean --verbose

# Check if build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo "📁 Site built to: site/"
    echo ""
    echo "To deploy to GitHub Pages, run:"
    echo "  cd docs-site && mkdocs gh-deploy --force"
else
    echo ""
    echo "❌ Build failed!"
    exit 1
fi
