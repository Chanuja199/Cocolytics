import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/cloudinary_service.dart';
import '../utils/app_colors.dart';
import '../providers/localization_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  File? _pickedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  void _sync(AuthProvider auth) {
    final user = auth.currentUser;
    if (user == null) return;
    _nameController.text = user.name;
    _phoneController.text = user.phone;
    _addressController.text = user.address;
    _cityController.text = user.city;
    _districtController.text = user.district;
  }

  Future<void> _pickImage() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 800,
    );
    if (picked == null) return;

    setState(() => _pickedImage = File(picked.path));
  }

  Future<ImageSource?> _showImageSourceDialog() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<String?> _uploadImage() async {
    if (_pickedImage == null) return null;

    setState(() => _isUploadingImage = true);
    try {
      final url = await CloudinaryService().uploadProfileImage(
        _pickedImage!.path,
      );
      return url;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image upload failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _handleLogout(AuthProvider auth) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        final loc = context.watch<LocalizationProvider>();
        return AlertDialog(
          title: Text(loc.translate('logout')),
          content: const Text('Do you want to log out now?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(loc.translate('cancel')),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(loc.translate('logout')),
          ),
        ],
      );
    },
    );

    if (shouldLogout == true) {
      await auth.logout();
      if (mounted) context.go('/login');
    }
  }

  Future<void> _save(AuthProvider auth) async {
    setState(() => _isSaving = true);

    String? newImageUrl;
    if (_pickedImage != null) {
      newImageUrl = await _uploadImage();
      if (newImageUrl == null) {
        setState(() => _isSaving = false);
        return;
      }
    }

    final ok = await auth.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      district: _districtController.text.trim(),
      profileImageUrl: newImageUrl ?? auth.currentUser?.profileImageUrl ?? '',
    );

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      if (ok) {
        _isEditing = false;
        _pickedImage = null;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Profile updated.' : auth.errorMessage),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user != null && _nameController.text.isEmpty) {
      _sync(auth);
    }

    final networkUrl = user?.profileImageUrl ?? '';
    final bool busy = _isSaving || _isUploadingImage;
    final loc = context.watch<LocalizationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          loc.translate('profile'),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),

            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.primaryLight.withAlpha(40),
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!) as ImageProvider
                      : networkUrl.isNotEmpty
                      ? NetworkImage(networkUrl)
                      : null,
                  child: (_pickedImage == null && networkUrl.isEmpty)
                      ? const Icon(
                          Icons.person,
                          size: 54,
                          color: AppColors.textSecondary,
                        )
                      : null,
                ),
                if (_isEditing)
                  GestureDetector(
                    onTap: busy ? null : _pickImage,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: _isUploadingImage
                          ? const Padding(
                              padding: EdgeInsets.all(7),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            _profileInput(
              icon: Icons.person_outline,
              label: 'Name',
              controller: _nameController,
              enabled: _isEditing,
            ),
            _profileInput(
              icon: Icons.phone_outlined,
              label: 'Phone',
              controller: _phoneController,
              enabled: _isEditing,
            ),
            _readonlyField(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user?.email ?? '',
            ),
            _profileInput(
              icon: Icons.home_outlined,
              label: 'Address',
              controller: _addressController,
              enabled: _isEditing,
            ),
            _profileInput(
              icon: Icons.location_city_outlined,
              label: 'City',
              controller: _cityController,
              enabled: _isEditing,
            ),
            _profileInput(
              icon: Icons.map_outlined,
              label: 'District',
              controller: _districtController,
              enabled: _isEditing,
            ),

            const SizedBox(height: 16),

            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy
                          ? null
                          : () {
                              setState(() {
                                _isEditing = false;
                                _pickedImage = null;
                              });
                              _sync(auth);
                            },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: busy ? null : () => _save(auth),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: busy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: () => setState(() => _isEditing = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Edit Details'),
              ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () =>
                  _handleLogout(auth),
              child: Text(
                loc.translate('logout'),
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileInput({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool enabled,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _readonlyField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$label: $value',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
