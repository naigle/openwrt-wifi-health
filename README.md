# OpenWrt Wi-Fi Health Dashboard

A lightweight, real-time Wi-Fi health dashboard for OpenWrt routers. No external dependencies, no Node.js, no databases — just a shell CGI script and a single HTML file served by the built-in `uhttpd`.

## Features

- **Per-radio stats** — channel utilisation, TX/RX airtime %, noise floor, station count
- **Per-station stats** — signal strength, TX/RX link rates, TX failure rate, inactive time, DHCP hostname
- **Health indicators** — colour-coded green/amber/red for every metric
- **System overview** — uptime, CPU load, RAM usage, WAN IP, internet latency
- **Auto-refresh** every 30 seconds with countdown timer
- **Sortable station table** — click any column header
- **Auto-detects** all AP interfaces and WAN — works on any OpenWrt router

## Requirements

- OpenWrt 23.05 or newer
- `iw` (installed by default)
- `uhttpd` (installed by default)

## Install

### Option 1 — install.sh (easiest, works from any machine with SSH)

```sh
curl -sL https://github.com/naigle/openwrt-wifi-health/releases/latest/download/install.sh \
  -o install.sh && chmod +x install.sh

# Password auth
./install.sh root@192.168.1.1

# SSH key auth
./install.sh root@192.168.1.1 ~/.ssh/my_router_key
```

### Option 2 — opkg .ipk

```sh
# Download and install the .ipk from the latest release
curl -sLO https://github.com/naigle/openwrt-wifi-health/releases/latest/download/wifi-health-dashboard_1.0.0-1_all.ipk
opkg install wifi-health-dashboard_1.0.0-1_all.ipk
```

### Option 3 — from source (OpenWrt SDK)

```sh
git clone https://github.com/naigle/openwrt-wifi-health
# Copy into your OpenWrt package feed, then:
make package/wifi-health-dashboard/compile
```

## Access

After install, open **http://\<router-ip\>/wifi-health/**

Default: [http://192.168.1.1/wifi-health/](http://192.168.1.1/wifi-health/)

## Uninstall

```sh
# Via opkg
opkg remove wifi-health-dashboard

# Manual
ssh root@192.168.1.1 "rm -rf /www/wifi-health /www/cgi-bin/wifi-health"
```

## Compatibility

Tested on:
- **BananaPi BPI-R4** (MediaTek MT7988 / Filogic 880, mt7996e Wi-Fi 7)

Should work on any OpenWrt router with `iw` and `uhttpd`. AP interface names and WAN interface are auto-detected so no manual configuration is needed.

## How it works

`/www/cgi-bin/wifi-health` is a shell script that collects metrics on each request using:
- `iw dev <iface> info` — channel, width, TX power
- `iw dev <iface> survey dump` — airtime utilisation and noise floor
- `iw dev <iface> station dump` — per-station signal, rates, TX failures
- `/proc/uptime`, `/proc/loadavg`, `/proc/meminfo` — system stats
- `/tmp/dhcp.leases` — device hostnames
- `ping` — WAN latency

The dashboard HTML (`/www/wifi-health/index.html`) fetches this JSON every 30 seconds and renders it client-side. No server-side state.

## Sysupgrade

The installer adds both files to `/etc/sysupgrade.conf` so they are preserved across firmware upgrades.

## License

MIT
