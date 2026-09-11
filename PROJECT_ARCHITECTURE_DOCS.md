# 🖥️ PC Builder App - Complete `lib/` Architecture Documentation

> **প্রজেক্টের বিবরণ:** এই প্রজেক্টটি একটি আধুনিক **Flutter PC Builder & Hardware E-Commerce Application**। এখানে **MVP (Model-View-Presenter)** আর্কিটেকচার প্যাটার্ন এবং **Firebase (Auth & Cloud Firestore)** ব্যাকএন্ড ব্যবহার করা হয়েছে।

---

## 📁 সামগ্রিক ফোল্ডার স্ট্রাকচার (Directory Overview)

```
lib/
├── core/                         # অ্যাপের কোর ইউটিলিটি, থিম, কনস্ট্যান্ট এবং কমন উইজেটস
│   ├── constants/                # কালার, স্ট্রিং এবং অফলাইন/ডিফল্ট ডেটাসেট
│   ├── theme/                    # গ্লোবাল ডার্ক ও লাইট থিম ডেটা
│   ├── utils/                    # রেসপনসিভ সাইজিং এবং হেল্পার ফাংশন
│   └── widgets/                  # অ্যাপের সর্বত্র ব্যবহৃত রি-ইউজেবল উইজেট
├── models/                       # ডেটা মডেল ও স্টেট ক্লাস (JSON Serialization সহ)
├── presenters/                   # বিজনেস লজিক এবং ভিউ-কন্ট্রাক্ট হ্যান্ডলার (MVP প্যাটার্ন)
├── services/                     # ফায়ারবেস অথেনটিকেশন এবং ক্লাউড ফায়ারস্টোর সার্ভিস
├── views/                        # অ্যাপের সকল ইউজার ইন্টারফেস (UI Screens & Sheets)
│   ├── auth/                     # লগইন ও সাইন-আপ রিলেটেড স্ক্রিন এবং কন্ট্রাক্ট
│   ├── builder/                  # কাস্টম পিসি বিল্ডার, কম্পোনেন্ট পিকার এবং সামারি মডাল
│   ├── home/                     # হোম ড্যাশবোর্ড, ব্যানার এবং পিসি ডিটেইলস ভিউ
│   ├── orders/                   # অর্ডার লিস্ট এবং লাইভ ট্র্যাকিং টাইমলাইন শিট
│   ├── profile/                  # ইউজার প্রোফাইল এবং সেভ করা কাস্টম বিল্ড হিস্ট্রি
│   └── splash/                   # স্প্ল্যাশ স্ক্রিন ও অটো-অথেনটিকেশন রাউটিং
├── firebase_options.dart         # ফায়ারবেস কনফিগারেশন ফাইল (Auto-generated CLI)
└── main.dart                     # অ্যাপের প্রধান এন্ট্রি পয়েন্ট (Main Function & App Init)
```

---

## 📑 প্রতিটি ফাইল ও ফোল্ডারের বিস্তারিত বিবরণ

---

### 1️⃣ রুট ফাইলসমূহ (Root Files)

#### 🔹 [main.dart](file:///d:/Elahi-versity-project/lib/main.dart)
- **কাজ:** এটি অ্যাপ্লিকেশনের প্রধান এন্ট্রি পয়েন্ট (`main()` function)।
- **কিভাবে কাজ করে:**
  1. `WidgetsFlutterBinding.ensureInitialized()` এর মাধ্যমে উইজেট বাইন্ডিং ইনিশিয়ালাইজ করে।
  2. `Firebase.initializeApp()` দিয়ে ফায়ারবেস কানেক্ট করে।
  3. `ScreenUtilInit` ব্যবহার করে রেসপনসিভ ডিজাইনের বেস স্ক্রিন সাইজ (`375x812`) সেট করে।
  4. গ্লোবাল থিম `AppTheme.lightTheme` অ্যাপ্লাই করে এবং হোম হিসেবে `SplashView()` কে লোড করে।

#### 🔹 [firebase_options.dart](file:///d:/Elahi-versity-project/lib/firebase_options.dart)
- **কাজ:** ফায়ারবেস প্রজেক্টের বিভিন্ন প্ল্যাটফর্ম (Android, iOS, Web, Windows) এর API Key, App ID, Messaging Sender ID ইত্যাদি কনফিগারেশন সংরক্ষণ করে।
- **কিভাবে কাজ করে:** FlutterFire CLI দ্বারা জেনারেট করা `DefaultFirebaseOptions.currentPlatform` রিটার্ন করে।

---

### 2️⃣ `core/` ফোল্ডার (Core Layer)

অ্যাপ্লিকেশনের গ্লোবাল কনফিগারেশন, থিম এবং রিইউজেবল উইজেটগুলো এখানে থাকে।

#### 📂 `core/constants/`
* 🔹 [app_colors.dart](file:///d:/Elahi-versity-project/lib/core/constants/app_colors.dart): অ্যাপের জন্য আধুনিক কালার প্যালেট (Primary Neon Cyan, Accent Purple, Dark Surfaces, Border Colors, Status Colors ইত্যাদি) সংরক্ষণ করে।
* 🔹 [app_strings.dart](file:///d:/Elahi-versity-project/lib/core/constants/app_strings.dart): অ্যাপে ব্যবহৃত বিভিন্ন টেক্সট, টাইটেল, ফর্ম লেবেল এবং এরর মেসেজ এক জায়গায় কনস্ট্যান্ট হিসেবে রাখে।
* 🔹 [app_data.dart](file:///d:/Elahi-versity-project/lib/core/constants/app_data.dart): সম্পূর্ণ অফলাইন ও ডিফল্ট হার্ডওয়্যার ক্যাটালগ (CPU, GPU, RAM, Motherboard, Prebuilt Gaming Rigs) সংরক্ষণ করে। ইন্টারনেট না থাকলে বা ফায়ারস্টোর ডেটা খালি থাকলেও অ্যাপ ক্র্যাশ না করে এই ডামি/ফলব্যাক ডেটা প্রদর্শন করে।

#### 📂 `core/theme/`
* 🔹 [app_theme.dart](file:///d:/Elahi-versity-project/lib/core/theme/app_theme.dart): অ্যাপের সম্পূর্ণ `ThemeData` সংজ্ঞায়িত করে। যেমন: Google Fonts (Poppins / Inter), AppBarTheme, CardTheme, ElevatedButtonTheme, InputBorder এবং ডার্ক মোড স্টাইলিং।

#### 📂 `core/utils/`
* 🔹 [screen_utils.dart](file:///d:/Elahi-versity-project/lib/core/utils/screen_utils.dart): স্ক্রিনের সাইজ অনুযায়ী মার্জিন, প্যাডিং, ফন্ট সাইজ এবং রেসপনসিভ ডাইমেনশন ক্যালকুলেট করার সহজ এক্সটেনশন ও হেল্পার ক্লাস।

#### 📂 `core/widgets/` (কমন ও রি-ইউজেবল উইজেটস)
* 🔹 [app_network_image.dart](file:///d:/Elahi-versity-project/lib/core/widgets/app_network_image.dart): ক্যাশড নেটওয়ার্ক ইমেজ লোডার, যা ইমেজ লোড হওয়ার সময় Shimmer এনিমেশন এবং ফেইল করলে অল্টারনেটিভ ফলব্যাক ইমেজ দেখায়।
* 🔹 [app_notification.dart](file:///d:/Elahi-versity-project/lib/core/widgets/app_notification.dart): কাস্টম টোস্ট ও স্ন্যাকবার নোটিফিকেশন সিস্টেম (সাকসেস, ওয়ার্নিং, এরর ও ইনফো কার্ড)।
* 🔹 [custom_button.dart](file:///d:/Elahi-versity-project/lib/core/widgets/custom_button.dart): গ্রেডিয়েন্ট কালার, আইকন এবং লোডিং স্পিনার সমৃদ্ধ কাস্টম বোতাম।
* 🔹 [live_badge.dart](file:///d:/Elahi-versity-project/lib/core/widgets/live_badge.dart): অর্ডারের লাইভ স্ট্যাটাস বা স্পেশাল অফার বোঝাতে পালসিং (Pulsing) এনিমেশন ব্যাজ।
* 🔹 [section_header.dart](file:///d:/Elahi-versity-project/lib/core/widgets/section_header.dart): বিভিন্ন সেকশনের টাইটেল, সাব-টাইটেল এবং "See All" অ্যাকশন বোতামের জন্য স্ট্যান্ডার্ড হেডার উইজেট।
* 🔹 [spec_chip.dart](file:///d:/Elahi-versity-project/lib/core/widgets/spec_chip.dart): কম্পোনেন্টের স্পেসিফিকেশন (যেমন: `32GB DDR5`, `240Hz`, `850W`) দেখানোর ছোট ব্যাজ চিপ।

---

### 3️⃣ `models/` ফোল্ডার (Data Layer)

অ্যাপের ডেটা স্ট্রাকচার এবং স্টেট ধারণকারী মডেল ক্লাস।

* 🔹 [user_model.dart](file:///d:/Elahi-versity-project/lib/models/user_model.dart):
  - **কাজ:** লগইন করা ইউজারের প্রোফাইল তথ্য (`uid`, `name`, `email`, `photoUrl`, `createdAt`) মডেল করে।
  - **ফাংশন:** `fromJson()` এবং `toJson()` এর মাধ্যমে Firestore ও App এর মধ্যে ডেটা কনভার্ট করে।

* 🔹 [pc_component_model.dart](file:///d:/Elahi-versity-project/lib/models/pc_component_model.dart):
  - **কাজ:** প্রতিটি হার্ডওয়্যার পার্টসের মডেল (ক্যাটাগরি: CPU, GPU, RAM, ইত্যাদি, ব্র্যান্ড, মডেল, প্রাইস, ওয়াটেজ, রেটিং, স্পেসিফিকেশন ম্যাপ ও ইমেজ URL)।

* 🔹 [pc_build_model.dart](file:///d:/Elahi-versity-project/lib/models/pc_build_model.dart):
  - **কাজ:** প্রি-বিল্ট গেমিং ও প্রোডাক্টিভিটি পিসির মডেল। এতে সম্পূর্ণ বিল্ডের নাম, মোট মূল্য, পারফরম্যান্স স্কোর (FPS Benchmark) এবং কম্পোনেন্ট লিস্ট থাকে।

* 🔹 [custom_build_state.dart](file:///d:/Elahi-versity-project/lib/models/custom_build_state.dart):
  - **কাজ:** কাস্টম পিসি বিল্ডারের লাইভ স্টেট ম্যানেজ করে। ইউজার কোন কোন পার্টস সিলেক্ট করেছে তা ট্র্যাক করে।
  - **ফিচার:** রিয়েল-টাইমে মোট মূল্য (`totalPrice`), সর্বমোট বিদ্যুৎ খরচ (`totalWattage`), পর্যাপ্ত পাওয়ার সাপ্লাই চেক (`isPsuSufficient`), এবং কমপ্যাটিবিলিটি চেক সম্পন্ন করে।

* 🔹 [order_model.dart](file:///d:/Elahi-versity-project/lib/models/order_model.dart):
  - **কাজ:** ব্যবহারকারীর অর্ডার এবং তার লাইভ ট্র্যাকিং হিস্ট্রি পরিচালনা করে।
  - **স্ট্যাটাস লাইফসাইকেল:** `Placed` ➔ `Confirmed` ➔ `Building` ➔ `Testing` ➔ `Out for Delivery` ➔ `Delivered`।

---

### 4️⃣ `services/` ফোল্ডার (Backend Services)

* 🔹 [auth_service.dart](file:///d:/Elahi-versity-project/lib/services/auth_service.dart):
  - **কাজ:** Firebase Authentication API হ্যান্ডেল করে।
  - **মেথডসমূহ:**
    - `signUpWithEmail()`: নতুন অ্যাকাউন্ট তৈরি ও Firestore-এ ইউজার প্রোফাইল ডাটা সেভ।
    - `login()`: ইমেইল ও পাসওয়ার্ড দিয়ে লগইন ভেরিফিকেশন।
    - `logout()`: সাইন আউট অপারেশন।
    - `currentUser`: বর্তমানে লগইন থাকা ইউজারের তথ্য রিট্রিভ।

* 🔹 [firestore_service.dart](file:///d:/Elahi-versity-project/lib/services/firestore_service.dart):
  - **কাজ:** Cloud Firestore এর সাথে যোগাযোগ করে রিয়েল-টাইম ডেটা স্ট্রিম ও সিঙ্ক করে।
  - **মেথডসমূহ:**
    - `streamComponents()` / `getComponents()`: ক্যাটাগরি অনুযায়ী পার্টস ক্যাটালগ আনা (ফলব্যাক সহ)।
    - `streamPrebuiltPcs()`: প্রি-বিল্ট পিসির লিস্ট আনা।
    - `createOrder()` / `streamUserOrders()`: কাস্টমারদের অর্ডার প্লেস করা এবং রিয়েল-টাইম ট্র্যাকিং আনা।
    - `saveCustomBuild()` / `getUserSavedBuilds()`: ইউজারের পছন্দের কাস্টম বিল্ড কনফিগারেশন সেভ ও লোড করা।
    - `updateUserProfile()`: নাম, ফোন ও ঠিকানা আপডেট করা।

---

### 5️⃣ `presenters/` ফোল্ডার (Business Logic - MVP Pattern)

ভিউ (UI) এবং ডেটা সার্ভিসের মাঝখানে লজিক লেয়ার হিসেবে কাজ করে।

* 🔹 [login_presenter.dart](file:///d:/Elahi-versity-project/lib/presenters/login_presenter.dart):
  - **কাজ:** লগইন ফর্মের ফিল্ড ভ্যালিডেশন (খালি ইমেইল/পাসওয়ার্ড চেক) করে, `AuthService.login()` কল করে, এবং `LoginViewContract` এর মাধ্যমে ভিউতে লোডিং, সাকসেস বা এরর মেসেজ পুশ করে।

* 🔹 [sign_up_presenter.dart](file:///d:/Elahi-versity-project/lib/presenters/sign_up_presenter.dart):
  - **কাজ:** সাইন-আপ ফর্ম ভ্যালিডেশন (পাসওয়ার্ড লেন্থ, পাসওয়ার্ড ম্যাচিং, ইমেইল ফরম্যাট) যাচাই করে, অ্যাকাউন্ট ক্রিয়েট করে এবং `SignUpViewContract` ইন্টারফেসে রেজাল্ট পাঠায়।

---

### 6️⃣ `views/` ফোল্ডার (UI Screens & Presentation)

#### 📂 `views/splash/`
* 🔹 [splash_view.dart](file:///d:/Elahi-versity-project/lib/views/splash/splash_view.dart):
  - **কাজ:** অ্যাপ চালু হলে আধুনিক নিয়ন সাইবারপাঙ্ক লোগো অ্যানিমেশন দেখায়।
  - **লজিক:** ব্যবহারকারী আগে থেকেই লগইন থাকলে সরাসরি `MainNavView`-এ নিয়ে যায়, অন্যথায় `LoginView`-এ পাঠায়।

#### 📂 `views/auth/`
* 🔹 [login_contract.dart](file:///d:/Elahi-versity-project/lib/views/auth/login_contract.dart): লগইন ভিউয়ের জন্য ইন্টারফেস মেথড (`showLoading`, `hideLoading`, `onLoginSuccess`, `onLoginError`)।
* 🔹 [login_view.dart](file:///d:/Elahi-versity-project/lib/views/auth/login_view.dart): ইমেইল-পাসওয়ার্ড ইনপুট ফর্ম, শো/হাইড পাসওয়ার্ড টগল, সাইন-আপ নেভিগেশন এবং লগইন বাটন।
* 🔹 [sign_up_contract.dart](file:///d:/Elahi-versity-project/lib/views/auth/sign_up_contract.dart): সাইন-আপ ভিউয়ের জন্য কন্ট্রাক্ট ইন্টারফেস।
* 🔹 [sign_up_view.dart](file:///d:/Elahi-versity-project/lib/views/auth/sign_up_view.dart): নাম, ইমেইল, পাসওয়ার্ড এবং পাসওয়ার্ড কনফার্মেশন সহ অ্যাকাউন্ট তৈরির ফর্ম।

#### 📂 `views/main_nav_view.dart`
* 🔹 [main_nav_view.dart](file:///d:/Elahi-versity-project/lib/views/main_nav_view.dart):
  - **কাজ:** অ্যাপের প্রধান বটম নেভিগেশন বার (Bottom Navigation Bar)।
  - **ট্যাবসমূহ:**
    1. 🏠 **Home** (`HomeView`)
    2. 🛠️ **PC Builder** (`BuilderView`)
    3. 📦 **Orders** (`OrdersView`)
    4. 👤 **Profile** (`ProfileView`)

#### 📂 `views/home/`
* 🔹 [home_view.dart](file:///d:/Elahi-versity-project/lib/views/home/home_view.dart):
  - **কাজ:** অ্যাপের মূল ড্যাশবোর্ড।
  - **ফিচার:** প্রোমো ব্যানার ক্যারোসেল, ক্যাটাগরি ফিল্টার চিপস, ফিচার্ড প্রি-বিল্ট পিসি গ্রিড, টপ কম্পোনেন্টস লিস্ট এবং দ্রুত কাস্টম বিল্ড শুরু করার শর্টকাট।
* 🔹 [pc_details_view.dart](file:///d:/Elahi-versity-project/lib/views/home/pc_details_view.dart):
  - **কাজ:** যেকোনো প্রি-বিল্ট পিসির বিস্তারিত ভিউ। পার্টসের তালিকা, গেম পারফরম্যান্স FPS বার (GTA V, Cyberpunk 2077, Valorant ইত্যাদি), ও সরাসরি অর্ডার করার অপশন।

#### 📂 `views/builder/`
* 🔹 [builder_view.dart](file:///d:/Elahi-versity-project/lib/views/builder/builder_view.dart):
  - **কাজ:** সম্পূর্ণ ইন্টারেক্টিভ কাস্টম পিসি বিল্ডার।
  - **ফিচার:** CPU, Motherboard, GPU, RAM, Storage, PSU, Cooler, Case আলাদা আলাদা স্লটে চুজ করার সুবিধা; লাইভ ওয়াটেজ মিটার (বিদ্যুৎ খরচ অ্যানালিসিস); ইনস্ট্যান্ট কম্প্যাটিবিলিটি স্ট্যাটাস।
* 🔹 [component_picker_sheet.dart](file:///d:/Elahi-versity-project/lib/views/builder/component_picker_sheet.dart):
  - **কাজ:** কোনো নির্দিষ্ট ক্যাটাগরির (যেমন: GPU) কম্পোনেন্ট সিলেক্ট করার জন্য বটম শীট। এতে সার্চ বার, ব্র্যান্ড ফিল্টার ও প্রাইস শর্টিং সুবিধা রয়েছে।
* 🔹 [build_summary_dialog.dart](file:///d:/Elahi-versity-project/lib/views/builder/build_summary_dialog.dart):
  - **কাজ:** বিল্ড সম্পন্ন হলে সম্পূর্ণ স্পেকশিট রসিদ আকারে দেখা, বিল্ডটি সেভ করে রাখা অথবা সরাসরি ক্যাশ অন ডেলিভারি/অনলাইন পেমেন্টে অর্ডার প্লেস করার ডায়ালগ।

#### 📂 `views/orders/`
* 🔹 [orders_view.dart](file:///d:/Elahi-versity-project/lib/views/orders/orders_view.dart):
  - **কাজ:** ইউজারের বর্তমান সক্রিয় ও পূর্বের সম্পন্ন হওয়া সকল অর্ডারের তালিকা ফিল্টার আকারে প্রদর্শন।
* 🔹 [order_details_sheet.dart](file:///d:/Elahi-versity-project/lib/views/orders/order_details_sheet.dart):
  - **কাজ:** অর্ডারের লাইভ ট্র্যাকিং স্ট্যাটাস টাইমলাইন (অর্ডার প্লেসড ➔ অ্যাসেম্বলিং ➔ বেঞ্চমার্কিং টেস্টিং ➔ কুরিয়ারে হস্তান্তর ➔ ডেলিভারি সম্পন্ন) এবং ডেলিভারি অ্যাড্রেস ও আইটেম রসিদ।

#### 📂 `views/profile/`
* 🔹 [profile_view.dart](file:///d:/Elahi-versity-project/lib/views/profile/profile_view.dart):
  - **কাজ:** ইউজার প্রোফাইল ম্যানেজমেন্ট। ইউজারের মোট অর্ডার সংখ্যা, সেভ করা বিল্ডের সংখ্যা, পার্সোনাল তথ্য এডিটিং এবং লগআউট অপশন।
* 🔹 [saved_builds_sheet.dart](file:///d:/Elahi-versity-project/lib/views/profile/saved_builds_sheet.dart):
  - **কাজ:** ব্যবহারকারীর পূর্বে সেভ করে রাখা কাস্টম পিসি কনফিগারেশনগুলোর তালিকা দেখা, বিল্ড ডিলিট করা অথবা পুনরায় বিল্ডারে লোড করা।

---

## 🔄 ডেটা ফ্লো ও আর্কিটেকচার ডায়াগ্রাম (Data Flow Overview)

```
[ User Interaction (UI View) ]
              │
              ▼
[ Presenter / Controller ]  <─── Validates Input & Dispatches Requests
              │
              ▼
[ Services Layer (Auth / Firestore) ]
              │
     ┌────────┴────────┐
     ▼                 ▼
[ Firebase Cloud ]  [ AppData (Offline Fallback) ]
     │                 │
     └────────┬────────┘
              ▼
[ Data Models (JSON Parsing) ]
              │
              ▼
[ View Contract -> UI Update (Reactive Stream / State) ]
```

---

## 💡 প্রজেক্টের প্রধান সুবিধাসমূহ (Key Highlights)
1. **MVP আর্কিটেকচার:** UI এবং বিজনেস লজিক সম্পূর্ণ আলাদা হওয়ায় কোড ক্লিন, মেইনটেইনেবল এবং টেস্টেবল।
2. **অফলাইন-ফার্স্ট ক্যাচিং:** ইন্টারনেট বা ক্লাউড ফায়ারস্টোরে সমস্যা হলেও `AppData` এর কারণে অ্যাপ কখনই ব্ল্যাঙ্ক হয় না বা ক্র্যাশ করে না।
3. **রিয়েল-টাইম লাইভ ট্র্যাকিং:** ফায়ারস্টোর স্ট্রিমসের মাধ্যমে অর্ডারের স্ট্যাটাস সাথে সাথে রিয়েল-টাইমে আপডেট হয়।
4. **স্মার্ট পিসি বিল্ডার অ্যালগরিদম:** কম্পোনেন্ট চয়েস অনুযায়ী স্বয়ংক্রিয়ভাবে মোট ওয়াটেজ ও কম্প্যাটিবিলিটি ক্যালকুলেট করে।
5. **রেসপনসিভ ও মডার্ন UI:** `flutter_screenutil` এবং নিয়ন গ্রেডিয়েন্ট ডার্ক থিমের মাধ্যমে যেকোনো স্ক্রিনে দৃষ্টিনন্দন অভিজ্ঞতা।
