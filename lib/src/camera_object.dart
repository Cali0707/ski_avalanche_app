import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraTest extends StatefulWidget {
  @override
  _CameraTestState createState() => _CameraTestState();
}

class _CameraTestState extends State<CameraTest> {
  CameraController? _camera;
  bool _cameraInitialized = false;
  CameraImage? _savedImage;

  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    List<CameraDescription> cameras = await availableCameras();

    _camera = new CameraController(cameras[0], ResolutionPreset.veryHigh);
    _camera!.initialize().then((_) async {
      await _camera!
          .startImageStream((CameraImage image) => _processCameraImage(image));
      setState(() {
        _cameraInitialized = true;
      });
    });
  }

  void _processCameraImage(CameraImage image) async {
    setState(() {
      _savedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: (_cameraInitialized)
          ? AspectRatio(
              aspectRatio: _camera!.value.aspectRatio,
              child: CameraPreview(_camera!))
          : CircularProgressIndicator(),
    );
  }
}
