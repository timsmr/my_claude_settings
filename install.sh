#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

python3 build.py

# Global rules — Claude Code is the only harness with user-level path-scoped rules.
mkdir -p ~/.claude/rules
cp -R dist/claude/rules/. ~/.claude/rules/

# Global instructions for harnesses that read AGENTS.md at user level.
mkdir -p ~/.codex ~/.config/opencode ~/.gemini
cp dist/AGENTS.md ~/.codex/AGENTS.md
cp dist/AGENTS.md ~/.config/opencode/AGENTS.md
cp dist/AGENTS.md ~/.gemini/GEMINI.md

# Copilot user-level instructions.
mkdir -p ~/.copilot/instructions
cp dist/copilot/instructions/*.md ~/.copilot/instructions/

# Skills: symlink into both conventions — ~/.claude/skills (Claude Code, opencode)
# and ~/.agents/skills (Codex, Zed, Warp, Cline). A git pull updates them all.
mkdir -p ~/.claude/skills ~/.agents/skills
for skill in skills/*/; do
  name=$(basename "$skill")
  for dest in ~/.claude/skills ~/.agents/skills; do
    [ -e "$dest/$name" ] && [ ! -L "$dest/$name" ] && rm -rf "${dest:?}/$name"
    ln -sfn "$(pwd)/$skill" "$dest/$name"
  done
done

if command -v claude >/dev/null; then
  claude plugin marketplace add DietrichGebert/ponytail || true
  claude plugin install ponytail@ponytail || true
fi

cat <<'EOF'

Installed globally: rules (Claude), AGENTS.md (Codex/opencode/Gemini),
instructions (Copilot), skills (symlinked into ~/.claude/skills + ~/.agents/skills).

Per-project, run from the project root:
  cp -R <this-repo>/dist/cursor/rules/.   .cursor/rules/
  cp -R <this-repo>/dist/windsurf/rules/. .windsurf/rules/
  cp    <this-repo>/dist/AGENTS.md        ./AGENTS.md

Cursor's user-level rules live in its Settings UI and cannot be installed from a file.
EOF
