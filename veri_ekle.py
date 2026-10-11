from database import veritabani_kur, ilan_ekle

veritabani_kur()
ilan_ekle(
    baslik="Test İnternet ve Ağ Teknolojileri (4291) Personel Alım İlanı",
    kurum="Örnek Bakanlık",
    link="https://kamuilan.sbb.gov.tr",
    detay_metni="Bu bir test ilanıdır. Nitelik kodu: 4291, Bilişim personeli alınacaktır."
)
print("Örnek ilan eklendi!")