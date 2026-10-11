import requests

TOKEN = "8958539108:AAGJA5wMnnXKsdZV9kDC7lUYb3hnJ86hWw0"
url = f"https://api.telegram.org/bot{TOKEN}/getUpdates"

response = requests.get(url)
data = response.json()

print("Gelen Yanıt:", data)

try:
    # Gelen mesajlar arasından chat id'yi çekmeye çalışalım
    chat_id = data["result"][0]["message"]["chat"]["id"]
    print(f"\n---> SENİN CHAT ID'N: {chat_id} <---")
except Exception as e:
    print("\n[Hata] Henüz botunuza hiç mesaj göndermemiş olabilirsiniz.")
    print("Lütfen Telegram'da botunuzun sohbetini açıp 'Selam' gibi bir mesaj gönderin ve bu kodu tekrar çalıştırın.")