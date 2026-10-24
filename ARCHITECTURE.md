# ARCHITECTURE.md

Gıda barkod tarayıcı uygulaması (Flutter + Firebase Spark). Bu dosya projenin mimari kurallarını anlatır. Kod yazan herkes (ve AI araçları) bu kurallara uymalıdır.

## Uygulama ne yapar

Kullanıcı bir gıdanın barkodunu okutur, uygulama Firestore'dan ürünü getirir ve içindekileri/alerjenleri gösterir. Kullanıcının seçtiği alerjenler üründe varsa uyarı verir.

## Teknoloji

- Flutter
- Firebase Auth (giriş) + Cloud Firestore (veri), Spark planı
- State management: Riverpod
- Rota yönetimi: go_router
- Barkod okuma: mobile_scanner

## Klasör yapısı

```
lib/
├─ main.dart
├─ router.dart                  # sadece rota tanımları + giriş yönlendirmesi
├─ core/
│  └─ allergen_list.dart        # profilde seçilebilen alerjen listesi
├─ data/
│  ├─ models/
│  │  ├─ product.dart
│  │  └─ history_item.dart
│  └─ repositories/
│     ├─ auth_repository.dart       # giriş / çıkış / kayıt
│     ├─ product_repository.dart    # barkod -> Product (+ bellek cache)
│     └─ user_repository.dart       # alerjen tercihleri, tarama geçmişi
└─ features/
   ├─ auth/auth_screen.dart
   ├─ home/home_screen.dart
   ├─ scanner/scanner_screen.dart
   ├─ product/product_screen.dart
   └─ profile/profile_screen.dart
```

## Akış

```
Ekranlar (features)  ->  Repository (data)  ->  Firebase
```

Örnek: Home'da Tara butonu -> Scanner barkodu okur -> `context.pushReplacement('/product/$code')` -> router barkodu ayıklayıp `ProductScreen`'e verir -> ProductScreen barkodu `product_repository`'ye verir -> repository Firestore'dan ürünü getirir -> ekran çizilir.

## Kurallar

1. **Firebase'e sadece `data/repositories/` dokunur.** Ekranda `FirebaseFirestore.instance` ya da `FirebaseAuth.instance` yazılmaz. Ekranlar repository'yi Riverpod provider üzerinden çağırır.
2. **Feature'lar birbirini import etmez.** Scanner, Home'u ya da Product'ı bilmez. Ekranlar arası iletişim sadece router adresi üzerinden, ve sadece barkod (String) taşınır: `/product/:barcode`.
3. **Controller katmanı yok.** Her ekran tek dosyadır. Küçük state'ler (yükleniyor, hata) ya `FutureProvider.when` ile ya da ekranın kendi `State`'i ile yönetilir. Controller, sadece bir ekranın state'i gerçekten karmaşıklaşırsa sonradan eklenir.
4. **Ekran şişerse bölünür.** Bir ekran dosyası 300-400 satırı geçip okunmaz hale gelirse, o feature altında `widgets/` klasörü açılır ve parçalar oraya taşınır. Başka alt klasör açılmaz.
5. **Ortak dosyalar dikkatle değişir.** `data/`, `core/` ve `router.dart` herkesi etkiler. Bu dosyalarda küçük commit atılır, mümkünse PR ile ilerlenir.

## Firestore yapısı

```
products/{barcode}            -> name, brand, ingredients[], allergens[]
users/{uid}                   -> allergens[]
users/{uid}/history/{barcode} -> name, scannedAt
```

- `products` herkese okunur, kimse yazamaz (veriyi biz yükleriz).
- `users/{uid}` ve altındaki her şey sadece o kullanıcıya açıktır.

## Alerjen yazımı (kritik)

`core/allergen_list.dart` içindeki değerler ile Firestore'daki ürünlerin `allergens` alanı **aynı yazımda** olmalıdır (küçük harf, aynı Türkçe karakterler). Eşleşme buna bağlıdır. Yazım farkı sessiz hata yaratır: kullanıcı alerjisi olan ürünü "güvenli" görebilir. Yeni veri yüklerken yazımı bu listeye göre normalize edin.

## Cache ve Spark limiti

- `product_repository.dart` içinde bellek içi cache vardır: aynı barkod için uygulama açıkken tekrar Firestore okuması harcanmaz.
- Spark günlük okuma limitine takılınırsa kalıcı cache (Hive ya da shared_preferences) sadece `product_repository.dart` içine eklenir. Ekranlara dokunulmaz.

## Yeni özellik eklerken

- Yeni bir veri işi (yeni sorgu, yeni alan) -> ilgili repository'ye fonksiyon eklenir, ekrandan çağrılır.
- Yeni bir ekran -> `features/<isim>/<isim>_screen.dart` açılır, `router.dart`'a rota eklenir.
- Yeni bir model -> `data/models/` altına eklenir.
- Bu kurallara uymayan bir değişiklik gerekiyorsa önce bu dosya güncellenir, sonra kod yazılır.

## İş bölümü (öneri)

Ekip küçük olduğu için aynı kişi hem ekranı hem mantığı yazabilir. Çakışmayı önleyen şey klasör sınırlarıdır: bir kişi `scanner/` üzerinde çalışırken diğeri `home/` üzerinde çalışabilir. Tek ortak sözleşme `/product/:barcode` rotasıdır.
