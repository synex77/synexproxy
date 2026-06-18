#!/data/data/com.termux/files/usr/bin/bash

# ============================================
# AJ Proxy - Synex Proxy PRO Installer
# Termux için otomatik kurulum
# ============================================

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
ENDCOLOR="\e[0m"
BOLD="\e[1m"

PROXY_VERSION="v3.0"
PROXY_DIR="$HOME/AJProxy"
HOSTS_FILE="/data/data/com.termux/files/usr/etc/hosts"

clear

echo -e "${CYAN}"
echo "    ___    _______  ____  _____       ____  ____  ________  _____"
echo "   /   |  / ___/\ \/ /\ \/ / /      / __ \/ __ \/ ____/  |/  / /"
echo "  / /| |  \__ \  \  /  \  / /      / /_/ / / / / / __/ /|_/ / / "
echo " / ___ | ___/ /  / /   / / /___   / ____/ /_/ / /_/ / /  / / /___"
echo "/_/  |_|/____/  /_/   /_/_____/  /_/    \____/\____/_/  /_/_____/"
echo -e "${ENDCOLOR}"
echo -e "${BOLD}${GREEN}         Synex Proxy PRO Installer ${PROXY_VERSION}${ENDCOLOR}"
echo -e "${YELLOW}         Termux Otomatik Kurulum${ENDCOLOR}"
echo ""

# --------------------------------------------
# 1. Paketleri Yükle
# --------------------------------------------
echo -e "${GREEN}[1/7] Gerekli paketler yükleniyor...${ENDCOLOR}"
pkg update -y > /dev/null 2>&1
pkg install -y wget openssl curl libcurl libenet tsu > /dev/null 2>&1
echo -e "${GREEN}      ✓ Paketler yüklendi${ENDCOLOR}"

# --------------------------------------------
# 2. Proxy Dizinini Oluştur
# --------------------------------------------
echo -e "${GREEN}[2/7] Proxy dizini hazırlanıyor...${ENDCOLOR}"
if [ -d "$PROXY_DIR" ]; then
    echo -e "${YELLOW}      Eski kurulum bulundu, yedekleniyor...${ENDCOLOR}"
    mv "$PROXY_DIR" "$PROXY_DIR.backup.$(date +%s)"
fi
mkdir -p "$PROXY_DIR"
echo -e "${GREEN}      ✓ Dizin hazır: $PROXY_DIR${ENDCOLOR}"

# --------------------------------------------
# 3. Hosts Dosyasını Ayarla (Virtual Hosts)
# --------------------------------------------
echo -e "${GREEN}[3/7] Virtual hosts ayarlanıyor (/etc/hosts)...${ENDCOLOR}"

# Önce eski AJProxy hostlarını temizle
if [ -f "$HOSTS_FILE" ]; then
    grep -v "# AJProxy" "$HOSTS_FILE" > "$PROXY_DIR/hosts.tmp" 2>/dev/null
    grep -v "growtopia1.com" "$PROXY_DIR/hosts.tmp" > "$PROXY_DIR/hosts.tmp2" 2>/dev/null
    grep -v "growtopia2.com" "$PROXY_DIR/hosts.tmp2" > "$HOSTS_FILE" 2>/dev/null
    rm -f "$PROXY_DIR/hosts.tmp" "$PROXY_DIR/hosts.tmp2"
fi

# Yeni hostları ekle
cat >> "$HOSTS_FILE" << 'HOSTSEOF'

# ============================================
# AJProxy - Synex Proxy Virtual Hosts
# ============================================
# AJProxy
195.62.48.50 www.growtopia1.com
195.62.48.50 www.growtopia2.com
HOSTSEOF

echo -e "${GREEN}      ✓ Virtual hosts eklendi${ENDCOLOR}"
echo -e "${CYAN}        → growtopia1.com → 195.62.48.50${ENDCOLOR}"
echo -e "${CYAN}        → growtopia2.com → 195.62.48.50${ENDCOLOR}"

# --------------------------------------------
# 4. Proxy Binary'sini İndir
# --------------------------------------------
echo -e "${GREEN}[4/7] AJ Proxy binary indiriliyor...${ENDCOLOR}"
cd "$PROXY_DIR"

wget -q --show-progress "https://github.com/joakimthecoder/ajtermux/raw/main/proxy" -O "$PROXY_DIR/proxy"
if [ ! -f "$PROXY_DIR/proxy" ]; then
    echo -e "${RED}      ✗ Proxy indirilemedi!${ENDCOLOR}"
    echo -e "${YELLOW}      Alternatif kaynak deneniyor...${ENDCOLOR}"
    wget -q --show-progress "https://raw.githubusercontent.com/joakimthecoder/ajtermux/main/proxy" -O "$PROXY_DIR/proxy"
fi

chmod +x "$PROXY_DIR/proxy"
echo -e "${GREEN}      ✓ Proxy indirildi${ENDCOLOR}"

# --------------------------------------------
# 5. Vars Dosyasını İndir
# --------------------------------------------
echo -e "${GREEN}[5/7] Yapılandırma dosyası (vars) indiriliyor...${ENDCOLOR}"
wget -q --show-progress "https://raw.githubusercontent.com/joakimthecoder/ajtermux/main/vars" -O "$PROXY_DIR/vars"
echo -e "${GREEN}      ✓ Yapılandırma dosyası indirildi${ENDCOLOR}"

# --------------------------------------------
# 6. Synex Proxy PRO Lua Scriptini İndir
# --------------------------------------------
echo -e "${GREEN}[6/7] Synex Proxy PRO mod menüsü indiriliyor...${ENDCOLOR}"
wget -q --show-progress "https://raw.githubusercontent.com/joakimthecoder/ajtermux/main/synex_pro.lua" -O "$PROXY_DIR/synex_pro.lua"
if [ ! -f "$PROXY_DIR/synex_pro.lua" ]; then
    echo -e "${YELLOW}      Mod menüsü ana repoda bulunamadı, alternatif deneniyor...${ENDCOLOR}"
    wget -q --show-progress "https://raw.githubusercontent.com/SynexProxy/pro/main/synex_pro.lua" -O "$PROXY_DIR/synex_pro.lua" 2>/dev/null
fi

if [ -f "$PROXY_DIR/synex_pro.lua" ]; then
    echo -e "${GREEN}      ✓ Synex Proxy PRO mod menüsü hazır${ENDCOLOR}"
else
    echo -e "${YELLOW}      ! Mod menüsü indirilemedi, manuel yüklemeniz gerekebilir${ENDCOLOR}"
fi

# --------------------------------------------
# 7. Başlatma Scripti Oluştur
# --------------------------------------------
echo -e "${GREEN}[7/7] Başlatma scripti oluşturuluyor...${ENDCOLOR}"

cat > "$HOME/ajproxy" << 'STARTEREOF'
#!/data/data/com.termux/files/usr/bin/bash
PROXY_DIR="$HOME/AJProxy"

cd "$PROXY_DIR"

# Hosts kontrol et
grep -q "growtopia1.com" /data/data/com.termux/files/usr/etc/hosts 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "\e[33m[UYARI] Virtual hosts bulunamadı, yeniden ayarlanıyor...\e[0m"
    echo "195.62.48.50 www.growtopia1.com" >> /data/data/com.termux/files/usr/etc/hosts
    echo "195.62.48.50 www.growtopia2.com" >> /data/data/com.termux/files/usr/etc/hosts
fi

# Proxy'i başlat
echo -e "\e[36mAJ Proxy başlatılıyor...\e[0m"
echo -e "\e[32mProxy Server: 195.62.48.50:1234\e[0m"
echo -e "\e[32mGrowtopia IP: 213.179.209.175:17043\e[0m"
echo -e "\e[33mÇıkmak için Ctrl+C\e[0m"
echo ""
./proxy "$@"
STARTEREOF

chmod +x "$HOME/ajproxy"

# --------------------------------------------
# KURULUM TAMAMLANDI
# --------------------------------------------
echo ""
echo -e "${BOLD}${GREEN}========================================${ENDCOLOR}"
echo -e "${BOLD}${GREEN}    ✓ KURULUM TAMAMLANDI!${ENDCOLOR}"
echo -e "${BOLD}${GREEN}========================================${ENDCOLOR}"
echo ""
echo -e "${CYAN}📁 Proxy dizini: ${YELLOW}$PROXY_DIR${ENDCOLOR}"
echo -e "${CYAN}🎮 Başlatma:    ${YELLOW}ajproxy${ENDCOLOR}"
echo -e "${CYAN}🌐 Hosts:       ${YELLOW}/data/data/com.termux/files/usr/etc/hosts${ENDCOLOR}"
echo ""
echo -e "${BOLD}${GREEN}Komutlar:${ENDCOLOR}"
echo -e "  ${YELLOW}ajproxy${ENDCOLOR}              - Proxy'i başlat"
echo -e "  ${YELLOW}ajproxy --help${ENDCOLOR}       - Yardım"
echo ""
echo -e "${BOLD}${YELLOW}SYNEX PROXY PRO Komutları (oyundayken):${ENDCOLOR}"
echo -e "  ${CYAN}/menu${ENDCOLOR}              - Ana menüyü aç"
echo -e "  ${CYAN}/ft${ENDCOLOR} / ${CYAN}/nf${ENDCOLOR}           - Fly aç/kapat"
echo -e "  ${CYAN}/ghost${ENDCOLOR} / ${CYAN}/gf${ENDCOLOR}       - Ghost/NoClip aç/kapat"
echo -e "  ${CYAN}/cbgl${ENDANTCOLOR} / ${CYAN}/cbgloff${ENDCOLOR}   - Auto CBGL aç/kapat"
echo -e "  ${CYAN}/cg${ENDCOLOR} / ${CYAN}/cgoff${ENDCOLOR}        - CheckGems aç/kapat"
echo -e "  ${CYAN}/fd${ENDCOLOR} / ${CYAN}/fdoff${ENDCOLOR}        - FastDrop aç/kapat"
echo -e "  ${CYAN}/afk${ENDCOLOR} / ${CYAN}/afkoff${ENDCOLOR}      - AFK modu aç/kapat"
echo -e "  ${CYAN}/tp [isim]${ENDCOLOR}        - Oyuncuya ışınlan"
echo -e "  ${CYAN}/drop [miktar]${ENDCOLOR}    - DL/WL düşür"
echo -e "  ${CYAN}/pullall${ENDCOLOR}          - Herkesi çek"
echo -e "  ${CYAN}/legend${ENDCOLOR}           - Legend title"
echo -e "  ${CYAN}/maxlevel${ENDCOLOR}         - Mavi isim (Max Level)"
echo ""
echo -e "${GREEN}Başlamak için: ${BOLD}ajproxy${ENDCOLOR}"
echo ""
