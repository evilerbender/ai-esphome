# ESPHome ESP32 Quick Start Guide

Get from fresh clone to flashing your first ESP32 in under 10 minutes!

## Prerequisites

- **Hardware**: ESP32 development board (ESP32-DevKitC, NodeMCU-32S, or similar)
- **USB Cable**: Data-capable USB cable to connect ESP32 to computer
- **WiFi**: 2.4GHz WiFi network (ESP32 doesn't support 5GHz)
- **OS**: Linux, macOS, or Windows with WSL2

## Step 1: Install UV (Python Package Manager)

UV is a fast Python package manager that manages Python versions and dependencies.

### Linux/macOS:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Windows (PowerShell):
```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### Verify Installation:
```bash
uv --version
# Should show: uv x.x.x
```

**Restart your terminal** after installation to ensure UV is in your PATH.

## Step 2: Clone Repository

```bash
# Clone the repository
git clone <your-repo-url>
cd ai-esphome

# Verify you're in the right place
ls
# Should see: README.md, pyproject.toml, config/, etc.
```

## Step 3: Install Dependencies

```bash
# Install Python and all dependencies (one command!)
make install
```

This command:
- Downloads and installs Python 3.11 (isolated from system Python)
- Installs ESPHome and all dependencies
- Sets up the development environment

**Takes 1-2 minutes on first run.**

### Verify Installation:
```bash
uv run esphome version
# Should show: Version: 2024.x.x
```

## Step 4: Configure Secrets

Create your secrets file with WiFi credentials and security keys:

```bash
# Copy example secrets file
cp config/secrets.yaml.example config/secrets.yaml

# Generate API encryption key
uv run esphome encryption-key
# Copy the output (looks like: abcdef1234567890...)
```

Now edit `config/secrets.yaml`:

```bash
# Use your preferred editor
nano config/secrets.yaml
# or
vim config/secrets.yaml
# or
code config/secrets.yaml  # VS Code
```

Replace these values:

```yaml
wifi_ssid: "YourWiFiSSID"              # Your 2.4GHz WiFi network name
wifi_password: "YourWiFiPassword"       # Your WiFi password

api_encryption_key: "PASTE_KEY_HERE"    # Paste the key from esphome encryption-key

ota_password: "YourOTAPassword"         # Create a password for OTA updates

ap_password: "YourFallbackAPPassword"   # Fallback AP password (if WiFi fails)
```

**Important:** `secrets.yaml` is gitignored and will never be committed.

## Step 5: Create Your First Device Config

### Option A: Use Example Device (Quickest)

The repo includes example devices. Let's use the simplest one:

```bash
# The minimal example is living-room-sensor
cat config/devices/living-room-sensor.yaml
```

This config includes:
- Basic ESP32 setup (ESP-IDF framework)
- WiFi with fallback AP
- Web server for debugging
- DHT22 temperature/humidity sensor on GPIO15
- Restart button
- WiFi signal and uptime sensors

**Skip to Step 6** to compile this example.

### Option B: Create Minimal Custom Device

Create a new minimal device from scratch:

```bash
# Create new device file
touch config/devices/my-first-esp32.yaml
```

Edit `config/devices/my-first-esp32.yaml`:

```yaml
substitutions:
  device_name: my-first-esp32
  friendly_name: "My First ESP32"
  board: esp32dev                    # Change if using different board

packages:
  base: !include ../common/base.yaml
  wifi: !include ../common/wifi.yaml

binary_sensor:
  - platform: status
    name: "${friendly_name} Status"
    id: device_status

sensor:
  - platform: wifi_signal
    name: "${friendly_name} WiFi Signal"
    update_interval: 60s

  - platform: uptime
    name: "${friendly_name} Uptime"

button:
  - platform: restart
    name: "${friendly_name} Restart"
```

This is a **minimal but functional** config with:
- Device status sensor
- WiFi signal strength
- Uptime tracking
- Restart button
- Web server (from base.yaml)

## Step 6: Validate Configuration

Before compiling, validate your config:

```bash
# Using living-room-sensor example
uv run esphome config config/devices/living-room-sensor.yaml

# OR using your custom device
uv run esphome config config/devices/my-first-esp32.yaml
```

**Expected output:**
```
INFO Reading configuration config/devices/...
INFO Detected timezone 'UTC'
INFO Configuration is valid!
```

**If you see errors:**
- Check YAML indentation (use spaces, not tabs)
- Verify substitutions are defined
- Ensure secrets.yaml exists with all required keys

## Step 7: Compile Firmware

Compile the firmware (doesn't flash yet):

```bash
# Using example
make compile DEVICE=living-room-sensor

# OR using custom device
uv run esphome compile config/devices/my-first-esp32.yaml
```

**First compile takes 3-5 minutes** (downloads ESP-IDF toolchain and libraries).
Subsequent compiles take 30-60 seconds.

**Expected output:**
```
INFO Compiling app...
INFO Linking...
INFO Building binary...
SUCCESS Compilation successful!
```

## Step 8: Connect ESP32

1. **Connect ESP32 to computer** via USB cable
2. **Identify USB port:**

   **Linux:**
   ```bash
   ls /dev/ttyUSB* /dev/ttyACM*
   # Usually: /dev/ttyUSB0 or /dev/ttyACM0
   ```

   **macOS:**
   ```bash
   ls /dev/cu.*
   # Usually: /dev/cu.usbserial-* or /dev/cu.SLAB_USBtoUART
   ```

   **Windows (WSL2):**
   ```bash
   ls /dev/ttyS*
   # Usually: /dev/ttyS3 or similar (maps to COM3)
   ```

3. **Grant permissions (Linux only):**
   ```bash
   sudo usermod -a -G dialout $USER
   # Log out and back in for changes to take effect

   # OR use sudo for single flash:
   sudo chown $USER /dev/ttyUSB0
   ```

## Step 9: Flash ESP32 (First Time - USB Required)

```bash
# Using example
make upload DEVICE=living-room-sensor

# OR using custom device
uv run esphome upload config/devices/my-first-esp32.yaml
```

**During upload:**
1. ESPHome will ask: **"How do you want to upload?"**
   - Choose: **"Serial port"** (first option)
2. Select your USB port from the list
3. Wait for upload to complete (takes ~1 minute)

**Expected output:**
```
INFO Connecting to /dev/ttyUSB0
INFO Uploading...
Writing at 0x00010000... (100%)
INFO Upload successful!
INFO Starting log output from /dev/ttyUSB0
```

**If upload fails:**
- Try holding BOOT button on ESP32 during upload
- Check USB cable is data-capable (not charge-only)
- Verify correct port selected
- Try different USB port

## Step 10: View Logs & Verify

After successful upload, logs will start streaming automatically:

```
INFO [app:100]: ESPHome version 2024.x.x compiled on Oct 18 2025
INFO [wifi:123]: WiFi Connected! SSID='YourWiFi' IP=192.168.1.XXX
INFO [app:100]: setup() finished successfully!
```

**Key things to verify:**
- ✓ ESP32 boots successfully
- ✓ Connects to WiFi (shows IP address)
- ✓ API starts successfully
- ✓ No error messages in red

**To stop logs:** Press `Ctrl+C`

**To view logs later:**
```bash
make logs DEVICE=living-room-sensor
# OR
uv run esphome logs config/devices/my-first-esp32.yaml
```

## Step 11: Access Web Interface

ESPHome includes a built-in web server for debugging.

**Open browser and navigate to:**
```
http://<ESP32_IP_ADDRESS>
# Example: http://192.168.1.150
```

**Or use mDNS (if supported on your network):**
```
http://my-first-esp32.local
```

You should see:
- Device status
- WiFi signal strength
- Uptime
- Restart button
- Any sensors you configured

## Step 12: Make Your First Change

Let's add a simple switch to test OTA updates:

Edit your device config (`config/devices/my-first-esp32.yaml`):

```yaml
# Add this section at the end of the file:

switch:
  - platform: restart
    name: "${friendly_name} Restart Switch"
```

**Save and upload via OTA (no USB needed!):**

```bash
uv run esphome upload config/devices/my-first-esp32.yaml
```

**ESPHome will ask: "How do you want to upload?"**
- Choose: **"Wirelessly"** (first option now!)
- Select your device from the list

**OTA upload takes ~30 seconds** and doesn't require USB!

**Refresh web interface** - you should see the new Restart Switch!

## 🎉 Success!

You now have a functional ESPHome ESP32 device!

### What You've Accomplished:

✅ Installed UV and ESPHome
✅ Configured WiFi and security
✅ Created a device configuration
✅ Compiled and flashed firmware
✅ Connected to WiFi
✅ Accessed web interface
✅ Performed OTA update

## Next Steps

### Add Sensors

Check available sensors in `config/common/sensors/`:

```bash
ls config/common/sensors/
# dht22.yaml  bme280.yaml
```

**Add DHT22 temperature/humidity sensor:**

Edit your device config:
```yaml
substitutions:
  sensor_pin: GPIO15  # Pin where DHT22 data is connected

packages:
  base: !include ../common/base.yaml
  wifi: !include ../common/wifi.yaml
  sensor_dht22: !include ../common/sensors/dht22.yaml  # Add this line
```

**Upload via OTA:**
```bash
uv run esphome upload config/devices/my-first-esp32.yaml
```

### Create More Devices

```bash
# Copy your working config
cp config/devices/my-first-esp32.yaml config/devices/bedroom-sensor.yaml

# Edit substitutions for new device
vim config/devices/bedroom-sensor.yaml
```

Change:
```yaml
substitutions:
  device_name: bedroom-sensor      # Must be unique!
  friendly_name: "Bedroom Sensor"
  board: esp32dev
```

### Use Dashboard (Optional)

For managing multiple devices with a web UI:

```bash
make dashboard
# OR
uv run esphome dashboard config/
```

Open browser: **http://localhost:6052**

The dashboard provides:
- Visual device management
- Click-to-compile/upload
- Log viewer
- Config editor

### Integrate with Home Assistant

1. In Home Assistant, go to **Settings → Devices & Services**
2. Click **"+ Add Integration"**
3. Search for **"ESPHome"**
4. Enter your ESP32's IP address or hostname
5. Enter the API encryption key from `secrets.yaml`
6. Your device and all sensors will appear automatically!

## Common Issues & Solutions

### ESP32 Won't Connect to WiFi

**Check:**
- WiFi is 2.4GHz (not 5GHz)
- Credentials in `secrets.yaml` are correct
- WiFi SSID/password have no special characters causing issues

**Fallback AP Mode:**
If WiFi fails, ESP32 creates a fallback AP:
- SSID: `my-first-esp32 Fallback`
- Password: (from `ap_password` in secrets.yaml)

Connect to this AP and configure WiFi via captive portal.

### Compilation Errors

**"error: board not found"**
- Change `board: esp32dev` to match your hardware
- See [ESP32 boards list](https://github.com/platformio/platform-espressif32/tree/master/boards)

**"substitution not found"**
- Ensure all `${variables}` are defined in `substitutions:` section

**YAML syntax errors:**
- Use spaces for indentation, not tabs
- Ensure consistent indentation (2 spaces per level)

### Upload Fails

**"Serial port not found"**
```bash
# Linux: Install drivers
sudo apt-get install python3-serial

# macOS: Install CP210x or CH340 drivers
# Windows: Install USB drivers for your ESP32 chip
```

**"Failed to connect"**
- Hold BOOT button during upload
- Try different USB cable
- Check `dmesg | tail` (Linux) for USB detection

### OTA Upload Fails

**"Device not found"**
- Ensure ESP32 is on same network
- Use IP address instead of hostname
- Check firewall isn't blocking port 3232

**"Authentication failed"**
- Verify `ota_password` in secrets.yaml matches

### Device Reboots Constantly

**Check logs:**
```bash
make logs DEVICE=my-first-esp32
```

**Common causes:**
- Insufficient power (use 5V 2A power supply, not just USB)
- Bad USB cable
- Hardware issue with ESP32 board
- Wrong GPIO pins (some pins cause boot issues)

**Avoid these GPIO pins for outputs:**
- GPIO0, GPIO2, GPIO12, GPIO15 (boot mode pins)
- GPIO1, GPIO3 (UART TX/RX)

Safe GPIOs for general use:
- GPIO4, GPIO5, GPIO16-GPIO19, GPIO21-GPIO23, GPIO25-GPIO27, GPIO32-GPIO33

## Useful Commands Reference

```bash
# Install dependencies
make install

# Compile device
make compile DEVICE=my-first-esp32

# Upload via USB (first time)
make upload DEVICE=my-first-esp32

# View logs
make logs DEVICE=my-first-esp32

# Validate config
uv run esphome config config/devices/my-first-esp32.yaml

# Clean build artifacts
make clean-build DEVICE=my-first-esp32

# Start dashboard
make dashboard

# Run pre-commit hooks
make pre-commit-run

# All commands
make help
```

## Device Config Template

**Minimal working template:**

```yaml
substitutions:
  device_name: my-device-name        # lowercase, hyphens only
  friendly_name: "My Device Name"    # human-readable
  board: esp32dev                    # your ESP32 board type

packages:
  base: !include ../common/base.yaml
  wifi: !include ../common/wifi.yaml

# Optional: Add sensors/switches/buttons below

binary_sensor:
  - platform: status
    name: "${friendly_name} Status"

sensor:
  - platform: wifi_signal
    name: "${friendly_name} WiFi Signal"
    update_interval: 60s

button:
  - platform: restart
    name: "${friendly_name} Restart"
```

## Documentation Resources

- **This Project:** `README.md` - Full project documentation
- **Git Hooks:** `docs/GIT_HOOKS.md` - Git workflow and commit conventions
- **ESPHome Official:** https://esphome.io/
- **ESP32 Reference:** https://esphome.io/components/esp32.html
- **Component Library:** https://esphome.io/components/
- **Cookbook:** https://esphome.io/cookbook/

## Getting Help

1. Check logs: `make logs DEVICE=your-device`
2. Validate config: `uv run esphome config config/devices/your-device.yaml`
3. Review `docs/GIT_HOOKS.md` for commit issues
4. Check ESPHome docs: https://esphome.io/
5. Search ESPHome Discord: https://discord.gg/KhAMKrd

## Summary Checklist

- [ ] UV installed and in PATH
- [ ] Repository cloned
- [ ] Dependencies installed (`make install`)
- [ ] `secrets.yaml` created with WiFi credentials
- [ ] API encryption key generated
- [ ] Device config created or example chosen
- [ ] Configuration validated
- [ ] Firmware compiled successfully
- [ ] ESP32 connected via USB
- [ ] Firmware flashed via USB
- [ ] Device connects to WiFi
- [ ] Web interface accessible
- [ ] OTA update tested
- [ ] Ready to add sensors!

**Time to complete:** 5-10 minutes (excluding compile time)

Welcome to ESPHome ESP32 development! 🚀
