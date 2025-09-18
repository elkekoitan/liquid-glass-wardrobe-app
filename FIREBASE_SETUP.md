# 🔥 FIREBASE SETUP GUIDE

## 📋 Prerequisites
- Google account: **turhanhamza@gmail.com** ✅
- Flutter CLI installed
- Firebase CLI installed

---

## 🚀 STEP 1: Create Firebase Project

### 1.1 Go to Firebase Console
1. Visit: https://console.firebase.google.com
2. Sign in with: **turhanhamza@gmail.com**
3. Click **"Add project"**

### 1.2 Project Configuration
```
Project Name: liquid-glass-fit-check
Project ID: liquid-glass-fit-check (or auto-generated)
Location: United States (us-central)
Enable Google Analytics: ✅ Yes
Analytics Account: Default Account for Firebase
```

---

## 🛠️ STEP 2: Configure Firebase Services

### 2.1 Authentication Setup
1. Go to **Authentication** > **Sign-in method**
2. Enable these providers:
   ```
   ✅ Email/Password
   ✅ Google (Optional - for social login)
   ✅ Anonymous (For testing)
   ```

### 2.2 Firestore Database
1. Go to **Firestore Database**
2. Click **"Create database"**
3. Start in **test mode** (for development)
4. Location: **us-central1**

### 2.3 Storage Setup
1. Go to **Storage**
2. Click **"Get started"**
3. Start in **test mode**
4. Location: **us-central1**

---

## 📱 STEP 3: Add Flutter App

### 3.1 Android App Setup
1. Click **"Add app"** > Android
2. Android package name: `com.liquidglass.fitcheck`
3. App nickname: `FitCheck Android`
4. Debug signing certificate SHA-1: (Optional for now)
5. **Download `google-services.json`**
6. Place file in: `android/app/google-services.json`

### 3.2 iOS App Setup
1. Click **"Add app"** > iOS
2. iOS bundle ID: `com.liquidglass.fitcheck`
3. App nickname: `FitCheck iOS`
4. **Download `GoogleService-Info.plist`**
5. Place file in: `ios/Runner/GoogleService-Info.plist`

---

## 🔧 STEP 4: Flutter Configuration

### 4.1 Install FlutterFire CLI
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

### 4.2 Configure Firebase
```bash
# Login to Firebase
firebase login

# Configure FlutterFire
flutterfire configure
```

**Select these options:**
- Project: `liquid-glass-fit-check`
- Platforms: ✅ Android, ✅ iOS, ✅ Web
- Bundle ID (iOS): `com.liquidglass.fitcheck`
- Package name (Android): `com.liquidglass.fitcheck`

### 4.3 Update Firebase Config File
Replace the placeholder values in:
`lib/core/config/firebase_config.dart`

Copy the values from the generated `firebase_options.dart` file.

---

## 📊 STEP 5: Firestore Security Rules

### 5.1 Update Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Public read for products (if you add them later)
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Test data access
    match /test/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 5.2 Storage Security Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User profile images
    match /users/{userId}/profile/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Wardrobe images
    match /users/{userId}/wardrobe/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Public product images
    match /products/{allPaths=**} {
      allow read: if true;
    }
  }
}
```

---

## 🧪 STEP 6: Testing Setup

### 6.1 Create Test User
1. Go to **Authentication** > **Users**
2. Click **"Add user"**
3. Email: `test@liquidglass.com`
4. Password: `test123456`

### 6.2 Add Test Data
Create a test document in Firestore:
```
Collection: test
Document ID: welcome
Data: {
  message: "Welcome to FitCheck!",
  timestamp: [current timestamp],
  version: "1.0.0"
}
```

---

## 🔑 IMPORTANT SECURITY NOTES

### 6.1 API Key Security
- ✅ Android/iOS API keys are safe to include in apps
- ⚠️ Never commit web API keys to public repos
- 🔒 Use environment variables for sensitive keys

### 6.2 Bundle/Package IDs
- Android: `com.liquidglass.fitcheck`
- iOS: `com.liquidglass.fitcheck`
- Make sure these match in your `pubspec.yaml`

---

## 📋 VERIFICATION CHECKLIST

After setup, verify these work:

### ✅ Authentication
- [ ] User can register with email/password
- [ ] User can sign in
- [ ] User can sign out
- [ ] User data syncs to Firestore

### ✅ Firestore
- [ ] Can read from collections
- [ ] Can write user data
- [ ] Security rules work properly

### ✅ Storage
- [ ] Can upload images
- [ ] Can download images
- [ ] Security rules work

---

## 🚨 TROUBLESHOOTING

### Common Issues:

1. **"Firebase project not found"**
   - Check project ID matches exactly
   - Verify you're signed in with correct Google account

2. **"Permission denied"**
   - Update Firestore security rules
   - Check user authentication status

3. **"Platform not configured"**
   - Make sure `google-services.json` (Android) is in correct folder
   - Make sure `GoogleService-Info.plist` (iOS) is in correct folder

4. **"FlutterFire not found"**
   - Run: `dart pub global activate flutterfire_cli`
   - Add to PATH: `~/.pub-cache/bin`

---

## 📞 NEXT STEPS

After Firebase setup is complete:

1. **Update AuthService** to use real Firebase
2. **Test authentication** in the app
3. **Implement user profile storage**
4. **Add image upload functionality**
5. **Set up analytics and crashlytics**

---

**Setup by**: AI Assistant  
**Date**: 2025-09-16  
**Account**: turhanhamza@gmail.com  
**Project**: FitCheck - AI Virtual Try-On