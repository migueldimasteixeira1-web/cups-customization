#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUP_ROOT="${CUPS_UI_BACKUP_ROOT:-/var/backups/cups-ui}"
CUPS_TEMPLATES_DIR="${CUPS_TEMPLATES_DIR:-/usr/share/cups/templates}"
CUPS_DOC_ROOT_DIR="${CUPS_DOC_ROOT_DIR:-/usr/share/cups/doc-root}"

die() {
  printf 'Erro: %s\n' "$*" >&2
  exit 1
}

run() {
  if [[ "${EUID}" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "comando obrigatorio nao encontrado: $1"
}

resolve_source_root() {
  local candidate

  for candidate in "$ROOT_DIR/config/cups-ui" "$ROOT_DIR"; do
    if [[ -d "$candidate/templates" && -d "$candidate/doc-root" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

restart_cups() {
  if command -v systemctl >/dev/null 2>&1; then
    if run systemctl restart cups; then
      return 0
    fi
    if run systemctl restart cupsd; then
      return 0
    fi
  fi

  if command -v service >/dev/null 2>&1; then
    if run service cups restart; then
      return 0
    fi
    if run service cupsd restart; then
      return 0
    fi
  fi

  die "nao foi possivel reiniciar o servico CUPS automaticamente"
}

if [[ "${EUID}" -ne 0 ]]; then
  require_command sudo
fi
require_command rsync

SOURCE_ROOT="$(resolve_source_root)" || die "nao encontrei templates/ e doc-root/ no projeto"
SRC_TEMPLATES="$SOURCE_ROOT/templates"
SRC_DOC_ROOT="$SOURCE_ROOT/doc-root"

[[ -d "$SRC_TEMPLATES" ]] || die "diretorio de templates nao encontrado: $SRC_TEMPLATES"
[[ -d "$SRC_DOC_ROOT" ]] || die "diretorio doc-root nao encontrado: $SRC_DOC_ROOT"
[[ -d "$CUPS_TEMPLATES_DIR" ]] || die "destino CUPS templates nao encontrado: $CUPS_TEMPLATES_DIR"
[[ -d "$CUPS_DOC_ROOT_DIR" ]] || die "destino CUPS doc-root nao encontrado: $CUPS_DOC_ROOT_DIR"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/cups-ui-$TIMESTAMP"

printf 'Criando backup em %s\n' "$BACKUP_DIR"
run mkdir -p "$BACKUP_DIR/templates" "$BACKUP_DIR/doc-root"
run rsync -a "$CUPS_TEMPLATES_DIR/" "$BACKUP_DIR/templates/"
run rsync -a "$CUPS_DOC_ROOT_DIR/" "$BACKUP_DIR/doc-root/"

printf 'Aplicando templates sem remover arquivos existentes...\n'
run rsync -a "$SRC_TEMPLATES/" "$CUPS_TEMPLATES_DIR/"

printf 'Aplicando doc-root sem remover arquivos existentes...\n'
run rsync -a "$SRC_DOC_ROOT/" "$CUPS_DOC_ROOT_DIR/"

printf 'Reiniciando CUPS...\n'
restart_cups

printf '\nCustomizacao aplicada com sucesso.\n'
printf 'Backup: %s\n' "$BACKUP_DIR"
printf 'Teste: http://localhost:631\n'
