import requests

# BotFather'dan aldığınız Bot Token'ı buraya yazın
TELEGRAM_BOT_TOKEN = "8958539108:AAGJA5wMnnXKsdZV9kDC7lUYb3hnJ86hWw0"

def telegram_mesaj_gonder(chat_id, mesaj):

    print(f"DEBUG - Okunan Token: {TELEGRAM_BOT_TOKEN}")
    if not TELEGRAM_BOT_TOKEN or TELEGRAM_BOT_TOKEN == "BURAYA_BOT_TOKEN_YAZILACAK":
        print("[HATA] Telegram Bot Token tanımlanmamış!")
        return False
        
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
    payload = {
        "chat_id": chat_id,
        "text": mesaj,
        "parse_mode": "Markdown"
    }
    
    try:
        response = requests.post(url, json=payload)
        if response.status_code == 200:
            print(f"[BİLDİRİM] Telegram mesajı başarıyla gönderildi (Chat ID: {chat_id})")
            return True
        else:
            print(f"[HATA] Telegram mesajı gönderilemedi: {response.text}")
            return False
    except Exception as e:
        print(f"[HATA] Bağlantı hatası: {e}")
        return False