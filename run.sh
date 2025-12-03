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

for ((i=0; i<$n; i++))
do
    docker rm byzzfuzz || true && \
    $TIMEOUT_CMD 25m docker run -v /var/run/docker.sock:/var/run/docker.sock -i --init --net host --name byzzfuzz byzzfuzz && \
    docker cp byzzfuzz:/home/traces . && \
    docker rm byzzfuzz
done
