#!/usr/bin/env bash
# Check GitHub releases and bump Homebrew formula versions and sha256 checksums.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
FORMULA_DIR="${REPO_ROOT}/Formula"

usage() {
  cat <<'EOF'
Usage: bump-up-version.sh [formula...]

Check the latest GitHub release for each Homebrew formula and bump
version and sha256 checksums when a newer release exists.

With no arguments, all formulas in Formula/ are checked.
Arguments are formula names, for example:
  ./scripts/bump-up-version.sh
  ./scripts/bump-up-version.sh picsum
  ./scripts/bump-up-version.sh picsum json2table

Environment:
  GITHUB_TOKEN   Optional GitHub API token. In GitHub Actions this is
                 provided automatically. Locally, gh auth token is used
                 when available.
EOF
}

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required command not found: $1" >&2
    exit 1
  fi
}

normalize_formula_name() {
  local name="$1"
  name="${name#Formula/}"
  name="${name%.rb}"
  printf '%s\n' "$name"
}

list_all_formulas() {
  local file
  shopt -s nullglob
  for file in "${FORMULA_DIR}"/*.rb; do
    basename "${file}" .rb
  done
  shopt -u nullglob
}

formula_field() {
  local file="$1"
  local field="$2"
  python3 -c '
import re, sys
path, field = sys.argv[1], sys.argv[2]
pattern = re.compile(rf"^\s*{re.escape(field)}\s+\"([^\"]+)\"")
with open(path, encoding="utf-8") as handle:
    for line in handle:
        match = pattern.match(line)
        if match:
            print(match.group(1))
            sys.exit(0)
sys.exit(1)
' "${file}" "${field}"
}

github_repo_from_homepage() {
  python3 -c '
import re, sys
homepage = sys.argv[1].rstrip("/")
if homepage.endswith(".git"):
    homepage = homepage[:-4]
match = re.search(r"github\.com[:/]([^/]+)/([^/]+)$", homepage)
if not match:
    sys.exit(1)
print(f"{match.group(1)}/{match.group(2)}")
' "$1"
}

strip_version_prefix() {
  local tag="$1"
  if [[ "${tag}" =~ ^v[0-9] ]]; then
    printf '%s\n' "${tag:1}"
  else
    printf '%s\n' "${tag}"
  fi
}

is_newer_version() {
  local current="$1"
  local latest="$2"
  if [[ "${current}" == "${latest}" ]]; then
    return 1
  fi
  local first
  first="$(printf '%s\n%s\n' "${current}" "${latest}" | sort -V | head -n1)"
  [[ "${first}" == "${current}" ]]
}

github_request() {
  local url="$1"
  local out="$2"
  curl -sS -L --retry 3 --retry-delay 1 \
    -o "${out}" -w '%{http_code}' \
    "${CURL_HEADERS[@]}" \
    "${url}"
}

sha256_of_url() {
  local url="$1"
  local tmp="${WORKDIR}/download"
  echo "    downloading $(basename "${url}")" >&2
  curl -fsSL --retry 3 --retry-delay 1 -o "${tmp}" "${url}"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "${tmp}" | awk '{print $1}'
  else
    shasum -a 256 "${tmp}" | awk '{print $1}'
  fi
}

sha256_for_asset() {
  local release_json="$1"
  local url="$2"
  local status=0
  local digest=""

  set +e
  digest="$(
    python3 -c '
import json, sys
path, url = sys.argv[1], sys.argv[2]
data = json.load(open(path, encoding="utf-8"))
for asset in data.get("assets") or []:
    if asset.get("browser_download_url") != url:
        continue
    digest = (asset.get("digest") or "").strip()
    if digest.lower().startswith("sha256:"):
        print(digest.split(":", 1)[1])
        sys.exit(0)
    sys.exit(2)
sys.exit(1)
' "${release_json}" "${url}"
  )"
  status=$?
  set -e

  case "${status}" in
    0)
      printf '%s\n' "${digest}"
      ;;
    2)
      sha256_of_url "${url}"
      ;;
    *)
      return 1
      ;;
  esac
}

formula_urls() {
  python3 -c '
import re, sys
pattern = re.compile(r"url\s+\"([^\"]+)\"")
with open(sys.argv[1], encoding="utf-8") as handle:
    for line in handle:
        match = pattern.search(line)
        if match:
            print(match.group(1))
' "$1"
}

update_formula_file() {
  local file="$1"
  local new_version="$2"
  local map_json="$3"
  python3 -c '
import json, re, sys

path, new_version, map_path = sys.argv[1], sys.argv[2], sys.argv[3]
sha_by_url = json.load(open(map_path, encoding="utf-8"))

version_re = re.compile(r"^(\s*version\s+\")[^\"]+(\".*)$")
url_re = re.compile(r"url\s+\"([^\"]+)\"")
sha_re = re.compile(r"^(\s*sha256\s+\")[0-9a-fA-F]+(\".*)$")

with open(path, encoding="utf-8") as handle:
    lines = handle.readlines()

pending_url = None
version_replaced = False
out = []

for line in lines:
    newline = "\n" if line.endswith("\n") else ""
    body = line[:-1] if newline else line

    if not version_replaced:
        match = version_re.match(body)
        if match:
            out.append(f"{match.group(1)}{new_version}{match.group(2)}{newline}")
            version_replaced = True
            continue

    url_match = url_re.search(body)
    if url_match:
        pending_url = url_match.group(1).replace("#{version}", new_version)
        out.append(line)
        continue

    sha_match = sha_re.match(body)
    if sha_match and pending_url:
        if pending_url not in sha_by_url:
            raise SystemExit(f"missing sha256 for {pending_url}")
        out.append(f"{sha_match.group(1)}{sha_by_url[pending_url]}{sha_match.group(2)}{newline}")
        pending_url = None
        continue

    out.append(line)

with open(path, "w", encoding="utf-8", newline="") as handle:
    handle.writelines(out)
' "${file}" "${new_version}" "${map_json}"
}

print_api_error() {
  local file="$1"
  python3 -c '
import json, sys
path = sys.argv[1]
try:
    data = json.load(open(path, encoding="utf-8"))
    message = data.get("message")
    if message:
        print(f"    {message}", file=sys.stderr)
except Exception:
    pass
' "${file}"
}

latest_release_json() {
  local repo="$1"
  local out="$2"
  local code

  code="$(github_request "https://api.github.com/repos/${repo}/releases/latest" "${out}")"
  if [[ "${code}" == "200" ]]; then
    return 0
  fi
  if [[ "${code}" != "404" ]]; then
    echo "    error: GitHub API ${code} for ${repo} releases/latest" >&2
    print_api_error "${out}"
    return 1
  fi

  local tags_json="${WORKDIR}/tags.json"
  code="$(github_request "https://api.github.com/repos/${repo}/tags?per_page=1" "${tags_json}")"
  if [[ "${code}" != "200" ]]; then
    echo "    error: GitHub API ${code} for ${repo} tags" >&2
    print_api_error "${tags_json}"
    return 1
  fi
  python3 -c '
import json, sys
tags_path, out_path = sys.argv[1], sys.argv[2]
tags = json.load(open(tags_path, encoding="utf-8"))
if not tags:
    raise SystemExit("no git tags found")
payload = {"tag_name": tags[0]["name"], "assets": []}
with open(out_path, "w", encoding="utf-8") as handle:
    json.dump(payload, handle)
' "${tags_json}" "${out}"
}

bump_formula() {
  local name="$1"
  local file="${FORMULA_DIR}/${name}.rb"

  echo "==> ${name}"

  if [[ ! -f "${file}" ]]; then
    echo "    error: formula not found: ${file}"
    return 1
  fi

  local homepage current repo
  homepage="$(formula_field "${file}" homepage)"
  current="$(formula_field "${file}" version)"
  if [[ -z "${homepage}" || -z "${current}" ]]; then
    echo "    error: could not read homepage/version from ${file}"
    return 1
  fi

  if ! repo="$(github_repo_from_homepage "${homepage}")"; then
    echo "    error: homepage is not a GitHub repo: ${homepage}"
    return 1
  fi

  echo "    github:  ${repo}"
  echo "    current: ${current}"

  local release_json="${WORKDIR}/${name}.json"
  if ! latest_release_json "${repo}" "${release_json}"; then
    return 1
  fi

  local tag latest
  tag="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8"))["tag_name"])' "${release_json}")"
  latest="$(strip_version_prefix "${tag}")"
  echo "    latest:  ${latest} (tag ${tag})"

  if ! is_newer_version "${current}" "${latest}"; then
    echo "    already up to date"
    return 0
  fi

  local url_template url sha
  local map_json="${WORKDIR}/${name}-sha.json"
  : > "${WORKDIR}/${name}-sha.tsv"

  while IFS= read -r url_template; do
    [[ -z "${url_template}" ]] && continue
    url="${url_template//\#\{version\}/${latest}}"
    if ! sha="$(sha256_for_asset "${release_json}" "${url}")"; then
      echo "    error: no release asset for ${url}"
      return 1
    fi
    echo "    sha256 $(basename "${url}") ${sha}"
    printf '%s\t%s\n' "${url}" "${sha}" >> "${WORKDIR}/${name}-sha.tsv"
  done < <(formula_urls "${file}")

  python3 -c '
import json, sys
tsv_path, out_path = sys.argv[1], sys.argv[2]
mapping = {}
with open(tsv_path, encoding="utf-8") as handle:
    for line in handle:
        line = line.rstrip("\n")
        if not line:
            continue
        url, sha = line.split("\t", 1)
        mapping[url] = sha
with open(out_path, "w", encoding="utf-8") as handle:
    json.dump(mapping, handle)
' "${WORKDIR}/${name}-sha.tsv" "${map_json}"

  update_formula_file "${file}" "${latest}" "${map_json}"
  echo "    bumped ${current} -> ${latest}"
  BUMPED_LINES+=("${name} ${current} -> ${latest}")
}

need_cmd curl
need_cmd python3

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ -z "${GITHUB_TOKEN:-}" && -z "${GH_TOKEN:-}" ]] && command -v gh >/dev/null 2>&1; then
  GITHUB_TOKEN="$(gh auth token 2>/dev/null || true)"
fi
GITHUB_TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-}}"

CURL_HEADERS=(
  -H "Accept: application/vnd.github+json"
  -H "X-GitHub-Api-Version: 2022-11-28"
  -H "User-Agent: siakhooi-homebrew-tap-bump"
)
if [[ -n "${GITHUB_TOKEN}" ]]; then
  CURL_HEADERS+=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
fi

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/bump-up-version.XXXXXX")"
trap 'rm -rf "${WORKDIR}"' EXIT

names=()
if [[ "$#" -eq 0 ]]; then
  while IFS= read -r name; do
    names+=("${name}")
  done < <(list_all_formulas)
else
  for arg in "$@"; do
    [[ -z "${arg}" ]] && continue
    names+=("$(normalize_formula_name "${arg}")")
  done
fi

if [[ "${#names[@]}" -eq 0 ]]; then
  echo "error: no formulas found in ${FORMULA_DIR}" >&2
  exit 1
fi

BUMPED_LINES=()
failed=0
for name in "${names[@]}"; do
  if ! bump_formula "${name}"; then
    failed=1
  fi
done

echo
if [[ "${#BUMPED_LINES[@]}" -gt 0 ]]; then
  echo "Updated:"
  for line in "${BUMPED_LINES[@]}"; do
    echo "  ${line}"
  done
elif [[ "${failed}" -eq 0 ]]; then
  echo "No formula versions to bump."
else
  echo "No formulas were updated; one or more checks failed."
fi

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  if [[ "${#BUMPED_LINES[@]}" -gt 0 ]]; then
    {
      echo "changed=true"
      echo "summary<<EOF"
      printf '%s\n' "${BUMPED_LINES[@]}"
      echo "EOF"
    } >> "${GITHUB_OUTPUT}"
  else
    echo "changed=false" >> "${GITHUB_OUTPUT}"
  fi
fi

exit "${failed}"
