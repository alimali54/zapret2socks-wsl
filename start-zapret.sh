#!/usr/bin/env bash

set -e

# Betiğin bulunduğu klasörü dinamik olarak tespit et ve oraya geç
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
cd "$SCRIPT_DIR"

# İkili dosyalara çalıştırma izni ver (zip'ten çıkınca izinler uçabiliyor)
chmod +x ./nfqws2 ./gost 2>/dev/null || true

# nftables kurulu mu kontrol et, yoksa otomatik yükle
if ! command -v nft >/dev/null 2>&1; then
    echo "nftables bulunamadı, kuruluyor..."
    sudo apt update && sudo apt install -y nftables
fi

# Tanımlı Parametreler
OPT1_ARGS="--payload=tls_client_hello --lua-desync=multidisorder:pos=2:seqovl=1"
OPT2_ARGS="--payload=tls_client_hello --lua-desync=multisplit:blob=fake_default_tls:ip_ttl=5:pos=2:nodrop:repeats=1"
OPT3_ARGS="--payload=tls_client_hello --lua-desync=fake:blob=0x00000000:ip_ttl=6:repeats=1"

# Menü
echo "================================================================================"
echo "                            LÜTFEN ISS SEÇİNİZ"
echo "================================================================================"
echo "1) Türk Telekom / Superonline / Kablonet / Turkcell Mobil / Vodafone Mobil"
echo "   -> $OPT1_ARGS"
echo ""
echo "2) Vodafone (Ev İnterneti)"
echo "   -> $OPT2_ARGS"
echo ""
echo "3) Türk Telekom Mobil"
echo "   -> $OPT3_ARGS"
echo ""
echo "4) Kendim parametre gireceğim"
echo "================================================================================"
read -rp "Seçiminiz [1-4]: " secim

case "$secim" in
    1)
        DESYNC_ARGS="$OPT1_ARGS"
        ;;
    2)
        DESYNC_ARGS="$OPT2_ARGS"
        ;;
    3)
        DESYNC_ARGS="$OPT3_ARGS"
        ;;
    4)
        echo ""
        echo "Örnek format: --payload=tls_client_hello --lua-desync=..."
        read -rp "Parametreyi girin: " DESYNC_ARGS
        if [ -z "$DESYNC_ARGS" ]; then
            echo "Boş parametre girildi, çıkılıyor."
            exit 1
        fi
        ;;
    *)
        echo "Geçersiz seçim yapıldı. Varsayılan (1) seçildi."
        DESYNC_ARGS="$OPT1_ARGS"
        ;;
esac

echo ""
echo "Kullanılacak parametre: $DESYNC_ARGS"

# nftables kurallarını ayarla
echo "nftables kuralları uygulanıyor..."
sudo killall nfqws2 2>/dev/null || true
sudo nft delete table inet ztest 2>/dev/null || true
sudo nft create table inet ztest
sudo nft add chain inet ztest post "{type filter hook postrouting priority 101;}"
sudo nft add rule inet ztest post meta mark and 0x40000000 == 0 tcp dport "{80,443}" ct original packets 1-12 queue num 200 bypass
sudo nft add rule inet ztest post meta mark and 0x40000000 == 0 udp dport "{443}" ct original packets 1-12 queue num 200 bypass

# nfqws2 başlat
echo "nfqws2 başlatılıyor..."
sudo ./nfqws2 --lua-init="@zapret-lib.lua" \
             --lua-init="@zapret-antidpi.lua" \
             --lua-init="@zapret-auto.lua" \
             $DESYNC_ARGS \
             --hostlist-exclude-domains=gov.tr \
             --qnum=200 > /dev/null 2>&1 &
NFQWS_PID=$!

sleep 1
if ! sudo kill -0 "$NFQWS_PID" 2>/dev/null; then
    echo "================================================================================"
    echo "HATA: nfqws2 başlatılamadı veya çöktü! Yanlış parametre: '$DESYNC_ARGS'"
    echo "================================================================================"
    sudo nft delete table inet ztest 2>/dev/null || true
    exit 1
fi

# gost başlat
echo "gost arka planda başlatılıyor..."
nohup ./gost -L "socks5://127.0.0.1:8849?udp=true&dns=https://1.0.0.1/dns-query" > /dev/null 2>&1 &

# Tüm arka plan süreçlerini terminalden kopar
disown -a 2>/dev/null || true

echo "================================================================================"
echo "Tüm servisler arka planda başlatıldı! Terminali kapatabilirsiniz."
echo "Bağlanılacak Proxy Adresi : socks5://127.0.0.1:8849"
echo "Durdurmak için            : ./stop-zapret.sh"
echo "================================================================================"