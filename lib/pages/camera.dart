// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';

// class Camera extends StatefulWidget {
//   final List<CameraDescription> cameras;

//   const Camera({super.key, required this.cameras});

//   @override
//   State<Camera> createState() => _CameraState();
// }

// class _CameraState extends State<Camera> {
//   late CameraController controller;

//   @override
//   void initState() {
//     super.initState();
//     controller = CameraController(widget.cameras[0], ResolutionPreset.max);
//     controller.initialize().then((value) {
//       if (!mounted) {
//         return;
//       }
//       setState(() {});
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     controller.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [Positioned.fill(child: CameraPreview(controller))],
//       ),
//     );
//   }
// }
