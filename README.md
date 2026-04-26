# 🌴 Cocolytics

> **An advanced AI-powered Coconut disease detection and environmental monitoring application.**

**Cocolytics** leverages Deep Learning to help farmers, agronomists, and plant enthusiasts identify coconut-related diseases from simple leaf scans. By bridging the gap between artificial intelligence and agriculture, Cocolytics provides instant diagnostics, actionable treatment plans, and localized monitoring to ensure crop health and yield optimization.

---

##  Features

* **Instant Disease Detection:** Utilize custom AI models to identify plant illnesses from a single uploaded or captured photo.
* **Severity Assessment:** Automatically categorizes the intensity of the detected disease (Low, Medium, High) to prioritize treatment.
* **Comprehensive Database:** Access detailed botanical information, scientific names, and typical symptoms of various coconut diseases.
* **Interactive Maps:** Monitor disease outbreaks and environmental trends localized across different districts.
* **Community Forum:** Connect with other growers, share agricultural insights, and ask questions.
* **Direct Support System:** Built-in WhatsApp integration for immediate expert assistance and consultation.

---

## 🛠️ Tech Stack

**Frontend**
* [Flutter](https://flutter.dev/) - Multi-platform UI framework
* **Provider** - State management

**Backend & Cloud**
* [Firebase](https://firebase.google.com/) - Authentication, Firestore (Database), and Cloud Storage

**Artificial Intelligence**
* **FastAPI** - High-performance backend serving custom Deep Learning models
* **Gemini API** - (Integrated via secrets for advanced data processing/generation)

---

## 📂 Project Structure

```text
lib/
├── models/       # Data structures for scans, users, and forum posts
├── providers/    # State management logic and view models
├── screens/      # UI implementation (Camera, Home, Forum, Maps, etc.)
├── services/     # API integrations (Firebase, Cloudinary, FastAPI)
├── utils/        # Helper functions, constants, and secret configurations
└── main.dart     # Application entry point 
```

## 🛠️ Built With
- **Framework**: Flutter (Multi-platform)
- **State Management**: Provider
- **Backend**: Firebase (Auth, Firestore, Storage)
- **AI Backend**: FastAPI (Custom Deep Learning Models)
- **Image Hosting**: Cloudinary

## 🔧 Installation
1.  **Clone the Repository**:
    ```bash
    git clone [your-repository-url]
    ```
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Configure Secrets**:
    Create a `lib/utils/secrets.dart` file with your API keys:
    ```dart
    class Secrets {
      static const String cloudinaryCloudName = "your_cloud_name";
      static const String cloudinaryUploadPreset = "your_preset";
      static const String geminiApiKey = "your_gemini_key";
    }
    ```
4.  **Run the App**:
    ```bash
    flutter run
    ```

## 📝 Author
Developed by **chanuja** - Focused on bridging AI and Agriculture.
