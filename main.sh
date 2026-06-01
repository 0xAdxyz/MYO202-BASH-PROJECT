#!/bin/bash

# İsim SOYİSİM
# Öğrenci Numarası
# Sertifika Bağlantıları:
# 1) https://
# 2) https://
# 3) https://credsverse.com/credentials/0055bab0-b92e-46af-866b-7ed2eac451f6

# ============================================================
# MYO202 BASH PROJECT - Sistem Bilgi Raporu ve Şifreleme
# ============================================================

RAPOR_DOSYASI="report.log"
SIFRELI_DOSYA="report.log.gpg"

# ----------------------------------------------------------
# 1) Günlük dosyası oluştur ve ISO tarih/saat yaz
# ----------------------------------------------------------
echo "$(date -u +"%Y-%m-%dT%H:%M:%S%z")" > "$RAPOR_DOSYASI"
echo "==========================================" >> "$RAPOR_DOSYASI"
echo "       SİSTEM DONANIM BİLGİ RAPORU        " >> "$RAPOR_DOSYASI"
echo "==========================================" >> "$RAPOR_DOSYASI"
echo "" >> "$RAPOR_DOSYASI"

# ----------------------------------------------------------
# 2) Donanım bilgilerini topla (Windows - wmic & getmac)
# ----------------------------------------------------------

echo "--- İşlemci Bilgisi ---" >> "$RAPOR_DOSYASI"
wmic cpu get Name,NumberOfCores,MaxClockSpeed /format:list 2>/dev/null \
    | tr -d '\r' | sed '/^$/d' >> "$RAPOR_DOSYASI"
echo "" >> "$RAPOR_DOSYASI"

echo "--- RAM Bilgisi ---" >> "$RAPOR_DOSYASI"
wmic memorychip get Capacity,Speed,Manufacturer /format:list 2>/dev/null \
    | tr -d '\r' | sed '/^$/d' >> "$RAPOR_DOSYASI"
echo "" >> "$RAPOR_DOSYASI"

echo "--- Anakart Bilgisi ---" >> "$RAPOR_DOSYASI"
wmic baseboard get Manufacturer,Product,SerialNumber /format:list 2>/dev/null \
    | tr -d '\r' | sed '/^$/d' >> "$RAPOR_DOSYASI"
echo "" >> "$RAPOR_DOSYASI"

echo "--- UUID Bilgisi ---" >> "$RAPOR_DOSYASI"
wmic csproduct get UUID /format:list 2>/dev/null \
    | tr -d '\r' | sed '/^$/d' >> "$RAPOR_DOSYASI"
echo "" >> "$RAPOR_DOSYASI"

echo "--- Disk Bilgisi ---" >> "$RAPOR_DOSYASI"
wmic diskdrive get Model,Size,SerialNumber /format:list 2>/dev/null \
    | tr -d '\r' | sed '/^$/d' >> "$RAPOR_DOSYASI"
echo "" >> "$RAPOR_DOSYASI"

echo "--- MAC Adresi Bilgisi ---" >> "$RAPOR_DOSYASI"
getmac /v /fo list 2>/dev/null \
    | tr -d '\r' | sed '/^$/d' >> "$RAPOR_DOSYASI"
echo "" >> "$RAPOR_DOSYASI"

echo "==========================================" >> "$RAPOR_DOSYASI"
echo "         RAPOR SONU                        " >> "$RAPOR_DOSYASI"
echo "==========================================" >> "$RAPOR_DOSYASI"

echo "[✔] Donanım bilgileri report.log dosyasına yazıldı."

# ----------------------------------------------------------
# 3) Kullanıcıdan parola al
# ----------------------------------------------------------
read -s -p "Lütfen parolanızı girin (MYO+202 formatında): " PAROLA
echo ""

# ----------------------------------------------------------
# 4) GPG ile AES256 simetrik şifreleme (batch modu)
# ----------------------------------------------------------
# Daha önce oluşturulmuş .gpg dosyası varsa sil
if [ -f "$SIFRELI_DOSYA" ]; then
    rm -f "$SIFRELI_DOSYA"
fi

gpg --batch --yes --passphrase "$PAROLA" \
    --symmetric --cipher-algo AES256 \
    --output "$SIFRELI_DOSYA" \
    "$RAPOR_DOSYASI"

if [ $? -eq 0 ]; then
    echo "[✔] report.log başarıyla AES256 ile şifrelendi -> report.log.gpg"
    # Orijinal şifresiz dosyayı sil
    rm -f "$RAPOR_DOSYASI"
    echo "[✔] Orijinal report.log dosyası silindi."
else
    echo "[✘] Şifreleme sırasında bir hata oluştu!"
    exit 1
fi

echo ""
echo "İşlem tamamlandı. Şifreli rapor: $SIFRELI_DOSYA"
