import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get aiBaseUrl => dotenv.get('AI_BASE_URL', fallback: 'http://localhost:8000');
  static const String predictEndpoint = '/predict';

  static const String whatsappNumber = '0740629020';
  static const String whatsappDefaultMessage =
      'Hello! I need help with my coconut crop.';

  static const String scansBox = 'scans_box';
  static const String treatmentsBox = 'treatments_box';
  static const String districtBox = 'district_box';
  static const String userBox = 'user_box';

  static const List<String> sriLankaDistricts = [
    'Colombo',
    'Gampaha',
    'Kalutara',
    'Kandy',
    'Matale',
    'Nuwara Eliya',
    'Galle',
    'Matara',
    'Hambantota',
    'Jaffna',
    'Kilinochchi',
    'Mannar',
    'Vavuniya',
    'Mullaitivu',
    'Batticaloa',
    'Ampara',
    'Trincomalee',
    'Kurunegala',
    'Puttalam',
    'Anuradhapura',
    'Polonnaruwa',
    'Badulla',
    'Moneragala',
    'Ratnapura',
    'Kegalle',
  ];
}
