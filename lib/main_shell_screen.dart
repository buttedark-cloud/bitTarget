import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/widgets/base_screen_layout.dart';
import 'package:bittarget/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;
  bool _isEnglish = true; // Глобальное состояние языка для оболочки
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleLanguage() {
    setState(() {
      _isEnglish = !_isEnglish;
    });
  }

  void _goToProfile() {
    setState(() {
      _currentIndex = 3;
    });
    _pageController.animateToPage(3, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    // Формируем список экранов с передачей текущего языка
    final List<Widget> screens = [
      HomeScreen(isEnglish: _isEnglish, onLanguageToggle: _toggleLanguage, onProfileTap: _goToProfile),
      BaseScreenLayout(
        child: Center(
          child: Text(_isEnglish ? 'Trade Screen' : 'Экран Торговли', style: const TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ),
      BaseScreenLayout(
        child: Center(
          child: Text(_isEnglish ? 'Wallet Screen' : 'Экран Кошелька', style: const TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ),
      BaseScreenLayout(
        child: Center(
          child: Text(_isEnglish ? 'Your Profile' : 'Ваш Профиль', style: const TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF000000), Color(0xFF121214), Color(0xFF1A1A1E)],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Свайпаемые экраны
              Padding(
                padding: const EdgeInsets.only(bottom: 80.0),
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  children: screens,
                ),
              ),

              // Плавающий нижний бар (Аппбар) с двуязычными названиями
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 5, 5, 5),
                    borderRadius: BorderRadius.circular(16),
                    border: const Border(top: BorderSide(color: Color.fromARGB(255, 72, 77, 73), width: 1.0)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.home_rounded, _isEnglish ? 'Home' : 'Главная', 0),
                      _buildNavItem(Icons.bar_chart_rounded, _isEnglish ? 'Trade' : 'Торговля', 1),
                      _buildNavItem(Icons.account_balance_wallet_rounded, _isEnglish ? 'Wallet' : 'Кошелек', 2),
                      _buildNavItem(Icons.person_rounded, _isEnglish ? 'Profile' : 'Профиль', 3),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      },
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? AppColors.neonGreen : AppColors.textSecondary, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: isActive ? AppColors.neonGreen : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
