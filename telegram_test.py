from bildirim import telegram_mesaj_gonder

# Buraya kendi Telegram Chat ID'ni yazabilirsin (Mobil uygulamada kaydettiğin ID)
test_chat_id = "7565987235"

mesaj = """🚨 *Test Bildirimi*

Bu mesaj Kamu Alım Takip sistemi tarafından Telegram entegrasyonunu test etmek için gönderilmiştir! 

*Eşleşen Kriter:* 4291, 3001
[İlanı İncele](https://kamuilan.sbb.gov.tr)"""

print("Telegram testi gönderiliyor...")
telegram_mesaj_gonder(test_chat_id, mesaj)