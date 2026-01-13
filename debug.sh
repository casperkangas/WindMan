#!/bin/bash
set -e

# Rebuild
./refresh.sh

echo "🚀 Launching in separate terminal..."

# The executable inside the .app
APP_BINARY="./WindMan.app/Contents/MacOS/WindMan"

# 'open' the binary directly creates a new Terminal window for it
open "$APP_BINARY"