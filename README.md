# Uzum Tezkor — Mijoz mobil ilovasi (Flutter)

Wolt/Glovo/Uzum Tezkor darajasidagi ovqat yetkazib berish platformasining
**mijoz tomoni**. `uzum-tezkor-backend` (NestJS) API'siga to'g'ridan-to'g'ri
ulanadi va bosqich-3'da qo'shilgan barcha integratsiyalardan (OTP, Google/Apple
login, Click/Payme/Uzum Bank, Firebase push, Socket.IO realtime) foydalanadi.

## 🎨 Dizayn

Admin va restoran paneli bilan bir xil brend tili davom ettirildi:

- **Ranglar:** mango-sariq (`#FF8A3D`) urg'u, to'q ko'k-kulrang `ink` (`#14161F`),
  yashilroq oq `paper` fon (`#F3F5F1`)
- **Shrift:** sarlavhalar — Space Grotesk, matn — Inter, narxlar — IBM Plex Mono
  (shrift fayllari `assets/`ga qo'shilmagan — bundle qilinmaguncha tizim shriftiga
  tushadi, ilova ishlashiga xalaqit bermaydi)
- **Dark / Light mode:** `ThemeMode.system` bo'yicha avtomatik, sozlamalarda
  qo'lda tanlash ham mavjud (17-band)
- **Til:** o'zbek/rus/ingliz — kod-generatsiyasiz yengil i18n tizimi
  (`lib/l10n/app_strings.dart`, 16-band)

## 📦 Qamrov (promptning 1–17-bandlariga mos)

| Band | Holat |
|---|---|
| 3. Ro'yxatdan o'tish | ✅ Telefon+OTP, Google, Apple, avatar/profil tahrirlash |
| 4–5. Asosiy sahifa | ✅ Banner, kategoriyalar, mashhur restoranlar, eng ko'p buyurtma qilingan, qidiruv |
| 6. Taom sahifasi | ✅ Rasmlar, narx/eski narx/chegirma, variant, qo'shimcha, sharh, reyting |
| 7. Savatcha | ✅ Qo'shish/o'chirish/miqdor, promo kod, bonus ball |
| 8. Buyurtma | ✅ Manzil, xaritadan tanlash, yetkazib berish/olib ketish, belgilangan vaqt, izoh |
| 9. To'lov | ✅ Click/Payme/Uzum Bank/karta/naqd (backend `payments/initiate` orqali) |
| 10. Xarita | ✅ Google Maps, GPS, kuryer jonli joylashuvi (Socket.IO), ETA maydonlari |
| 14. Bildirishnoma | ✅ FCM device-token ro'yxatga olish, in-app ro'yxat |
| 16. Til | ✅ uz/ru/en |
| 17. Texnologiya | ✅ Flutter + Riverpod + go_router + Dio + Socket.IO |
| 18. Xavfsizlik | ✅ Secure storage'da JWT, avtomatik refresh-token, hech qanday narx clientda hisoblanmaydi (checkout serverga xom ma'lumot yuboradi) |

**Hali qo'shilmagan:** 11-band (kuryer ilovasi — alohida loyiha bo'ladi),
15-band (AI tavsiyalar — backendda alohida endpoint kerak).

## 🗂 Arxitektura

```
lib/
├── core/            # theme, network (Dio+interceptors), router, storage, config
├── data/
│   ├── models/      # Backend entity'lariga 1:1 mos JSON modellar
│   └── repositories/# Har bir controller uchun alohida repository
├── state/           # Riverpod provider/notifier'lar (auth, cart, orders...)
├── features/        # Har bir ekran/oqim uchun alohida papka
├── shared/widgets/   # Umumiy komponentlar (PriceText, RatingBadge, ...)
└── l10n/             # Yengil i18n (uz/ru/en)
```

- **State management:** Riverpod (`StateNotifier` + `FutureProvider`)
- **Navigatsiya:** `go_router`, auth holatiga qarab avtomatik redirect
  (`splash → onboarding → auth → profil to'ldirish → asosiy oqim`)
- **Tarmoq:** `ApiClient` (Dio) — access token avtomatik qo'shiladi, 401 kelsa
  `refresh` orqali tokenni yangilab so'rovni bir marta qayta yuboradi
- **Realtime:** `RealtimeService` — backend `RealtimeGateway`dagi bir xil xona/hodisa
  nomlaridan foydalanadi (`order:{id}` xonasi, `orderStatusUpdate`,
  `courierLocationUpdate`)

## 🚀 Ishga tushirish

```bash
flutter pub get

flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:3000 \
  --dart-define=SOCKET_URL=http://10.0.2.2:3000 \
  --dart-define=GOOGLE_MAPS_API_KEY=<xaritalar_kaliti> \
  --dart-define=GOOGLE_CLIENT_ID=<google_oauth_client_id>
```

> `API_BASE_URL` — Android emulyatorida lokal backendga ulanish uchun
> `10.0.2.2` ishlatiladi (localhost emas). Haqiqiy qurilmada backend serverning
> tarmoqdagi IP/domenini bering.

### Native loyihalar (Android / iOS) — holat

Endi bu arxivda **Android va iOS uchun deyarli to'liq native konfiguratsiya** bor:

- `android/settings.gradle`, `android/build.gradle`, `android/app/build.gradle`,
  `android/gradle.properties`, `MainActivity.kt`, `styles.xml`,
  `launch_background.xml` (light/dark), `proguard-rules.pro`, debug/profile
  manifest qo'shimchalari — barchasi yozilgan
- `ios/Podfile`, `AppDelegate.swift` (Google Maps kaliti bilan),
  `Runner-Bridging-Header.h`, `Flutter/*.xcconfig`, `Main.storyboard`,
  `LaunchScreen.storyboard`, `Assets.xcassets` manifestlari — barchasi yozilgan

**Faqat ikkita narsa qoldi — ular Flutter/Xcode tomonidan avtomatik generatsiya
qilinadigan ikkilik (binary)/murakkab fayllar, shuning uchun qo'lda yozib
bo'lmaydi:**

1. **`android/gradlew` + `gradle-wrapper.jar`** — Gradle binary fayli
2. **`ios/Runner.xcodeproj/project.pbxproj`** — Xcode loyiha fayli

Buni to'ldirish uchun loyiha papkasida **bitta marta**:

```bash
flutter create --org uz.uzumtezkor --project-name uzum_tezkor_customer .
```

buyrug'ini bering. **Bu buyruq xavfsiz** — mavjud fayllarni (yuqoridagilarning
barchasini) o'zgartirmaydi, faqat yo'q bo'lgan ikkita narsani (`gradlew` va
Xcode loyihasi) qo'shadi.

> ⚠️ Shundan keyin ham qo'lda qilish kerak bo'lgan bitta narsa: app ikonka
> PNG fayllari (`ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png` va
> Android `mipmap-*` papkalari) — bular dizayn fayli, shuning uchun kod bilan
> yaratib bo'lmaydi. https://appicon.co kabi xizmat orqali logotipingizdan
> generatsiya qilib qo'yishingiz mumkin.

### Backend bilan bog'lash

Bu ilova `uzum-tezkor-backend-bosqich3`dagi barcha endpointlardan foydalanadi
(auth, restaurants, products, orders, payments, reviews, promocodes, bonus,
notifications, banners, addresses). Backendni avval ishga tushiring:

```bash
cd uzum-tezkor-backend
docker compose up -d   # yoki lokal PostgreSQL bilan
npm run start:dev
```

## 🔐 Xavfsizlik eslatmalari

- Access/refresh tokenlar `flutter_secure_storage` orqali saqlanadi (Android:
  EncryptedSharedPreferences, iOS: Keychain)
- Barcha narx/chegirma hisob-kitoblari **serverda** amalga oshadi — mobil ilova
  faqat ko'rsatish uchun taxminiy summa hisoblaydi, `createOrder` chaqiruvida esa
  xom `productId`/`variantId`/`addonId` va `quantity`larni yuboradi
- Google/Apple ID tokenlar to'g'ridan-to'g'ri backendning `/auth/social-login`
  endpointiga yuboriladi — backend ularni Google/Apple serverlarida qayta tekshiradi

## 🤖 GitHub orqali avtomatik APK qurish

Reponi GitHub'ga yuklashning o'zi APK yaratmaydi — buning uchun
`.github/workflows/build-apk.yml` fayli qo'shilgan (GitHub Actions). U har
safar `main` branchga push qilinganda avtomatik ishga tushadi va **debug
APK**ni tayyorlab qo'yadi.

### Sozlash qadamlari

1. Reponi GitHub'ga yuklang:
   ```bash
   git init
   git add .
   git commit -m "Uzum Tezkor mijoz ilovasi"
   git branch -M main
   git remote add origin https://github.com/<foydalanuvchi>/<repo>.git
   git push -u origin main
   ```
2. Repo sozlamalarida (**Settings → Secrets and variables → Actions**) quyidagilarni qo'shing:
   - **Secrets:** `GOOGLE_MAPS_API_KEY`, `GOOGLE_CLIENT_ID`
   - **Variables (ixtiyoriy):** `API_BASE_URL`, `SOCKET_URL` — backendingiz internetga ochiq bo'lgan manzili (masalan `https://api.sizning-domeningiz.uz`). Ko'rsatmasangiz, workflow standart placeholder manzildan foydalanadi.
3. Push qilgach, GitHub'da **Actions** bo'limiga o'ting — "Build APK" workflow ishlayotganini ko'rasiz (~5–8 daqiqa).
4. Tugagach, o'sha workflow ishi ichidan **Artifacts** bo'limida
   `uzum-tezkor-customer-debug-apk` faylini yuklab olasiz — bu telefonga
   o'rnatiladigan tayyor `.apk`.

> ⚠️ Bu **debug APK** — sinov uchun yaxshi, lekin Play Store'ga chiqarish uchun
> emas. Play Store uchun `--release` build va imzolash (signing) kaliti kerak
> bo'ladi — buni xohlasangiz alohida sozlab beraman.



1. Kuryer mobil ilovasi (Flutter) — 11-band
2. AI tavsiya tizimi uchun backend endpoint + shu ilovada ko'rsatish — 15-band
3. Shrift fayllarini (`SpaceGrotesk`, `Inter`, `IBMPlexMono`) `assets/fonts/`ga
   qo'shib `pubspec.yaml`da e'lon qilish
4. `firebase_options.dart`ni `flutterfire configure` orqali generatsiya qilib
   push bildirishnomalarni to'liq yoqish
