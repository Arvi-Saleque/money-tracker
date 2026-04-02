import 'package:flutter/material.dart';

import '../../core/theme/premium_card_style.dart';

Widget buildPremiumCard({
  required BuildContext context,
  required Widget child,
  EdgeInsetsGeometry? padding,
  Gradient? gradient,
}) {
  final cardStyle = Theme.of(context).extension<PremiumCardStyle>()!;

  return Container(
    padding: padding ?? cardStyle.padding,
    decoration: BoxDecoration(
      color: cardStyle.backgroundColor,
      gradient: gradient,
      borderRadius: BorderRadius.circular(cardStyle.radius),
      border: Border.all(color: cardStyle.borderColor),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: cardStyle.shadowColor,
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: child,
  );
}

Widget buildPremiumInkCard({
  required BuildContext context,
  required Widget child,
  required VoidCallback onTap,
  EdgeInsetsGeometry? padding,
}) {
  final cardStyle = Theme.of(context).extension<PremiumCardStyle>()!;

  return Material(
    color: cardStyle.backgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(cardStyle.radius),
      side: BorderSide(color: cardStyle.borderColor),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(cardStyle.radius),
      onTap: onTap,
      child: Padding(padding: padding ?? cardStyle.padding, child: child),
    ),
  );
}
