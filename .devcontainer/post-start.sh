#!/usr/bin/env bash
set -euo pipefail

if [ ! -f .workshop-state/.motd-shown ]; then
  printf '\nTerraform workshop codespace is ready. Open labs/00-welcome.md to begin.\n\n'
  touch .workshop-state/.motd-shown
fi
