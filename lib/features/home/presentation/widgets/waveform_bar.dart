import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class WaveformBar extends StatelessWidget {
  const WaveformBar({
    super.key,
    required this.controller,
    required this.playing,
  });

  final AnimationController controller;
  final bool playing;

  static const _heights = [
    3.0, 6.0, 10.0, 14.0, 8.0, 18.0, 12.0, 6.0, 20.0, 14.0,
    8.0, 16.0, 10.0, 22.0, 16.0, 6.0, 18.0, 12.0, 8.0, 14.0,
    20.0, 8.0, 12.0, 6.0, 18.0, 10.0, 6.0, 4.0,
  ];

  @override
  Widget build(BuildContext context) {
    const barCount = 28;
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(barCount, (i) {
            final base = _heights[i % _heights.length];
            final h = playing
                ? base * (0.6 + 0.4 * ((controller.value + i / barCount) % 1.0))
                : base * 0.5;
            return Container(
              width: 2.5,
              height: h,
              decoration: BoxDecoration(
                color: i < (barCount * 0.4).toInt()
                    ? AppColors.waveformActive
                    : AppColors.waveformIdle,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
