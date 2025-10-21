import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

class CameraPageController {
  CameraController? cameraController;
  List<XFile> capturedImages = [];
  XFile? currentImage;

  Future<void> requestStoragePermission() async {
    // Check if the platform is not web, as web has no permissions
    if (!kIsWeb) {
      // Request storage permission
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

      // Request camera permission
      var cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        await Permission.camera.request();
      }
    }
  }

  Future<CameraController?> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print("Nenhuma câmera encontrada");
        return null;
      }

      cameraController = CameraController(cameras.first, ResolutionPreset.high);
      await cameraController!.initialize();

      return cameraController;
    } catch (e) {
      print("Erro ao inicializar a câmera: $e");
      return null;
    }
  }

  Future<void> switchCamera() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    final cameras = await availableCameras();
    final lensDirection = cameraController!.description.lensDirection;

    CameraDescription newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
    } else {
      newDescription = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
    }

    await cameraController!.dispose();
    cameraController = CameraController(newDescription, ResolutionPreset.high);
    await cameraController!.initialize();
  }

  Future<XFile?> takePicture() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return null;
    }

    try {
      XFile imageFile = await cameraController!.takePicture();
      currentImage = imageFile;
      return imageFile;
    } catch (e) {
      print("Erro ao capturar imagem: $e");
      return null;
    }
  }

  void addMorePhotos() {
    if (currentImage != null) {
      capturedImages.add(currentImage!);
      currentImage = null;
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < capturedImages.length) {
      capturedImages.removeAt(index);
    }
  }

  void discardCurrentImage() {
    currentImage = null;
  }

  List<String> getAllImagePaths() {
    List<XFile> allImages = [...capturedImages];
    if (currentImage != null) {
      allImages.add(currentImage!);
    }
    return allImages.map((img) => img.path).toList();
  }

  void clearAllImages() {
    capturedImages.clear();
    currentImage = null;
  }

  int getTotalImagesCount() {
    return capturedImages.length + (currentImage != null ? 1 : 0);
  }

  bool hasImages() {
    return capturedImages.isNotEmpty || currentImage != null;
  }

  void dispose() {
    cameraController?.dispose();
    capturedImages.clear();
    currentImage = null;
  }
}
