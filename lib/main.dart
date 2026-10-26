import 'package:bittarget/main_shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/wallet/cubit/wallet_cubit.dart';

void main() {
  runApp(const CryptoTrackerApp());
}

class CryptoTrackerApp extends StatelessWidget {
  const CryptoTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WalletCubit(),
      child: MaterialApp(
        title: 'BitTarget',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainShellScreen(), // <-- Запускаем через обертку с нижним баром
      ),
    );
  }
}
