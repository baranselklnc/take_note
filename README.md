# Take Note - Flutter Not Uygulaması

Flutter ile geliştirilmiş, gelişmiş arama özellikleri, offline destek ve akıllı not işleme özelliklerine sahip modern, AI destekli bir not alma uygulaması.

## Özellikler

### Temel İşlevsellik
- **Kimlik Doğrulama**: Supabase Auth ile güvenli kayıt olma, giriş yapma ve çıkış yapma
- **Not CRUD**: Not oluşturma, okuma, güncelleme, silme ve geri yükleme
- **Gelişmiş Arama**: Vurgulama ve semantic search özellikleri ile gerçek zamanlı arama
- **Not Sabitleme**: Önemli notları listenin en üstüne sabitleme
- **Silme Geri Al**: Snackbar bildirimleri ile 5 saniyelik geri alma işlevi
- **Offline Destek**: Çevrimiçi olduğunda otomatik senkronizasyon ile Hive local storage

### AI Destekli Özellikler
- **Not Özetleme**: Sıkıştırma istatistikleri ile AI destekli içerik özetleme
- **Otomatik Etiketleme**: Daha iyi organizasyon için akıllı etiket oluşturma
- **İçerik Kategorilendirme**: Otomatik not kategorilendirme
- **Semantic Search**: İçerik anlamını anlamak için AI kullanan gelişmiş arama

### Kullanıcı Deneyimi
- **Modern UI**: Özel temalama ile Material Design 3
- **Karanlık Mod**: Açık, karanlık ve sistem teması desteği
- **Responsive Tasarım**: Mobil ve masaüstü için optimize edilmiş
- **Onboarding**: SVG çizimlerle çok adımlı kullanıcı tanıtımı
- **Kullanıcı İstatistikleri**: Not kullanımı ve içerik analitiği
- **Kalıcı Arama**: Gelişmiş filtreleme ile her zaman görünür arama çubuğu

### Teknik Özellikler
- **Offline-First**: İnternet bağlantısı olmadan sorunsuz çalışma
- **Gerçek Zamanlı Sync**: Çevrimiçi olduğunda backend ile otomatik senkronizasyon
- **Hata Yönetimi**: Türkçe kullanıcı dostu hata mesajları
- **Performans**: Staggered grid layout ve animasyonlarla optimize edilmiş

## Mimari

### Tasarım Desenleri
- **MVVM Pattern**: Riverpod ile temiz katman ayrımı
- **Repository Pattern**: Soyutlanmış veri erişim katmanı
- **Provider Pattern**: Riverpod ile dependency injection

### Teknoloji Stack'i
- **Frontend**: Flutter 3.6+ ve Dart
- **State Management**: Code generation ile Riverpod
- **Backend Entegrasyonu**: Özel FastAPI backend + Supabase
- **Local Storage**: Offline veri kalıcılığı için Hive
- **UI Framework**: FlexColorScheme ile Material Design 3
- **Navigation**: Type-safe routing için GoRouter
- **HTTP Client**: Interceptor'lar ve hata yönetimi ile Dio

### Ana Bağımlılıklar
```yaml
# State Management
flutter_riverpod: ^2.4.9
riverpod_annotation: ^2.3.3
flutter_hooks: ^0.20.5
hooks_riverpod: ^2.4.9

# Backend & Storage
supabase_flutter: ^2.0.0
hive: ^2.2.3
dio: ^5.4.0

# UI & Animations
flutter_staggered_grid_view: ^0.7.0
flutter_animate: ^4.5.0
flex_color_scheme: ^7.3.1
google_fonts: ^6.1.0

# Code Generation
freezed: ^2.4.6
json_serializable: ^6.7.1
riverpod_generator: ^2.3.9
```

## Proje Yapısı

```
lib/
├── core/
│   ├── constants/          # API endpoint'leri ve app sabitleri
│   ├── errors/             # Özel exception sınıfları
│   ├── network/            # HTTP client ve network yardımcıları
│   └── storage/            # Hive local storage implementasyonu
├── models/                 # Freezed ile veri modelleri
├── services/               # API service ve storage service
├── viewmodels/             # Riverpod provider'ları ve business logic
├── views/                  # UI ekranları ve sayfalar
│   ├── auth/              # Login ve signup sayfaları
│   ├── notes/             # Not listesi, oluşturma, düzenleme, detay sayfaları
│   ├── profile/           # Kullanıcı profili ve ayarlar
│   ├── onboarding/        # Çok adımlı onboarding akışı
│   └── main/              # Ana navigasyon
├── shared/
│   ├── widgets/           # Yeniden kullanılabilir UI bileşenleri
│   └── theme/             # App temalama ve renkler
└── providers/             # Theme ve onboarding provider'ları
```


```

## Kurulum

### Ön Gereksinimler
- Flutter SDK 3.6 veya üzeri
- Dart SDK 3.0 veya üzeri
- Supabase hesabı
- Backend API sunucusu (FastAPI/Flask)

### 1. Repository'yi klonlayın
```bash
git clone <repository-url>
cd take_note
```

### 2. Bağımlılıkları yükleyin
```bash
flutter pub get
```

### 3. Environment Konfigürasyonu
Root dizinde `.env` dosyası oluşturun:
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key-here
```

### 4. Backend API Kurulumu
Uygulama aşağıdaki endpoint'lere sahip özel bir backend API gerektirir:

#### Temel Endpoint'ler
- `GET /notes` - Kullanıcının notlarını listele
- `POST /notes` - Yeni not oluştur
- `PUT /notes/{id}` - Notu güncelle
- `DELETE /notes/{id}` - Notu sil
- `POST /notes/{id}/restore` - Silinen notu geri yükle
- `PUT /notes/{id}/pin` - Not sabitleme durumunu değiştir

#### Arama Endpoint'leri
- `GET /notes/search` - Sorgu ile not arama
- `GET /notes/semantic-search` - AI ile semantic search

#### AI Endpoint'leri
- `POST /notes/{id}/summarize` - Not özeti oluştur
- `POST /notes/{id}/auto-tag` - Otomatik etiketler oluştur
- `POST /notes/{id}/ai-process` - Tam AI işleme

### 5. Supabase Veritabanı Kurulumu
`notes` tablosunu oluşturun:
```sql
CREATE TABLE notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  title TEXT NOT NULL,
  content TEXT,
  is_pinned BOOLEAN DEFAULT FALSE,
  is_deleted BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS'yi etkinleştir
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

-- Policy'leri oluştur
CREATE POLICY "Users can view own notes" ON notes
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own notes" ON notes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own notes" ON notes
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own notes" ON notes
  FOR DELETE USING (auth.uid() = user_id);
```

### 6. Code Generation
Gerekli code dosyalarını oluşturun:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 7. Uygulamayı çalıştırın
```bash
flutter run
```

## Ana Özellik Implementasyonu

### Offline-First Mimari
- Notlar Hive kullanılarak local olarak saklanır
- Çevrimiçi olduğunda backend ile otomatik sync
- Offline olduğunda local veriye graceful fallback
- Eşzamanlı düzenlemeler için conflict resolution

### AI Entegrasyonu
- İçerik işleme için backend AI endpoint'leri
- Backend mevcut olmadığında AI özellikleri için local fallback
- İstatistiklerle kullanıcı dostu AI sonuç dialog'ları
- Daha iyi içerik keşfi için semantic search

### Modern UI/UX
- Özel renk şemaları ile Material Design 3
- Flutter Animate ile smooth animasyonlar
- Notlar için staggered grid layout
- Vurgulama ile kalıcı arama çubuğu
- Çok adımlı onboarding akışı

### State Management
- Reactive state management için Riverpod
- Type-safe provider'lar için code generation
- Uygun hata yönetimi ve loading state'leri
- Daha iyi UX için optimistic update'ler

## Güvenlik

- Hassas konfigürasyon için environment variable'lar
- Supabase'de Row Level Security (RLS)
- Kullanıcıya özel veri erişim policy'leri
- Supabase ile güvenli authentication akışı
- Input validation ve sanitization
- Güvenlik için hata mesajı sanitization'ı

## Geliştirme

### Code Generation
Proje birkaç code generation aracı kullanır:
- Immutable data class'lar için `freezed`
- JSON serialization için `json_serializable`
- Provider generation için `riverpod_generator`
- Hive adapter'ları için `hive_generator`

Model değişikliklerinden sonra code generation çalıştırın:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Test
```bash
flutter test
```

### Linting
```bash
flutter analyze
```





## Teşekkürler

