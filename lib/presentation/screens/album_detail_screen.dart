import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/utils/responsive_extensions.dart';
import 'package:media_player/presentation/widgets.dart';

class AlbumDetailScreen extends StatelessWidget {
  const AlbumDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.w(0.06).clamp(16.0, 32.0);
    final verticalPadding = context.h(0.02).clamp(12.0, 24.0);
    final cardPadding = context.w(0.04).clamp(12.0, 20.0);
    final albumArtSize = context.w(0.18).clamp(60.0, 96.0);
    final btnWidth = context.w(0.46).clamp(140.0, 240.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            children: [
              // Top White Card with Album Art and Metadata
              Container(
                padding: EdgeInsets.all(cardPadding),
                decoration: BoxDecoration(
                  color: AppColors.textLight,
                  borderRadius: BorderRadius.circular(context.w(0.04).clamp(12.0, 20.0)),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Album Square with Star
                    Container(
                      width: albumArtSize,
                      height: albumArtSize,
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(albumArtSize * 0.16),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.star_rounded,
                          color: AppColors.textLight,
                          size: albumArtSize * 0.58,
                        ),
                      ),
                    ),
                    SizedBox(width: context.w(0.04).clamp(10.0, 20.0)),
                    // Title and info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lorem ipsum',
                            style: AppTypography.titleLarge.copyWith(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: context.sp(18),
                            ),
                          ),
                          SizedBox(height: context.h(0.005).clamp(2.0, 6.0)),
                          Text(
                            'March 1 at 09:00\n150 songs\n755 minutes',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textDark.withValues(alpha: 0.7),
                              fontSize: context.sp(11),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Coral highlight bar under card
              Container(
                height: context.h(0.006).clamp(4.0, 7.0),
                margin: EdgeInsets.symmetric(
                  horizontal: context.w(0.03).clamp(8.0, 16.0),
                ),
                decoration: const BoxDecoration(
                  color: AppColors.accentCoral,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(4),
                  ),
                ),
              ),
              SizedBox(height: context.h(0.03).clamp(16.0, 32.0)),

              // Rating Stars (5 stars)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(0.01).clamp(2.0, 6.0),
                    ),
                    child: Icon(
                      index < 4
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: AppColors.textLight,
                      size: context.iconSize(28),
                    ),
                  );
                }),
              ),
              SizedBox(height: context.h(0.03).clamp(16.0, 32.0)),

              // Bio / Description text
              Text(
                'Lorem ipsum',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: context.sp(16),
                ),
              ),
              SizedBox(height: context.h(0.012).clamp(6.0, 14.0)),
              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textLight.withValues(alpha: 0.9),
                  fontSize: context.sp(12),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.h(0.04).clamp(20.0, 42.0)),

              // Action button "LOREM"
              CommonCoralButton(
                text: 'LOREM',
                width: btnWidth,
                onPressed: () {
                  final tracks = context.read<AudioPlayerCubit>().state.tracks;
                  if (tracks.isNotEmpty) {
                    context.read<AudioPlayerCubit>().playTrack(tracks.first);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Playing Album: Lorem ipsum',
                          style: TextStyle(fontSize: context.sp(13)),
                        ),
                        backgroundColor: AppColors.cardSurfaceLight,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
