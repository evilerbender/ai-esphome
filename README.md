# ESPHome ESP32 Multi-Device Project

This project provides a structured scaffolding for managing multiple ESP32 devices using ESPHome. It follows best practices for configuration management, code reuse, and multi-device deployments.

**🚀 New to this project? Start with [docs/QUICKSTART.md](docs/QUICKSTART.md) for a step-by-step guide!**

## Project Structure

```
/opt/ai-esphome/
├── config/
│   ├── common/                      # Shared configurations
│   │   ├── base.yaml               # Common settings (logger, api, ota, web_server)
│   │   ├── wifi.yaml               # WiFi configuration with fallback AP
│   │   └── sensors/                # Reusable sensor configurations
│   │       ├── dht22.yaml          # DHT22 temperature/humidity sensor
│   │       └── bme280.yaml         # BME280 I2C environmental sensor
│   ├── devices/                     # Individual device configurations
│   │   ├── living-room-sensor.yaml
│   │   ├── bedroom-climate.yaml
│   │   └── garage-door-controller.yaml
│   └── secrets.yaml.example         # Template for credentials
├── custom_components/               # Custom ESPHome components
│   └── example_component/
├── .esphome/                       # Build cache (gitignored)
├── .gitignore
├── README.md
├── requirements.txt
└── docker-compose.yml
```

## Quick Start

### 1. Prerequisites

**Choose one of the following setups:**

#### Option A: Docker + Docker Compose (Recommended for simplicity)
- Docker and Docker Compose installed
- UV and Python will be automatically managed inside the container

#### Option B: UV (Recommended for performance and local development)
- **UV** - Fast Python package and project manager (replaces pip, virtualenv, pipx, poetry)
  - **Linux/macOS**: `curl -LsSf https://astral.sh/uv/install.sh | sh`
  - **Windows**: `powershell -c "irm https://astral.sh/uv/install.ps1 | iex"`
  - UV will automatically install and manage Python 3.11 for you
- **Python is NOT required** - UV downloads and manages Python installations automatically

### 2. Setup Secrets

Copy the secrets template and fill in your credentials:

```bash
cp config/secrets.yaml.example config/secrets.yaml
```

Edit `config/secrets.yaml` with your values:
- WiFi SSID and password
- API encryption key (generate with: `uv run esphome encryption-key`)
- OTA password
- Fallback AP password

### 3. Install Python and Dependencies (UV Only)

**IMPORTANT**: This project uses UV-managed Python. Never use system Python.

```bash
# UV automatically installs Python 3.11 (from .python-version) and all dependencies
uv python install
uv pip install -r pyproject.toml
```

**Verify your setup:**
```bash
# Check Python version (should be 3.11.x)
uv run python --version

# Verify ESPHome is installed
uv run esphome version
```

### 4. Start ESPHome Dashboard

#### Option A: Using Docker (Recommended)

```bash
docker-compose up -d
```

Access the dashboard at: `http://localhost:6052`

Default credentials:
- Username: `admin`
- Password: `esphome` (change in docker-compose.yml)

#### Option B: Using UV Directly

```bash
uv run esphome dashboard config/
```

Access the dashboard at: `http://localhost:6052`

### 4. Configure Your First Device

1. Edit one of the example device configs in `config/devices/`
2. Update the `substitutions:` section with your device-specific values:
   - `device_name`: Unique identifier (lowercase, hyphens)
   - `friendly_name`: Human-readable name
   - `board`: Your ESP32 board type (esp32dev, esp32-s2, esp32-s3, esp32-c3, etc.)
   - Pin assignments for sensors/actuators

### 5. Compile and Upload

**All commands use `uv run` to ensure correct Python version:**

#### From Dashboard:
1. Open http://localhost:6052
2. Click on your device
3. Click "Install" → Choose upload method (USB, OTA, etc.)

#### From Command Line:

```bash
# Compile only
uv run esphome compile config/devices/living-room-sensor.yaml

# Compile and upload via USB
uv run esphome run config/devices/living-room-sensor.yaml

# Upload OTA (after initial USB flash)
uv run esphome upload config/devices/living-room-sensor.yaml

# View logs
uv run esphome logs config/devices/living-room-sensor.yaml

# Validate configuration
uv run esphome config config/devices/living-room-sensor.yaml
```

**Using Makefile shortcuts:**

```bash
# Compile all device configurations
make compile-all

# Validate all configurations
make validate-all

# Start dashboard
make dashboard
```

## Managing Multiple Devices

### Adding a New Device

1. Copy an existing device config:
```bash
cp config/devices/living-room-sensor.yaml config/devices/my-new-device.yaml
```

2. Edit `my-new-device.yaml`:
   - Update `substitutions` with unique values
   - Modify `packages` to include desired sensor configs
   - Add device-specific sensors/switches/automations

3. Compile and flash

### Creating Reusable Sensor Configs

Add new sensor configurations to `config/common/sensors/`:

```yaml
# config/common/sensors/my-sensor.yaml
sensor:
  - platform: my_sensor
    pin: ${sensor_pin}
    name: "${friendly_name} My Sensor"
    id: my_sensor_id
```

Then include in device configs:

```yaml
packages:
  base: !include ../common/base.yaml
  wifi: !include ../common/wifi.yaml
  my_sensor: !include ../common/sensors/my-sensor.yaml
```

## ESP32 Board Types

Common ESP32 variants supported:
- `esp32dev` - Generic ESP32
- `esp32-s2-saola-1` - ESP32-S2
- `esp32-s3-devkitc-1` - ESP32-S3
- `esp32-c3-devkitm-1` - ESP32-C3
- `esp32-c6-devkitc-1` - ESP32-C6

See [ESPHome Boards](https://github.com/platformio/platform-espressif32/tree/master/boards) for complete list.

## Framework Choice

This scaffolding uses **ESP-IDF** (Espressif IoT Development Framework) by default, which is the recommended framework for ESP32:

```yaml
esp32:
  board: esp32dev
  framework:
    type: esp-idf
```

To use Arduino framework instead (for compatibility):

```yaml
esp32:
  board: esp32dev
  framework:
    type: arduino
```

## Common Configurations Explained

### base.yaml
Contains core ESPHome settings shared across all devices:
- Device naming and platform
- Logger configuration
- API with encryption
- OTA updates
- Web server on port 80

### wifi.yaml
WiFi connection with automatic fallback AP:
- Connects to your WiFi using secrets
- Creates fallback AP if WiFi fails
- Includes captive portal for easy reconfiguration

## Custom Components

Place custom ESPHome components in `custom_components/`:

```
custom_components/
└── my_component/
    ├── __init__.py
    ├── my_component.cpp
    ├── my_component.h
    └── sensor.py
```

Reference in device configs:

```yaml
external_components:
  - source:
      type: local
      path: custom_components
```

## Tips & Best Practices

1. **Always use UV for Python execution** - Never use system Python
2. **Verify Python version** with `uv run python --version` before compiling
3. **Use `uv run` prefix** for all ESPHome commands to ensure correct environment
4. **Always use substitutions** for device-specific values (names, pins)
5. **Give every component an ID** for easy referencing and automation
6. **Use packages** to avoid config duplication across devices
7. **Never commit secrets.yaml** - it's gitignored by default
8. **Use ESP-IDF framework** for better performance and compatibility
9. **Flash via USB first**, then use OTA for updates
10. **Test configs** with `uv run esphome config` before flashing
11. **Enable web_server** for debugging via browser
12. **Monitor logs** with `uv run esphome logs config/devices/device-name.yaml`
13. **Follow Conventional Commits** format for commit messages (enforced by git hooks)
14. **Let pre-commit hooks run** - they validate configs and prevent common errors

## Git Hooks & Quality Assurance

This project uses **pre-commit hooks** to maintain code quality and prevent common errors:

### Installed Hooks

**Pre-commit (runs before commit):**
- **Trailing whitespace removal** - Cleans up file formatting
- **End-of-file fixer** - Ensures files end with newline
- **YAML syntax validation** - Checks YAML files for syntax errors
- **Large file detection** - Prevents committing files >1MB
- **Merge conflict detection** - Catches unresolved merge markers
- **Private key detection** - Prevents accidentally committing SSH keys
- **Ruff linter/formatter** - Auto-formats Python code in custom components
- **ESPHome config validation** - Validates all device YAML configs before commit
- **Secrets detection** - Warns about hardcoded passwords/keys
- **Secrets.yaml blocker** - Prevents committing secrets.yaml file

**Commit-msg (validates commit message):**
- **Conventional Commits enforcement** - Requires proper commit message format

### Commit Message Format

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

Types:
  feat:     New feature
  fix:      Bug fix
  docs:     Documentation changes
  style:    Code style changes (formatting)
  refactor: Code refactoring
  perf:     Performance improvements
  test:     Adding/updating tests
  build:    Build system changes
  ci:       CI/CD changes
  chore:    Other changes (dependencies, config)

Examples:
  feat: add BME680 sensor support
  fix(wifi): resolve connection timeout issue
  docs: update README with new device instructions
  chore: update esphome to 2024.7.0
```

### Managing Hooks

```bash
# Run hooks manually on all files
make pre-commit-run

# Reinstall hooks after updates
make pre-commit-install

# Skip hooks temporarily (NOT recommended)
git commit --no-verify -m "message"
```

### What Hooks Prevent

✓ Invalid ESPHome YAML configurations reaching the repository
✓ Hardcoded passwords/API keys in config files
✓ Accidentally committing `secrets.yaml`
✓ Large binary files bloating the repository
✓ Inconsistent code formatting
✓ Poor commit message documentation

## Troubleshooting

### Device won't connect to WiFi
- Check credentials in `secrets.yaml`
- Look for fallback AP (Device Name + "Fallback")
- Connect to fallback AP and reconfigure via captive portal

### Compilation errors
- Verify board type matches your hardware
- Check pin assignments for your specific board
- Ensure all required sensors/libraries are available
- Verify Python version: `uv run python --version` (should be 3.11.x)

### OTA upload fails
- Ensure device is connected to same network
- Try USB upload if OTA is unreachable
- Check OTA password in secrets.yaml

### Can't find device on network
- Check mDNS is working: `ping device-name.local`
- View IP in ESPHome dashboard logs
- Connect to fallback AP to check connection

### UV/Python issues
- **UV not found**: Ensure UV is in PATH, restart terminal
  - Linux/macOS: `export PATH="$HOME/.local/bin:$PATH"`
  - Windows: Add `%USERPROFILE%\.local\bin` to PATH
- **Wrong Python version**: Run `uv python install` to reinstall correct version
- **Check installed Python**: `uv python list --only-installed`
- **Verify project Python**: `uv run python --version` (should match `.python-version`)
- **ESPHome not found**: Reinstall dependencies with `uv pip install -r pyproject.toml`

### Docker issues
- Check logs: `docker logs esphome`
- Restart container: `docker-compose restart`
- Rebuild: `docker-compose down && docker-compose up -d --build`

### Git hook failures
- **ESPHome validation fails**: Fix YAML syntax errors before committing
- **Secrets detected**: Move hardcoded passwords to `secrets.yaml` with `!secret` directive
- **Commit message rejected**: Use Conventional Commits format (see Git Hooks section)
- **Pre-commit errors**: Run `make pre-commit-run` to see detailed errors

## Resources

- [ESPHome Official Documentation](https://esphome.io/)
- [ESP32 Component Reference](https://esphome.io/components/esp32.html)
- [ESPHome Cookbook](https://esphome.io/cookbook/)
- [Home Assistant Integration](https://www.home-assistant.io/integrations/esphome/)

## License

This scaffolding is provided as-is for ESP32/ESPHome projects.
