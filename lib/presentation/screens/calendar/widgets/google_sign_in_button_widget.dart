import 'package:app/core/constants/app_colors.dart';
import 'package:app/presentation/blocs/calendar/calendar_bloc.dart';
import 'package:app/presentation/blocs/calendar/calendar_event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Google Sign-In button widget for Google Calendar.
///
/// On web: Firebase Auth is used for login, but accessing Google Calendar API
/// requires a separate OAuth flow that's complex to implement with the current
/// google_sign_in 7.x API on web. Shows a placeholder message.
///
/// On mobile: Uses google_sign_in native flow.
class GoogleSignInButtonWidget extends StatelessWidget {
  const GoogleSignInButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // On web, Calendar API integration requires complex OAuth setup
      // that is not well-supported by google_sign_in 7.x
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 48, color: AppColors.accent),
          const SizedBox(height: 16),
          const Text(
            'Google Calendar en web',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'requiere configuración OAuth adicional.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Usa la app móvil para ver tu calendario.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    // On mobile, use google_sign_in native flow
    return ElevatedButton.icon(
      onPressed: () {
        context.read<CalendarBloc>().add(CalendarGoogleSignInRequested());
      },
      icon: const Icon(Icons.login),
      label: const Text('Conectar Google Calendar'),
    );
  }
}
