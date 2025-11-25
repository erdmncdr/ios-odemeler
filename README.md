# Finance Tracker - Premium iOS Uygulaması

Modern ve şık bir finans takip uygulaması. Liquid glass teması ile premium kullanıcı deneyimi sunar.

## 🌟 Özellikler

### 💰 Temel Fonksiyonlar
- **Gider Takibi**: Günlük harcamalarınızı kategorilere göre kaydedin
- **Gelir Yönetimi**: Kazançlarınızı takip edin ve net bakiyenizi görün
- **Borç Yönetimi**: Borçlarınızı kaydedin ve ödeme durumlarını takip edin
- **Gelecek Ödemeler**: Yaklaşan ödemelerinizi hatırlayın ve zamanında ödeyin

### 🎨 Tasarım Özellikleri
- **Liquid Glass Tema**: Modern glassmorphism tasarım dili
- **Otomatik Dark/Light Mode**: Sistem ayarlarına göre otomatik tema
- **Premium Animasyonlar**: Akıcı ve doğal geçişler
- **Özel Bottom Navigation**: Liquid glass efektli özel tab bar
- **Gradient Renkler**: Göz alıcı renk geçişleri

### 📊 Özellikler
- **Finansal Özet**: Toplam gelir, gider ve bakiye görünümü
- **Kategori Bazlı Takip**: 10+ önceden tanımlı kategori
- **Tarih Takibi**: Geçmiş ve gelecek işlemler
- **Hızlı İşlemler**: Tek dokunuşla işlem ekleme
- **Veri Kalıcılığı**: UserDefaults ile otomatik kayıt
- **Türkçe Lokalizasyon**: Tam Türkçe dil desteği

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
│   └── ThemeManager.swift           # Tema sistemi ve stil yönetimi
└── Assets.xcassets/                 # Görsel varlıklar
```

## 🚀 Kurulum

### Gereksinimler
- Xcode 15.0 veya üzeri
- macOS Sonoma veya üzeri
- iOS 17.0+ cihaz veya simulator

### Adımlar
1. Projeyi klonlayın veya indirin
2. `FinanceTracker.xcodeproj` dosyasını Xcode ile açın
3. Hedef cihazı veya simulatörü seçin
4. ⌘+R ile projeyi çalıştırın

## 📱 Kullanım

### İşlem Ekleme
1. İlgili tab'a (Giderler, Gelirler, Borçlar veya Ödemeler) gidin
2. Sağ üstteki "+" butonuna tıklayın
3. Gerekli bilgileri doldurun
4. "Kaydet" butonuna tıklayın

### İşlem Görüntüleme
- Herhangi bir işlem kartına dokunarak detayları görüntüleyin
- Uzun basarak silme menüsüne erişin

### Borç Ödeme
- Borçlar veya Gelecek Ödemeler ekranında
- "Ödendi Olarak İşaretle" butonuna tıklayın

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
