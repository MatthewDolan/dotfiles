#!/usr/bin/env bash
set -euo pipefail

bats -r tests "$@"
