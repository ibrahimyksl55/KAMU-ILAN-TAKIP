# 🔔 Kamu Alım Takip & Akıllı Filtreleme Asistanı

Resmi kurumlardaki (SBB vb.) ilanları günlük olarak otomatik tarayan, mükerrer kayıtları veritabanı düzeyinde engelleyen ve kullanıcıların profilindeki nitelik kodlarına (*örn. 4291, 3001*) ve anahtar kelimelere göre **nokta atışı akıllı filtreleme** yaparak Telegram üzerinden anlık bildirim gönderen modern bir takip sistemidir.

---

## 🚀 Projenin Amacı ve Öne Çıkan Özellikler

* **Nokta Atışı Filtreleme:** Kullanıcının sadece kendi arama kriterlerine ve nitelik kodlarına uyan ilanları listeler, gürültülü ve alakasız veri akışını engeller.
* **Mükerrer Kayıt Koruması:** SQLite veritabanında link bazlı `UNIQUE` kısıtlaması sayesinde aynı ilanın sisteme tekrar eklenmesini önler.
* **Telegram Entegrasyonu:** Eşleşen ilanları anında ilgili kullanıcının Telegram Chat ID'sine özel bildirim olarak ulaştırır.
* **Çoklu Platform Desteği:** Python FastAPI altyapısına sahip güçlü bir backend ve Flutter ile geliştirilmiş modern, koyu temalı (Dark Mode) bir mobil/web arayüzü sunar.

---

## 🛠️ Kullanılan Teknoloji Yığını

* **Frontend (Arayüz):** Flutter (Mobil & Web uyumlu, özel `AppTheme` ve `FilterChip` yapıları)
* **Backend (Sunucu):** Python FastAPI, Pydantic
* **Veritabanı:** SQLite (`kamu_ilanlari.db`), SQL Dinamik Sorgu Mimarisi
* **Veri Kazıma (Scraping):** BeautifulSoup, Requests
* **Bildirim Servisi:** Telegram Bot API

---

## ⚙️ Sistem Mimarisi ve İşleyiş

1. **Scraper Katmanı (`scraper.py`):** Resmi kaynaklardaki ilan başlıklarını ve detay metinlerini periyodik olarak çeker.
2. **Veritabanı Katmanı (`database.py`):** Çekilen verileri `ilanlar` tablosuna işlerken mükerrerlik kontrolü yapar; kullanıcı ayarlarını ve arama kriterlerini `kullanicilar` tablosunda saklar.
3. **API Katmanı (`main.py`):** FastAPI üzerinden `/api/ilanlar/filtrele` ve `/api/kullanici/ayarlar` uç noktalarını sunarak arayüz ile veritabanı arasında güvenli ve hızlı köprü kurar.
4. **Mobil/Web Katmanı (`main.dart`):** Kullanıcının kendi nitelik kodlarını tanımlayabildiği, gelen nokta atışı ilanları akışta ve favorilerde görebildiği modern arayüzü barındırır.

---

## 📂 Proje Dosya Yapısı

```text
kamu_ilan_proje/
│
├── kamu_ilan_mobil/          # Flutter Frontend Projesi
│   ├── lib/
│   │   └── main.dart         # Ana Mobil Arayüz ve API İstekleri
│   └── android/              # Android APK Yapılandırma Dosyaları
│
├── main.py                   # FastAPI Backend & Akıllı Filtreleme Uç Noktaları
├── scraper.py                # Web Kazıma ve Telegram Bildirim Servisi
├── database.py               # SQLite Veritabanı ve Tablo Kurulumları
└── kamu_ilanlari.db          # İlişkisel Veritabanı Dosyası
```
🛠️ Kurulum, Çalıştırma ve APK Süreci
Projeyi yerel ortamında çalıştırmak ve Android için derlemek istersen sırasıyla şu adımları izleyebilirsin:

1. Backend (FastAPI) Çalıştırılması
Terminalde proje ana dizinine gelerek bağımlılıkları yükle ve sunucuyu başlat:
```text
pip install fastapi uvicorn requests beautifulsoup4 pydantic
uvicorn main:app --host 0.0.0.0 --reload
```

2. Frontend (Flutter) Çalıştırılması
kamu_ilan_proje/kamu_ilan_mobil dizinine geçerek mobil/web uygulamasını derle:
```text
cd kamu_ilan_mobil
flutter pub get
flutter run
```

3. APK Kurulum Dosyasının Oluşturulması
Android cihazlar için release APK sürümünü oluşturmak üzere şu komutu çalıştırabilirsin:
```text
flutter build apk --release
```
Çıktı Konumu: build/app/outputs/flutter-apk/app-release.apk

👤 İletişim & Geliştirici
İbrahim Yüksel

GitHub: @ibrahimyksl55
