# AeroCast Weather — Flutter Mobile Application with REST API & Firebase Storage

> **Developed for Practical 12:** Develop and Deploy a Complete Flutter App with Backend API and Firebase Storage (Final Project Demo)  
> **Institution:** VIVA Institute of Technology (Department of Computer Science & Engineering - AI & ML)

---

## 🌟 Key Features

1. **Modern Glassmorphic UI:**
   - Dynamic atmospheric backgrounds (Sunny, Rainy, Stormy, Cloudy, Night) adapting in real time to the current weather condition.
   - Glassmorphic card styling with backdrop blur and sleek typography.
2. **Real-Time REST Weather API (GET):**
   - Live temperature, "feels like" metric, high/low limits, humidity, wind velocity, pressure, and UV index.
   - 24-Hour horizontal hourly forecast with weather condition badges.
   - 7-Day climate outlook with min-max temperature range visualization.
   - Multi-city search with autocomplete quick chips and saved favorites.
3. **Citizen Climate Observation Feed (REST CRUD + Firebase Storage):**
   - **Image Capture & Upload (`image_picker` + `firebase_storage`):** Take sky/storm photos via camera or pick from gallery, upload directly to Firebase Cloud Storage, and obtain public download URLs.
   - **REST POST (`/api/reports`):** Store observations with cloud image links, temperature, and condition notes.
   - **REST GET (`/api/reports`):** Display feed of community observations.
   - **REST PUT (`/api/reports/:id`):** Edit existing notes and temperature readings.
   - **REST DELETE (`/api/reports/:id`):** Remove observations.
4. **Persistent On-Device Storage (`shared_preferences`):**
   - Saves all searched and favorited cities locally to the physical device / emulator.
   - Automatically remembers the last viewed location when the app restarts.
   - 1-tap bookmark button in the top App Bar to add/remove locations from device storage.
5. **Firebase Authentication (`firebase_auth`):**
   - User sign-in, user registration, and evaluator/guest bypass mode.
6. **Self-Contained Fallback Mode:**
   - Runs out-of-the-box in demo mode even before Firebase or the local backend is configured, preventing crashes during presentation.

---

## 📂 Project Directory Structure

```
weather_app/
├── lib/
│   ├── main.dart                      # App entry point, MultiProvider & routes
│   ├── models/
│   │   ├── weather_model.dart         # Weather, hourly & daily forecast models
│   │   └── weather_report_model.dart  # Observation & Firebase image model
│   ├── services/
│   │   ├── weather_api_service.dart   # REST API client (GET, POST, PUT, DELETE)
│   │   └── firebase_service.dart      # Firebase Auth & Firebase Storage handler
│   ├── providers/
│   │   └── weather_provider.dart      # ChangeNotifier Provider state management
│   ├── screens/
│   │   ├── splash_screen.dart         # Animated branded splash screen
│   │   ├── login_screen.dart          # Firebase auth & guest login screen
│   │   ├── home_screen.dart           # Flagship weather dashboard
│   │   ├── weather_detail_screen.dart # In-depth atmospheric metrics (UV, AQI)
│   │   ├── city_search_screen.dart    # City search & favorites management
│   │   ├── add_report_screen.dart     # Image picker & Firebase Storage upload form
│   │   └── reports_list_screen.dart   # Community feed with REST CRUD actions
│   ├── theme/
│   │   └── app_theme.dart             # Weather gradients & glassmorphism theme
│   └── widgets/
│       ├── glass_container.dart       # BackdropFilter frosted glass widget
│       └── weather_info_tile.dart     # Metric summary tiles
├── backend/
│   ├── server.js                      # Express.js REST API (GET, POST, PUT, DELETE)
│   ├── package.json                   # Backend dependencies (express, cors)
│   └── README.md                      # API endpoints & Postman verification guide
├── android/
│   └── app/src/main/AndroidManifest.xml # Permissions (INTERNET, CAMERA, STORAGE)
├── pubspec.yaml                       # Flutter project configuration & packages
├── PRACTICAL_12_REPORT.md             # Complete formal lab report document
└── README.md                          # Project documentation
```

---

## 🚀 How to Run the Project

### 1. Start the Backend REST API (Node.js)
Open PowerShell or Terminal:
```bash
cd backend
npm install
npm start
```
The server will start on `http://localhost:5000` with routes:
- `GET /api/reports`
- `POST /api/reports`
- `PUT /api/reports/:id`
- `DELETE /api/reports/:id`

### 2. Run the Flutter App
Ensure Flutter SDK is installed and added to PATH, then:
```bash
flutter pub get
flutter run
```

### 3. Build the Release APK
```bash
flutter build apk --release
```
The built APK is saved at:  
`build/app/outputs/flutter-apk/app-release.apk`

---

## ☁️ Firebase Configuration (Optional for Live Firebase Production)
1. Go to [Firebase Console](https://console.firebase.google.com/) and create a project.
2. Add an Android app with package name: `com.viva.weather_app`.
3. Download `google-services.json` and place it in `android/app/`.
4. Enable **Firebase Authentication** (Email/Password & Anonymous) and **Firebase Storage** (Rules: `allow read, write: if true;` or auth-guarded).
5. The application automatically detects Firebase and uses live cloud storage! If not yet configured, the app runs gracefully in simulation mode.

---

## 📄 Academic Lab Report
The complete laboratory report matching the VIVA Institute format is available at:  
[`PRACTICAL_12_REPORT.md`](./PRACTICAL_12_REPORT.md)
