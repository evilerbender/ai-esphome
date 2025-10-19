# Git Hooks Documentation

This project uses automated git hooks to maintain code quality, prevent common errors, and enforce best practices.

## Overview

**Pre-commit Framework**: Industry-standard hook management system
**Hook Location**: `.git/hooks/` (installed automatically)
**Configuration**: `.pre-commit-config.yaml`
**Custom Hooks**: `hooks/` directory

## Hooks Summary

### Pre-Commit Hooks (Before Commit)

| Hook | Purpose | Impact |
|------|---------|--------|
| **trailing-whitespace** | Remove trailing spaces | Auto-fixes |
| **end-of-file-fixer** | Add newline at EOF | Auto-fixes |
| **check-yaml** | Validate YAML syntax | Blocks commit on error |
| **check-added-large-files** | Prevent files >1MB | Blocks commit |
| **check-merge-conflict** | Detect `<<<<<<<` markers | Blocks commit |
| **mixed-line-ending** | Enforce LF line endings | Auto-fixes |
| **detect-private-key** | Find SSH/API keys | Blocks commit |
| **ruff** (linter) | Lint Python code | Auto-fixes |
| **ruff-format** | Format Python code | Auto-fixes |
| **yamllint** | Lint YAML files | Blocks commit on error |
| **esphome-config-validate** | Validate ESPHome configs | Blocks commit on error |
| **secrets-check** | Detect hardcoded secrets | Blocks commit + warns |
| **no-direct-commit-secrets** | Block secrets.yaml | Blocks commit |

### Commit-Msg Hook (After Commit Message)

| Hook | Purpose | Impact |
|------|---------|--------|
| **commit-msg** | Enforce Conventional Commits | Blocks commit on invalid format |

## Conventional Commits Format

```
<type>[optional scope]: <description>
```

### Valid Types

- `feat` - New feature (e.g., `feat: add BME680 sensor support`)
- `fix` - Bug fix (e.g., `fix(wifi): resolve connection timeout`)
- `docs` - Documentation (e.g., `docs: update README with setup instructions`)
- `style` - Formatting changes (e.g., `style: fix indentation in base.yaml`)
- `refactor` - Code restructuring (e.g., `refactor: simplify sensor config structure`)
- `perf` - Performance improvements (e.g., `perf: optimize MQTT message handling`)
- `test` - Test changes (e.g., `test: add validation tests for sensor configs`)
- `build` - Build system (e.g., `build: update docker-compose for Python 3.11`)
- `ci` - CI/CD changes (e.g., `ci: add GitHub Actions workflow`)
- `chore` - Maintenance (e.g., `chore: update esphome to 2024.7.0`)

### Examples

✅ **Good commit messages:**
```
feat: add support for SCD40 CO2 sensor
fix(ota): increase upload timeout to 300s
docs: document custom component development
chore(deps): update esphome to 2024.10.0
refactor: split sensor configs into separate files
```

❌ **Bad commit messages:**
```
Update stuff
Fixed bug
WIP
asdf
Updated config
```

## Custom Hook Details

### ESPHome Config Validation (`hooks/validate-esphome-configs.sh`)

**What it does:**
- Runs `esphome config` on all device YAML files
- Validates syntax, includes, substitutions, and component definitions
- Prevents invalid configs from being committed

**When it runs:**
- On commit when any file in `config/devices/*.yaml` is modified
- Via `make pre-commit-run` manually

**How to fix failures:**
```bash
# Run validation manually to see errors
uv run esphome config config/devices/your-device.yaml

# Common issues:
# - Missing substitutions
# - Invalid pin numbers
# - Typos in component names
# - Missing includes
```

### Secrets Detection (`hooks/check-secrets.sh`)

**What it does:**
- Scans YAML files for hardcoded passwords, API keys, tokens
- Detects long hex strings that might be encryption keys
- Suggests using `secrets.yaml` with `!secret` directive

**Patterns detected:**
- `password: "actual_password"` (should be `password: !secret wifi_password`)
- `api_key: "hardcoded_key"`
- `token: "secret_token"`
- Long hex strings (32+ characters) without `!secret`

**How to fix:**
1. Move sensitive values to `config/secrets.yaml`:
   ```yaml
   wifi_password: "YourActualPassword"
   api_key: "your_api_key_here"
   ```

2. Reference in device configs with `!secret`:
   ```yaml
   wifi:
     ssid: !secret wifi_ssid
     password: !secret wifi_password
   ```

### Secrets.yaml Blocker

**What it does:**
- Prevents accidentally committing `secrets.yaml` file

**If triggered:**
```
❌ secrets.yaml should never be committed
```

**Solution:**
- Remove `secrets.yaml` from staging: `git reset config/secrets.yaml`
- Verify `.gitignore` contains `secrets.yaml`

## Manual Hook Execution

### Run All Hooks
```bash
make pre-commit-run
# OR
uv run pre-commit run --all-files
```

### Run Specific Hook
```bash
uv run pre-commit run esphome-config-validate
uv run pre-commit run ruff
uv run pre-commit run yamllint
```

### Run on Specific Files
```bash
uv run pre-commit run --files config/devices/living-room-sensor.yaml
```

## Bypassing Hooks (Not Recommended)

**Skip all hooks:**
```bash
git commit --no-verify -m "message"
```

**⚠️ WARNING:** Only use `--no-verify` for:
- Emergency hotfixes
- Temporary work-in-progress commits on feature branches
- When hooks are legitimately broken

**Never bypass hooks when:**
- Merging to main branch
- Creating releases
- Sharing commits with team

## Hook Maintenance

### Update Pre-Commit Hooks
```bash
uv run pre-commit autoupdate
```

### Reinstall Hooks
```bash
make pre-commit-install
# OR
uv run pre-commit install
cp hooks/commit-msg .git/hooks/commit-msg
```

### Clean Hook Cache
```bash
uv run pre-commit clean
```

## Troubleshooting

### Hook Fails with "command not found"

**Problem:** Hook can't find `uv` or `esphome`

**Solution:**
```bash
# Reinstall dependencies
uv sync

# Verify UV is in PATH
which uv

# Reinstall hooks
make pre-commit-install
```

### ESPHome Validation Takes Too Long

**Problem:** Validating all configs is slow

**Solution:**
- Only modified device configs trigger validation (configured in `.pre-commit-config.yaml`)
- Consider excluding test/draft configs from `config/devices/` directory

### Ruff Auto-Fix Changes My Code

**Problem:** Ruff reformats code unexpectedly

**Solution:**
- Review changes: `git diff`
- Configure Ruff in `pyproject.toml` if needed
- Stage the auto-fixed changes: `git add .`

### Commit Message Rejected

**Problem:** Commit message doesn't follow Conventional Commits

**Solution:**
```bash
# Check your message format
# Must be: type: description
# OR: type(scope): description

# Good examples:
git commit -m "feat: add new sensor"
git commit -m "fix(wifi): timeout issue"
git commit -m "docs: update README"
```

### Hook Infrastructure Issues

**Problem:** Pre-commit framework itself has issues

**Solution:**
```bash
# Reinstall pre-commit
uv pip install --force-reinstall pre-commit

# Reinstall hooks
uv run pre-commit uninstall
uv run pre-commit install

# Verify installation
ls -la .git/hooks/
```

## CI/CD Integration

These hooks can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run pre-commit hooks
  run: |
    uv sync
    uv run pre-commit run --all-files
```

This ensures the same quality checks run:
- Locally on developer machines
- In pull requests
- Before merging to main

## Best Practices

1. **Run hooks before pushing:** `make pre-commit-run`
2. **Commit frequently** with meaningful messages
3. **Never force-push** over failed hooks without investigation
4. **Keep hooks updated:** `uv run pre-commit autoupdate` monthly
5. **Test custom hooks** in `hooks/` directory before deploying
6. **Document new hooks** in this file when added
7. **Use descriptive commit messages** that explain "why", not just "what"

## Further Reading

- [Pre-commit Framework](https://pre-commit.com/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Ruff Linter](https://docs.astral.sh/ruff/)
- [ESPHome Configuration](https://esphome.io/guides/configuration-types.html)
