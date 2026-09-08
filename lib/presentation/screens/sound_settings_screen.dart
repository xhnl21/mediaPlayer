import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/utils/responsive_extensions.dart';
import 'package:media_player/presentation/widgets.dart';

class SoundSettingsScreen extends StatelessWidget {
  const SoundSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.w(0.06).clamp(16.0, 32.0);
    final verticalPadding = context.h(0.02).clamp(12.0, 24.0);
    final dividerHeight = context.h(0.025).clamp(14.0, 28.0);
    final btnWidth = context.w(0.46).clamp(140.0, 240.0);

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
                  child: BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: context.h(0.01).clamp(4.0, 12.0),
                              ),
                              // Title
                              Text(
                                'LOREM COLOR',
                                style: AppTypography.displayMedium.copyWith(
                                  fontSize: context.sp(20),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: context.h(0.03).clamp(14.0, 30.0),
                              ),

                              // 4 Switch Items
                              _buildToggleRow(
                                context,
                                title: 'Lorem ipsum',
                                subtitle: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam',
                                value: state.settings.loremIpsum1,
                                onChanged: (val) => context
                                    .read<SettingsCubit>()
                                    .toggleLoremIpsum1(val),
                              ),
                              Divider(
                                color: AppColors.divider,
                                height: dividerHeight,
                              ),

                              _buildToggleRow(
                                context,
                                title: 'Dolor sit amet',
                                subtitle: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam',
                                value: state.settings.dolorSitAmet,
                                onChanged: (val) => context
                                    .read<SettingsCubit>()
                                    .toggleDolorSitAmet(val),
                              ),
                              Divider(
                                color: AppColors.divider,
                                height: dividerHeight,
                              ),

                              _buildToggleRow(
                                context,
                                title: 'Consectetur adipiscing',
                                subtitle: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam',
                                value: state.settings.consecteturAdipiscing,
                                onChanged: (val) => context
                                    .read<SettingsCubit>()
                                    .toggleConsecteturAdipiscing(val),
                              ),
                              Divider(
                                color: AppColors.divider,
                                height: dividerHeight,
                              ),

                              _buildToggleRow(
                                context,
                                title: 'Lorem ipsum',
                                subtitle: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam',
                                value: state.settings.loremIpsum2,
                                onChanged: (val) => context
                                    .read<SettingsCubit>()
                                    .toggleLoremIpsum2(val),
                              ),
                            ],
                          ),

                          // Bottom Button
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: context.h(0.02).clamp(12.0, 24.0),
                            ),
                            child: Center(
                              child: CommonCoralButton(
                                text: 'CREATE',
                                width: btnWidth,
                                onPressed: () {
                                  context.read<SettingsCubit>().saveSettings();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Settings encrypted and persisted successfully',
                                        style: TextStyle(
                                          fontSize: context.sp(13),
                                        ),
                                      ),
                                      backgroundColor:
                                          AppColors.cardSurfaceLight,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildToggleRow(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: context.sp(14),
                ),
              ),
              SizedBox(height: context.h(0.005).clamp(2.0, 6.0)),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: context.sp(11),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: context.w(0.03).clamp(8.0, 16.0)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.textLight,
          activeTrackColor: AppColors.accentCoral,
          inactiveThumbColor: AppColors.textLight,
          inactiveTrackColor: AppColors.inputBackground,
        ),
      ],
    );
  }
}
