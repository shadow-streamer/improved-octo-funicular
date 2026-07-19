#!/bin/bash
# Common functions for site-cloner scripts
# Source this file: source "$(dirname "$0")/../lib/common.sh"

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Load config
load_config() {
    local config_file="${1:-$(dirname "$0")/../config/defaults.conf}"
    if [[ -f "$config_file" ]]; then
        # shellcheck source=/dev/null
        source "$config_file"
    fi
    # Defaults
    USER_AGENT="${USER_AGENT:-Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36}"
    TIMEOUT="${TIMEOUT:-30}"
    CONCURRENT="${CONCURRENT:-4}"
}

# Logging functions
log_info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
log_step()    { echo -e "${BLUE}[$1/$2]${NC} $3"; }

# Validate URL
validate_url() {
    local url="$1"
    if [[ ! "$url" =~ ^https?:// ]]; then
        log_error "Invalid URL: $url (must start with http:// or https://)"
        return 1
    fi
    return 0
}

# Extract domain from URL
extract_domain() {
    echo "$1" | sed 's|https\?://||' | cut -d'/' -f1 | cut -d':' -f1
}

# Check if command exists
require_cmd() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        log_error "Required command not found: $cmd"
        log_info "Install with: apt-get install $2"
        return 1
    fi
    return 0
}

# Check for sudo
has_sudo() {
    command -v sudo &>/dev/null && sudo -n true 2>/dev/null
}

# Safe mkdir
safe_mkdir() {
    mkdir -p "$1" || { log_error "Cannot create directory: $1"; return 1; }
}

# Download with retry
download() {
    local url="$1"
    local output="$2"
    local max_retries="${3:-3}"
    local retry=0

    while [[ $retry -lt $max_retries ]]; do
        if curl -sL --fail --max-time "$TIMEOUT" \
            -H "User-Agent: $USER_AGENT" \
            -H "Referer: ${REFERER:-$url}" \
            -o "$output" "$url" 2>/dev/null; then
            return 0
        fi
        ((retry++))
        [[ $retry -lt $max_retries ]] && sleep 1
    done

    log_warn "Failed to download after $max_retries attempts: $url"
    return 1
}

# Get file size in human readable format
human_size() {
    local bytes="$1"
    if [[ $bytes -ge 1073741824 ]]; then
        echo "$(echo "scale=1; $bytes/1073741824" | bc)GB"
    elif [[ $bytes -ge 1048576 ]]; then
        echo "$(echo "scale=1; $bytes/1048576" | bc)MB"
    elif [[ $bytes -ge 1024 ]]; then
        echo "$(echo "scale=1; $bytes/1024" | bc)KB"
    else
        echo "${bytes}B"
    fi
}

# Count files in directory
count_files() {
    find "$1" -type f 2>/dev/null | wc -l
}

# Get total size of directory
total_size() {
    find "$1" -type f -exec stat -c%s {} + 2>/dev/null | awk '{s+=$1} END {print s+0}'
}

# Check if URL is accessible
check_url() {
    local url="$1"
    curl -sL --fail --max-time 5 -o /dev/null "$url" 2>/dev/null
}
