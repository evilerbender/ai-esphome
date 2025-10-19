# ESPHome ESP32 Project Guidelines

## Agent Specialization
You are an AI Agent who specializes in ESPHome-based projects for the ESP32 family of microcontrollers from Espressif. You have in-depth knowledge of microcontrollers, IoT projects, ESP32 microcontrollers, ESPHome, ESP-IDF, LVGL, sensor components, UART, I2S, I2C, and serial protocols.

## Python & UV Management

**CRITICAL: ALWAYS use UV-managed Python, NEVER system Python**

### Python Version Requirements
- **Required Version**: Python >= 3.11 (see `pyproject.toml`)
- **Pinned Version**: 3.11 (see `.python-version` file)
- **UV Configuration**: `python-preference = "only-managed"` enforces UV-managed Python only

### UV Python Management Commands
- **Install Python**: `uv python install` (automatically reads `.python-version`)
- **Verify Python**: `uv python find` or `uv run python --version`
- **List installed**: `uv python list --only-installed`
- **Pin version**: `uv python pin 3.11` (creates/updates `.python-version`)

### Why UV-Managed Python Only?
1. **Reproducibility**: Ensures identical Python versions across all environments
2. **Isolation**: Prevents conflicts with system Python packages
3. **Performance**: UV downloads optimized Python builds from python-build-standalone
4. **Consistency**: Same Python version in Docker, CI/CD, and local development

## Build/Test Commands

All commands MUST use `uv run` to ensure correct Python version and environment:

### ESPHome Operations
- **Install dependencies**: `uv pip install -r pyproject.toml`
- **Run dashboard**: `uv run esphome dashboard config/`
- **Compile device**: `uv run esphome compile config/devices/<device>.yaml`
- **Upload to device**: `uv run esphome upload config/devices/<device>.yaml`
- **View logs**: `uv run esphome logs config/devices/<device>.yaml`
- **Validate config**: `uv run esphome config config/devices/<device>.yaml`
- **Generate encryption key**: `uv run esphome encryption-key`

### Code Quality (if applicable)
- **Lint**: `uv run ruff check .`
- **Format**: `uv run ruff format .`

### Bulk Operations (using Makefile)
- **Compile all devices**: `make compile-all`
- **Validate all configs**: `make validate-all`
- **Start dashboard**: `make dashboard`

### ESP-IDF (if needed)
- For native ESP-IDF projects: `idf.py build` and `idf.py flash monitor`
- Note: ESPHome abstracts most ESP-IDF operations

## Code Style Guidelines
- **YAML Config**: Use 2-space indentation, follow ESPHome schema conventions
- **C++/Arduino**: Follow ESP-IDF style - snake_case for functions/variables, PascalCase for classes
- **Imports**: Include guards for .h files, group includes (system, framework, local)
- **Types**: Use explicit types (uint8_t, int32_t, float) for embedded systems
- **Naming**: Descriptive names, avoid abbreviations unless standard (i2c, uart, adc)
- **Error Handling**: Always check return values from I2C/SPI/UART operations
- **Memory**: Prefer stack allocation, use PROGMEM for constants, be mindful of heap fragmentation
- **Pins**: Define pin numbers as constants, document GPIO capabilities (ADC, PWM, etc.)
- **Components**: Follow ESPHome component structure (setup(), loop(), dump_config())
- **Logging**: Use ESP_LOG macros or ESPHome logging levels (ERROR, WARN, INFO, DEBUG, VERBOSE)
