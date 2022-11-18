import 'package:flutter/material.dart';
import 'package:flutter_dialog_manager/flutter_dialog_manager.dart';
import 'package:lottie/lottie.dart';

class DownloadingDialog extends StatelessWidget {

  const DownloadingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogBuilder(
      dismissible: false,
      builder: (dialogKey) {
        return Container(
          key: dialogKey,
          height: 150,
          width: 180,
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LottieBuilder.asset(
                "assets/animations/downloading.json",
                height: 120,
                width: 120,
                animate: true,
                reverse: true,
                repeat: true,
              ),
             
            ],
          ),
        );
      },
    );
  }
}
