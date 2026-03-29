import 'package:app/core/constants/app_colors.dart';
import 'package:app/presentation/blocs/auth/auth_bloc.dart';
import 'package:app/presentation/blocs/auth/auth_event.dart';
import 'package:app/presentation/blocs/auth/auth_state.dart';
import 'package:app/presentation/blocs/streaks/streaks_bloc.dart';
import 'package:app/presentation/blocs/streaks/streaks_event.dart';
import 'package:app/presentation/blocs/streaks/streaks_state.dart';
import 'package:app/presentation/screens/profile/profile_achievement_data.dart';
import 'package:app/presentation/screens/profile/widgets/profile_achievement_grid.dart';
import 'package:app/presentation/screens/profile/widgets/profile_user_card.dart';
import 'package:app/presentation/widgets/error_state.dart';
import 'package:app/presentation/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StreaksBloc>().add(StreaksLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil y estadísticas')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const LoadingIndicator();
          }

          return BlocBuilder<StreaksBloc, StreaksState>(
            builder: (context, streakState) {
              final achievements = streakState is StreaksLoaded
                  ? buildProfileAchievements(streakState)
                  : const <ProfileAchievementData>[];
              final currentStreak = streakState is StreaksLoaded
                  ? streakState.totalCurrentStreak
                  : 0;
              final longestStreak = streakState is StreaksLoaded
                  ? streakState.longestStreak
                  : 0;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileUserCard(
                      user: authState.user,
                      currentStreak: currentStreak,
                      longestStreak: longestStreak,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'LOGROS Y ESTADÍSTICAS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (streakState is StreaksLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: LoadingIndicator(),
                      )
                    else if (streakState is StreaksError)
                      ErrorState(
                        title: 'No se pudieron cargar tus estadísticas',
                        message: streakState.message,
                        onRetry: _reloadStreaks,
                      )
                    else
                      ProfileAchievementGrid(achievements: achievements),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.read<AuthBloc>().add(AuthSignOutRequested());
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Cerrar sesión'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _reloadStreaks() {
    context.read<StreaksBloc>().add(StreaksLoadRequested());
  }
}
