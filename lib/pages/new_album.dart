import 'package:flutter/material.dart';
import 'package:tcc_flutter/controller/new_album_controller.dart';
import 'package:tcc_flutter/utils/widget/button.dart';
import 'package:tcc_flutter/utils/widget/input.dart';
import 'package:tcc_flutter/utils/widget/input_image.dart';

class NewAlbum extends StatefulWidget {
  final String groupId;

  const NewAlbum({super.key, required this.groupId});

  @override
  State<NewAlbum> createState() => _NewAlbumState();
}

class _NewAlbumState extends State<NewAlbum> {
  final NewAlbumController controller = NewAlbumController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Novo álbum")),
      body: Form(
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
                  onPressed: () async {
                    await controller.submit(context, widget.groupId);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
