# CI/CD Setup Guide

Bu dokümantasyon, Liquid Glass OTP App projesi için GitHub Actions CI/CD pipeline'ının kurulumu ve yapılandırması hakkında bilgi içerir.

## 🔧 Gerekli GitHub Secrets

Aşağıdaki secrets'ları GitHub repository'nizin Settings > Secrets and variables > Actions bölümünde tanımlamanız gerekir:

### Firebase Configuration
```
FIREBASE_WEB_API_KEY=your_web_api_key
FIREBASE_WEB_APP_ID=your_web_app_id
FIREBASE_WEB_MESSAGING_SENDER_ID=your_messaging_sender_id
FIREBASE_WEB_PROJECT_ID=your_project_id
FIREBASE_WEB_AUTH_DOMAIN=your_auth_domain
FIREBASE_WEB_STORAGE_BUCKET=your_storage_bucket
FIREBASE_WEB_MEASUREMENT_ID=your_measurement_id

FIREBASE_ANDROID_API_KEY=your_android_api_key
FIREBASE_ANDROID_APP_ID=your_android_app_id

FIREBASE_IOS_API_KEY=your_ios_api_key
FIREBASE_IOS_APP_ID=your_ios_app_id
FIREBASE_IOS_IOS_BUNDLE_ID=your_ios_bundle_id

FIREBASE_MACOS_API_KEY=your_macos_api_key
FIREBASE_MACOS_APP_ID=your_macos_app_id
FIREBASE_MACOS_IOS_BUNDLE_ID=your_macos_bundle_id

FIREBASE_WINDOWS_API_KEY=your_windows_api_key
FIREBASE_WINDOWS_APP_ID=your_windows_app_id
```

### API Keys
```
GEMINI_API_KEY=your_gemini_api_key
```

### Firebase Deployment (Opsiyonel - Web deployment için)
```
FIREBASE_TOKEN=your_firebase_token
FIREBASE_SERVICE_ACCOUNT_KEY=your_service_account_json
FIREBASE_PROJECT_ID=your_project_id
```

## 🚀 Workflow'lar

### 1. Flutter CI/CD (`flutter_ci.yml`)

**Tetikleyiciler:**
- `main` ve `develop` branch'lerine push
- `main` ve `develop` branch'lerine pull request

**Jobs:**

#### Test Job
- Code quality checks (formatting, analysis)
- Unit test'lerin çalıştırılması
- Test coverage raporu
- Codecov'a coverage upload

#### Build Jobs (Sadece main branch'e push'ta)
- **Android Build**: APK ve AAB dosyalarının oluşturulması
- **Web Build**: Web versiyonunun build edilmesi
- **iOS Build**: iOS versiyonunun build edilmesi (macOS runner)

### 2. Deploy Workflow (`deploy.yml`)

**Tetikleyiciler:**
- `main` branch'e push
- Manuel tetikleme (`workflow_dispatch`)

**Özellikler:**
- Web versiyonunu Firebase Hosting'e deploy eder
- Otomatik environment variables enjeksiyonu
- Build artifacts'ların yönetimi

## 📋 Kurulum Adımları

### 1. GitHub Secrets Yapılandırması

1. GitHub repository'nize gidin
2. Settings > Secrets and variables > Actions
3. "New repository secret" butonuna tıklayın
4. Yukarıdaki listedeki her secret için:
   - Name: Secret adı
   - Value: Gerçek değer
   - "Add secret" butonuna tıklayın

### 2. Firebase Service Account (Deployment için)

Firebase Hosting deployment için:

1. Firebase Console'a gidin
2. Project Settings > Service accounts
3. "Generate new private key" butonuna tıklayın
4. İndirilen JSON dosyasının içeriğini `FIREBASE_SERVICE_ACCOUNT_KEY` secret'ına ekleyin

### 3. Firebase Token (Alternatif)

```bash
npm install -g firebase-tools
firebase login:ci
```

Çıkan token'ı `FIREBASE_TOKEN` secret'ına ekleyin.

## 🔍 Monitoring ve Debugging

### Workflow Durumunu Kontrol Etme

1. GitHub repository > Actions tab
2. Son workflow run'larını görüntüleyin
3. Başarısız job'lar için log'ları inceleyin

### Yaygın Sorunlar ve Çözümleri

#### 1. Environment Variables Hatası
- Tüm gerekli secrets'ların tanımlandığından emin olun
- Secret adlarının doğru yazıldığından emin olun

#### 2. Build Hatası
- Flutter version uyumluluğunu kontrol edin
- Dependencies'lerin güncel olduğundan emin olun

#### 3. Deployment Hatası
- Firebase project ID'nin doğru olduğundan emin olun
- Service account permissions'larını kontrol edin

## 📊 Code Coverage

Codecov entegrasyonu ile test coverage takibi:

1. [Codecov.io](https://codecov.io)'ya gidin
2. GitHub hesabınızla giriş yapın
3. Repository'yi ekleyin
4. Coverage raporları otomatik olarak güncellenecek

## 🔄 Workflow Optimizasyonu

### Cache Kullanımı
- Flutter SDK cache'i aktif
- Pub dependencies cache'i aktif
- Node.js dependencies cache'i aktif

### Paralel Job'lar
- Test job tüm build job'lardan önce çalışır
- Build job'lar paralel olarak çalışır
- Sadece main branch'e push'ta build job'lar çalışır

### Artifact Management
- Build çıktıları artifact olarak saklanır
- 90 gün boyunca erişilebilir
- İndirilebilir format

## 🛡️ Güvenlik

### Secret Management
- API key'ler GitHub Secrets'ta güvenli şekilde saklanır
- .env dosyası .gitignore'da
- .env.example template dosyası mevcut

### Branch Protection
- main branch için protection rules önerilir
- Pull request review requirement
- Status check requirement

## 📈 Gelecek İyileştirmeler

- [ ] Automated testing on multiple Flutter versions
- [ ] Integration tests
- [ ] Performance testing
- [ ] Automated security scanning
- [ ] Release automation
- [ ] Slack/Discord notifications
- [ ] Staging environment deployment