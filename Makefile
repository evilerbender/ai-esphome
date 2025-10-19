.PHONY: help install dashboard compile-all validate-all clean logs pre-commit-run pre-commit-install

help:
	@echo "ESPHome ESP32 Project - Available Commands"
	@echo ""
	@echo "Setup & Installation:"
	@echo "  make install          - Install UV and sync dependencies"
	@echo ""
	@echo "Development:"
	@echo "  make dashboard        - Start ESPHome dashboard (http://0.0.0.0:6052)"
	@echo "  make validate-all     - Validate all device configurations"
	@echo "  make compile-all      - Compile all device configurations"
	@echo "  make lint             - Run Ruff linter on custom components"
	@echo ""
	@echo "Individual Devices:"
	@echo "  make compile DEVICE=<name>    - Compile specific device"
	@echo "  make upload DEVICE=<name>     - Upload to specific device"
	@echo "  make logs DEVICE=<name>       - View logs from specific device"
	@echo "  make clean-build DEVICE=<name> - Clean build for specific device"
	@echo ""
	@echo "Docker:"
	@echo "  make docker-up        - Start ESPHome dashboard in Docker"
	@echo "  make docker-down      - Stop Docker containers"
	@echo "  make docker-logs      - View Docker logs"
	@echo ""
	@echo "Utilities:"
	@echo "  make clean            - Clean all build artifacts"
	@echo "  make secrets          - Generate example secrets file"
	@echo "  make pre-commit-run   - Run all pre-commit hooks manually"
	@echo "  make pre-commit-install - Install/reinstall pre-commit hooks"
	@echo ""
	@echo "Examples:"
	@echo "  make compile DEVICE=living-room-sensor"
	@echo "  make upload DEVICE=bedroom-climate"
	@echo "  make logs DEVICE=garage-door-controller"

install:
	@echo "Installing UV and syncing dependencies..."
	@command -v uv >/dev/null 2>&1 || (echo "UV not found. Install with: curl -LsSf https://astral.sh/uv/install.sh | sh" && exit 1)
	uv sync

dashboard:
	uv run esphome dashboard config/

validate-all:
	@echo "Validating all device configurations..."
	@for file in config/devices/*.yaml; do \
		echo "Validating $$file..."; \
		uv run esphome config "$$file" || exit 1; \
	done
	@echo "All configurations valid!"

compile-all:
	@echo "Compiling all device configurations..."
	@for file in config/devices/*.yaml; do \
		echo "Compiling $$file..."; \
		uv run esphome compile "$$file" || exit 1; \
	done
	@echo "All devices compiled successfully!"

compile:
	@if [ -z "$(DEVICE)" ]; then \
		echo "Error: DEVICE parameter required. Usage: make compile DEVICE=living-room-sensor"; \
		exit 1; \
	fi
	uv run esphome compile config/devices/$(DEVICE).yaml

upload:
	@if [ -z "$(DEVICE)" ]; then \
		echo "Error: DEVICE parameter required. Usage: make upload DEVICE=living-room-sensor"; \
		exit 1; \
	fi
	uv run esphome upload config/devices/$(DEVICE).yaml

logs:
	@if [ -z "$(DEVICE)" ]; then \
		echo "Error: DEVICE parameter required. Usage: make logs DEVICE=living-room-sensor"; \
		exit 1; \
	fi
	uv run esphome logs config/devices/$(DEVICE).yaml

clean-build:
	@if [ -z "$(DEVICE)" ]; then \
		echo "Error: DEVICE parameter required. Usage: make clean-build DEVICE=living-room-sensor"; \
		exit 1; \
	fi
	uv run esphome clean config/devices/$(DEVICE).yaml

lint:
	@if [ -d "custom_components" ]; then \
		echo "Running Ruff linter on custom components..."; \
		uv run ruff check custom_components/; \
	else \
		echo "No custom_components directory found."; \
	fi

clean:
	@echo "Cleaning build artifacts..."
	rm -rf .esphome/
	find . -type d -name ".pioenvs" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".piolibdeps" -exec rm -rf {} + 2>/dev/null || true
	@echo "Clean complete!"

secrets:
	@if [ ! -f "config/secrets.yaml" ]; then \
		echo "Copying example secrets file..."; \
		cp config/secrets.yaml.example config/secrets.yaml; \
		echo "Created config/secrets.yaml - Please edit with your credentials"; \
	else \
		echo "config/secrets.yaml already exists"; \
	fi

docker-up:
	docker-compose up -d
	@echo "ESPHome dashboard starting at http://localhost:6052"

docker-down:
	docker-compose down

docker-logs:
	docker-compose logs -f esphome

pre-commit-run:
	@echo "Running all pre-commit hooks..."
	uv run pre-commit run --all-files

pre-commit-install:
	@echo "Installing pre-commit hooks..."
	uv run pre-commit install
	cp hooks/commit-msg .git/hooks/commit-msg
	chmod +x .git/hooks/commit-msg
	@echo "Pre-commit hooks installed successfully!"
