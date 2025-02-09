#!/bin/ash

LOCK_DIR="/var/run/backup"
mkdir -p "$LOCK_DIR"

# Usage: acquire_lock lockname
# Returns: 0 if lock acquired, 1 if already locked
acquire_lock() {
    local LOCK_FILE="$LOCK_DIR/$1.lock"

    # Check if process in lock file still exists
    if [ -f "$LOCK_FILE" ]; then
        local PID=$(cat "$LOCK_FILE")
        if [ -d "/proc/$PID" ]; then
            return 1
        fi
        # Process no longer exists, remove stale lock
        rm -f "$LOCK_FILE"
    fi

    # Create lock file with current PID
    echo $$ >"$LOCK_FILE"
    return 0
}

# Usage: release_lock lockname
release_lock() {
    local LOCK_FILE="$LOCK_DIR/$1.lock"
    rm -f "$LOCK_FILE"
}
