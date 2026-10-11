import requests
from bs4 import BeautifulSoup
from database import veritabani_kur, ilan_ekle, tum_kullanicilari_getir, kullanici_ekle
from bildirim import telegram_mesaj_gonder

def test_kullanicisi_olustur():
    kullanici_ekle(
        ad_soyad="İbrahim", 
        telegram_chat_id="7565987235", 
        aranacak_kelimeler="4291, 3001, Bilişim, Mühendis, Memur, Sağlık, Üniversite, Uzman"
    )

# SBB'nin ilan listeleme / arama sonuçlarının bulunduğu tam kaynak URL'si
HEDEF_SITELER = [
    {
        "isim": "SBB Kamu İlan",
        "url": "https://kamuilan.sbb.gov.tr/",
        "secici": "a[href*='ilanDetay.aspx']" # Sadece ilan detayına giden linkleri doğrudan seçer
    }
]

def coklu_site_tara_ve_dagit():
    veritabani_kur()
    test_kullanicisi_olustur()
    
    kullanicilar = tum_kullanicilari_getir()

    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    }

    toplam_yeni_ilan = 0

    for site in HEDEF_SITELER:
        print(f"\n[{site['isim']}] taranıyor: {site['url']}")
        try:
            response = requests.get(site['url'], headers=headers, timeout=10)
            print(f"HTTP Durum Kodu: {response.status_code}")
            
            if response.status_code != 200:
                continue

            soup = BeautifulSoup(response.text, 'html.parser')
            # Doğrudan ilan detay linklerini filtreleyerek seçiyoruz
            linkler = soup.select(site['secici'])
            print(f"Bulunan geçerli ilan link sayısı: {len(linkler)}")

            islenen = 0
            for link in linkler:
                baslik = link.get_text(strip=True)
                href = link.get('href')

                if baslik and len(baslik) > 10 and href:
                    if href.startswith('/'):
                        detay_url = f"https://kamuilan.sbb.gov.tr{href}"
                    elif not href.startswith('http'):
                        detay_url = f"https://kamuilan.sbb.gov.tr/{href}"
                    else:
                        detay_url = href

                    try:
                        detay_resp = requests.get(detay_url, headers=headers, timeout=5)
                        if detay_resp.status_code == 200:
                            detay_soup = BeautifulSoup(detay_resp.text, 'html.parser')
                            detay_metni = detay_soup.get_text()

                            yeni_id = ilan_ekle(
                                baslik=baslik, 
                                kurum=site['isim'], 
                                link=detay_url, 
                                detay_metni=detay_metni[:1000]
                            )

                            if yeni_id:
                                toplam_yeni_ilan += 1
                                islenen += 1
                                print(f"[YENİ İLAN EKLENDİ]: {baslik[:40]}...")
                                
                                if kullanicilar:
                                    for ad, chat_id, kelimeler_str in kullanicilar:
                                        kullanici_hedefleri = [k.strip().lower() for k in kelimeler_str.split(",")]
                                        for hedef in kullanici_hedefleri:
                                            if hedef in detay_metni.lower() or hedef in baslik.lower():
                                                mesaj = f"🚨 Merhaba {ad}, kriterinle eşleşen yeni ilan!\n\n*Kurum:* {site['isim']}\n*Başlık:* {baslik}\n\n[İlana Git]({detay_url})"
                                                telegram_ozel_mesaj_gonder(chat_id, mesaj)
                                                break
                    except Exception as sub_e:
                        continue

            print(f"Bu oturumda {site['isim']} kaynağından {islenen} yeni ilan işlendi.")

        except Exception as e:
            print(f"Hata oluştu ({site['isim']}): {e}")

    print(f"\nTüm tarama süreçleri tamamlandı! Toplam {toplam_yeni_ilan} yeni ilan sisteme eklendi.")

def telegram_ozel_mesaj_gonder(chat_id, mesaj):
    TOKEN = "8958539108:AAGJA5wMnnXKsdZV9kDC7lUYb3hnJ86hWw0"
    url = f"https://api.telegram.org/bot{TOKEN}/sendMessage"
    payload = {
        "chat_id": chat_id,
        "text": mesaj,
        "parse_mode": "Markdown"
    }
    try:
        requests.post(url, json=payload)
    except Exception as e:
        print(f"Telegram gönderim hatası: {e}")

if __name__ == "__main__":
    coklu_site_tara_ve_dagit()