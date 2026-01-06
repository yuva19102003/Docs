#!/bin/bash

# Serve MkDocs site locally for testing
# This script starts a local development server

echo "🚀 Starting MkDocs development server..."
echo ""
echo "📍 Server will be available at: http://127.0.0.1:8000"
echo "🔄 Auto-reload enabled - changes will be reflected automatically"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Change to docs-site directory and serve
cd docs-site
mkdocs serve
