#!/usr/bin/env bash
# =============================================================================
# Port Mapper v1.0.0 — Install Script
# =============================================================================

set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="port-mapper"
SOURCE_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/port-mapper.sh"

echo -e "${CYAN}${BOLD}"
echo "  ┌─────────────────────────────────────────┐"
echo "  │     Port Mapper — Installer v1.0.0      │"
echo "  └─────────────────────────────────────────┘"
echo -e "${RESET}"

# Cek file sumber ada
if [[ ! -f "$SOURCE_FILE" ]]; then
  echo -e "${RED}✗ File port-mapper.sh tidak ditemukan di direktori ini.${RESET}"
  exit 1
fi

# Cek macOS
if [[ "$(uname)" != "Darwin" ]]; then
  echo -e "${YELLOW}⚠  Script ini dioptimalkan untuk macOS.${RESET}"
fi

echo -e "  Menginstal ke ${BOLD}${INSTALL_DIR}/${SCRIPT_NAME}${RESET}..."

# Install
if cp "$SOURCE_FILE" "${INSTALL_DIR}/${SCRIPT_NAME}" 2>/dev/null; then
  chmod +x "${INSTALL_DIR}/${SCRIPT_NAME}"
  echo -e "  ${GREEN}✓ Instalasi berhasil!${RESET}"
else
  echo -e "  ${YELLOW}⚠  Perlu izin sudo...${RESET}"
  sudo cp "$SOURCE_FILE" "${INSTALL_DIR}/${SCRIPT_NAME}"
  sudo chmod +x "${INSTALL_DIR}/${SCRIPT_NAME}"
  echo -e "  ${GREEN}✓ Instalasi berhasil dengan sudo!${RESET}"
fi

echo ""
echo -e "  Coba sekarang: ${CYAN}${BOLD}port-mapper list${RESET}"
echo ""
