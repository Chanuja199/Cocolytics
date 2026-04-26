import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/scan_provider.dart';
import '../services/connectivity_service.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();
  
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        _setCamera(_controller!.description);
      }
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _selectedCameraIndex = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
        if (_selectedCameraIndex == -1) _selectedCameraIndex = 0;
        await _setCamera(_cameras[_selectedCameraIndex]);
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _setCamera(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller!.dispose();
    }
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    try {
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setCamera(_cameras[_selectedCameraIndex]);
  }

  Future<Position?> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      return null;
    }
  }
  
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null) {
        await _processImage(image.path);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _takeLivePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isTakingPicture) return;

    try {
      final XFile image = await _controller!.takePicture();
      await _controller!.pausePreview();
      await _processImage(image.path);
      
      if (mounted && _controller != null) {
        await _controller!.resumePreview();
      }
    } catch (e) {
      debugPrint('Take picture error: $e');
    }
  }

  Future<void> _processImage(String imagePath) async {
    setState(() => _isProcessing = true);

    try {
      final position = await _getLocation();
      final connectivity = context.read<ConnectivityService>();
      final isOnline = await connectivity.isOnline();

      final authProvider = context.read<AuthProvider>();
      final String userId = authProvider.currentUser?.id ?? 'anonymous';
      final String district = authProvider.currentUser?.district ?? 'Unknown';

      if (!mounted) return;

      await context.read<ScanProvider>().scanLeaf(
        imagePath: imagePath,
        userId: userId,
        district: district,
        latitude: position?.latitude,
        longitude: position?.longitude,
        isOnline: isOnline,
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);

      final scanProvider = context.read<ScanProvider>();

      if (scanProvider.state == ScanState.success) {
        context.push('/result');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                scanProvider.errorMessage.isNotEmpty
                    ? scanProvider.errorMessage
                    : 'Scan failed. Please try again.',
              ),
              backgroundColor: AppColors.warning,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      final errorStr = e.toString().toLowerCase();
      if (!errorStr.contains('cancel') && !errorStr.contains('pick')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildCameraView(),
          if (_isProcessing)
            Container(
              color: Colors.black87,
              child: _buildProcessingOverlay(),
            ),
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryLight),
          SizedBox(height: 24),
          Text(
            'Analyzing coconut leaf...',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'This may take a few seconds',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    final bool isCameraReady = _controller != null && _controller!.value.isInitialized;

    return Stack(
      children: [
        Positioned.fill(
          child: isCameraReady
              ? AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                )
              : Container(color: Colors.black),
        ),

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black87, Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/home');
                  }
                },
              ),
              title: const Text('Cocolytics', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),

        Center(
          child: CustomPaint(
            size: const Size(280, 280),
            painter: _ScanFramePainter(),
          ),
        ),

        Positioned(
          bottom: 160,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Position the coconut leaf inside the frame',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: _pickFromGallery,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              
              GestureDetector(
                onTap: _takeLivePicture,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.withOpacity(0.5), width: 4),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.camera,
                      color: Colors.black,
                      size: 38,
                    ),
                  ),
                ),
              ),
              
              GestureDetector(
                onTap: _switchCamera,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.flip_camera_android,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 40;
    const double radius = 8;

    canvas.drawLine(Offset(0, cornerLength), Offset(0, radius), paint);
    canvas.drawLine(Offset(radius, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(
      Offset(size.width - cornerLength, 0),
      Offset(size.width - radius, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, radius),
      Offset(size.width, cornerLength),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height - cornerLength),
      Offset(0, size.height - radius),
      paint,
    );
    canvas.drawLine(
      Offset(radius, size.height),
      Offset(cornerLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - cornerLength, size.height),
      Offset(size.width - radius, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height - cornerLength),
      Offset(size.width, size.height - radius),
      paint,
    );

    final centerPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1;
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawLine(Offset(cx - 15, cy), Offset(cx + 15, cy), centerPaint);
    canvas.drawLine(Offset(cx, cy - 15), Offset(cx, cy + 15), centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

