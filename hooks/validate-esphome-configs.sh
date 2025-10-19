#!/usr/bin/env bash

set -e

echo "Validating ESPHome device configurations..."

DEVICE_DIR="config/devices"
FAILED=0

if [ ! -d "$DEVICE_DIR" ]; then
    echo "Error: $DEVICE_DIR directory not found"
    exit 1
fi

for config in "$DEVICE_DIR"/*.yaml; do
    if [ -f "$config" ]; then
        echo "  Validating $(basename "$config")..."
        if ! uv run esphome config "$config" > /dev/null 2>&1; then
            echo "  ❌ FAILED: $(basename "$config")"
            uv run esphome config "$config"
            FAILED=1
        else
            echo "  ✓ Valid: $(basename "$config")"
        fi
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo "❌ ESPHome configuration validation failed!"
    echo "Fix the errors above before committing."
    exit 1
fi

echo "✓ All ESPHome configurations are valid!"
exit 0
