#!/usr/bin/env bash
set -Eeuo pipefail

# ------------------------------------------------------------
# install_from_list.sh
# - Read package names from a list file
# - Filter only installable packages on current Ubuntu (apt-cache show)
# - Install filtered packages via apt
# - Output: resolved list + missing list + logs
#
# Usage:
#   ./install_from_list.sh [list_file]
#
# Default list_file: ./manual-packages.list
# ------------------------------------------------------------

log_info()  { echo "[INFO ] $*"; }
log_warn()  { echo "[WARN ] $*"; }
log_error() { echo "[ERROR] $*" 1>&2; }

require_cmd() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1 || {
        log_error "Required command not found: $cmd"
        exit 1
    }
}

require_root_or_sudo() {
    if [[ "${EUID}" -ne 0 ]]; then
        if command -v sudo >/dev/null 2>&1; then
            log_info "Not running as root. Will use sudo where needed."
        else
            log_error "Not root and sudo not found. Please run as root."
            exit 1
        fi
    fi
}

run_apt_update() {
    if [[ "${EUID}" -eq 0 ]]; then
        apt update -y
    else
        sudo apt update -y
    fi
}

run_apt_install() {
    local resolved_file="$1"
    if [[ ! -s "$resolved_file" ]]; then
        log_warn "No installable packages found. Nothing to install."
        return 0
    fi

    if [[ "${EUID}" -eq 0 ]]; then
        xargs -a "$resolved_file" apt install -y
    else
        xargs -a "$resolved_file" sudo apt install -y
    fi
}

main() {
    require_cmd sed
    require_cmd awk
    require_cmd xargs
    require_cmd apt-cache
    require_cmd sort
    require_cmd comm

    require_root_or_sudo

    local list_file="${1:-./manual-packages.list}"
    if [[ ! -f "$list_file" ]]; then
        log_error "List file not found: $list_file"
        log_error "Usage: $0 [list_file]"
        exit 1
    fi

    local ts
    ts="$(date +%Y%m%d_%H%M%S)"

    local base_dir
    base_dir="$(cd "$(dirname "$list_file")" && pwd)"

    local resolved_file="${base_dir}/manual-packages.resolved.${ts}.list"
    local missing_file="${base_dir}/manual-packages.missing.${ts}.list"
    local all_file="${base_dir}/manual-packages.all.${ts}.list"
    local log_file="${base_dir}/manual-packages.install.${ts}.log"

    log_info "List file      : $list_file"
    log_info "Resolved file  : $resolved_file"
    log_info "Missing file   : $missing_file"
    log_info "Install log    : $log_file"

    # 1) Normalize list:
    # - remove comments (# ...)
    # - trim spaces
    # - remove empty lines
    # - unique sort
    sed -e 's/#.*$//' -e 's/^[[:space:]]*//;s/[[:space:]]*$//' "$list_file" \
    | sed '/^[[:space:]]*$/d' \
    | sort -u > "$all_file"

    log_info "Total packages in list (after cleanup): $(wc -l < "$all_file" | tr -d ' ')"

    # 2) apt update (to make cache fresh)
    log_info "Running apt update..."
    run_apt_update >>"$log_file" 2>&1

    # 3) Filter installable packages using apt-cache show
    log_info "Filtering installable packages for this OS..."
    : > "$resolved_file"
    : > "$missing_file"

    while IFS= read -r pkg; do
        if apt-cache show "$pkg" >/dev/null 2>&1; then
            echo "$pkg" >> "$resolved_file"
        else
            echo "$pkg" >> "$missing_file"
        fi
    done < "$all_file"

    log_info "Installable: $(wc -l < "$resolved_file" | tr -d ' ')"
    log_info "Missing    : $(wc -l < "$missing_file" | tr -d ' ')"

    # 4) Install resolved packages
    log_info "Installing installable packages..."
    run_apt_install "$resolved_file" >>"$log_file" 2>&1

    log_info "Done."
    log_info "Tip: check install log -> $log_file"
}

main "$@"
