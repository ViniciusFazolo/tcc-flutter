import 'package:flutter/material.dart';
import 'package:tcc_flutter/controller/new_album_controller.dart';
import 'package:tcc_flutter/utils/widget/button.dart';
import 'package:tcc_flutter/utils/widget/input.dart';
import 'package:tcc_flutter/utils/widget/input_image.dart';
import 'package:tcc_flutter/utils/widget/loading_overlay.dart';

class NewAlbum extends StatefulWidget {
  final String groupId;

  const NewAlbum({super.key, required this.groupId});

  @override
  State<NewAlbum> createState() => _NewAlbumState();
}

class _NewAlbumState extends State<NewAlbum> {
  bool isLoading = false;
  final NewAlbumController controller = NewAlbumController();

  Future<void> _handleSubmit() async {
    setState(() {
      isLoading = true;
    });

    try {
      await controller.submit(context, widget.groupId);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Novo álbum")),
      body: Stack(
        children: [
          Form(
            key: controller.formKey,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                spacing: 10,
                children: [
                  InputImage(
                    multiple: false,
                    onChanged: (image) {
                      setState(() {
                        controller.image = image;
                      });
                    },
                  ),
                  Input(
                    label: "Nome do álbum",
                    controller: controller.nameController,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Button(
                      label: "Salvar",
                      onPressed: isLoading ? null : _handleSubmit,
                    ),
                  ),
                ],
              ),
            ),
          ),
          LoadingOverlay(
            isLoading: isLoading,
            message: "Aguarde, o álbum já está sendo criado...",
          ),
        ],
      ),
    );
  }
}