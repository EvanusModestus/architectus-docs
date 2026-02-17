# ============================================================================
# Architectus Documentation - Build System
# ============================================================================

.PHONY: all site clean help serve preview

# Default target
all: site

# Build Antora site
site:
	@echo "Building Antora site..."
	npx antora antora-playbook.yml
	@echo "Site built at ./build/site/"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf build .cache
	@echo "Clean complete."

# Serve locally (requires http-server or python)
serve: site
	@echo "Serving site at http://localhost:8000"
	@cd build/site && python3 -m http.server 8000

# Preview - build and open in browser
preview: site
	@echo "Opening site in browser..."
	@xdg-open build/site/index.html 2>/dev/null || open build/site/index.html 2>/dev/null || echo "Open build/site/index.html manually"

# Install dependencies
install:
	@echo "Installing dependencies..."
	npm install
	@echo "Dependencies installed."

# Help
help:
	@echo "Architectus Documentation - Available targets:"
	@echo ""
	@echo "  make          - Build site (default)"
	@echo "  make site     - Build Antora site"
	@echo "  make clean    - Remove build artifacts"
	@echo "  make serve    - Build and serve locally"
	@echo "  make preview  - Build and open in browser"
	@echo "  make install  - Install npm dependencies"
	@echo "  make help     - Show this help"
