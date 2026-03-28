import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/connectivity_service.dart';

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, child) {
        if (connectivity.isOnline) {
          return const SizedBox.shrink();
        }
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4),
          color: Colors.orange,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 16, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Modo offline',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
