#!/usr/bin/env bash

set -e

echo "Checking for hardcoded secrets in YAML files..."

FAILED=0

for file in "$@"; do
    if [[ "$file" == *"secrets.yaml"* ]] || [[ "$file" == *"secrets.yaml.example"* ]]; then
        continue
    fi

    if grep -qE '(password|api_key|token|secret):\s*["\047][^$!]' "$file" 2>/dev/null; then
        echo "❌ FAILED: $file contains hardcoded secrets"
        echo "   Use secrets.yaml with !secret directive instead"
        echo "   Example: wifi_password: !secret wifi_password"
        FAILED=1
    fi

    if grep -qE '[0-9a-fA-F]{32,}' "$file" 2>/dev/null; then
        if ! grep -q '!secret' "$file"; then
            echo "⚠️  WARNING: $file may contain API keys or encryption keys"
            echo "   Consider using secrets.yaml if these are sensitive"
        fi
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo "❌ Secret detection failed! Move sensitive data to secrets.yaml"
    exit 1
fi

echo "✓ No hardcoded secrets detected"
exit 0
