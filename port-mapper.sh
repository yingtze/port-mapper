#!/usr/bin/env bash
# =============================================================================
# Port Mapper v1.0.0
# Lihat semua port yang sedang dipakai, proses mana yang pakai, kill dengan mudah
# https://github.com/yingtze/port-mapper
# =============================================================================

set -euo pipefail

# ── Warna & Gaya ─────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Konstanta ─────────────────────────────────────────────────────────────────
VERSION="1.0.0"
SCRIPT_NAME="port-mapper"

# ── Fungsi Bantuan ────────────────────────────────────────────────────────────
print_banner() {
  echo -e "${CYAN}${BOLD}"
  echo "  ██████╗  ██████╗ ██████╗ ████████╗    ███╗   ███╗ █████╗ ██████╗ "
  echo "  ██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝    ████╗ ████║██╔══██╗██╔══██╗"
  echo "  ██████╔╝██║   ██║██████╔╝   ██║       ██╔████╔██║███████║██████╔╝"
  echo "  ██╔═══╝ ██║   ██║██╔══██╗   ██║       ██║╚██╔╝██║██╔══██║██╔═══╝ "
  echo "  ██║     ╚██████╔╝██║  ██║   ██║       ██║ ╚═╝ ██║██║  ██║██║     "
  echo "  ╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝       ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     "
  echo -e "${RESET}"
  echo -e "  ${DIM}v${VERSION} — Port Manager untuk macOS${RESET}"
  echo -e "  ${DIM}─────────────────────────────────────────────────────────────────${RESET}"
  echo ""
}

print_help() {
  print_banner
  echo -e "${BOLD}PENGGUNAAN:${RESET}"
  echo -e "  ${CYAN}${SCRIPT_NAME}${RESET} [perintah] [opsi]"
  echo ""
  echo -e "${BOLD}PERINTAH:${RESET}"
  echo -e "  ${GREEN}list${RESET}               Tampilkan semua port yang aktif"
  echo -e "  ${GREEN}list -p <port>${RESET}     Cari port tertentu"
  echo -e "  ${GREEN}list -n <nama>${RESET}     Filter berdasarkan nama proses"
  echo -e "  ${GREEN}kill <port>${RESET}        Kill proses yang memakai port tertentu"
  echo -e "  ${GREEN}kill -f <port>${RESET}     Kill tanpa konfirmasi (force)"
  echo -e "  ${GREEN}watch${RESET}              Pantau port secara real-time (refresh 2 detik)"
  echo -e "  ${GREEN}watch -i <detik>${RESET}   Pantau dengan interval custom"
  echo -e "  ${GREEN}info <port>${RESET}        Detail lengkap proses pada port tertentu"
  echo -e "  ${GREEN}version${RESET}            Tampilkan versi"
  echo -e "  ${GREEN}help${RESET}               Tampilkan bantuan ini"
  echo ""
  echo -e "${BOLD}CONTOH:${RESET}"
  echo -e "  ${DIM}${SCRIPT_NAME} list${RESET}                 # Semua port aktif"
  echo -e "  ${DIM}${SCRIPT_NAME} list -p 3000${RESET}         # Cek port 3000"
  echo -e "  ${DIM}${SCRIPT_NAME} list -n node${RESET}         # Semua proses node"
  echo -e "  ${DIM}${SCRIPT_NAME} kill 3000${RESET}            # Kill port 3000"
  echo -e "  ${DIM}${SCRIPT_NAME} kill -f 8080${RESET}         # Kill port 8080 tanpa tanya"
  echo -e "  ${DIM}${SCRIPT_NAME} watch${RESET}                # Live monitor"
  echo -e "  ${DIM}${SCRIPT_NAME} info 3000${RESET}            # Detail port 3000"
  echo ""
}

# ── Ambil Data Port ───────────────────────────────────────────────────────────
get_ports() {
  # Gunakan lsof untuk mendapatkan semua port TCP/UDP yang LISTEN atau ESTABLISHED
  lsof -iTCP -iUDP -n -P 2>/dev/null | grep -E "LISTEN|ESTABLISHED" | awk '
  {
    # Kolom: COMMAND PID USER FD TYPE DEVICE SIZE/OFF NODE NAME
    cmd=$1; pid=$2; user=$3; name=$9; state=$10
    # Ambil port dari kolom NAME (format: *:port atau host:port)
    split(name, a, ":")
    port = a[length(a)]
    # Singkirkan duplikat dan bukan angka
    if (port+0 > 0 && pid+0 > 0) {
      key = pid":"port
      if (!seen[key]++) {
        print port"\t"pid"\t"cmd"\t"user"\t"state"\t"name
      }
    }
  }' | sort -n
}

get_port_info() {
  local port=$1
  lsof -iTCP:"${port}" -iUDP:"${port}" -n -P 2>/dev/null
}

# ── Format Tabel ──────────────────────────────────────────────────────────────
print_table_header() {
  echo -e "${BOLD}${DIM}$(printf '%-8s %-8s %-20s %-12s %-14s %s' 'PORT' 'PID' 'PROSES' 'USER' 'STATUS' 'ALAMAT')${RESET}"
  echo -e "${DIM}$(printf '%.0s─' {1..80})${RESET}"
}

colorize_status() {
  local status=$1
  case "$status" in
    LISTEN)      echo -e "${GREEN}${status}${RESET}" ;;
    ESTABLISHED) echo -e "${BLUE}${status}${RESET}" ;;
    *)           echo -e "${DIM}${status}${RESET}" ;;
  esac
}

colorize_process() {
  local proc=$1
  case "$proc" in
    node|npm|npx)     echo -e "${GREEN}${proc}${RESET}" ;;
    python*|python3)  echo -e "${YELLOW}${proc}${RESET}" ;;
    ruby|rails)       echo -e "${RED}${proc}${RESET}" ;;
    java|mvn|gradle)  echo -e "${MAGENTA}${proc}${RESET}" ;;
    nginx|apache*)    echo -e "${CYAN}${proc}${RESET}" ;;
    docker*)          echo -e "${BLUE}${proc}${RESET}" ;;
    *)                echo -e "${RESET}${proc}${RESET}" ;;
  esac
}

# ── Perintah: List ────────────────────────────────────────────────────────────
cmd_list() {
  local filter_port=""
  local filter_name=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p|--port) filter_port="$2"; shift 2 ;;
      -n|--name) filter_name="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  local data
  data=$(get_ports)

  if [[ -z "$data" ]]; then
    echo -e "${YELLOW}⚠  Tidak ada port aktif yang ditemukan.${RESET}"
    return
  fi

  # Filter
  if [[ -n "$filter_port" ]]; then
    data=$(echo "$data" | awk -F'\t' -v p="$filter_port" '$1 == p')
  fi
  if [[ -n "$filter_name" ]]; then
    data=$(echo "$data" | awk -F'\t' -v n="$filter_name" 'tolower($3) ~ tolower(n)')
  fi

  if [[ -z "$data" ]]; then
    echo -e "${YELLOW}⚠  Tidak ada hasil yang cocok dengan filter.${RESET}"
    return
  fi

  local count
  count=$(echo "$data" | wc -l | tr -d ' ')

  echo -e "${BOLD}${CYAN}🔍 Port Aktif${RESET} ${DIM}(${count} ditemukan)${RESET}"
  echo ""
  print_table_header

  while IFS=$'\t' read -r port pid proc user status addr; do
    local colored_status colored_proc
    colored_status=$(colorize_status "$status")
    colored_proc=$(colorize_process "$proc")
    printf "%-8s %-8s %-20b %-12s %-14b %s\n" \
      "${BOLD}${port}${RESET}" \
      "${DIM}${pid}${RESET}" \
      "${colored_proc}" \
      "${user}" \
      "${colored_status}" \
      "${DIM}${addr}${RESET}"
  done <<< "$data"

  echo ""
  echo -e "${DIM}Tip: gunakan '${SCRIPT_NAME} kill <port>' untuk menghentikan proses${RESET}"
}

# ── Perintah: Kill ────────────────────────────────────────────────────────────
cmd_kill() {
  local force=false
  local port=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--force) force=true; shift ;;
      *)          port="$1"; shift ;;
    esac
  done

  if [[ -z "$port" ]]; then
    echo -e "${RED}✗ Error: port tidak ditentukan.${RESET}"
    echo -e "  Contoh: ${CYAN}${SCRIPT_NAME} kill 3000${RESET}"
    exit 1
  fi

  # Validasi angka
  if ! [[ "$port" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}✗ Error: '${port}' bukan nomor port yang valid.${RESET}"
    exit 1
  fi

  local data
  data=$(get_ports | awk -F'\t' -v p="$port" '$1 == p')

  if [[ -z "$data" ]]; then
    echo -e "${YELLOW}⚠  Tidak ada proses yang memakai port ${BOLD}${port}${RESET}${YELLOW}.${RESET}"
    return
  fi

  echo -e "${BOLD}Proses yang memakai port ${CYAN}${port}${RESET}${BOLD}:${RESET}"
  echo ""
  print_table_header

  local pids=()
  while IFS=$'\t' read -r p pid proc user status addr; do
    local colored_status colored_proc
    colored_status=$(colorize_status "$status")
    colored_proc=$(colorize_process "$proc")
    printf "%-8s %-8s %-20b %-12s %-14b %s\n" \
      "${BOLD}${p}${RESET}" \
      "${DIM}${pid}${RESET}" \
      "${colored_proc}" \
      "${user}" \
      "${colored_status}" \
      "${DIM}${addr}${RESET}"
    pids+=("$pid")
  done <<< "$data"

  # Deduplikasi PID
  local unique_pids
  IFS=$'\n' read -r -d '' -a unique_pids < <(printf '%s\n' "${pids[@]}" | sort -u && printf '\0')

  echo ""

  if [[ "$force" == false ]]; then
    echo -ne "${YELLOW}⚡ Kill ${#unique_pids[@]} proses? (y/N): ${RESET}"
    read -r confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      echo -e "${DIM}Dibatalkan.${RESET}"
      return
    fi
  fi

  local killed=0
  for pid in "${unique_pids[@]}"; do
    if kill -9 "$pid" 2>/dev/null; then
      echo -e "${GREEN}✓ PID ${pid} berhasil di-kill${RESET}"
      ((killed++))
    else
      echo -e "${RED}✗ Gagal kill PID ${pid} — coba dengan sudo${RESET}"
    fi
  done

  echo ""
  echo -e "${GREEN}${BOLD}🎯 Selesai! ${killed}/${#unique_pids[@]} proses dihentikan.${RESET}"
}

# ── Perintah: Info ────────────────────────────────────────────────────────────
cmd_info() {
  local port="$1"

  if [[ -z "$port" ]]; then
    echo -e "${RED}✗ Error: port tidak ditentukan.${RESET}"
    exit 1
  fi

  echo -e "${BOLD}${CYAN}📋 Detail Port ${port}${RESET}"
  echo ""

  local lsof_output
  lsof_output=$(get_port_info "$port")

  if [[ -z "$lsof_output" ]]; then
    echo -e "${YELLOW}⚠  Port ${port} tidak digunakan saat ini.${RESET}"
    return
  fi

  echo "$lsof_output"

  # Info tambahan dari ps
  echo ""
  echo -e "${BOLD}${DIM}── Info Proses Lengkap ──────────────────────────────${RESET}"
  local pid
  pid=$(echo "$lsof_output" | awk 'NR>1 {print $2}' | head -1)
  if [[ -n "$pid" ]]; then
    ps -p "$pid" -o pid,ppid,user,%cpu,%mem,vsz,rss,stat,start,time,command 2>/dev/null || true
  fi
}

# ── Perintah: Watch ───────────────────────────────────────────────────────────
cmd_watch() {
  local interval=2

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i|--interval) interval="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  echo -e "${CYAN}${BOLD}👁  Mode Watch — Refresh setiap ${interval} detik. Tekan Ctrl+C untuk berhenti.${RESET}"
  echo ""

  while true; do
    clear
    print_banner
    echo -e "${DIM}$(date '+%H:%M:%S') — Auto refresh setiap ${interval}s | Ctrl+C untuk keluar${RESET}"
    echo ""
    cmd_list
    sleep "$interval"
  done
}

# ── Perintah: Version ─────────────────────────────────────────────────────────
cmd_version() {
  echo -e "${CYAN}${BOLD}Port Mapper${RESET} v${VERSION}"
  echo -e "${DIM}macOS Port Manager — dibuat dengan ❤ untuk developer Indonesia${RESET}"
}

# ── Entry Point ───────────────────────────────────────────────────────────────
main() {
  local command="${1:-help}"
  shift || true

  case "$command" in
    list|ls)       cmd_list "$@" ;;
    kill|k)        cmd_kill "$@" ;;
    info|i)        cmd_info "$@" ;;
    watch|w)       cmd_watch "$@" ;;
    version|-v|--version) cmd_version ;;
    help|-h|--help)       print_help ;;
    *)
      echo -e "${RED}✗ Perintah '${command}' tidak dikenal.${RESET}"
      echo -e "  Jalankan ${CYAN}${SCRIPT_NAME} help${RESET} untuk melihat daftar perintah."
      exit 1
      ;;
  esac
}

main "$@"
