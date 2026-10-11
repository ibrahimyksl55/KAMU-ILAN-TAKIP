from fastapi import FastAPI, Query
from pydantic import BaseModel
import sqlite3
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# FastAPI uygulamasını oluşturduktan sonra (app = FastAPI() satırından hemen sonra):
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Tüm kaynaklardan gelen isteklere izin ver
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class KullaniciAyarlariModel(BaseModel):
    ad_soyad: str
    telegram_chat_id: str
    aranacak_kelimeler: str

@app.post("/api/kullanici/ayarlar")
def kullanici_ayarlarini_kaydet(veri: KullaniciAyarlariModel):
    """Kullanıcının profil ayarlarını ve takip kriterlerini veritabanına kaydeder/günceller."""
    conn = sqlite3.connect("kamu_ilanlari.db")
    cursor = conn.cursor()
    try:
        cursor.execute('''
            INSERT INTO kullanicilar (ad_soyad, telegram_chat_id, aranacak_kelimeler)
            VALUES (?, ?, ?)
            ON CONFLICT(telegram_chat_id) DO UPDATE SET
                ad_soyad = excluded.ad_soyad,
                aranacak_kelimeler = excluded.aranacak_kelimeler
        ''', (veri.ad_soyad, veri.telegram_chat_id, veri.aranacak_kelimeler))
        conn.commit()
        return {"status": "success", "message": "Kullanıcı ayarları başarıyla kaydedildi!"}
    except Exception as e:
        return {"status": "error", "message": str(e)}
    finally:
        conn.close()

@app.get("/api/ilanlar/filtrele")
def ilanlari_kriter_gore_getir(
    kullanici_id: int = None, 
    arama_terimi: str = Query(None, description="Örn: 4291, Bilişim, Mühendis")
):
    """
    Kullanıcının profilinde kayıtlı nitelik kodlarına veya arama çubuğuna 
    girdiği kelimelere göre SIKI VE NOKTA ATIŞI filtreleme yapar.
    Kriter girilmemişse boş liste döner (rastgele ilan akışı sunmaz).
    """
    conn = sqlite3.connect("kamu_ilanlari.db")
    cursor = conn.cursor()
    
    hedef_kelime = arama_terimi
    
    if kullanici_id and not hedef_kelime:
        cursor.execute("SELECT aranacak_kelimeler FROM kullanicilar WHERE id = ?", (kullanici_id,))
        kullanici_row = cursor.fetchone()
        if kullanici_row and kullanici_row[0]:
            hedef_kelime = kullanici_row[0]

    # Eğer hiçbir arama terimi veya kriter belirtilmemişse, gürültü yaratmamak için boş liste döndür!
    if not hedef_kelime or not hedef_kelime.strip():
        conn.close()
        return {
            "status": "success",
            "filter_applied": "Yok",
            "count": 0,
            "data": []
        }

    kelimeler = [k.strip() for k in hedef_kelime.split(",") if k.strip()]
    sartlar = []
    parametreler = []
    for k in kelimeler:
        sartlar.append("(baslik LIKE ? OR detay_metni LIKE ?)")
        parametreler.extend([f"%{k}%", f"%{k}%"])
        
    sorgu = f"SELECT id, baslik, kurum, link, tarih FROM ilanlar WHERE " + " OR ".join(sartlar) + " ORDER BY id DESC"
    cursor.execute(sorgu, tuple(parametreler))
        
    kayitlar = cursor.fetchall()
    conn.close()
    
    ilan_listesi = []
    for row in kayitlar:
        ilan_listesi.append({
            "id": row[0],
            "baslik": row[1],
            "kurum": row[2],
            "link": row[3],
            "tarih": row[4]
        })
        
    return {
        "status": "success",
        "filter_applied": hedef_kelime,
        "count": len(ilan_listesi),
        "data": ilan_listesi
    }