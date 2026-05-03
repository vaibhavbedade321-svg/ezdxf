#!/usr/bin/env bash
# Olympus challenge runner for ezdxf polygon buffer.
#
# Usage:
#     ./test.sh --output_path <junit.xml> base   # existing regression tests
#     ./test.sh --output_path <junit.xml> new    # new buffer module tests
set -euo pipefail

OUTPUT_PATH=""
MODE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --output_path)
            OUTPUT_PATH="$2"
            shift 2
            ;;
        base|new)
            MODE="$1"
            shift
            ;;
        *)
            echo "unknown argument: $1" >&2
            exit 2
            ;;
    esac
done

if [[ -z "$OUTPUT_PATH" || -z "$MODE" ]]; then
    echo "usage: test.sh --output_path <path> {base|new}" >&2
    exit 2
fi

cd "$(dirname "$0")/.."

NEW_TEST="tests/test_06_math/test_667_polygon_buffer.py"

case "$MODE" in
    base)
        python3 -m pytest tests/ \
            --ignore=tests/test_08_addons \
            --ignore="$NEW_TEST" \
            -v --junitxml="$OUTPUT_PATH"
        ;;
    new)
        python3 -m pytest "$NEW_TEST" \
            -v --junitxml="$OUTPUT_PATH"
        ;;
esac
