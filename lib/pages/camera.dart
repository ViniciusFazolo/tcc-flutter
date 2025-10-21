import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tcc_flutter/controller/camera_controller.dart';

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraPageState();
}

class _CameraPageState extends State<Camera> {
  CameraPageController controller = CameraPageController();
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await controller.requestStoragePermission();
    final cam = await controller.initializeCamera();

    if (!mounted) return;
    setState(() {
      isCameraInitialized = cam != null;
    });
  }

  Future<void> _switchCamera() async {
    await controller.switchCamera();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _takePicture() async {
    await controller.takePicture();
    if (!mounted) return;
    setState(() {});
  }

  void _addMorePhotos() {
    controller.addMorePhotos();
    setState(() {});
  }

  void _removeImage(int index) {
    controller.removeImage(index);
    setState(() {});
  }

  void _discardCurrentImage() {
    controller.discardCurrentImage();
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Se uma imagem foi capturada, mostra o preview
    if (controller.currentImage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Preview da imagem capturada
            Positioned.fill(
              child: Image.file(
                File(controller.currentImage!.path),
                fit: BoxFit.contain,
              ),
            ),

            // Botão de voltar (refazer foto)
            Positioned(
              top: 50,
              left: 15,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: _discardCurrentImage,
                ),
              ),
            ),

            // Botões na parte inferior
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botão adicionar mais fotos
                    ElevatedButton.icon(
                      onPressed: _addMorePhotos,
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text(
                        'Adicionar mais fotos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Botão prosseguir
                    ElevatedButton(
                      onPressed: () {
                        List<String> imagePaths = controller.getAllImagePaths();
                        Navigator.pop(context, imagePaths);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        controller.hasImages()
                            ? 'Prosseguir (${controller.getTotalImagesCount()} foto${controller.getTotalImagesCount() > 1 ? 's' : ''})'
                            : 'Prosseguir',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Caso contrário, mostra a câmera normal
    return Scaffold(
      body: isCameraInitialized && controller.cameraController != null
          ? Stack(
              children: [
                Positioned.fill(
                  child: CameraPreview(controller.cameraController!),
                ),

                // Botão de voltar
                Positioned(
                  top: 50,
                  left: 15,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // Preview das imagens capturadas (mini galeria no topo à direita)
                if (controller.capturedImages.isNotEmpty) ...[
                  Positioned(
                    top: 50,
                    right: 15,
                    child: Container(
                      height: 80,
                      width: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(8),
                        itemCount: controller.capturedImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(controller.capturedImages[index].path),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: -5,
                                  right: -5,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 24,
                                        minHeight: 24,
                                      ),
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      onPressed: () => _removeImage(index),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // ✅ Botão de finalizar (check) fixo no canto direito logo abaixo da galeria
                  Positioned(
                    top: 110, // ~um pouco abaixo da galeria
                    right: 25,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          List<String> imagePaths = controller
                              .getAllImagePaths();
                          Navigator.pop(context, imagePaths);
                        },
                      ),
                    ),
                  ),
                ],

                // Controles da câmera na parte inferior
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Botão de alternar câmera (à esquerda)
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _switchCamera,
                            icon: const Icon(
                              Icons.cameraswitch_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),

                        // Botão de captura (centro)
                        Expanded(
                          child: Center(
                            child: SizedBox(
                              width: 70,
                              height: 70,
                              child: GestureDetector(
                                onTap: _takePicture,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 5,
                                    ),
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Botão de finalizar (direita) - só aparece se tiver fotos
                        controller.capturedImages.isNotEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    List<String> imagePaths = controller
                                        .getAllImagePaths();
                                    Navigator.pop(context, imagePaths);
                                  },
                                ),
                              )
                            : const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
