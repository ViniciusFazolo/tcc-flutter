import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  message,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
