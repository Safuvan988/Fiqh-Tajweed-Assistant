# 🕌 QuranFiqh Assistant

> **A premium Islamic Fiqh & Tajweed companion — powered by Google Gemini AI**

A cross-platform Flutter application that helps Muslims get accurate Islamic rulings and Quran recitation guidance through a beautiful, conversational AI interface. Built with Shafi'i Fiqh as the default madhab, with support for Hanafi, Maliki, and Hanbali schools.

---

## ✨ Features

### 🤖 AI-Powered Q&A (Ask Screen)
- **Conversational interface** — ask any Fiqh or Tajweed question in plain language
- **Hybrid answer engine** — local Masa'la database (offline) + Google Gemini 1.5 Pro (online)
- **Typewriter streaming animation** — answers appear character-by-character for a premium feel
- **Structured answers** — includes ruling, Qur'anic reference (Arabic + translation), Hadith (Arabic + translation), and detailed Fiqh explanation
- **Bookmark answers** — save important rulings to your personal Firestore bookmarks

### 🏠 Home Screen — Daily Islamic Content
- **Verse of the Day** — Qur'anic ayah with Arabic text & translation
- **Daily Masa'la** — bite-sized Fiqh ruling with full explanation
- **Tajweed Tip** — daily recitation rule explained clearly
- **Daily Dhikr** — remembrance of Allah with context and virtues
- Content fetched dynamically from Gemini AI with a graceful static fallback

### 📚 Learn Screen (Tajweed)
- Structured Tajweed rule lessons
- Audio pronunciation support via `audioplayers`

### 🔖 Bookmarks
- Cloud-synced bookmarks stored in Firestore per user account
- Browse and manage saved rulings anytime

### 💬 Chat History
- Session-based conversation history with drawer navigation
- Start new chats or resume previous sessions

### ⚙️ Settings
- **Madhab selector** — Shafi'i, Hanafi, Maliki, Hanbali
- **Language** — English, Malayalam (മലയാളം), Arabic (العربية)
- **Dark/Light mode** toggle
- **Font size** adjustment slider
- **AI answer style** — Concise, Detailed, or Scholarly
- **Profile management** — display name editing, email display
- **Data & Privacy** — clear chat history, view bookmarks, log out

### 🔐 Authentication
- **Google Sign-In** for full account access
- **Anonymous (Guest) mode** for instant access without registration
- Firebase Auth with session persistence

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart) |
| **State Management** | Riverpod (`flutter_riverpod`) |
| **AI Engine** | Google Gemini 1.5 Pro & Flash API |
| **Backend** | Firebase (Auth, Firestore, Storage, Crashlytics) |
| **Authentication** | Firebase Auth + Google Sign-In |
| **Local Storage** | `shared_preferences` |
| **Fonts** | Google Fonts — Inter (English), Amiri (Arabic), Noto Sans Malayalam |
| **Icons/SVG** | `flutter_svg` |
| **Audio** | `audioplayers` |
| **Networking** | `http` |
| **Error Tracking** | Firebase Crashlytics |

---

## 📂 Project Structure

```
lib/
├── core/
│   └── theme/               # AppTheme, AppColors, AppTextStyles
├── models/                  # Data models (ChatMessage, UserModel, etc.)
├── providers/               # Riverpod providers (auth, settings, etc.)
├── screens/
│   ├── ask/                 # AI Q&A chat screen
│   ├── auth/                # Login screen
│   ├── bookmarks/           # Saved answers screen
│   ├── home/                # Daily content home screen
│   ├── learn/               # Tajweed learning screen
│   ├── settings/            # Settings & profile screen
│   └── tajweed/             # Tajweed rules browser
├── services/
│   ├── audio_service.dart   # Audio playback
│   ├── auth_service.dart    # Firebase Auth logic
│   ├── chat_history_service.dart  # Local session management
│   ├── daily_content_service.dart # Home content caching
│   ├── firestore_service.dart     # Firestore CRUD operations
│   ├── gemini_service.dart        # Gemini AI API integration
│   └── settings_service.dart     # User preferences persistence
├── widgets/                 # Reusable UI components
└── main.dart                # App entry point + Firebase init
assets/
├── data/
│   └── masaala.json         # Offline Fiqh ruling database
├── icons/                   # SVG icon set
└── images/                  # App launcher icon & static images
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) `>=3.10.7`
- A Firebase project with **Android** and/or **iOS** app configured
- A [Google Gemini API key](https://aistudio.google.com/app/apikey)

### 1. Clone the Repository

```bash
git clone https://github.com/Safuvan988/Fiqh-Tajweed-Assistant.git
cd Fiqh-Tajweed-Assistant
```

### 2. Set Up Environment Variables

Create a `.env` file in the project root:

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

> ⚠️ **Never commit your `.env` file.** It is already listed in `.gitignore`.

### 3. Configure Firebase

- Place your `google-services.json` in `android/app/`
- Place your `GoogleService-Info.plist` in `ios/Runner/`
- Enable **Firebase Auth** (Email/Password + Google + Anonymous)
- Enable **Cloud Firestore**
- Enable **Firebase Crashlytics**

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run the App

```bash
flutter run
```

---

## 🔑 Firebase Firestore Structure

```
users/{userId}/
  ├── name
  ├── email
  ├── isGuest
  └── createdAt

bookmarks/{bookmarkId}/
  ├── userId
  ├── question
  ├── answer
  └── createdAt

chatSessions/{sessionId}/
  └── messages/{messageId}/
        ├── text
        ├── sender
        └── timestamp
```

---

## 📱 Supported Platforms

| Platform | Status |
|---|---|
| Android | ✅ Supported |
| iOS | ✅ Supported |
| Web | 🔧 Configured (experimental) |
| Windows | 🔧 Configured (experimental) |
| macOS | 🔧 Configured (experimental) |
| Linux | 🔧 Configured (experimental) |

---

## 🌐 Language Support

| Language | Code | Status |
|---|---|---|
| English | `en` | ✅ Full |
| Malayalam | `ml` | ⚠️ UI option available (in progress) |
| Arabic | `ar` | ⚠️ UI option available (in progress) |

---

## ⚠️ Disclaimer

This application is intended as an **educational and assistive tool** for Muslims seeking general guidance. It is **not a substitute** for a qualified Islamic scholar. For important religious, legal, or personal matters, always consult a knowledgeable and trusted scholar.

---

## 🤝 Contributing

Contributions, suggestions, and feedback are welcome!

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

---

## 📄 License

This project is for educational and personal use. All Islamic content is sourced from authentic classical references. Please use responsibly.

---

<div align="center">
  <p>Made with ❤️ for the Muslim community</p>
  <p><em>بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ</em></p>
</div>
