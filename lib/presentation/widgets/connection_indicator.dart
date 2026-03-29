import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/connectivity_service.dart';

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ConnectivityService.instance,
      builder: (context, child) {
        if (ConnectivityService.instance.isOnline) {
          return const SizedBox.shrink();
        }
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4),
          color: AppColors.warning,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 14, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Modo offline',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
