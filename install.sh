#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p ~/.claude/rules ~/.claude/skills
cp -Rv rules/. ~/.claude/rules/
cp -Rv skills/. ~/.claude/skills/

if command -v claude >/dev/null; then
  claude plugin marketplace add DietrichGebert/ponytail || true
  claude plugin install ponytail@ponytail || true
else
  echo "claude CLI not found — skipping plugin install"
fi

echo "Done. Rules, skills and plugins installed."
