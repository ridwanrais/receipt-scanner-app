import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    // Initialize the camera controller
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    // Initialize the controller future
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Scan Receipt',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the camera is initialized, display the preview
            return Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CameraPreview(_controller),
                      // Receipt overlay guide
                      _buildReceiptOverlay(),
                      // Flash control button
                      Positioned(
                        top: 16,
                        right: 16,
                        child: FloatingActionButton.small(
                          heroTag: 'flashButton',
                          backgroundColor: Colors.black54,
                          onPressed: () async {
                            setState(() {
                              _isFlashOn = !_isFlashOn;
                            });
                            await _controller.setFlashMode(
                              _isFlashOn ? FlashMode.torch : FlashMode.off,
                            );
                          },
                          child: Icon(
                            _isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCaptureControls(),
              ],
            );
          } else {
            // Otherwise, display a loading indicator
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget _buildReceiptOverlay() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Align receipt within box',
            style: TextStyle(
              color: Colors.white,
              backgroundColor: Colors.black45,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Icon(
            Icons.receipt_long,
            size: 48,
            color: Colors.white.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureControls() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Back button
          FloatingActionButton(
            heroTag: 'backButton',
            backgroundColor: Colors.white24,
            mini: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          // Capture button
          FloatingActionButton(
            heroTag: 'captureButton',
            backgroundColor: Colors.white,
            onPressed: () async {
              try {
                // Ensure the camera is initialized
                await _initializeControllerFuture;

                // Show loading indicator
                if (!context.mounted) return;
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );

                // Take the picture
                final image = await _controller.takePicture();

                // Get temporary directory
                final directory = await getTemporaryDirectory();
                final imagePath = join(directory.path, '${DateTime.now()}.jpg');

                // Copy the file to the new path
                final File imageFile = File(image.path);
                final File savedImage = await imageFile.copy(imagePath);

                // Close loading dialog
                if (!context.mounted) return;
                Navigator.pop(context);

                // Return the image file
                // ignore: use_build_context_synchronously
                Navigator.pop(context, savedImage);
              } catch (e) {
                // If an error occurs, log the error
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Icon(Icons.camera_alt, color: Colors.black),
          ),
          // Placeholder for symmetry
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
