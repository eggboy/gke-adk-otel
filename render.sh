#!/bin/sh
# Render the k8s manifests by replacing ${VAR} placeholders with values from ./.env.
#
# Needs only POSIX sh + awk, which are preinstalled on macOS and every Linux
# (including BusyBox/Alpine), so there is no envsubst/gettext dependency.
#
#   ./render.sh | kubectl apply -f -     # deploy
#   ./render.sh > k8s/rendered.yaml      # inspect first (file is git-ignored)
#
# Unset or empty variables are an error: the script exits non-zero and prints
# nothing, so a partial manifest is never piped into kubectl.
set -eu
cd "$(dirname "$0")"

if [ ! -f .env ]; then
  echo "error: .env not found. Run: cp .env.example .env   (then edit it)" >&2
  exit 1
fi

set -a
# .env is user-created and git-ignored, so ShellCheck cannot follow it.
# shellcheck source=/dev/null
. ./.env
set +a

render() {
  awk '{
    out = ""
    while (match($0, /[$][{][A-Za-z_][A-Za-z0-9_]*[}]/)) {
      name = substr($0, RSTART + 2, RLENGTH - 3)
      if (!(name in ENVIRON) || ENVIRON[name] == "") {
        printf "error: %s is not set in .env (needed by %s)\n", name, FILENAME > "/dev/stderr"
        exit 1
      }
      out = out substr($0, 1, RSTART - 1) ENVIRON[name]
      $0 = substr($0, RSTART + RLENGTH)
    }
    print out $0
  }' "$1"
}

# Render everything into memory first; only print once every file succeeded.
rendered=$(
  for f in k8s/instrumentation.yaml k8s/deployment.yaml; do
    echo "---"
    render "$f" || exit 1
  done
)

printf '%s\n' "$rendered"
