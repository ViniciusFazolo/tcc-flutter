import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraPageState();
}

class _CameraPageState extends State<Camera> {
  CameraController? controller;
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print("Nenhuma câmera encontrada");
        return;
      }

      controller = CameraController(cameras.first, ResolutionPreset.high);

      await controller!.initialize();
      if (!mounted) return;
      setState(() {
        isCameraInitialized = true;
      });
    } catch (e) {
      print("Erro ao inicializar a câmera: $e");
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isCameraInitialized
          ? Stack(
              children: [
                Positioned.fill(child: CameraPreview(controller!)),
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
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () async {
                              if (controller == null ||
                                  !controller!.value.isInitialized)
                                return;

                              final cameras = await availableCameras();

                              final lensDirection =
                                  controller!.description.lensDirection;
                              CameraDescription newDescription;
                              if (lensDirection == CameraLensDirection.front) {
                                newDescription = cameras.firstWhere(
                                  (cam) =>
                                      cam.lensDirection ==
                                      CameraLensDirection.back,
                                  orElse: () => cameras.first,
                                );
                              } else {
                                newDescription = cameras.firstWhere(
                                  (cam) =>
                                      cam.lensDirection ==
                                      CameraLensDirection.front,
                                  orElse: () => cameras.first,
                                );
                              }

                              await controller!.dispose();
                              controller = CameraController(
                                newDescription,
                                ResolutionPreset.high,
                              );
                              await controller!.initialize();
                              if (!mounted) return;
                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.cameraswitch_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),

                        Expanded(
                          child: Center(
                            child: SizedBox(
                              width: 70,
                              height: 70,
                              child: GestureDetector(
                                onTap: () {
                                  // ação para capturar foto
                                },
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

                        const SizedBox(width: 60),
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
