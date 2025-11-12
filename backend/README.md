# Dava Takip Backend API

Python Flask ile geliştirilmiş backend API servisi.

## Kurulum

```bash
# Sanal ortam oluştur
python -m venv venv

# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate

# Bağımlılıkları yükle
pip install -r requirements.txt

# Sunucuyu başlat
python app.py
```

API `http://localhost:5000` adresinde çalışacaktır.

## API Endpoints

### Hesaplama Modülleri

- `POST /api/hesaplama/infaz-suresi` - İnfaz süresi hesaplama
- `POST /api/hesaplama/miras-sakli-pay` - Miras saklı pay hesaplama
- `POST /api/hesaplama/harc` - Mahkeme harç hesaplama
- `POST /api/hesaplama/vekalet-ucreti` - Vekalet ücreti hesaplama
- `POST /api/hesaplama/arabuluculuk` - Arabuluculuk ücreti hesaplama
- `POST /api/hesaplama/makbuz` - Makbuz hesaplama

### Döviz

- `GET /api/doviz/kurlar` - TCMB'den güncel döviz kurları
- `POST /api/doviz/donustur` - Döviz dönüştürme

### Mevzuat

- `GET /api/mevzuat/arama?q=terim&tur=kanun` - Mevzuat arama

### Yargıtay Karar Arama

- `POST /api/yargitay/arama` - Yargıtay karar arama (gerçek veriler)
  - Body: `{"aranacak_kelime": "...", "birim": "...", "kurul": "...", "hukuk_dairesi": "...", "ceza_dairesi": "...", "esas_no": "...", "karar_no": "...", "karar_tarihi_baslangic": "...", "karar_tarihi_bitis": "...", "sirala": "esas_no"}`

- `GET /api/yargitay/populer` - Popüler kararlar (en çok tıklanan 10 karar)

### İçtihat

- `GET /api/ictihat/arama?q=terim&tur=yuksek_mahkeme` - İçtihat arama

### Pratik Bilgiler

- `GET /api/pratik-bilgiler/genel` - Genel bilgiler
- `GET /api/pratik-bilgiler/avukatlik-kurallari` - Avukatlık kuralları
- `GET /api/pratik-bilgiler/sozluk?q=terim` - Sözlük

### Yazım

- `GET /api/yazim/sablonlar` - Yazım şablonları

### AI Chat (Hukuk Asistanı)

- `POST /api/ai/chat` - AI chat (sadece hukuk konularında cevap verir)
  - Body: `{"message": "soru", "asistan_turu": "ictihat|mevzuat|dilekce|sozlesme|genel", "history": []}`

- `POST /api/ai/dilekce-yaz` - AI ile dilekçe yazma
  - Body: `{"dilekce_turu": "Genel Dilekçe", "mahkeme": "...", "davaci": "...", "davali": "...", "konu": "...", "ek_bilgiler": "..."}`

## OpenAI API Key Kurulumu

AI yanıtları için OpenAI API key gereklidir. İki yöntemle ekleyebilirsiniz:

### Yöntem 1: .env Dosyası (Önerilen)
```bash
# .env.example dosyasını .env olarak kopyalayın
cp .env.example .env

# .env dosyasını düzenleyip API key'inizi ekleyin
```

### Yöntem 2: Environment Variable
```bash
# Windows
set OPENAI_API_KEY=your_api_key_here

# Linux/Mac
export OPENAI_API_KEY=your_api_key_here
```

**Not:** `.env` dosyası `.gitignore`'da olduğu için Git'e commit edilmez (güvenlik için).

API key yoksa sistem fallback yanıtlar kullanır (sadece hukuk konularında).

