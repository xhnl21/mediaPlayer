import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Title
              const Padding(
                padding: EdgeInsets.only(top: 24.0),
                child: Text(
                  'MOBILE APP',
                  style: AppTypography.displayMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              // Center graphic logo
              const Center(child: AppLogoWidget(size: 160)),

              // Bottom Description, Button and Link
              Column(
                children: [
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textLight.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  CommonCoralButton(
                    text: 'GET STARTED',
                    onPressed: () {
                      context.read<NavigationCubit>().navigateTo(
                        AppScreen.auth,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      context.read<NavigationCubit>().navigateTo(
                        AppScreen.dashboardGrid,
                      );
                    },
                    child: Text(
                      'Lorem ipsum dolor sit amet',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
