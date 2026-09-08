import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Profile Avatar and Details
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final name = state is Authenticated
                      ? state.user.name
                      : 'Lorem Name';
                  final status = state is Authenticated
                      ? state.user.statusMessage
                      : 'Dolor sit amet \n Hicius 25489';

                  return Row(
                    children: [
                      // Avatar Circle
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentCoral,
                          border: Border.all(
                            color: AppColors.textLight,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Name and Status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.textLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              status,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Menu Options List
              _buildMenuItem(
                title: 'Lorem',
                onTap: () => context.read<NavigationCubit>().navigateTo(
                  AppScreen.dashboardGrid,
                ),
              ),
              _buildMenuItem(
                title: 'Ipsum dolor',
                onTap: () => context.read<NavigationCubit>().navigateTo(
                  AppScreen.playlistTracks,
                ),
              ),
              _buildMenuItem(
                title: 'Sit amet',
                onTap: () => context.read<NavigationCubit>().navigateTo(
                  AppScreen.searchGenres,
                ),
              ),
              _buildMenuItem(
                title: 'Lorem ipsum',
                onTap: () => context.read<NavigationCubit>().navigateTo(
                  AppScreen.albumDetail,
                ),
              ),
              _buildMenuItem(
                title: 'Dolor',
                onTap: () => context.read<NavigationCubit>().navigateTo(
                  AppScreen.soundSettings,
                ),
              ),
              const SizedBox(height: 12),

              // Log out option
              InkWell(
                onTap: () {
                  context.read<AuthCubit>().logout();
                  context.read<NavigationCubit>().navigateTo(AppScreen.welcome);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  child: Row(
                    children: [
                      Text(
                        'Log out',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.logout_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 32),

              // Bottom Checkbox: "Lorem ipsum dolor"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.accentCoral,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lorem ipsum dolor',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({required String title, required VoidCallback onTap}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Row(
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textLight,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const Divider(color: AppColors.divider, height: 1),
      ],
    );
  }
}
