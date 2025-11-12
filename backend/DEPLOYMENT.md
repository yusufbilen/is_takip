# Backend Deployment Rehberi

Bu rehber, Dava Takip backend'ini bulut sunucuya deploy etmek için adımları içerir.

## 🚀 Hızlı Başlangıç

### Seçenek 1: Render (ÜCRETSİZ - Önerilen) ⭐

1. **Render hesabı oluşturun**: https://render.com (GitHub ile giriş yapın)
2. **Yeni Web Service oluşturun**:
   - "New" > "Web Service" seçin
   - GitHub repo'nuzu bağlayın
   - **Settings**:
     - **Name**: `dava-takip-backend` (istediğiniz isim)
     - **Root Directory**: `backend`
     - **Environment**: `Python 3`
     - **Build Command**: `pip install -r requirements.txt`
     - **Start Command**: `gunicorn app:app`
   - **Environment Variables**:
     - Key: `OPENAI_API_KEY`
     - Value: API key'iniz
   - **Plan**: Free (ücretsiz)
3. **Create Web Service**: Deploy başlar!

**Render URL'i**: `https://dava-takip-backend.onrender.com`

**Not**: Ücretsiz plan uyku moduna girebilir (ilk istek 30-60 saniye sürebilir)

---

### Seçenek 2: Railway (Ücretli - $5/ay)

1. **Railway hesabı oluşturun**: https://railway.app
2. **Yeni proje oluşturun**: "New Project" > "Deploy from GitHub repo"
3. **Backend klasörünü seçin**: `backend` klasörünü root olarak ayarlayın
4. **Environment Variables ekleyin**:
   - `OPENAI_API_KEY`: OpenAI API key'iniz
   - `PORT`: Railway otomatik ayarlar (gerekmez)
5. **Deploy**: Otomatik deploy başlar!

**Railway URL'i**: `https://your-project-name.railway.app`

---

### Seçenek 3: Render

1. **Render hesabı oluşturun**: https://render.com
2. **Yeni Web Service oluşturun**:
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `gunicorn app:app`
   - **Root Directory**: `backend`
3. **Environment Variables ekleyin**:
   - `OPENAI_API_KEY`: OpenAI API key'iniz
4. **Deploy**: Otomatik deploy başlar!

**Render URL'i**: `https://your-project-name.onrender.com`

---

### Seçenek 3: Fly.io (ÜCRETSİZ - Alternatif)

1. **Fly.io hesabı oluşturun**: https://fly.io
2. **Fly CLI kurulumu**:
   ```bash
   # Windows: https://fly.io/docs/hands-on/install-flyctl/
   # Mac: brew install flyctl
   ```
3. **Login**:
   ```bash
   fly auth login
   ```
4. **Deploy**:
   ```bash
   cd backend
   fly launch
   ```
5. **Environment Variables**:
   ```bash
   fly secrets set OPENAI_API_KEY=your_api_key_here
   ```

**Fly.io URL'i**: `https://your-app-name.fly.dev`

---

### Seçenek 4: Heroku

1. **Heroku CLI kurulumu**:
   ```bash
   # Windows: https://devcenter.heroku.com/articles/heroku-cli
   # Mac: brew install heroku/brew/heroku
   ```

2. **Heroku'ya giriş yapın**:
   ```bash
   heroku login
   ```

3. **Yeni uygulama oluşturun**:
   ```bash
   cd backend
   heroku create your-app-name
   ```

4. **Environment Variables ekleyin**:
   ```bash
   heroku config:set OPENAI_API_KEY=your_api_key_here
   ```

5. **Deploy edin**:
   ```bash
   git init  # Eğer git yoksa
   git add .
   git commit -m "Initial commit"
   git push heroku main
   ```

**Heroku URL'i**: `https://your-app-name.herokuapp.com`

---

### Seçenek 5: DigitalOcean App Platform (Ücretli - $5/ay)

1. **DigitalOcean hesabı oluşturun**: https://www.digitalocean.com
2. **Yeni App oluşturun**: "Create App" > GitHub repo seçin
3. **Ayarlar**:
   - **Type**: Web Service
   - **Build Command**: `pip install -r requirements.txt`
   - **Run Command**: `gunicorn app:app`
   - **Root Directory**: `backend`
4. **Environment Variables ekleyin**: `OPENAI_API_KEY`
5. **Deploy**: Otomatik deploy başlar!

---

## 📱 Flutter Uygulamasını Güncelleme

Backend deploy edildikten sonra, Flutter uygulamasındaki `lib/services/api_service.dart` dosyasını güncelleyin:

```dart
static const String _productionUrl = 'https://your-backend-url.railway.app/api';
// veya
static const String _productionUrl = 'https://your-backend-url.onrender.com/api';
// veya
static const String _productionUrl = 'https://your-app-name.herokuapp.com/api';
```

## 🔒 Güvenlik Notları

1. **API Key Güvenliği**: 
   - `.env` dosyasını asla Git'e commit etmeyin
   - Production'da environment variables kullanın

2. **CORS**: 
   - Backend'de `CORS(app)` zaten aktif
   - Production'da domain kısıtlaması ekleyebilirsiniz

3. **HTTPS**: 
   - Tüm production servisleri otomatik HTTPS sağlar
   - Flutter uygulamasında `https://` kullanın

## 🧪 Test

Deploy sonrası test:

```bash
curl https://your-backend-url.railway.app/api/ai/chat \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"message": "Merhaba", "asistan_turu": "genel", "history": []}'
```

## 📊 Monitoring

- **Railway**: Dashboard'da loglar ve metrics görüntülenir
- **Render**: Dashboard'da loglar görüntülenir
- **Heroku**: `heroku logs --tail` komutu ile loglar görüntülenir

## 💰 Maliyet Karşılaştırması

| Servis | Ücretsiz | Ücretli | Notlar |
|--------|----------|---------|--------|
| **Render** | ✅ Evet | - | Uyku modu var (ilk istek yavaş) |
| **Fly.io** | ✅ Evet | $0.000015/saniye | Kredi limiti var |
| **Railway** | ❌ Hayır | $5/ay | Ücretsiz tier kaldırıldı |
| **Heroku** | ❌ Hayır | $7/ay+ | Ücretsiz tier kaldırıldı |
| **DigitalOcean** | ❌ Hayır | $5/ay | En ucuz ücretli seçenek |

**Öneri**: Render ile başlayın (ücretsiz), sonra ihtiyaç olursa ücretli plana geçin.

## 🐛 Sorun Giderme

### Backend çalışmıyor:
- Logları kontrol edin
- Environment variables doğru mu?
- Port ayarları doğru mu?

### CORS hatası:
- Backend'de `CORS(app)` aktif mi?
- Flutter'da doğru URL kullanılıyor mu?

### OpenAI API hatası:
- API key doğru mu?
- Environment variable doğru ayarlanmış mı?

