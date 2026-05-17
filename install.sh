#!/usr/bin/env bash
# WiFi Health Dashboard — installer for OpenWrt
# https://github.com/mattbird/openwrt-wifi-health
#
# Usage:
#   ./install.sh [user@host] [ssh-key]
#   curl -sL .../install.sh | bash -s root@192.168.1.1
#
# Defaults: root@192.168.1.1, ~/.ssh/openwrt_router (falls back to password auth)

set -e

TARGET="${1:-root@192.168.1.1}"
KEY="${2:-$HOME/.ssh/openwrt_router}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"

if [ -f "$KEY" ]; then
    SSH="ssh -i $KEY -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10"
else
    SSH="ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10"
fi

echo "WiFi Health Dashboard installer"
echo "  Target : $TARGET"
echo "  SSH key: ${KEY} $([ -f "$KEY" ] && echo '(found)' || echo '(not found, will use password)')"
echo ""

send_file() {
    local src="$1" dst="$2" mode="$3"
    if [ -f "$src" ]; then
        $SSH "$TARGET" "cat > $dst" < "$src"
    else
        # Embedded fallback (populated by CI)
        local varname="$4"
        echo "${!varname}" | base64 -d | $SSH "$TARGET" "cat > $dst"
    fi
    $SSH "$TARGET" "chmod $mode $dst"
}

$SSH "$TARGET" "mkdir -p /www/wifi-health /www/cgi-bin"

send_file "$REPO_DIR/src/wifi-health" "/www/cgi-bin/wifi-health" "755" "CGI_B64"
echo "  ✓ CGI backend installed"

send_file "$REPO_DIR/src/index.html" "/www/wifi-health/index.html" "644" "HTML_B64"
echo "  ✓ Dashboard HTML installed"

$SSH "$TARGET" "
    grep -qF '/www/wifi-health/index.html' /etc/sysupgrade.conf 2>/dev/null || echo '/www/wifi-health/index.html' >> /etc/sysupgrade.conf
    grep -qF '/www/cgi-bin/wifi-health'    /etc/sysupgrade.conf 2>/dev/null || echo '/www/cgi-bin/wifi-health'    >> /etc/sysupgrade.conf
"
echo "  ✓ Added to sysupgrade preserve list"
echo ""
echo "Done. Open http://${TARGET##*@}/wifi-health/"

# Embedded file content (populated by CI — do not edit below this line)
CGI_B64=""
HTML_B64=""
