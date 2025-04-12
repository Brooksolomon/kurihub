import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class CheckInScreen extends StatefulWidget {
  final CameraDescription camera;
  const CheckInScreen({required this.camera, super.key});

  @override
  _CheckInScreenState createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen>
    with SingleTickerProviderStateMixin {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      enableContours: true,
      enableClassification: true,
    ),
  );
  bool _isProcessing = false;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0; // 0 for front, 1 for back
  String? _feedbackMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeCameras();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeCameras() async {
    _cameras = await availableCameras();
    // Default to front camera (selfie) for check-in
    _selectedCameraIndex = _cameras!.indexWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );
    if (_selectedCameraIndex == -1) {
      _selectedCameraIndex = 0; // Fallback to first available camera
    }
    await _initializeCameraController();
  }

  Future<void> _initializeCameraController() async {
    _controller = CameraController(
      _cameras![_selectedCameraIndex],
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _faceDetector.close();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _flipCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    setState(() {
      _isProcessing = true;
      _feedbackMessage = null;
    });

    await _controller.dispose();
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    await _initializeCameraController();

    setState(() {
      _isProcessing = false;
    });
  }

  Future<Map<String, dynamic>> _detectFace(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        return {'success': false, 'message': 'No face detected'};
      }
      if (faces.length > 1) {
        return {'success': false, 'message': 'Multiple faces detected'};
      }

      final face = faces.first;
      if (face.smilingProbability != null && face.smilingProbability! < 0.8) {
        return {'success': false, 'message': 'Please smile to verify liveness'};
      }

      return {'success': true, 'message': 'Face detected'};
    } catch (e) {
      return {'success': false, 'message': 'Error detecting face: $e'};
    }
  }

  Future<Map<String, dynamic>> _compareFacesWithRekognition(
    String liveImagePath,
    String uploadedImageUrl,
  ) async {
    try {
      // Prepare the request to the Flask backend
      final url = Uri.parse(
        'https://mv342wgl-5000.uks1.devtunnels.ms/compareface',
      ); // Replace with your backend URL
      var request = http.MultipartRequest('POST', url);

      // Add the live image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'source_image',
          liveImagePath,
          filename: 'source_image.jpg',
        ),
      );

      // Add the target image URL
      request.fields['target_image_url'] = uploadedImageUrl;

      // Send the request
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      print("shanks");
      print(responseBody.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody.body);
        final result = data['result'] as String;

        if (result.contains('Similarity')) {
          // Extract similarity percentage from the result (e.g., "Similarity: 95.23%")
          final similarity = double.parse(
            result.split(' ')[1].replaceAll('%', ''),
          );
          return {
            'success': similarity >= 90,
            'message': similarity >= 90 ? 'Face matched' : 'Face not matched',
            'similarity': similarity,
          };
        } else {
          return {'success': false, 'message': result};
        }
      } else {
        return {
          'success': false,
          'message': 'Backend error: ${responseBody.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error comparing faces: $e'};
    }
  }

  Future<void> _handleCheckIn() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _feedbackMessage = null;
    });

    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final detectionResult = await _detectFace(image.path);

      if (!detectionResult['success']) {
        setState(() {
          _feedbackMessage = detectionResult['message'];
          _animationController.forward(from: 0);
        });
        return;
      }

      const uploadedImageUrl =
          'https://drive.google.com/uc?export=download&id=1NWlGZTW_f_Iwkd62FSBV2bRXN1V7ZsKn';
      final recognitionResult = await _compareFacesWithRekognition(
        image.path,
        uploadedImageUrl,
      );

      setState(() {
        _feedbackMessage = recognitionResult['message'];
        _animationController.forward(from: 0);
      });

      if (recognitionResult['success']) {
        await Future.delayed(const Duration(milliseconds: 500));
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() {
        _feedbackMessage = 'Error during check-in: $e';
        _animationController.forward(from: 0);
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            title: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            content: const Text(
              'Check-in Successful!\nWelcome to your stay.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  children: [
                    CameraPreview(_controller),
                    // Face Positioning Overlay
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.7),
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Check-In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.flip_camera_ios,
                        color: Colors.white,
                      ),
                      onPressed: _isProcessing ? null : _flipCamera,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Feedback Message
          if (_feedbackMessage != null)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _feedbackMessage!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Capture Button
                GestureDetector(
                  onTap: _isProcessing ? null : _handleCheckIn,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueAccent,
                        ),
                        child: const Icon(
                          Icons.camera,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Position your face within the circle',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Loading Indicator
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                strokeWidth: 5,
              ),
            ),
        ],
      ),
    );
  }
}
