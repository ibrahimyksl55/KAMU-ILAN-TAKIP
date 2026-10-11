import sqlite3

def veritabani_kur():
    conn = sqlite3.connect("kamu_ilanlari.db")
    cursor = conn.cursor()
    
    # İlanlar Tablosu
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS ilanlar (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            baslik TEXT,
            kurum TEXT,
            link TEXT UNIQUE,
            detay_metni TEXT,
            tarih TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # Kullanıcılar Tablosu
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS kullanicilar (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ad_soyad TEXT,
            telegram_chat_id TEXT UNIQUE,
            aranacak_kelimeler TEXT
        )
    ''')
    
    conn.commit()
    conn.close()

def ilan_ekle(baslik, kurum, link, detay_metni):
    conn = sqlite3.connect("kamu_ilanlari.db")
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT id FROM ilanlar WHERE link = ?", (link,))
        if cursor.fetchone():
            return None
            
        cursor.execute('''
            INSERT INTO ilanlar (baslik, kurum, link, detay_metni)
            VALUES (?, ?, ?, ?)
        ''', (baslik, kurum, link, detay_metni))
        conn.commit()
        return cursor.lastrowid
    except Exception as e:
        print(f"İlan ekleme hatası: {e}")
        return None
    finally:
        conn.close()

def kullanici_ekle(ad_soyad, telegram_chat_id, aranacak_kelimeler):
    conn = sqlite3.connect("kamu_ilanlari.db")
    cursor = conn.cursor()
    try:
        cursor.execute('''
            INSERT OR IGNORE INTO kullanicilar (ad_soyad, telegram_chat_id, aranacak_kelimeler)
            VALUES (?, ?, ?)
        ''', (ad_soyad, telegram_chat_id, aranacak_kelimeler))
        conn.commit()
    except Exception as e:
        print(f"Kullanıcı ekleme hatası: {e}")
    finally:
        conn.close()

def tum_kullanicilari_getir():
    conn = sqlite3.connect("kamu_ilanlari.db")
    cursor = conn.cursor()
    cursor.execute("SELECT ad_soyad, telegram_chat_id, aranacak_kelimeler FROM kullanicilar")
    kullanicilar = cursor.fetchall()
    conn.close()
    return kullanicilar