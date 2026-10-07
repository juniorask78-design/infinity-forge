#!/usr/bin/env bash
# Validate the frozen server image only. No push, export, deployment or proxy changes.
set -Eeuo pipefail
server_dir="$(realpath "${1:?Usage: validate_linux_server.sh SERVER_DIR TEST_DIR OUTPUT_DIR}")"
test_dir="$(realpath "${2:?Missing TEST_DIR}")"
mkdir -p "${3:?Missing OUTPUT_DIR}"
output="$(realpath "$3")"
helper="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/linux_server_identity.py"
image="infinity-forge-linux-validation:${GITHUB_RUN_ID:-local}-$$"
container="infinity-forge-linux-validation-${GITHUB_RUN_ID:-local}-$$"
stage="preflight"
created=0
linux_executed=false
cleanup() {
    code=$?
    trap - EXIT
    set +e
    docker rm -f "$container-e2e_test" "$container-online_e2e" >/dev/null 2>&1
    if ((created)); then
        docker logs "$container" >"$output/server.log" 2>&1
        docker inspect "$container" >"$output/container-before-stop.json"
        timeout 30s docker stop --time 10 "$container" >"$output/stop.log" 2>&1
        docker inspect "$container" >"$output/container-after-stop.json"
        docker rm "$container" >/dev/null 2>&1
    fi
    printf '{"exit_code":%d,"last_stage":"%s","linux_executed":%s}\n' "$code" "$stage" "$linux_executed" >"$output/result.json"
    printf 'Validation exit=%s stage=%s\n' "$code" "$stage"
    [[ ! -f "$output/server.log" ]] || cat "$output/server.log"
    exit "$code"
}
trap cleanup EXIT
for command in docker python3 sha256sum timeout realpath; do command -v "$command" >/dev/null; done
[[ "$(uname -s)" == Linux ]] || { echo 'This validation requires Linux.' >&2; exit 1; }
linux_executed=true
docker version >"$output/docker-version.txt"
uname -a >"$output/linux.txt"
# Verify the exact prepared artifacts; no re-export and no hidden Dockerfile adaptation.
printf '%s  %s\n' \
  4db53e7919a467fd7c5d152e5b255f39d0278be3a499ea4421afe95dbb495a7e "$server_dir/Dockerfile" \
  613033fe5f942837db902c62666d6a6f44ec4a28220b25e4c91034ea78f45c03 "$server_dir/infinity_forge_server.pck" \
  c77a132d0111fb082e8d0061532f973c0ff1d09075e925c86f0fc0a27b7328da "$test_dir/e2e_test.gd" \
  2901d688be66a4b66ddc421da908616698ccd6312469a26726496328fb03b8ef "$test_dir/online_e2e.gd" \
  | sha256sum --check | tee "$output/input-hashes.txt"
stage="docker-build"
timeout 600s docker build --pull -t "$image" -f "$server_dir/Dockerfile" "$server_dir" 2>&1 | tee "$output/build.log"
docker image inspect "$image" >"$output/image.json"
stage="runtime-user-and-libraries"
uid="$(timeout 30s docker run --rm --network none --entrypoint /usr/bin/id "$image" -u)"
printf '%s\n' "$uid" | tee "$output/uid.txt"
[[ "$uid" =~ ^[0-9]+$ && "$uid" != 0 ]] || { echo 'Container default user is root or invalid.' >&2; exit 1; }
timeout 30s docker run --rm --network none --entrypoint /usr/bin/ldd "$image" /usr/local/bin/godot 2>&1 | tee "$output/ldd.txt"
if grep -q 'not found' "$output/ldd.txt"; then echo 'Missing Linux runtime library.' >&2; exit 1; fi
stage="container-start"
created=1
timeout 30s docker run -d --name "$container" --env PORT=10000 -p 127.0.0.1:10000:10000 "$image" | tee "$output/container-id.txt"
stage="health-and-welcome"
timeout 90s python3 "$helper" "$output/identity.json" --wait-seconds 60 | tee "$output/identity.log"
# On Ubuntu, host networking reaches only the local validation service at loopback.
# Each external test loads core/net and the class registry from the frozen pack.
for test in e2e_test online_e2e; do
    stage="$test"
    timeout 150s docker run --rm --name "$container-$test" --network host \
      --mount "type=bind,src=$test_dir,dst=/checks,readonly" \
      --entrypoint /usr/local/bin/godot "$image" \
      --headless --main-pack /app/infinity_forge_server.pck \
      -s "/checks/$test.gd" -- --url ws://127.0.0.1:10000 \
      2>&1 | tee "$output/$test.log"
    grep -q 'RÉUSSI :' "$output/$test.log"
done
stage="complete"
echo 'Frozen Linux image, non-root user, ldd, health/welcome and both external tests passed.'
