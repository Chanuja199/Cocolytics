**Cocolytics** is an advanced AI-powered Coconut disease detection and environmental monitoring application developed by **chanuja**. It leverages Deep Learning to help farmers and plant enthusiasts identify coconut-related diseases from simple leaf scans and provides actionable treatment plans.

## 🚀 Key Features
- **Instant Disease Detection**: Uses AI to identify plant illnesses from a single photo.
- **Severity Assessment**: Categorizes the intensity of the disease (Low, Medium, High).
- **Comprehensive Database**: Provides symptoms, scientific names, and botanical details.
- **Interactive Maps**: Localized monitoring of disease outbreaks across districts.
- **Community Forum**: Connect with other growers and share insights.
- **Support System**: Direct WhatsApp integration for expert assistance.

## 📂 Project Structure
- `lib/screens`: UI implementation (Camera, Home, Forum, etc.)
- `lib/providers`: State management using the Provider package.
- `lib/services`: Integration with Firebase, Cloudinary, and FastAPI AI models.
- `lib/models`: Data structures for scans, users, and forum posts.

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