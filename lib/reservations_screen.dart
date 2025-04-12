import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen>
    with SingleTickerProviderStateMixin {
  File? _uploadedImage; // Image selected from gallery
  List<String> _brokenRules = []; // Broken rules from the backend
  bool _isProcessing = false;
  String? _feedbackMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _uploadedImage = File(image.path);
        _brokenRules = [];
        _feedbackMessage = null;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_isProcessing || _uploadedImage == null) return;

    setState(() {
      _isProcessing = true;
      _feedbackMessage = null;
      _brokenRules = [];
    });

    try {
      // Prepare the request to the Flask backend
      final url = Uri.parse(
        'https://mv342wgl-5000.uks1.devtunnels.ms/analyze-image',
      ); // Replace with your backend URL
      var request = http.MultipartRequest('POST', url);

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          _uploadedImage!.path,
          filename: 'room_image.jpg',
        ),
      );

      // Send the request
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody.body);
        final brokenRules = List<String>.from(data['broken_rules']);

        setState(() {
          _brokenRules = brokenRules;
          _feedbackMessage =
              brokenRules.isEmpty ? 'All rules passed!' : 'Rules check failed.';
          _animationController.forward(from: 0);
        });

        if (brokenRules.isEmpty) {
          await Future.delayed(const Duration(milliseconds: 500));
          _showSuccessDialog();
        }
      } else {
        setState(() {
          _feedbackMessage = 'Backend error: ${responseBody.body}';
          _animationController.forward(from: 0);
        });
      }
    } catch (e) {
      setState(() {
        _feedbackMessage = 'Error analyzing image: $e';
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
              'Room Check Passed!\nThe room meets all requirements.',
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
          // Background
          Container(
            color: Colors.grey[100],
            child: Column(
              children: [
                // Image Preview
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_uploadedImage != null)
                          Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: FileImage(_uploadedImage!),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.grey[300],
                            ),
                            child: const Icon(
                              Icons.image,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _pickImageFromGallery,
                          icon: const Icon(Icons.upload),
                          label: const Text('Upload Room Image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Rules Check Results
                if (_brokenRules.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Broken Rules:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._brokenRules.map(
                          (rule) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  rule,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
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
                      'Room Check',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_uploadedImage != null)
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.blueAccent),
                        onPressed: _isProcessing ? null : _analyzeImage,
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
