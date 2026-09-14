import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('ar'));

class T {
  const T(this.context);

  final BuildContext context;
  bool get ar => Localizations.localeOf(context).languageCode == 'ar';
  String text(String arabic, String english) => ar ? arabic : english;
}
