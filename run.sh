#!/bin/bash
set -euo pipefail

readonly PID_FILE="microsocks.pid"
readonly LOG_FILE="microsocks.log"
readonly URL_FILE="microsocks.url"
readonly PROG="./microsocks"

build() {
    echo "Building microsocks..."
    make || { echo "Build failed" >&2; exit 1; }
    if [[ ! -x "$PROG" ]]; then
        echo "Error: microsocks binary not found or not executable." >&2
        exit 1
    fi
}

is_running() {
    if [[ -f "$PID_FILE" ]]; then
        local pid
        pid=$(<"$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

start() {
    if is_running; then
        echo "microsocks is already running (PID: $(<"$PID_FILE"))."
        return 0
    fi

    build

    local user=""
    local pass=""
    local extra_args=()

    while getopts "u:p:" opt; do
        case "${opt}" in
            u) user="${OPTARG}" ;;
            p) pass="${OPTARG}" ;;
            *) break ;;
        esac
    done
    shift $((OPTIND-1))
    extra_args=("$@")

    local args=()
    if [[ -n "$user" ]] && [[ -n "$pass" ]]; then
        args+=("-u" "$user" "-P" "$pass")
    elif [[ -n "$user" ]] || [[ -n "$pass" ]]; then
        echo "Error: Both username and password must be provided for authentication." >&2
        exit 2
    fi
    args+=("${extra_args[@]}")

    # Extract port and listen IP for the message
    local port="1080"
    local listen_ip="0.0.0.0"
    local i=0
    while [[ $i -lt ${#extra_args[@]} ]]; do
        if [[ "${extra_args[$i]}" == "-p" ]]; then
            port="${extra_args[$((i+1))]}"
        elif [[ "${extra_args[$i]}" == "-i" ]]; then
            listen_ip="${extra_args[$((i+1))]}"
        fi
        ((i++))
    done

    if [[ "$listen_ip" == "0.0.0.0" ]]; then
        listen_ip=$(hostname -I | awk '{print $1}')
    fi

    echo "Starting microsocks in background..."
    nohup "$PROG" "${args[@]}" > "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
    
    local url="socks5h://"
    if [[ -n "$user" ]]; then
        url+="${user}:${pass}@"
    fi
    url+="${listen_ip}:${port}"

    echo "$url" > "$URL_FILE"
    echo "microsocks started (PID: $!, Log: $LOG_FILE)"
    echo "Connection URL: $url"
}

stop() {
    if ! is_running; then
        echo "microsocks is not running."
        [[ -f "$PID_FILE" ]] && rm "$PID_FILE"
        return 0
    fi

    local pid
    pid=$(<"$PID_FILE")
    echo "Stopping microsocks (PID: $pid)..."
    kill "$pid"
    
    # Wait for process to exit
    local timeout=5
    while kill -0 "$pid" 2>/dev/null && [[ $timeout -gt 0 ]]; do
        sleep 1
        ((timeout--))
    done

    if kill -0 "$pid" 2>/dev/null; then
        echo "Forcing stop..."
        kill -9 "$pid"
    fi

    rm -f "$PID_FILE" "$URL_FILE"
    echo "microsocks stopped."
}

status() {
    if is_running; then
        echo "microsocks is running (PID: $(<"$PID_FILE"))."
        if [[ -f "$URL_FILE" ]]; then
            echo "Connection URL: $(<"$URL_FILE")"
        fi
        echo "Last 5 lines of log:"
        tail -n 5 "$LOG_FILE"
    else
        echo "microsocks is not running."
    fi
}

usage() {
    echo "Usage: $0 {start|stop|status} [options]"
    echo "Options for start:"
    echo "  -u <user>     Username for authentication"
    echo "  -p <pass>     Password for authentication"
    echo "  [extra_args]  Any other microsocks arguments"
    exit 2
}

[[ $# -lt 1 ]] && usage

COMMAND="$1"
shift

case "$COMMAND" in
    start)  start "$@" ;;
    stop)   stop ;;
    status) status ;;
    *)      usage ;;
esac
