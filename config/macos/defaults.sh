#!/bin/bash

set -e

echo "Applying macOS system settings..."

source "$(dirname "$0")/system.sh"
source "$(dirname "$0")/keyboard.sh"
source "$(dirname "$0")/dock.sh"
source "$(dirname "$0")/finder.sh"
source "$(dirname "$0")/screenshot.sh"
source "$(dirname "$0")/trackpad.sh"
source "$(dirname "$0")/menu.sh"
source "$(dirname "$0")/security.sh"
source "$(dirname "$0")/animation.sh"
source "$(dirname "$0")/mouse.sh"
source "$(dirname "$0")/controlcenter.sh"

echo ""
echo "Done! Some settings require a restart to take effect."
