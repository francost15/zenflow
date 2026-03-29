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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'PROTOCOL: PROFILE',
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5,
            color: isDark ? AppColors.stone : Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileUserCard(
                      user: authState.user,
                      currentStreak: currentStreak,
                      longestStreak: longestStreak,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'LOGROS Y ESTADÍSTICAS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontFamily: 'Space Grotesk',
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 2.0,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 48),
                    GestureDetector(
                      onTap: () {
                        context.read<AuthBloc>().add(AuthSignOutRequested());
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: isDark
                                ? AppColors.monolithBorder
                                : Colors.black12,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            'TERMINAR SESIÓN',
                            style: TextStyle(
                              fontFamily: 'Space Grotesk',
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              color: isDark ? AppColors.stone : Colors.black87,
                            ),
                          ),
                        ),
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
