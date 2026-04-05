import 'package:flutter/material.dart';

import '../../l10n/l10n_extension.dart';

String sharedWalletText(BuildContext context, String en, String bn) {
  return context.l10n.isBangla ? bn : en;
}
