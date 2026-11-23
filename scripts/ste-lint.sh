#!/usr/bin/env bash
# ASD-STE100 gate for the prose of this repository: every tracked AGENTS.md, README.md and docs/**/*.md passes
# ste-lint.py (github.com/danyuchn/asd-ste100-skill, scripts/ste-lint.py) with zero hard findings.
# Hard findings: semicolons, sentences over 25 words, phrasal verbs, nominalizations, marketing adjectives,
# synonym rotation and list items that end in "and" or "or". Passive voice and compound tenses are advisory.
# The linter skips fenced code, code spans, links and URLs itself, so nothing else is excluded for parsing.
# The linter is fetched at a pinned commit and checked by SHA-256 before it runs.
# Usage: ste-lint.sh [FILE...]. With no FILE it lints every tracked document the gate covers.
set -euo pipefail

readonly rev=65c8ab6ef5fcb3619c8e6daca43e68627f3d7b4a
readonly sum=66c454b94dea0f81334f36b222775b62b6ec24e25c0e62308f23c550ef3eaa3d
readonly url="https://raw.githubusercontent.com/danyuchn/asd-ste100-skill/${rev}/scripts/ste-lint.py"
cache="${XDG_CACHE_HOME:-${HOME}/.cache}/ste-lint/${rev}"
lint="${cache}/ste-lint.py"

digest() {
	if command -v sha256sum >/dev/null; then
		sha256sum "$1" | cut -d' ' -f1
	else
		shasum -a 256 "$1" | cut -d' ' -f1
	fi
}

have=""
if [[ -f ${lint} ]]; then
	have="$(digest "${lint}")"
fi
if [[ ${have} != "${sum}" ]]; then
	mkdir -p "${cache}"
	curl -fsSL -o "${lint}.part" "${url}"
	got="$(digest "${lint}.part")"
	if [[ ${got} != "${sum}" ]]; then
		echo "ste-lint.py at ${rev}: SHA-256 ${got}, expected ${sum}" >&2
		exit 2
	fi
	mv "${lint}.part" "${lint}"
fi

# The linter's own tests run first, so a broken linter never passes a document.
python3 -I "${lint}" --selftest >/dev/null

excluded=()

if (($# > 0)); then
	python3 -I "${lint}" "$@"
else
	git ls-files -z -- ':(glob)**/AGENTS.md' ':(glob)**/README.md' ':(glob)**/docs/**/*.md' ${excluded[@]+"${excluded[@]}"} |
		xargs -0 python3 -I "${lint}"
fi
