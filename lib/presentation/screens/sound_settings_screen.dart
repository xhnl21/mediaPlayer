import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/widgets.dart';

class SoundSettingsScreen extends StatelessWidget {
  const SoundSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    'LOREM COLOR',
                    style: AppTypography.displayMedium.copyWith(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // 4 Switch Items
                  _buildToggleRow(
                    title: 'Lorem ipsum',
                    subtitle: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam',
                    value: state.settings.loremIpsum1,
                    onChanged: (val) =>
                        context.read<SettingsCubit>().toggleLoremIpsum1(val),
                  ),
                  const Divider(color: AppColors.divider, height: 28),

                  _buildToggleRow(
                    title: 'Dolor sit amet',
                    subtitle: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam',
                    value: state.settings.dolorSitAmet,
                    onChanged: (val) =>
                        context.read<SettingsCubit>().toggleDolorSitAmet(val),
                  ),
                  const Divider(color: AppColors.divider, height: 28),

                  _buildToggleRow(
                    title: 'Consectetur adipiscing',
                    subtitle: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam',
                    value: state.settings.consecteturAdipiscing,
                    onChanged: (val) => context
                        .read<SettingsCubit>()
                        .toggleConsecteturAdipiscing(val),
                  ),
                  const Divider(color: AppColors.divider, height: 28),

                  _buildToggleRow(
                    title: 'Lorem ipsum',
                    subtitle: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam',
                    value: state.settings.loremIpsum2,
                    onChanged: (val) =>
                        context.read<SettingsCubit>().toggleLoremIpsum2(val),
                  ),
                  const Spacer(),

                  // CREATE Button
                  Center(
                    child: CommonCoralButton(
                      text: 'CREATE',
                      width: 180,
                      onPressed: () {
                        context.read<SettingsCubit>().saveSettings();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Settings encrypted and persisted successfully',
                            ),
                            backgroundColor: AppColors.cardSurfaceLight,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow({
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
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
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
