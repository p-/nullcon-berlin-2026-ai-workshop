#!/bin/bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

echo "🚀 Setting up Seclab Taskflows development environment..."

# Create Python virtual environment
echo "📦 Creating Python virtual environment..."
python3 -m venv .venv

# Activate virtual environment and install dependencies
echo "📥 Installing Python dependencies..."
source .venv/bin/activate
python -m pip install --upgrade pip

# Use the project's build backend without Hatch's unrelated CLI dependencies.
python -m pip install --upgrade --upgrade-strategy eager -e . hatchling
python -m pip check
python -m hatchling build

echo "✅ Development environment setup complete!"
