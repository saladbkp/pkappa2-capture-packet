#!/usr/bin/env bash
set -euo pipefail

FILE="$1"

# ====== pkappa2 上传配置 ====== -> check .env from pkappa2
PKAPPA2_IP="xx.xxx.xx.xx"        # 改成你的 pkappa2 IP
PKAPPA2_PORT="8080"              # 改成你的 pkappa2 port
PKAPPA2_USER="user"             # pcap upload 用户
PKAPPA2_PASSWD="password"  # pcap upload 密码（不是 UI 密码）

BASENAME="$(basename "$FILE")"

echo "[*] FINISHED $BASENAME, uploading..."

# --fail：HTTP 非 2xx 直接失败
# --retry：网络抖动自动重试
curl --fail --silent --show-error \
  --retry 5 --retry-delay 2 --retry-all-errors \
  --data-binary "@$FILE" \
  "http://${PKAPPA2_USER}:${PKAPPA2_PASSWD}@${PKAPPA2_IP}:${PKAPPA2_PORT}/upload/${BASENAME}"

# 上传成功再删本地，避免丢数据
rm -f "$FILE"
echo "[*] Uploaded and removed $BASENAME"
