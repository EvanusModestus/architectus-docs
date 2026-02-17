# ============================================================================
# Architectus Documentation Hub
# ============================================================================
# Central orchestration for multi-component Antora documentation.
#
# Architecture: Hub-Spoke Model
#   - Hub (this repo): Orchestration, branding, unified build
#   - Spokes: Content repositories (architectus-technology, architectus-literature, etc.)
#
# Usage:
#   make              - Build unified documentation site
#   make diagrams     - Render all diagrams to SVG
#   make serve        - Build and serve locally
#   make clean        - Remove build artifacts
#   make help         - Show all targets
# ============================================================================

SHELL := /bin/bash
.PHONY: all local site diagrams serve clean help check-deps kroki kroki-stop kroki-status

# Configuration
PLAYBOOK := antora-playbook.yml
PLAYBOOK_LOCAL := antora-playbook-local.yml
BUILD_DIR := build/site
DIAGRAM_DIR := diagrams
CACHE_DIR := .cache
KROKI_URL := http://localhost:18000
KROKI_CONTAINER := architectus-kroki

# Colors
GREEN  := \033[0;32m
YELLOW := \033[1;33m
CYAN   := \033[0;36m
BLUE   := \033[0;34m
BOLD   := \033[1m
NC     := \033[0m

# Diagram tools
D2 := d2
MMDC := mmdc
DOT := dot

# Default target (uses local paths for development, stops Kroki after)
all: diagrams local kroki-stop

# ============================================================================
# Kroki Diagram Server
# ============================================================================

# Start Kroki containers (idempotent - safe to call multiple times)
kroki:
	@if ! curl -s -o /dev/null -w '' $(KROKI_URL)/health 2>/dev/null; then \
		echo -e "$(CYAN)Starting Kroki diagram server...$(NC)"; \
		docker compose up -d; \
		echo -e "$(YELLOW)Waiting for Kroki to be ready...$(NC)"; \
		for i in 1 2 3 4 5 6 7 8 9 10; do \
			if curl -s -o /dev/null -w '' $(KROKI_URL)/health 2>/dev/null; then \
				echo -e "$(GREEN)Kroki ready at $(KROKI_URL)$(NC)"; \
				break; \
			fi; \
			sleep 1; \
		done; \
	else \
		echo -e "$(GREEN)Kroki already running at $(KROKI_URL)$(NC)"; \
	fi

# Stop Kroki containers
kroki-stop:
	@echo -e "$(YELLOW)Stopping Kroki diagram server...$(NC)"
	@docker compose down
	@echo -e "$(GREEN)Kroki stopped$(NC)"

# Check Kroki status
kroki-status:
	@if curl -s -o /dev/null -w '' $(KROKI_URL)/health 2>/dev/null; then \
		echo -e "$(GREEN)Kroki: RUNNING at $(KROKI_URL)$(NC)"; \
		docker compose ps --format "table {{.Name}}\t{{.Status}}" 2>/dev/null || true; \
	else \
		echo -e "$(YELLOW)Kroki: NOT RUNNING$(NC)"; \
		echo -e "  Run 'make kroki' to start"; \
	fi

# ============================================================================
# Documentation Site
# ============================================================================

# Local build (for development - uses filesystem paths)
local: kroki $(PLAYBOOK_LOCAL)
	@echo -e "$(CYAN)Building documentation site (local paths)...$(NC)"
	@npx antora $(PLAYBOOK_LOCAL)
	@echo -e "$(GREEN)$(BOLD)Site built: $(BUILD_DIR)/index.html$(NC)"

# CI build (uses GitHub URLs - requires credentials)
site: kroki $(PLAYBOOK)
	@echo -e "$(CYAN)Building unified documentation site (GitHub)...$(NC)"
	@npx antora $(PLAYBOOK)
	@echo -e "$(GREEN)$(BOLD)Site built: $(BUILD_DIR)/index.html$(NC)"

serve: diagrams local
	@echo -e "$(BLUE)Serving documentation on http://localhost:8000...$(NC)"
	@echo -e "$(YELLOW)Press Ctrl+C to stop$(NC)"
	@cd $(BUILD_DIR) && python3 -m http.server 8000; \
		echo -e "$(YELLOW)Stopping Kroki...$(NC)" && $(MAKE) -s kroki-stop

# Build and stop Kroki (for one-off builds - saves resources)
build: diagrams local
	@$(MAKE) kroki-stop
	@echo -e "$(GREEN)Build complete. Kroki stopped.$(NC)"

# ============================================================================
# Diagram Rendering
# ============================================================================

diagrams: diagrams-d2 diagrams-mermaid diagrams-graphviz
	@echo -e "$(GREEN)All diagrams rendered$(NC)"

diagrams-d2:
	@echo -e "$(CYAN)Rendering D2 diagrams...$(NC)"
	@for f in $(DIAGRAM_DIR)/*.d2; do \
		if [ -f "$$f" ]; then \
			echo -e "  $(BLUE)→$(NC) $$f"; \
			$(D2) "$$f" "$${f%.d2}.svg" 2>/dev/null || echo -e "    $(YELLOW)[SKIP] d2 not installed$(NC)"; \
		fi \
	done

diagrams-mermaid:
	@echo -e "$(CYAN)Rendering Mermaid diagrams...$(NC)"
	@for f in $(DIAGRAM_DIR)/*.mmd; do \
		if [ -f "$$f" ]; then \
			echo -e "  $(BLUE)→$(NC) $$f"; \
			$(MMDC) -i "$$f" -o "$${f%.mmd}.svg" 2>/dev/null || echo -e "    $(YELLOW)[SKIP] mmdc not installed$(NC)"; \
		fi \
	done

diagrams-graphviz:
	@echo -e "$(CYAN)Rendering Graphviz diagrams...$(NC)"
	@for f in $(DIAGRAM_DIR)/*.dot; do \
		if [ -f "$$f" ]; then \
			echo -e "  $(BLUE)→$(NC) $$f"; \
			$(DOT) -Tsvg "$$f" -o "$${f%.dot}.svg" 2>/dev/null || echo -e "    $(YELLOW)[SKIP] dot not installed$(NC)"; \
		fi \
	done

# ============================================================================
# Maintenance
# ============================================================================

clean:
	@echo -e "$(YELLOW)Cleaning build artifacts...$(NC)"
	@rm -rf $(BUILD_DIR) $(CACHE_DIR)
	@echo -e "$(GREEN)Clean complete$(NC)"

check-deps:
	@echo -e "$(CYAN)Checking dependencies...$(NC)"
	@echo -n "  node: " && node --version 2>/dev/null || echo -e "$(YELLOW)NOT FOUND$(NC)"
	@echo -n "  npx: " && npx --version 2>/dev/null || echo -e "$(YELLOW)NOT FOUND$(NC)"
	@echo -n "  d2: " && $(D2) --version 2>/dev/null || echo -e "$(YELLOW)NOT FOUND (optional)$(NC)"
	@echo -n "  mmdc: " && $(MMDC) --version 2>/dev/null || echo -e "$(YELLOW)NOT FOUND (optional)$(NC)"
	@echo -n "  dot: " && $(DOT) -V 2>&1 | head -1 || echo -e "$(YELLOW)NOT FOUND (optional)$(NC)"

# ============================================================================
# Help
# ============================================================================

help:
	@echo -e "$(BOLD)Architectus Documentation Hub$(NC)"
	@echo ""
	@echo -e "$(BOLD)Site Build:$(NC)"
	@echo -e "  $(GREEN)make$(NC)              Build unified site (Kroki stays running)"
	@echo -e "  $(GREEN)make build$(NC)        Build and stop Kroki after (recommended)"
	@echo -e "  $(GREEN)make site$(NC)         Build Antora site only (GitHub URLs)"
	@echo -e "  $(GREEN)make local$(NC)        Build Antora site (local paths)"
	@echo ""
	@echo -e "$(BOLD)Kroki (Diagram Server):$(NC)"
	@echo -e "  $(CYAN)make kroki$(NC)        Start Kroki containers (auto-starts with build)"
	@echo -e "  $(CYAN)make kroki-stop$(NC)   Stop Kroki containers"
	@echo -e "  $(CYAN)make kroki-status$(NC) Check if Kroki is running"
	@echo ""
	@echo -e "$(BOLD)Diagrams:$(NC)"
	@echo -e "  $(CYAN)make diagrams$(NC)     Render all diagrams to SVG"
	@echo ""
	@echo -e "$(BOLD)Development:$(NC)"
	@echo -e "  $(BLUE)make serve$(NC)        Build and serve locally on :8000"
	@echo ""
	@echo -e "$(BOLD)Utilities:$(NC)"
	@echo -e "  $(YELLOW)make clean$(NC)        Remove build artifacts"
	@echo -e "  $(YELLOW)make check-deps$(NC)   Verify required tools"
	@echo -e "  $(YELLOW)make help$(NC)         This message"
	@echo ""
	@echo -e "$(BOLD)Content Domains:$(NC)"
	@echo -e "  • Technology (Linux, security, networking, automation)"
	@echo -e "  • Literature (Cervantes, García Márquez, Reina Valera)"
	@echo -e "  • Mathematics (foundations, applications)"
	@echo -e "  • Music (theory, composition)"
	@echo -e "  • Languages (Spanish B2→C2)"
	@echo -e "  • Philosophy (faith, reason, worldview)"
	@echo ""
	@echo -e "Output: $(BUILD_DIR)/"
