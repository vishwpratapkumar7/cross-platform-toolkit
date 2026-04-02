#!/usr/bin/env bash
# ============================================================
# netcheck.sh - Network Diagnostic Tool
# Works on: Linux, Termux, macOS
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

TIMEOUT=5
PING_COUNT=4

ok()   { echo -e " ${GREEN}✅ PASS${RESET} - $1"; }
fail() { echo -e " ${RED}❌ FAIL${RESET} - $1"; }
info() { echo -e " ${CYAN}ℹ️  INFO${RESET} - $1"; }
warn() { echo -e " ${YELLOW}⚠️  WARN${RESET} - $1"; }

header() {
  echo -e "\n${BOLD}${BLUE}━━━ $1 ━━━${RESET}"
}

echo -e "\n${BOLD}${CYAN}  🌐 Network Diagnostic Tool${RESET}"
echo -e "  Time: $(date '+%Y-%m-%d %H:%M:%S')\n"

# ── DNS Check ────────────────────────────────────────────────
header "DNS Resolution"
DNS_HOSTS=("google.com" "github.com" "cloudflare.com" "example.com")
for host in "${DNS_HOSTS[@]}"; do
  if host "$host" &>/dev/null 2>&1 || nslookup "$host" &>/dev/null 2>&1 || getent hosts "$host" &>/dev/null; then
    ok "DNS resolved: $host"
  else
    fail "DNS failed: $host"
  fi
done

# ── Ping Test ────────────────────────────────────────────────
header "Ping Test"
PING_HOSTS=("8.8.8.8" "1.1.1.1" "208.67.222.222")
for host in "${PING_HOSTS[@]}"; do
  if ping -c "$PING_COUNT" -W "$TIMEOUT" "$host" &>/dev/null; then
    LATENCY=$(ping -c "$PING_COUNT" -W "$TIMEOUT" "$host" 2>/dev/null | tail -1 | awk -F'/' '{print $5}')
    ok "Ping to $host → ${LATENCY}ms avg"
  else
    fail "Cannot ping $host"
  fi
done

# ── HTTP/HTTPS Test ──────────────────────────────────────────
header "HTTP/HTTPS Connectivity"
if command -v curl &>/dev/null; then
  URLS=("https://google.com" "https://github.com" "https://api.github.com" "http://example.com")
  for url in "${URLS[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$TIMEOUT" "$url" 2>/dev/null)
    if [[ "$STATUS" -ge 200 && "$STATUS" -lt 400 ]]; then
      ok "HTTP $STATUS → $url"
    else
      fail "HTTP $STATUS → $url"
    fi
  done
else
  warn "curl not installed, skipping HTTP tests"
fi

# ── Speed Test (rough) ───────────────────────────────────────
header "Download Speed (Rough)"
if command -v curl &>/dev/null; then
  START=$(date +%s%N)
  curl -s -o /dev/null --max-time 10 "https://speed.cloudflare.com/__down?bytes=1000000" 2>/dev/null
  END=$(date +%s%N)
  DIFF=$(( (END - START) / 1000000 ))
  if [[ $DIFF -gt 0 ]]; then
    SPEED=$(( (1000000 * 8) / (DIFF * 1000) ))
    info "Approx download speed: ~${SPEED} Mbps (1MB test)"
  fi
fi

# ── Local Network ────────────────────────────────────────────
header "Local Network Info"
if command -v ip &>/dev/null; then
  ip -4 addr show 2>/dev/null | grep "inet " | grep -v "127.0.0.1" | while read -r line; do
    IFACE=$(echo "$line" | awk '{print $NF}')
    IP=$(echo "$line" | awk '{print $2}')
    info "Interface $IFACE → $IP"
  done
elif command -v ifconfig &>/dev/null; then
  ifconfig 2>/dev/null | grep "inet " | grep -v "127.0.0.1" | awk '{print "  Interface: " $2}'
fi

GATEWAY=$(ip route show default 2>/dev/null | awk '/default/{print $3}' | head -1)
[[ -n "$GATEWAY" ]] && info "Default gateway: $GATEWAY"

# ── Port Check ───────────────────────────────────────────────
header "Common Ports Status (Local)"
PORTS=(22 80 443 3000 8080 8443 3306 5432 6379 27017)
for port in "${PORTS[@]}"; do
  if command -v nc &>/dev/null; then
    if nc -z -w2 localhost "$port" 2>/dev/null; then
      ok "Port $port is OPEN locally"
    fi
  elif command -v bash &>/dev/null; then
    if (echo >/dev/tcp/localhost/$port) 2>/dev/null; then
      ok "Port $port is OPEN locally"
    fi
  fi
done

# ── MTU & Traceroute ─────────────────────────────────────────
header "Network Path"
if command -v traceroute &>/dev/null; then
  info "Traceroute to 8.8.8.8 (first 5 hops):"
  traceroute -m 5 -w 2 8.8.8.8 2>/dev/null | head -8 | sed 's/^/    /'
elif command -v tracepath &>/dev/null; then
  info "Tracepath (first 5 hops):"
  tracepath -n -m 5 8.8.8.8 2>/dev/null | head -6 | sed 's/^/    /'
fi

echo -e "\n${GREEN}${BOLD}  ✅ Network check complete!${RESET}\n"
