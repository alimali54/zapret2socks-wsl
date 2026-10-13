#!/usr/bin/env bash

echo "Servisler kapatılıyor..."

# Süreçleri sonlandır
sudo killall -9 nfqws2 2>/dev/null || true
killall -9 gost 2>/dev/null || true

# nftables tablosunu temizle
sudo nft delete table inet ztest 2>/dev/null || true

echo "Temizlik tamamlandı. Tüm servisler durduruldu."