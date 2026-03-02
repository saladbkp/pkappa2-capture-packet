#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# ====== 配置区 ======
INTERVAL=300                 # 5 minutes
PCAP_DIR="$(pwd)/pcaps"
IFACE="any"                  
HOSTNAME_TAG="$(hostname -s)"

# pkappa2 server（分析机）
PKAPPA2_IP="xxx.xxx.xx.x"    # 改成你的 pkappa2 IP
PKAPPA2_PORT="8080"          # 改成你的 pkappa2 port

# 你要抓的 service ports（示例：HTTP/HTTPS/SSH/自定义服务 80 443 8080 8443 1337,5000 is for demo）
TCP_PORTS=(5000)
UDP_PORTS=(53 123)

# 可选：不抓 ssh（避免噪音）
EXCLUDE_SSH=true

mkdir -p "$PCAP_DIR"
chmod 700 "$PCAP_DIR"

# ====== 生成 BPF filter ======
join_ports() {
  local proto="$1"; shift
  local arr=("$@")
  local out=""
  for p in "${arr[@]}"; do
    if [ -z "$out" ]; then
      out="(${proto} port ${p})"
    else
      out="${out} or (${proto} port ${p})"
    fi
  done
  echo "$out"
}

TCP_EXPR="$(join_ports tcp "${TCP_PORTS[@]}")"
UDP_EXPR="$(join_ports udp "${UDP_PORTS[@]}")"

if [ -n "$TCP_EXPR" ] && [ -n "$UDP_EXPR" ]; then
  PORT_FILTER="( ${TCP_EXPR} or ${UDP_EXPR} )"
elif [ -n "$TCP_EXPR" ]; then
  PORT_FILTER="( ${TCP_EXPR} )"
elif [ -n "$UDP_EXPR" ]; then
  PORT_FILTER="( ${UDP_EXPR} )"
else
  # 如果你没填 ports，就全抓（不推荐长期全抓）
  PORT_FILTER="(tcp or udp)"
fi

# 重点：排除上传到 pkappa2 的流量，避免“抓到上传包 → 上传 → 再被抓到”指数增长
EXCLUDE_UPLOAD="and not (host ${PKAPPA2_IP} and port ${PKAPPA2_PORT})"

# 可选：排除 ssh
if [ "$EXCLUDE_SSH" = true ]; then
  EXCLUDE_SSH_EXPR="and not (port 22)"
else
  EXCLUDE_SSH_EXPR=""
fi

BPF="(${PORT_FILTER}) ${EXCLUDE_UPLOAD} ${EXCLUDE_SSH_EXPR}"

echo "[*] IFACE=$IFACE"
echo "[*] PCAP_DIR=$PCAP_DIR"
echo "[*] INTERVAL=$INTERVAL"
echo "[*] FILTER=$BPF"

exec tcpdump -n -i "$IFACE" "$BPF" \
  -Z root \
  -G "$INTERVAL" \
  -w "${PCAP_DIR}/${HOSTNAME_TAG}_${IFACE}_%Y%m%d_%H%M%S.pcap" \
  -z "$(pwd)/tcpdump_complete.sh"
