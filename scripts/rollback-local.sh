#!/usr/bin/env bash
set -Eeuo pipefail

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

[[ -d "$BACKUP_ROOT" ]] || die "nenhum diretorio de backup encontrado em $BACKUP_ROOT"
[[ -d "$CUPS_TEMPLATES_DIR" ]] || die "destino CUPS templates nao encontrado: $CUPS_TEMPLATES_DIR"
[[ -d "$CUPS_DOC_ROOT_DIR" ]] || die "destino CUPS doc-root nao encontrado: $CUPS_DOC_ROOT_DIR"

mapfile -t BACKUPS < <(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -name 'cups-ui-*' | sort -r)

if [[ "${#BACKUPS[@]}" -eq 0 ]]; then
  die "nenhum backup disponivel em $BACKUP_ROOT"
fi

printf 'Backups disponiveis:\n'
for index in "${!BACKUPS[@]}"; do
  printf '  %d) %s\n' "$((index + 1))" "${BACKUPS[$index]}"
done

printf '\nEscolha o numero do backup para restaurar: '
read -r CHOICE

if ! [[ "$CHOICE" =~ ^[0-9]+$ ]]; then
  die "escolha invalida"
fi

if (( CHOICE < 1 || CHOICE > ${#BACKUPS[@]} )); then
  die "backup fora da lista"
fi

SELECTED_BACKUP="${BACKUPS[$((CHOICE - 1))]}"

[[ -d "$SELECTED_BACKUP/templates" ]] || die "backup sem templates: $SELECTED_BACKUP"
[[ -d "$SELECTED_BACKUP/doc-root" ]] || die "backup sem doc-root: $SELECTED_BACKUP"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
SAFETY_BACKUP="$BACKUP_ROOT/cups-ui-pre-rollback-$TIMESTAMP"

printf 'Criando backup de seguranca em %s\n' "$SAFETY_BACKUP"
run mkdir -p "$SAFETY_BACKUP/templates" "$SAFETY_BACKUP/doc-root"
run rsync -a "$CUPS_TEMPLATES_DIR/" "$SAFETY_BACKUP/templates/"
run rsync -a "$CUPS_DOC_ROOT_DIR/" "$SAFETY_BACKUP/doc-root/"

printf 'Restaurando templates de %s\n' "$SELECTED_BACKUP"
run rsync -a --delete "$SELECTED_BACKUP/templates/" "$CUPS_TEMPLATES_DIR/"

printf 'Restaurando doc-root de %s\n' "$SELECTED_BACKUP"
run rsync -a --delete "$SELECTED_BACKUP/doc-root/" "$CUPS_DOC_ROOT_DIR/"

printf 'Reiniciando CUPS...\n'
restart_cups

printf '\nRollback concluido com sucesso.\n'
printf 'Backup restaurado: %s\n' "$SELECTED_BACKUP"
printf 'Backup de seguranca: %s\n' "$SAFETY_BACKUP"
printf 'Teste: http://localhost:631\n'
