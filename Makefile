include $(TOPDIR)/rules.mk

PKG_NAME:=wifi-health-dashboard
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Matt Bird
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/wifi-health-dashboard
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Wi-Fi Health Dashboard
  DEPENDS:=+iw +uhttpd
  URL:=https://github.com/naigle/openwrt-wifi-health
endef

define Package/wifi-health-dashboard/description
  Real-time Wi-Fi health dashboard for OpenWrt routers.
  Served by uhttpd at /wifi-health/ with a JSON CGI backend.

  Shows per-radio channel utilisation, TX/RX airtime, noise floor,
  and per-station signal strength, link rates, TX failure rate and
  DHCP hostnames. Auto-detects all AP interfaces and WAN.
  Auto-refreshes every 30 seconds.

  Tested on: BananaPi BPI-R4 (MT7988 / mt7996e), but works on any
  OpenWrt router with iw and uhttpd.
endef

define Build/Compile
endef

define Package/wifi-health-dashboard/install
	$(INSTALL_DIR) $(1)/www/cgi-bin
	$(INSTALL_DIR) $(1)/www/wifi-health
	$(INSTALL_BIN)  ./src/wifi-health  $(1)/www/cgi-bin/wifi-health
	$(INSTALL_DATA) ./src/index.html   $(1)/www/wifi-health/index.html
endef

define Package/wifi-health-dashboard/postinst
#!/bin/sh
grep -qF '/www/wifi-health/index.html' /etc/sysupgrade.conf 2>/dev/null || echo '/www/wifi-health/index.html' >> /etc/sysupgrade.conf
grep -qF '/www/cgi-bin/wifi-health'    /etc/sysupgrade.conf 2>/dev/null || echo '/www/cgi-bin/wifi-health'    >> /etc/sysupgrade.conf
exit 0
endef

define Package/wifi-health-dashboard/prerm
#!/bin/sh
sed -i '\|/www/wifi-health/index.html|d' /etc/sysupgrade.conf 2>/dev/null
sed -i '\|/www/cgi-bin/wifi-health|d'    /etc/sysupgrade.conf 2>/dev/null
exit 0
endef

$(eval $(call BuildPackage,wifi-health-dashboard))
