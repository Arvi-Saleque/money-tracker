import 'package:flutter/material.dart';

@immutable
class GradientColors extends ThemeExtension<GradientColors> {
  const GradientColors({
    required this.heroGradient,
    required this.chartGradient,
    required this.successGradient,
  });

  final LinearGradient heroGradient;
  final LinearGradient chartGradient;
  final LinearGradient successGradient;

  @override
  GradientColors copyWith({
    LinearGradient? heroGradient,
    LinearGradient? chartGradient,
    LinearGradient? successGradient,
  }) {
    return GradientColors(
      heroGradient: heroGradient ?? this.heroGradient,
      chartGradient: chartGradient ?? this.chartGradient,
      successGradient: successGradient ?? this.successGradient,
    );
  }

  @override
  GradientColors lerp(ThemeExtension<GradientColors>? other, double t) {
    if (other is! GradientColors) {
      return this;
    }

    return GradientColors(
      heroGradient: LinearGradient.lerp(heroGradient, other.heroGradient, t)!,
      chartGradient: LinearGradient.lerp(
        chartGradient,
        other.chartGradient,
        t,
      )!,
      successGradient: LinearGradient.lerp(
        successGradient,
        other.successGradient,
        t,
      )!,
    );
  }
}
