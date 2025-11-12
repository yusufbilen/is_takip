# GitHub'a Yükleme Rehberi

## 1. GitHub'da Yeni Repo Oluşturun

1. https://github.com adresine gidin
2. Sağ üstte "+" > "New repository" tıklayın
3. **Repository name**: `is_takip` (veya istediğiniz isim)
4. **Description**: "Dava Takip Mobil Uygulaması"
5. **Public** veya **Private** seçin (Private önerilir - API key güvenliği için)
6. **Initialize this repository with:** Hiçbirini işaretlemeyin (README, .gitignore, license)
7. **Create repository** butonuna tıklayın

## 2. Terminal Komutları (Proje Klasöründe)

```bash
# Git repository başlat
git init

# Tüm dosyaları ekle
git add .

# İlk commit
git commit -m "Initial commit: Dava Takip uygulaması"

# GitHub repo'nuzu remote olarak ekle
# NOT: YOUR_USERNAME ve REPO_NAME'i kendi bilgilerinizle değiştirin
git remote add origin https://github.com/YOUR_USERNAME/is_takip.git

# Branch oluştur ve değiştir
git branch -M main

# GitHub'a push et
git push -u origin main
```

## 3. Önemli Notlar

- `.env` dosyası `.gitignore`'da olduğu için push edilmez (güvenlik)
- API key'ler GitHub'a gitmez
- İlk push'ta GitHub kullanıcı adı ve şifre istenebilir

## 4. Push Sonrası

GitHub'da repo göründükten sonra Render'da "Connect GitHub" yapabilirsiniz!

