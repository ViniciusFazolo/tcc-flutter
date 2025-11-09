import 'package:flutter/material.dart';
import 'package:tcc_flutter/controller/new_group_controller.dart';
import 'package:tcc_flutter/utils/widget/button.dart';
import 'package:tcc_flutter/utils/widget/input.dart';
import 'package:tcc_flutter/utils/widget/input_image.dart';
import 'package:tcc_flutter/utils/widget/loading_overlay.dart';

class NewGroup extends StatefulWidget {
  const NewGroup({super.key});

  @override
  State<NewGroup> createState() => _NewGroupState();
}

class _NewGroupState extends State<NewGroup> {
  NewGroupController controller = NewGroupController();
  bool isLoading = false;

  Future<void> _handleSubmit() async {
    setState(() {
      isLoading = true;
    });

    try {
      await controller.submit(context);
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
      appBar: AppBar(title: Text("Novo grupo")),
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
                    label: "Nome do grupo",
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
            message: "Aguarde, o grupo já está sendo criado...",
          ),
        ],
      ),
    );
  }
}
