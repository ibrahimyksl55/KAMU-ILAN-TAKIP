import time
import schedule
from scraper import ilanlari_tara_ve_dagit

def gorev():
    print("\n[OTOMATİK TARAMA] Arka plan taraması başlatıldı...")
    try:
        ilanlari_tara_ve_dagit()
        print("[OTOMATİK TARAMA] Tarama başarıyla tamamlandı ve dağıtıldı.")
    except Exception as e:
        print(f"[HATA] Tarama sırasında bir sorun oluştu: {e}")

# İlk açılışta hemen bir kez çalıştır
gorev()

# Her 1 saatte bir çalışacak şekilde ayarla (süreyi ihtiyacınıza göre değiştirebilirsiniz)
schedule.every(1).hours.do(gorev)

# Veya test için her 1 dakikada bir çalıştırmak isterseniz:
# schedule.every(1).minutes.do(gorev)

print("Sistem otomatik arkaplan taraması için aktif edildi. Kapatmak için Ctrl+C tuşlarına basın.")

while True:
    schedule.run_pending()
    time.sleep(1)