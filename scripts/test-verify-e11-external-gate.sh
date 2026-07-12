#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
verifier="$repo_root/scripts/verify-e11-external-gate.sh"
temp=$(mktemp -d)
trap 'rm -rf "$temp"' EXIT

write_valid() {
  local path=$1
  cat >"$path" <<'JSON'
{"version":1,"story_id":"US-093","target_repository":"git@github.com:hoangnb24/symphony.git","target_commit":"1111111111111111111111111111111111111111","protocol_tag":"harness-cli-v0.1.14","validation_run":"local-us093-fixture","completed_at":"2026-07-12T00:00:00Z","owner_attestation":{"type":"reviewed-git-commit","repository":"git@github.com:hoangnb24/symphony.git","commit":"1111111111111111111111111111111111111111","reviewed_by":"fixture-owner","reviewed_at":"2026-07-12T00:00:00Z"},"release":null}
JSON
  shasum -a 256 "$path" >"$path.sha256"
}

expect_failure() {
  local name=$1
  shift
  if E11_GATE_ALLOW_UNTRACKED_FIXTURE=1 "$verifier" "$@" >/dev/null 2>&1; then
    echo "error: negative fixture passed: $name" >&2
    exit 1
  fi
}

valid="$temp/valid.json"
write_valid "$valid"
E11_GATE_ALLOW_UNTRACKED_FIXTURE=1 "$verifier" US-093 "$valid" >/dev/null

cp "$valid" "$temp/tampered.json"
cp "$valid.sha256" "$temp/tampered.json.sha256"
printf ' ' >>"$temp/tampered.json"
expect_failure tampered-checksum US-093 "$temp/tampered.json"

wrong_story="$temp/wrong-story.json"
write_valid "$wrong_story"
expect_failure wrong-story US-094 "$wrong_story"

old_protocol="$temp/old-protocol.json"
write_valid "$old_protocol"
jq '.protocol_tag="harness-cli-v0.1.11"' "$old_protocol" >"$old_protocol.tmp"
mv "$old_protocol.tmp" "$old_protocol"
shasum -a 256 "$old_protocol" >"$old_protocol.sha256"
expect_failure old-protocol US-093 "$old_protocol"

bad_attestation="$temp/bad-attestation.json"
write_valid "$bad_attestation"
jq '.owner_attestation.commit="2222222222222222222222222222222222222222"' "$bad_attestation" >"$bad_attestation.tmp"
mv "$bad_attestation.tmp" "$bad_attestation"
shasum -a 256 "$bad_attestation" >"$bad_attestation.sha256"
expect_failure bad-attestation US-093 "$bad_attestation"

rm "$valid.sha256"
expect_failure missing-sidecar US-093 "$valid"

echo "E11 external gate fixtures passed"
