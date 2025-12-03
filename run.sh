#! /bin/bash

# run.sh: run Byzzfuzz runs in a loop
# Usage: ./run.sh [N]
# Defaults: N=300

n=${1:-300}

# Prefer gtimeout (mac coreutils) if available, otherwise use GNU timeout (Linux).
# Both support the --foreground flag; if neither is present, exit with an error.
if command -v gtimeout >/dev/null 2>&1; then
    TIMEOUT_CMD="gtimeout --foreground"
elif command -v timeout >/dev/null 2>&1; then
    TIMEOUT_CMD="timeout --foreground"
else
    echo "ERROR: neither 'gtimeout' nor 'timeout' found in PATH.\n\t- On mac: install coreutils (brew install coreutils) which provides 'gtimeout'\n\t- On Linux: ensure 'timeout' (coreutils) is available." >&2
    exit 1
fi

# 构建，并将输出隐藏只在报错的时候打印
cargo build -p rust-ripple-p2p >/dev/null 2>&1 

# Create a single run-level timestamp folder name (e.g., 2025_11_22_17h35m) and export it
RUN_TS=$(date +"%Y_%m_%d_%Hh%Mm")
export RUN_TS

for ((i=0; i<$n; i++))
do
    # # ensure no leftover
    # docker rm byzzfuzz || true

    # # start container detached so we can periodically copy traces while it's running
    # docker run -v /var/run/docker.sock:/var/run/docker.sock -d --init --net host --name byzzfuzz byzzfuzz

    # # prepare local folder for this run
    # run_dir="traces/run_${i}"
    # mkdir -p "$run_dir"

    # # background copier: while container exists, copy /home/traces out every 5s
    # (
    #     while docker ps -q -f name=byzzfuzz >/dev/null 2>&1; do
    #         ts=$(date +%s)
    #         # copy into a timestamped subfolder to keep intermediate snapshots
    #         docker cp byzzfuzz:/home/traces "$run_dir/traces_${ts}" >/dev/null 2>&1 || true
    #         sleep 5
    #     done
    # ) &

    # COPIER_PID=$!

    # # wait for container to finish, with timeout
    # # docker wait blocks until container stops; wrap with timeout command
    # $TIMEOUT_CMD 25m docker wait byzzfuzz || true

    # # final copy (ensure we have the last traces)
    # docker cp byzzfuzz:/home/traces "$run_dir/traces_final" >/dev/null 2>&1 || true

    # # cleanup: stop/remove container and wait for copier to exit
    # docker rm -f byzzfuzz || true
    # # give copier a moment to detect container gone and exit
    # wait $COPIER_PID 2>/dev/null || true
	# export RUST_BACKTRACE=1
    cargo run -q -p rust-ripple-p2p -- --toxiproxy-path ./toxiproxy-server
done
