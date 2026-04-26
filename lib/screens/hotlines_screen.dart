import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';
import '../models/support_model.dart';

class HotlinesScreen extends StatelessWidget {
  const HotlinesScreen({super.key});

  /// Launches WhatsApp with a pre-filled assistance message.
  Future<void> _openWhatsApp(String number) async {
    final message = Uri.encodeComponent(
      'Hello! I need help with my coconut crop.',
    );
    final url = 'https://wa.me/$number?text=$message';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Triggers a native phone call to the specified number.
  Future<void> _callNumber(String number) async {
    final cleanNumber = number.replaceAll(' ', '').replaceAll('+', '');
    final uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contacts = SupportData.getContacts();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Government Hotlines',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Immediate Assistance',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () => _callNumber('1920'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF2E8B57)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.phone_in_talk,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Agriculture Hotline',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          '1920',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Regional & Specialized Contacts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...contacts.map(
              (contact) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Divider(height: 20, thickness: 0.5),

                    ...contact.phones.map(
                      (phone) => _buildContactAction(
                        icon: Icons.phone_outlined,
                        label: 'Call: $phone',
                        onTap: () => _callNumber(phone),
                        color: AppColors.primary,
                      ),
                    ),

                    if (contact.whatsappNumber != null)
                      _buildContactAction(
                        icon: Icons.chat_outlined,
                        label: 'WhatsApp: ${contact.whatsappNumber}',
                        onTap: () => _openWhatsApp(contact.whatsappNumber!),
                        color: const Color(0xFF25D366),
                      ),

                    ...contact.emails.map(
                      (email) => _buildContactAction(
                        icon: Icons.email_outlined,
                        label: email,
                        onTap: () {}, // Add email launch logic if needed
                        color: Colors.blueGrey,
                      ),
                    ),

                    if (contact.websiteUrl != null)
                      _buildContactAction(
                        icon: Icons.language,
                        label: 'Visit Website',
                        onTap: () async {
                          final uri = Uri.parse(contact.websiteUrl!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        color: AppColors.primary,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: color == AppColors.primary ? color : Colors.black87,
                  fontWeight: color == AppColors.primary
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
