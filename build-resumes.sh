#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LATEX_DIR="$SCRIPT_DIR/latex"
readonly BASE_NAME="kiron_sukesan_resume"
readonly OUTPUT_ROOT="$SCRIPT_DIR/resumepdfs/$(date +%Y)"

temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/resume-build.XXXXXX")"
trap 'rm -rf "$temporary_root"' EXIT

usage() {
  cat <<EOF
Usage: $(basename "$0") [suffix]

Build every resume, or only the resume matching the given suffix.

Examples:
  $(basename "$0")
  $(basename "$0") phd
  $(basename "$0") tech
EOF
}

if [[ $# -gt 1 ]]; then
  usage >&2
  exit 2
fi

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -eq 1 ]]; then
  if [[ ! $1 =~ ^[[:alnum:]_-]+$ ]]; then
    echo "Invalid resume suffix: $1" >&2
    exit 2
  fi

  sources=("$LATEX_DIR/${BASE_NAME}_$1.tex")
else
  shopt -s nullglob
  sources=("$LATEX_DIR/${BASE_NAME}_"*.tex)
  shopt -u nullglob
fi

if [[ ${#sources[@]} -eq 0 || ! -f ${sources[0]} ]]; then
  echo "No matching resume found." >&2
  echo "Available suffixes:" >&2
  for source in "$LATEX_DIR/${BASE_NAME}_"*.tex; do
    [[ -f $source ]] || continue
    suffix="${source##*/${BASE_NAME}_}"
    echo "  ${suffix%.tex}" >&2
  done
  exit 1
fi

for source in "${sources[@]}"; do
  suffix="${source##*/${BASE_NAME}_}"
  suffix="${suffix%.tex}"
  output_dir="$OUTPUT_ROOT/$suffix"
  build_dir="$temporary_root/$suffix"

  mkdir -p "$output_dir" "$build_dir"
  echo "Building $suffix resume..."
  pdflatex \
    -interaction=nonstopmode \
    -halt-on-error \
    -output-directory="$build_dir" \
    -jobname="$BASE_NAME" \
    "$source"
  mv "$build_dir/$BASE_NAME.pdf" "$output_dir/$BASE_NAME.pdf"
done

echo "Resume PDFs written to $OUTPUT_ROOT"
