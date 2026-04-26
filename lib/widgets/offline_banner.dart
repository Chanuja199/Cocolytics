import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.offlineBanner,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: const Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            'No internet connection — some features unavailable',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
