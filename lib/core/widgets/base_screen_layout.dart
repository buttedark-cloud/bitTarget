import 'package:bittarget/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class BaseScreenLayout extends StatelessWidget {
  final Widget child;

  const BaseScreenLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Трендовый градиент: от чисто черного сверху к глубокому темно-серому снизу
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000), // Абсолютный черный сверху
              Color(0xFF121214), // Темно-серый углеродный снизу
              Color(0xFF1A1A1E), // Чуть светлее на дне для объема
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // --- ЕДИНЫЙ ЛОГОТИП ДЛЯ ВСЕХ ЭКРАНОВ ---
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.neonGreen,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppColors.neonGreen.withOpacity(0.6), blurRadius: 6, spreadRadius: 1)],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Image.asset('assets/images/logo.png', height: 24, fit: BoxFit.contain),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // --- УНИКАЛЬНЫЙ КОНТЕНТ ЭКРАНА ---
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
