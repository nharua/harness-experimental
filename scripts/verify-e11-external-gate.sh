#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: $0 <US-093|US-094|US-095|US-096> [receipt.json]" >&2
  exit 2
}

[[ $# -ge 1 && $# -le 2 ]] || usage
story_id=$1
case "$story_id" in
  US-093|US-094|US-095|US-096) ;;
  *) echo "error: unsupported E11 external story: $story_id" >&2; exit 2 ;;
esac

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
receipt=${2:-"$repo_root/docs/provenance/e11-receipts/$story_id.json"}
checksum_file="${receipt}.sha256"

fail() {
  echo "error: E11 receipt gate failed for $story_id: $*" >&2
  exit 1
}

command -v jq >/dev/null 2>&1 || fail "jq is required"
[[ -f "$receipt" ]] || fail "receipt is missing: $receipt"
[[ -f "$checksum_file" ]] || fail "checksum sidecar is missing: $checksum_file"

expected=$(awk 'NF && $1 !~ /^#/ {print $1; exit}' "$checksum_file")
[[ "$expected" =~ ^[0-9a-f]{64}$ ]] || fail "checksum sidecar must begin with one lowercase SHA-256"
actual=$(shasum -a 256 "$receipt" | awk '{print $1}')
[[ "$actual" == "$expected" ]] || fail "receipt checksum mismatch"

if [[ ${E11_GATE_ALLOW_UNTRACKED_FIXTURE:-0} != 1 ]]; then
  receipt_rel=${receipt#"$repo_root"/}
  checksum_rel=${checksum_file#"$repo_root"/}
  [[ "$receipt_rel" != "$receipt" ]] || fail "receipt must be inside repository-harness"
  git -C "$repo_root" ls-files --error-unmatch -- "$receipt_rel" >/dev/null 2>&1 \
    || fail "receipt must be committed before proxy completion"
  git -C "$repo_root" ls-files --error-unmatch -- "$checksum_rel" >/dev/null 2>&1 \
    || fail "checksum sidecar must be committed before proxy completion"
fi

jq -e --arg story "$story_id" '
  type == "object" and
  .version == 1 and
  .story_id == $story and
  .target_repository == "git@github.com:hoangnb24/symphony.git" and
  (.target_commit | type == "string" and test("^[0-9a-f]{40}$")) and
  .protocol_tag == "harness-cli-v0.1.14" and
  (.validation_run | type == "string" and length > 0) and
  (.completed_at | type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$")) and
  (.owner_attestation | type == "object") and
  .owner_attestation.type == "reviewed-git-commit" and
  .owner_attestation.repository == .target_repository and
  .owner_attestation.commit == .target_commit and
  (.owner_attestation.reviewed_by | type == "string" and length > 0) and
  (.owner_attestation.reviewed_at | type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$")) and
  (.release == null or (
    .release.tag | type == "string" and length > 0 and
    .release.manifest_sha256 | type == "string" and test("^[0-9a-f]{64}$")
  ))
' "$receipt" >/dev/null || fail "receipt schema, identity, protocol, or owner attestation is invalid"

echo "E11 external receipt verified: $story_id ($actual)"
