#!/usr/bin/env bash
# DEPRECATED — replaced by forge.sh which supports install / update / uninstall / status / restore.
# Forwarding install command to the new script.
exec "$(dirname "${BASH_SOURCE[0]}")/forge.sh" install "$@"
