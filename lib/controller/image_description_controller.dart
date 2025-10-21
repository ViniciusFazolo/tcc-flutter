import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tcc_flutter/pages/group_details.dart';
import 'package:tcc_flutter/pages/home.dart';
import 'package:tcc_flutter/service/publish_service.dart';
import 'package:tcc_flutter/utils/prefs.dart';
import 'package:tcc_flutter/utils/utils.dart';

class ImageDescriptionController {
  Future<void> handleSubmit({
    required BuildContext context,
    required String? selectedAlbum,
    required List<String> imagePaths,
    required String description,
    required VoidCallback onStartLoading,
    required VoidCallback onFinishLoading,
  }) async {
    if (selectedAlbum == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um álbum'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    onStartLoading();

    try {
      final String authorId = await Prefs.getString("id");

      final PublishService publishService = PublishService(baseUrl: apiBaseUrl);
      final List<XFile> imageFiles = imagePaths
          .map((path) => XFile(path))
          .toList();

      publishService.submit(
        albumId: selectedAlbum,
        authorId: authorId,
        imagens: imageFiles,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fotos salva com sucesso')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar imagens: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      onFinishLoading();
    }
  }
}
