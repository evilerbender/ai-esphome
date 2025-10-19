# Git Hooks Quick Reference

## Commit Message Format
```
<type>: <description>
<type>(scope): <description>
```

## Valid Types
| Type | Use For |
|------|---------|
| `feat` | New features |
| `fix` | Bug fixes |
| `docs` | Documentation |
| `style` | Formatting |
| `refactor` | Code restructuring |
| `perf` | Performance |
| `test` | Tests |
| `build` | Build system |
| `ci` | CI/CD |
| `chore` | Maintenance |

## Common Commands
```bash
# Run hooks manually
make pre-commit-run

# Reinstall hooks
make pre-commit-install

# Normal commit
git commit -m "feat: add new sensor"

# Emergency bypass (NOT recommended)
git commit --no-verify -m "message"
```

## Hook Failures

### ESPHome Config Invalid
```bash
uv run esphome config config/devices/your-device.yaml
# Fix errors, then commit again
```

### Hardcoded Secrets Detected
```bash
# Move to secrets.yaml
echo "wifi_password: YourPassword" >> config/secrets.yaml

# Use !secret directive
# wifi:
#   password: !secret wifi_password
```

### Commit Message Rejected
```bash
# ✗ Bad: "Updated config"
# ✓ Good: "feat: add BME680 sensor"
```

## Hooks Summary (14 Total)

**Auto-Fix (6):**
- Trailing whitespace
- End of file
- Line endings
- Ruff lint
- Ruff format
- Mixed line endings

**Validation (8):**
- YAML syntax
- ESPHome configs
- Large files (>1MB)
- Merge conflicts
- Private keys
- Hardcoded secrets
- secrets.yaml block
- Commit message format

## More Info
See `docs/GIT_HOOKS.md` for complete documentation.
