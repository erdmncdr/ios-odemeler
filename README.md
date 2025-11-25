# Cüzdan Takip v2 - Premium iOS Uygulaması

Modern ve şık bir finans takip uygulaması. Liquid glass teması ile premium kullanıcı deneyimi sunar.

## 🌟 Özellikler

### 💰 Temel Fonksiyonlar
- **Gider Takibi**: Günlük harcamalarınızı kategorilere göre kaydedin
- **Gelir Yönetimi**: Kazançlarınızı takip edin ve net bakiyenizi görün
- **Çift Yönlü Borç Yönetimi**:
  - Bizim borçlarımızı takip edin (başkalarına olan borçlar)
  - Verilen borçları takip edin (bize borçlu olanlar)
- **Gelecek Ödemeler**: Yaklaşan ödemelerinizi hatırlayın ve zamanında ödeyin
- **📱 Akıllı Bildirimler**:
  - 3 gün önce hatırlatma
  - 1 gün önce hatırlatma
  - Ödeme günü bildirimi

### 🎨 Tasarım Özellikleri
- **Premium Liquid Glass Tema**: Gelişmiş glassmorphism tasarım dili
  - Çok katmanlı blur efektleri
  - Gradient stroke'lar
  - Dinamik gölgeler
- **Otomatik Dark/Light Mode**: Sistem ayarlarına göre otomatik tema
- **Premium Animasyonlar**: Spring animasyonları ile akıcı ve doğal geçişler
- **Özel Bottom Navigation**: Tam liquid glass efektli özel tab bar
- **Gradient Renkler**: Göz alıcı renk geçişleri ve matched geometry efektleri

### 📊 Özellikler
- **Finansal Özet**: Toplam gelir, gider ve bakiye görünümü
- **Kategori Bazlı Takip**: 10+ önceden tanımlı kategori
- **Tarih Takibi**: Geçmiş ve gelecek işlemler
- **Hızlı İşlemler**: Tek dokunuşla işlem ekleme
- **Veri Kalıcılığı**: UserDefaults ile otomatik kayıt
- **Türkçe Lokalizasyon**: Tam Türkçe dil desteği
- **Segmented Control**: Borçlar ekranında iki tip borç arasında geçiş
- **Otomatik Bildirim Planlama**: İşlem eklendiğinde/güncellendiğinde otomatik bildirim ayarlama

## 🏗 Teknik Detaylar

### Mimari
- **Framework**: SwiftUI (iOS 17+)
- **Dil**: Swift 5.0
- **Minimum iOS**: iOS 17.0
- **Veri Yönetimi**: MVVM pattern
- **Persistence**: UserDefaults (JSON encoding)

### Proje Yapısı
```
FinanceTracker/
├── FinanceTrackerApp.swift          # Ana uygulama dosyası
├── ContentView.swift                # Ana görünüm ve tab navigation
├── Models/
│   ├── TransactionModel.swift       # Veri modelleri
│   └── DataManager.swift            # Veri yönetimi ve CRUD işlemleri
├── Views/
│   ├── ExpensesView.swift           # Giderler ekranı
│   ├── IncomeView.swift             # Gelirler ekranı
│   ├── DebtsView.swift              # Borçlar ekranı
│   └── UpcomingPaymentsView.swift   # Gelecek ödemeler ekranı
├── Components/
│   └── GlassCardView.swift          # Yeniden kullanılabilir bileşenler
├── Utilities/
│   ├── ThemeManager.swift           # Tema sistemi ve stil yönetimi
│   └── NotificationManager.swift    # Bildirim yönetimi
└── Assets.xcassets/                 # Görsel varlıklar
```

## 🚀 Kurulum

### Gereksinimler
- Xcode 15.0 veya üzeri
- macOS Sonoma veya üzeri
- iOS 17.0+ cihaz veya simulator

### Simulator'de Çalıştırma
1. Projeyi klonlayın veya indirin
2. `FinanceTracker.xcodeproj` dosyasını Xcode ile açın
3. Hedef cihazı veya simulatörü seçin
4. ⌘+R ile projeyi çalıştırın

## 📱 iPhone'da Çalıştırma (iPhone 17 Pro)

### Ön Gereksinimler
- ✅ Mac bilgisayar (macOS Sonoma veya üzeri)
- ✅ Xcode 15.0 veya üzeri
- ✅ iPhone 17 Pro (iOS 17+)
- ✅ Lightning/USB-C kablosu
- ✅ Apple ID (ücretsiz geliştirici hesabı yeterli)

### Adım 1: Apple ID ile Giriş Yapın
1. Xcode'u açın
2. Menü çubuğundan **Xcode → Settings** (veya **Preferences**)
3. **Accounts** sekmesine gidin
4. Sol altta **+** butonuna tıklayın
5. **Apple ID** seçin
6. Apple ID ve şifrenizi girin
7. **Sign In** ile giriş yapın

### Adım 2: Projeyi Açın
1. Terminal'de proje klasörüne gidin:
   ```bash
   cd /path/to/ios-odemeler
   ```
2. Xcode proje dosyasını açın:
   ```bash
   open FinanceTracker/FinanceTracker.xcodeproj
   ```

### Adım 3: Signing & Capabilities Ayarları

#### Otomatik Signing (Önerilen)
1. Xcode'da sol panelden **FinanceTracker** projesine tıklayın
2. **TARGETS** altında **FinanceTracker** seçin
3. **Signing & Capabilities** sekmesine gidin
4. **Automatically manage signing** kutusunu işaretleyin
5. **Team** dropdown'ından Apple ID hesabınızı seçin
6. **Bundle Identifier** otomatik oluşturulur: `com.cuzdantakip.app`

#### Manuel Signing (İleri Seviye)
1. Apple Developer Portal'dan Certificate ve Provisioning Profile oluşturun
2. Xcode'da **Automatically manage signing** işaretini kaldırın
3. Sertifikalarınızı manuel olarak seçin

### Adım 4: iPhone'unuzu Hazırlayın

#### iPhone'u Geliştirici Moduna Alın
1. iPhone'da **Ayarlar → Gizlilik ve Güvenlik** gidin
2. **Geliştirici Modu**'nu bulun ve açın
3. iPhone yeniden başlatılacak
4. Yeniden başladıktan sonra onaylayın

#### iPhone'u Mac'e Bağlayın
1. Lightning/USB-C kablosu ile iPhone'u Mac'e bağlayın
2. iPhone'da **"Bu bilgisayara güven?"** sorusuna **Güven** deyin
3. Mac'te istenirse iPhone şifresini girin

### Adım 5: Cihazı Xcode'da Seçin
1. Xcode üst kısmındaki **cihaz seçici**'ye tıklayın
2. **"iPhone 17 Pro"** (veya cihazınızın adı) seçin
3. Cihaz listede görünmüyorsa:
   - **Window → Devices and Simulators** (⇧⌘2)
   - iPhone'unuz listede görünmeli
   - Görünmüyorsa kabloyu kontrol edin

### Adım 6: Uygulamayı Derleyin ve Çalıştırın
1. ⌘+B ile projeyi derleyin (Build)
2. Hata yoksa ⌘+R ile çalıştırın (Run)
3. Xcode, uygulamayı iPhone'a yükleyecek

### Adım 7: iPhone'da Uygulamaya Güvenin

#### İlk Çalıştırmada
iPhone'da şu hata görünebilir:
> **"Güvenilmeyen Geliştirici"**
> Bu uygulama güvenilmeyen bir geliştirici tarafından yüklendi

#### Çözüm:
1. iPhone'da **Ayarlar → Genel → VPN ve Cihaz Yönetimi** gidin
2. **Geliştirici Uygulaması** bölümünde Apple ID'nizi bulun
3. Üzerine tıklayın
4. **"[Apple ID]'ye Güven"** butonuna basın
5. Onaylayın
6. Uygulamayı tekrar açın

### Adım 8: Bildirimleri Etkinleştirin
1. Uygulama ilk açılışta bildirim izni isteyecek
2. **"İzin Ver"** seçin
3. iOS ayarlarından da kontrol edin:
   - **Ayarlar → Bildirimler → Cüzdan Takip v2**
   - Tüm izinleri açık olduğundan emin olun

## 🔧 Sorun Giderme

### "No signing certificate found" Hatası
**Çözüm:**
1. Xcode → Settings → Accounts
2. Apple ID'nizi kontrol edin
3. **Download Manual Profiles** butonuna tıklayın
4. Signing & Capabilities'te Team'i yeniden seçin

### "The maximum number of apps for free development profiles has been reached"
**Çözüm:**
- Ücretsiz Apple ID ile maksimum 3 uygulama yükleyebilirsiniz
- Eski test uygulamalarını iPhone'dan silin
- Veya Apple Developer Program'a ($99/yıl) kayıt olun

### iPhone Xcode'da Görünmüyor
**Çözüm:**
1. Kabloyu değiştirin (bazı kablolar sadece şarj için)
2. Mac ve iPhone'u yeniden başlatın
3. Xcode'u kapatıp açın
4. **"Bu bilgisayara güven"** onayını tekrarlayın

### Uygulama Çöküyor veya Açılmıyor
**Çözüm:**
1. Xcode'da **Product → Clean Build Folder** (⇧⌘K)
2. Derived Data'yı temizleyin:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. Projeyi yeniden derleyin (⌘+B)
4. iPhone'u yeniden başlatın

### Wireless Debugging (Kablosuz)
iPhone'u her seferinde kablo ile bağlamak istemiyorsanız:

1. iPhone'u kablo ile bağlayın
2. Xcode → **Window → Devices and Simulators**
3. iPhone'unuzu seçin
4. **"Connect via network"** kutusunu işaretleyin
5. iPhone ve Mac aynı WiFi ağında olmalı
6. Artık kablosuz çalışabilirsiniz

## 📱 Kullanım

### İşlem Ekleme
1. İlgili tab'a (Giderler, Gelirler, Borçlar veya Ödemeler) gidin
2. Sağ üstteki "+" butonuna tıklayın
3. Gerekli bilgileri doldurun
4. "Kaydet" butonuna tıklayın

### İşlem Görüntüleme
- Herhangi bir işlem kartına dokunarak detayları görüntüleyin
- Uzun basarak silme menüsüne erişin

### Borç Yönetimi
- **Bizim Borçlar**: Başkalarına olan borçlarınız
- **Verilen Borçlar**: Başkalarına verdiğiniz borçlar (bize borçlu olanlar)
- Segmented control ile iki tip arasında geçiş yapın
- "Ödendi Olarak İşaretle" veya "Geri Ödendi" butonuna tıklayın

### Bildirimler
- İlk açılışta bildirim izni istenir
- Gelecek ödemeler ve borçlar için otomatik bildirim ayarlanır
- 3 gün önce, 1 gün önce ve ödeme günü bildirimleri

## 🎨 Tema Sistemi

### Renkler
- **Primary Gradient**: Mavi-Mor geçişli
- **Accent Gradient**: Pembe-Turuncu geçişli
- **Success Gradient**: Yeşil-Mavi geçişli
- **Warning Gradient**: Turuncu-Kırmızı geçişli

### Fontlar
- **SF Rounded**: Başlıklar için
- **SF Pro**: Gövde metinleri için
- Türkçe karakterlere tam destek

### Efektler
- Glass blur efekti (glassmorphism)
- Yumuşak gölgeler
- Spring animasyonları
- Matched geometry efektleri

## 📊 Veri Modeli

### Transaction
- `id`: UUID
- `title`: String
- `amount`: Double
- `type`: TransactionType (expense, income, debt, upcoming)
- `category`: TransactionCategory
- `date`: Date
- `note`: String
- `isPaid`: Bool
- `dueDate`: Date? (opsiyonel)

### Kategoriler
- Yemek 🍽️
- Ulaşım 🚗
- Alışveriş 🛒
- Faturalar 📄
- Eğlence 🎭
- Sağlık ⚕️
- Eğitim 📚
- Maaş 💵
- Yatırım 📈
- Diğer ⭕

## 🔮 Gelecek Özellikler

- [ ] iCloud senkronizasyonu
- [ ] Grafik ve istatistikler
- [ ] Bütçe hedefleri
- [ ] Widget desteği
- [ ] Apple Watch uygulaması
- [ ] Bildirimler (yaklaşan ödemeler için)
- [ ] Export/Import (CSV, PDF)
- [ ] Çoklu para birimi desteği
- [ ] Face ID/Touch ID koruma
- [ ] Kategori özelleştirme

## 🛠 Geliştirme

### Yeni Özellik Ekleme
1. Model güncellemesi (gerekirse): `TransactionModel.swift`
2. DataManager'a CRUD metotları: `DataManager.swift`
3. View oluşturma: `Views/` klasörü
4. Component oluşturma (gerekirse): `Components/` klasörü
5. Tema güncellemesi (gerekirse): `ThemeManager.swift`

### Kod Stili
- SwiftUI best practices
- MVVM pattern
- Anlamlı değişken isimleri
- Türkçe yorumlar ve string'ler
- Modüler yapı

## 📝 Lisans

Bu proje kişisel kullanım için geliştirilmiştir.

## 👨‍💻 Geliştirici

Claude AI tarafından geliştirilmiştir.

## 🙏 Teşekkürler

- SwiftUI framework'ü için Apple'a
- SF Symbols için Apple'a
- Modern iOS tasarım ilkeleri için tasarım topluluğuna

---

**Not**: Bu uygulama demo verileriyle birlikte gelir. İlk açılışta örnek işlemler otomatik olarak oluşturulur. Gerçek kullanım için bu verileri silebilirsiniz.

## 📸 Ekran Görüntüleri

Uygulama aşağıdaki ekranları içerir:
- **Giderler**: Tüm harcamalarınız ve bugünkü özet
- **Gelirler**: Kazançlarınız ve net bakiye
- **Borçlar**: Ödenmesi gereken ve ödenmiş borçlar
- **Gelecek Ödemeler**: Yaklaşan ödemeler ve acil bildirimler

Her ekran liquid glass teması ile şık bir görünüme sahiptir ve otomatik olarak dark/light mode'a uyum sağlar.
