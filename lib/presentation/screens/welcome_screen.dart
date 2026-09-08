import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/utils/responsive_extensions.dart';
import 'package:media_player/presentation/widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.w(0.08).clamp(16.0, 36.0);
    final verticalPadding = context.h(0.02).clamp(12.0, 24.0);
    final logoSize = (context.isLandscape ? context.h(0.32) : context.w(0.42))
        .clamp(90.0, 180.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Title
                      Padding(
                        padding: EdgeInsets.only(top: context.h(0.02)),
                        child: Text(
                          'MOBILE APP',
                          style: AppTypography.displayMedium.copyWith(
                            fontSize: context.sp(20),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Center graphic logo
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: context.h(0.02),
                        ),
                        child: Center(child: AppLogoWidget(size: logoSize)),
                      ),

                      // Bottom Description, Button and Link
                      Column(
                        children: [
                          Text(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textLight.withValues(alpha: 0.9),
                              fontSize: context.sp(12),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: context.h(0.03).clamp(16.0, 32.0)),
                          CommonCoralButton(
                            text: 'GET STARTED',
                            onPressed: () {
                              context.read<NavigationCubit>().navigateTo(
                                AppScreen.auth,
                              );
                            },
                          ),
                          SizedBox(height: context.h(0.018).clamp(10.0, 20.0)),
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
                                fontSize: context.sp(12),
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          SizedBox(height: context.h(0.015).clamp(8.0, 16.0)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
