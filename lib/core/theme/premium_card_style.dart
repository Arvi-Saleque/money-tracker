import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
class PremiumCardStyle extends ThemeExtension<PremiumCardStyle> {
  const PremiumCardStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.shadowColor,
    required this.radius,
    required this.padding,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color shadowColor;
  final double radius;
  final EdgeInsets padding;

  @override
  PremiumCardStyle copyWith({
    Color? backgroundColor,
    Color? borderColor,
    Color? shadowColor,
    double? radius,
    EdgeInsets? padding,
  }) {
    return PremiumCardStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      shadowColor: shadowColor ?? this.shadowColor,
      radius: radius ?? this.radius,
      padding: padding ?? this.padding,
    );
  }

  @override
  PremiumCardStyle lerp(ThemeExtension<PremiumCardStyle>? other, double t) {
    if (other is! PremiumCardStyle) {
      return this;
    }

    return PremiumCardStyle(
      backgroundColor:
          Color.lerp(backgroundColor, other.backgroundColor, t) ??
          backgroundColor,
      borderColor: Color.lerp(borderColor, other.borderColor, t) ?? borderColor,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t) ?? shadowColor,
      radius: lerpDouble(radius, other.radius, t) ?? radius,
      padding: EdgeInsets.lerp(padding, other.padding, t) ?? padding,
    );
  }
}
