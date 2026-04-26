import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/localization_provider.dart';
import '../services/cloudinary_service.dart';
import '../utils/app_colors.dart';

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

  /// Upload picked image to Cloudinary and return the secure URL.
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // background-light
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 8),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: AppBar(
              backgroundColor: const Color(0xFFF8FAFC).withOpacity(0.85),
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(
                  color: const Color(0xFFE2E8F0), // border-slate-200
                  height: 1.0,
                ),
              ),
              title: const Text(
                'Profile ',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color(0xFF0F172A), // text-slate-900
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 24),
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1FAE5), // bg-emerald-100
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/icon.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5), // emerald-100
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          image: _pickedImage != null
                              ? DecorationImage(
                                  image: FileImage(_pickedImage!),
                                  fit: BoxFit.cover,
                                )
                              : networkUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(networkUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: (_pickedImage == null && networkUrl.isEmpty)
                            ? const Icon(
                                Icons.person_outline,
                                size: 54,
                                color: Color(0xFF059669), // emerald-600
                              )
                            : null,
                      ),
                      if (_isEditing)
                        GestureDetector(
                          onTap: busy ? null : _pickImage,
                          child: Container(
                            margin: const EdgeInsets.only(right: 4, bottom: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF065F46), // primary
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: _isUploadingImage
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name.isNotEmpty == true ? user!.name : 'User',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Member since Jan 2024',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      color: Color(0xFF64748B), // text-slate-500
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              _buildInfoCard(
                icon: Icons.person_outline,
                topLabel: 'NAME / සම්පූර්ණ නම',
                displayValue: user?.name ?? '-',
                controller: _nameController,
                isEditing: _isEditing,
              ),
              _buildInfoCard(
                icon: Icons.phone_outlined,
                topLabel: 'PHONE NUMBER / දුරකථන අංකය',
                displayValue: user?.phone ?? '-',
                controller: _phoneController,
                isEditing: _isEditing,
                keyboardType: TextInputType.phone,
              ),
              _buildInfoCard(
                icon: Icons.mail_outline,
                topLabel: 'EMAIL ADDRESS / විද්‍යුත් තැපෑල',
                displayValue: user?.email ?? '-',
                controller: TextEditingController(text: user?.email),
                isEditing: _isEditing,
                readOnly: true,
              ),
              _buildInfoCard(
                icon: Icons.home_outlined,
                topLabel: 'ADDRESS / ලිපිනය',
                displayValue: user?.address ?? '-',
                controller: _addressController,
                isEditing: _isEditing,
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.location_city_outlined,
                      topLabel: 'CITY / නගරය',
                      displayValue: user?.city ?? '-',
                      controller: _cityController,
                      isEditing: _isEditing,
                      isGridItem: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.map_outlined,
                      topLabel: 'DISTRICT / දිස්ත්‍රික්කය',
                      displayValue: user?.district ?? '-',
                      controller: _districtController,
                      isEditing: _isEditing,
                      isGridItem: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              if (_isEditing)
                Row(
                  children: [
                    Expanded(
                      child: _buildSecondaryOutlineButton(
                        title: 'Cancel',
                        subtitle: 'අවලංගු කරන්න',
                        onPressed: busy
                            ? null
                            : () {
                                setState(() {
                                  _isEditing = false;
                                  _pickedImage = null;
                                });
                                _sync(auth);
                              },
                        color: const Color(0xFF64748B),
                        borderColor: const Color(0xFFE2E8F0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPrimaryButton(
                        title: 'Save Details',
                        subtitle: 'සුරකින්න',
                        onPressed: busy ? null : () => _save(auth),
                        isLoading: busy,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildPrimaryButton(
                      title: 'Edit Details',
                      subtitle: 'විස්තර සංස්කරණය කරන්න',
                      onPressed: () => setState(() => _isEditing = true),
                      isLoading: false,
                    ),
                    _buildSecondaryOutlineButton(
                      title: 'Logout',
                      subtitle: 'ඉවත් වන්න',
                      onPressed: () => _handleLogout(auth),
                      color: const Color(0xFFF43F5E), // rose-500
                      borderColor: const Color(0xFFFFE4E6), // rose-100
                    ),
                  ],
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String topLabel,
    required String displayValue,
    required TextEditingController controller,
    required bool isEditing,
    bool readOnly = false,
    TextInputType? keyboardType,
    bool isGridItem = false,
  }) {
    return Container(
      margin: isGridItem ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isGridItem ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)), // slate-100
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isGridItem ? 6 : 8),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5), // emerald-50
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF065F46), // primary
              size: isGridItem ? 20 : 22,
            ),
          ),
          SizedBox(width: isGridItem ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topLabel,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Color(0xFF94A3B8), // slate-400
                  ),
                ),
                const SizedBox(height: 4),
                isEditing && !readOnly
                    ? TextFormField(
                        controller: controller,
                        keyboardType: keyboardType,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B), // slate-800
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 0,
                          ),
                          border: InputBorder.none,
                        ),
                      )
                    : Text(
                        displayValue.isEmpty ? '-' : displayValue,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                          height: 1.4,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String title,
    required String subtitle,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF065F46), // primary bg-emerald-800 equivalent
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF065F46).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSecondaryOutlineButton({
    required String title,
    required String subtitle,
    required VoidCallback? onPressed,
    required Color color,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
