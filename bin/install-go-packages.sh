#!/bin/bash

set -e

echo "Installing Go packages..."

packages=(
    "github.com/jesseduffield/lazygit@latest"
)

for package in "${packages[@]}"; do
    echo "  -> Installing $package"
    go install "$package"
done

echo "Go packages installation completed!"