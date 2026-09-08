import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/utils/responsive_extensions.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.w(0.06).clamp(16.0, 32.0);
    final verticalPadding = context.h(0.015).clamp(8.0, 20.0);
    final avatarSize = context.w(0.16).clamp(54.0, 76.0);
    final checkboxSize = context.iconSize(18);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: context.h(0.01).clamp(4.0, 12.0)),

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
                        width: avatarSize,
                        height: avatarSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentCoral,
                          // Justified exception: 2px ring border
                          border: Border.all(
                            color: AppColors.textLight,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          size: avatarSize * 0.62,
                          color: AppColors.textLight,
                        ),
                      ),
                      SizedBox(width: context.w(0.04).clamp(10.0, 20.0)),
                      // Name and Status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.textLight,
                                fontSize: context.sp(18),
                              ),
                            ),
                            SizedBox(height: context.h(0.005).clamp(2.0, 6.0)),
                            Text(
                              status,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: context.sp(12),
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
              SizedBox(height: context.h(0.035).clamp(18.0, 36.0)),

              // Menu Options List
              _buildMenuItem(
                context,
                title: 'Lorem',
                onTap: () => context.read<NavigationCubit>().navigateTo(
                  AppScreen.dashboardGrid,
                ),
              ),
              _buildMenuItem(
                context,
                title: 'Ipsum dolor',
                onTap: () => context.read<NavigationCubit>().navigateTo(
                  AppScreen.playlistTracks,
                ),
              ),
              _buildMenuItem(
                context,
                title: 'Sit amet',
                onTap: () => context.read<NavigationCubit>().navigateTo(
                  AppScreen.searchGenres,
                ),
              ),
              _buildMenuItem(
                context,
                title: 'Lorem ipsum',
                onTap: () => context.read<NavigationCubit>().navigateTo(
                  AppScreen.albumDetail,
                ),
              ),
              _buildMenuItem(
                context,
                title: 'Dolor',
                onTap: () => context.read<NavigationCubit>().navigateTo(
                  AppScreen.soundSettings,
                ),
              ),
              SizedBox(height: context.h(0.012).clamp(6.0, 14.0)),

              // Log out option
              InkWell(
                onTap: () {
                  context.read<AuthCubit>().logout();
                  context.read<NavigationCubit>().navigateTo(AppScreen.welcome);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: context.h(0.016).clamp(10.0, 18.0),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Log out',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textLight,
                          fontSize: context.sp(16),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.logout_rounded,
                        color: AppColors.textSecondary,
                        size: context.iconSize(20),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(color: AppColors.divider, height: 1),
              SizedBox(height: context.h(0.035).clamp(18.0, 36.0)),

              // Bottom Checkbox: "Lorem ipsum dolor"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: checkboxSize,
                    height: checkboxSize,
                    decoration: BoxDecoration(
                      color: AppColors.accentCoral,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.check,
                      size: context.iconSize(14),
                      color: AppColors.textLight,
                    ),
                  ),
                  SizedBox(width: context.w(0.02).clamp(4.0, 10.0)),
                  Text(
                    'Lorem ipsum dolor',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textLight,
                      fontSize: context.sp(12),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.h(0.025).clamp(12.0, 26.0)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: context.h(0.016).clamp(10.0, 18.0),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textLight,
                    fontSize: context.sp(15),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: context.iconSize(20),
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
