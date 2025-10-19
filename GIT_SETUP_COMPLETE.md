# Git Repository Setup Complete! ✓

## What Was Configured

### Repository Initialization
✓ Git repository initialized with `main` as default branch
✓ `.gitignore` configured for ESPHome, Python, UV, and IDE files
✓ `.gitattributes` enforces LF line endings for consistency

### Pre-Commit Framework
✓ `pre-commit>=3.5.0` added to dev dependencies
✓ `yamllint>=1.33.0` added for YAML validation
✓ All dependencies synced with UV

### Automated Git Hooks (13 Total)

#### Standard Pre-Commit Hooks (7):
1. **trailing-whitespace** - Auto-removes trailing spaces
2. **end-of-file-fixer** - Ensures files end with newline
3. **check-yaml** - Validates YAML syntax (excludes ESPHome configs)
4. **check-added-large-files** - Blocks files >1MB
5. **check-merge-conflict** - Detects unresolved merge markers
6. **mixed-line-ending** - Enforces LF line endings
7. **detect-private-key** - Prevents committing SSH/API keys

#### Code Quality Hooks (3):
8. **ruff** (linter) - Lints Python code with auto-fix
9. **ruff-format** - Auto-formats Python code
10. **yamllint** - Strict YAML linting (line-length: 120)

#### Custom ESPHome Hooks (3):
11. **esphome-config-validate** - Validates device YAML configs with `esphome config`
12. **secrets-check** - Detects hardcoded passwords/API keys
13. **no-direct-commit-secrets** - Blocks committing `secrets.yaml`

#### Commit Message Hook (1):
14. **commit-msg** - Enforces Conventional Commits format

### Hook Scripts Created

| File | Purpose |
|------|---------|
| `hooks/validate-esphome-configs.sh` | Validates all device YAML files using ESPHome CLI |
| `hooks/check-secrets.sh` | Scans for hardcoded secrets and suggests `!secret` directive |
| `hooks/commit-msg` | Validates commit message format |

### Configuration Files

| File | Purpose |
|------|---------|
| `.pre-commit-config.yaml` | Hook configuration and versions |
| `.gitattributes` | Line ending enforcement |
| `.gitignore` | Ignore patterns (includes UV-specific entries) |

### Documentation

| File | Description |
|------|-------------|
| `docs/GIT_HOOKS.md` | Comprehensive git hooks documentation |
| `README.md` | Updated with Git Hooks section |
| `AGENTS.md` | No changes needed (focuses on ESPHome/Python) |

### Makefile Commands Added

```bash
make pre-commit-run        # Run all hooks manually
make pre-commit-install    # Reinstall hooks after updates
```

## How to Use

### Normal Workflow
```bash
# Make your changes
vim config/devices/my-device.yaml

# Stage changes
git add config/devices/my-device.yaml

# Commit (hooks run automatically)
git commit -m "feat: add temperature sensor to my-device"
```

### Hooks Run Automatically On:
- `git commit` - Pre-commit hooks validate files
- `git commit` - Commit-msg hook validates message format

### Manual Hook Execution
```bash
# Run all hooks on staged files
make pre-commit-run

# Run all hooks on all files
uv run pre-commit run --all-files

# Run specific hook
uv run pre-commit run esphome-config-validate
```

## Conventional Commits Cheat Sheet

```
feat: add new feature
fix: bug fix
docs: documentation change
style: formatting change
refactor: code restructuring
perf: performance improvement
test: test changes
build: build system changes
ci: CI/CD changes
chore: maintenance (deps, etc.)
```

Examples:
```bash
git commit -m "feat: add BME680 air quality sensor"
git commit -m "fix(wifi): increase connection timeout"
git commit -m "docs: add sensor wiring diagram"
git commit -m "chore(deps): update esphome to 2024.10.0"
```

## What Hooks Prevent

✅ Invalid ESPHome YAML configurations
✅ Hardcoded passwords and API keys
✅ Accidentally committing `secrets.yaml`
✅ Large binary files
✅ Inconsistent code formatting
✅ Trailing whitespace and line ending issues
✅ Private keys in repository
✅ Poor commit message documentation

## Next Steps

### 1. Create Initial Commit
```bash
# All files are staged and ready
git commit -m "chore: initial ESPHome ESP32 project setup with UV and git hooks"
```

### 2. Test Hooks Work
```bash
# Try invalid commit message
git commit --allow-empty -m "bad message"
# Should fail with Conventional Commits error

# Try valid commit message
git commit --allow-empty -m "test: verify git hooks"
# Should succeed
```

### 3. Start Development
```bash
# Add a new device
cp config/devices/living-room-sensor.yaml config/devices/my-device.yaml
vim config/devices/my-device.yaml
git add config/devices/my-device.yaml
git commit -m "feat: add my-device ESP32 configuration"
```

### 4. Optional: Set Up Remote
```bash
# Add remote repository
git remote add origin https://github.com/yourusername/your-repo.git

# Push to remote
git push -u origin main
```

## Troubleshooting

### Hook Fails with "command not found"
```bash
# Reinstall dependencies
uv sync

# Reinstall hooks
make pre-commit-install
```

### ESPHome Validation Fails
```bash
# Check config manually
uv run esphome config config/devices/your-device.yaml

# Fix errors and try again
git add config/devices/your-device.yaml
git commit -m "fix: resolve YAML syntax errors"
```

### Commit Message Rejected
```bash
# Use proper format: <type>: <description>
git commit -m "feat: add new sensor"  # ✓ Good
git commit -m "Added new sensor"       # ✗ Bad
```

### Skip Hooks Temporarily (Emergency Only)
```bash
git commit --no-verify -m "emergency: hotfix"
```

## Files Overview

```
/opt/ai-esphome/
├── .git/                           # Git repository
│   └── hooks/
│       ├── pre-commit              # Installed by pre-commit framework
│       └── commit-msg              # Custom conventional commits validator
├── .gitattributes                  # Line ending enforcement
├── .gitignore                      # Ignore patterns (includes UV)
├── .pre-commit-config.yaml         # Hook configuration
├── .python-version                 # Python 3.11 pinned
├── pyproject.toml                  # UV dependencies (includes pre-commit)
├── Makefile                        # Shortcuts (includes hook commands)
├── hooks/                          # Custom hook scripts
│   ├── validate-esphome-configs.sh # ESPHome YAML validator
│   ├── check-secrets.sh            # Hardcoded secret detector
│   └── commit-msg                  # Commit message validator
├── docs/
│   └── GIT_HOOKS.md                # Comprehensive hook documentation
├── config/
│   ├── common/                     # Reusable configs
│   ├── devices/                    # Device-specific configs
│   └── secrets.yaml.example        # Example secrets (never committed)
└── README.md                       # Updated with Git Hooks section
```

## Summary

Your ESPHome ESP32 project now has:

✅ **Modern UV-based Python management** (10-100x faster)
✅ **Automated code quality checks** (pre-commit hooks)
✅ **ESPHome config validation** (catches errors before commit)
✅ **Security measures** (secrets detection, key blocking)
✅ **Conventional Commits enforcement** (clear git history)
✅ **Comprehensive documentation** (README + dedicated hook docs)
✅ **Easy-to-use Makefile commands** (shortcuts for common tasks)

You're ready to develop! 🚀

## Support

For detailed information about hooks, see `docs/GIT_HOOKS.md`.

For ESPHome development, see `README.md` and `AGENTS.md`.
