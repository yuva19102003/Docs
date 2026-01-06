#!/bin/bash

# Build MkDocs site for GitHub Pages
# This script builds the documentation site using the configuration in .mkdocs/mkdocs.yml

echo "🔨 Building MkDocs site..."
echo ""

# Build the site
mkdocs build --config-file .mkdocs/mkdocs.yml --clean --verbose

# Check if build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo "📁 Site built to: site/"
    echo ""
    echo "To deploy to GitHub Pages, run:"
    echo "  mkdocs gh-deploy --config-file .mkdocs/mkdocs.yml --force"
else
    echo ""
    echo "❌ Build failed!"
    exit 1
fi
