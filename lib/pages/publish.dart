import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tcc_flutter/controller/publish_controller.dart';

class Publish extends StatefulWidget {
  final String albumId;
  const Publish({super.key, required this.albumId});

  @override
  State<Publish> createState() => _PublishState();
}

class _PublishState extends State<Publish> {
  PublishController controller = PublishController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller.fetchPublishsByAlbumId(widget.albumId).then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text("Fotos")),
      body: controller.publishs.isNotEmpty
          ? SingleChildScrollView(
              child: Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 10,
                    children: controller.publishs.map((pub) {
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 15,
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    pub.author!.image ?? "",
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pub.author!.name!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      style: TextStyle(fontSize: 12),
                                      DateFormat(
                                        "dd/MM/yyyy HH:mm",
                                      ).format(DateTime.parse(pub.whenSent!)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            pub.description != null
                                ? Text(pub.description!)
                                : SizedBox(height: 0),
                            if (pub.images != null && pub.images!.isNotEmpty)
                              SizedBox(
                                height: 200, // altura do carrossel
                                width: double.infinity,
                                child: PageView.builder(
                                  itemCount: pub.images!.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      child: Container(
                                        color: Colors.black87,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.network(
                                            pub.images![index].image!,
                                            fit: BoxFit.contain,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            )
          : Center(child: Text("Não há fotos", style: TextStyle(fontSize: 20))),
    );
  }
}
